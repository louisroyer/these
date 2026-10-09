#!/usr/bin/env lua
--[[
-- Copyright Louis Royer. All rights reserved.
-- Use of this source code is governed by a MIT-style license that can be
-- found in the LICENSE file.
-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: Louis Royer <infos.louis.royer@gmail.com>
--]]
require("lualibs.lua")
require("unicode")

luaglossary = {}

--[[
-- Print a warning
--]]
local function warn(str)
    tex.sprint("\\PackageWarningNoLine{luaglossary}{"..str.."}")
end

--[[
--  Make first letter of a string uppercase.
--  Compatible with unicode strings (so it works with words starting with accentuated letters).
--]]
local function firstToUpper(str)
  return unicode.utf8.upper(unicode.utf8.sub(str, 1, 1))..unicode.utf8.sub(str, 2)
end

--[[
-- Detect usage of a reference to a glossary term ("\\hypperref[glossary:term]") within a glossary definition.
--]]
local function detect_hyperref(s)
  --[[
  --  In this function, we don't use [unicode.utf8.find] because it returns byte position
  --  in the string, which cannot be used by [unicode.utf8.sub], and because we are
  --  searching for "\\hyperref[glossary:" and "]" which are fully ascii anyway.
  --]]
  local pos = 1
  while(pos < string.len(s))
  do
    local _, a = string.find(s, "\\hyperref[glossary:", pos, true)
    if a == nil then
      return
    end
    if a < string.len(s) then
      pos = a+1
    else
      return
    end
    local _, b = string.find(s, "]", pos, true)
    if b == nil then
      return
    end
    local r = string.sub(s, pos, b-1) 
    if luaglossary.data[r] then
      luaglossary.data[r].used_in_glossary = true
    end
    pos = b
  end
end

--[[
-- Loads glossary from json file.
-- Argument "mode" can be either "main" (default) or "subfile".
-- When "mode" is subfile, hyperlinks to glossary will not be created. This mode should be used when you want to compile only a single chapter (because glossary chapter is not generated).
--]]
function luaglossary.load(filename, mode)
  local f = io.open(filename, "r")
  if not f then
    tex.error("Could not open file '"..filename.."'")
    return
  end
  local s = f:read("*all")
  f:close()
  luaglossary.data = utilities.json.tolua(s)
  if luaglossary.data == nil then
    tex.error("Could not parse '"..filename.."': json not formatted correctly")
  end
  luaglossary.keys = {}
  for k, _ in pairs(luaglossary.data) do
    -- initialisation
    luaglossary.data[k].not_first = false
    luaglossary.data[k].used_in_glossary = false
    if luaglossary.data[k].index then
        table.insert(luaglossary.keys, k)
    end
  end
  
  -- detect links in desc/shortedsc
  for k, _ in pairs(luaglossary.data) do
    if luaglossary.data[k].desc then
        detect_hyperref(luaglossary.data[k].desc)
    end
    if luaglossary.data[k].shortdesc then
        detect_hyperref(luaglossary.data[k].shortdesc)
    end
  end
  
  -- mode subfile avoid creating hyperlinks, mode main is the default
  if mode == nil or mode == "" then
    mode = "main"
  end
  luaglossary.mode = mode
  
  -- sort by index
  table.sort(luaglossary.keys, function(a, b)
    return string.lower(luaglossary.data[a].index) < string.lower(luaglossary.data[b].index)
  end)
end

--[[
-- Check if a term is defined in glossary.
--]]
local function check_term(term_id)
  if not luaglossary.data then
    tex.error("Glossary has not been initialized. Use '\\loadluaglossary{filename}' first")
    return false
  end
  if not luaglossary.data[term_id] then
    tex.error("Term '"..term_id.."' is not defined")
    return false
  end
  return true
end

--[[
-- Make text in italics.
--]]
local function textit(str)
  return '\\textit{'..str..'}'
end

--[[
-- Make text in bold.
--]]
local function textbf(str)
  return '\\textbf{'..str..'}'
end

--[[
-- Print pageref* for a given ref.
--]]
local function pageref(ref)
  return '\\pageref*{'..ref..'}'
end

--[[
-- Create hyperlink if "enabled" parameter is true.
--]]
local function hyperref(enabled, anchor, display)
    if not enabled then
        return display
    end
    return "\\hyperref["..anchor.."]{"..display.."}"
end

--[[
-- Check if link should be created for a given term.
--]]
local function is_link_enabled(term_id)
  return (luaglossary.mode == "main") and
    (luaglossary.data[term_id].print or (luaglossary.data[term_id].print == nil)) -- disabled when print == false
end

--[[
-- Print a term and definition within the glossary (if it is used, or if we force it to be displayed).
--]]
local function print_def(term_id, term, force)
  if (not term.print) and (term.print ~= nil) then
    return true
  end
  if (not force) and (not term.print) and (not term.not_first) then
    return true
  end

  -- header
  tex.sprint('\\noindent ')
  tex.print('\\begin{minipage}{\\textwidth-17pt}')
  tex.sprint('\\noindent ')
  tex.sprint('\\phantomsection')
  tex.sprint('\\label{glossary:'..term_id..'}')
  
  -- print label
  if (not term.desc) and (not term.shortdesc) and (not term.ref) and (not (term.voirref and term.voirlabel)) then
    if not (term.short and term.en) then
      tex.error("Glossary item '".. term_id .."' has no description")
      return false
    end
    if term.fr then
      tex.sprint(textbf(term.short).."("..textit(term.en).."): "..term.fr)
    else
      tex.sprint(textbf(term.short)..": "..textit(term.en))
    end
  else
    if term.short then
      if term.fr then
        if term.en then
          if term.enlong then
            tex.sprint(textbf(firstToUpper(term.fr)))
            if term.fralt then
              tex.sprint(" ou "..textbf(term.fralt))
            end
            tex.print('\\newline')
            tex.sprint("\\hspace*{5mm}("..textit(term.en)..", "..term.short..")")
          else
            tex.sprint(textbf(firstToUpper(term.fr))..(term.fralt and " ou "..textbf(term.fralt) or "").." ("..textit(term.en)..", "..term.short..")")
          end
        else
          tex.sprint(textbf(firstToUpper(term.fr))..(term.fralt and " ou "..textbf(term.fralt) or ""))
        end
      elseif term.alt then
        tex.sprint(textbf(term.short).." ou "..textbf(term.alt).." ("..textit(term.en)..")")
      elseif term.en then
        if term.enalt then
          tex.sprint(textbf(term.short).." ("..textit(term.en).." ou "..textit(term.enalt)..")")
        else
          tex.sprint(textbf(term.short).." ("..textit(term.en)..")")
        end
      elseif term.voirref and term.voirlabel then
        tex.sprint(textbf(term.short))
      else
        error("Glossary item '".. term_id .."' has usable label")
        return false
      end
    else
      if term.fr then
        if term.en then
          if term.enlong then
            tex.sprint(textbf(fisrtToUpper(term.fr)))
            if term.fralt then
              tex.sprint(" ou "..textbf(term.fralt))
            end
            tex.print('\\newline')
            tex.sprint("\\hspace*{5mm}("..textit(term.en)..")")
          else
            tex.sprint(textbf(firstToUpper(term.fr))..(term.fralt and " ou "..textbf(term.fralt) or "").." ("..textit(term.en)..")")
          end
        elseif term.fralt then
          tex.sprint(textbf(firstToUpper(term.fr)).." ou "..textbf(term.fralt))
        else
          tex.sprint(textbf(firstToUpper(term.fr)))
        end
      else
        tex.sprint(textbf(textit(firstToUpper(term.en))))
      end
    end
  end
  
  -- print description
  if term.desc or (term.voirref and term.voirlabel and term.voirlong) then
    tex.print('\\newline')
    if term.desc then
        tex.sprint('\\indent '..term.desc)
    end
  elseif term.shortdesc or (term.voirref and term.voirlabel) or term.ref then
    tex.sprint(': ')
  end
  if term.shortdesc then
    if term.desc then
      warn("Glossary item '"..term_id.."' has both a desc and a shortdesc")
    else
      tex.sprint(term.shortdesc)
      if term.ref or (term.voirref and term.voirlabel) then
        tex.sprint('; ')
      end
    end
  end
  if term.voirref and term.voirlabel then
    if term.desc then
      tex.sprint(' ')
      term.voirlong = true -- new sentence
    end
    if term.voirlong then
      tex.sprint('Cf. «~'..hyperref(true, 'glossary:'..term.voirref, term.voirlabel)..'~».')
    else
      tex.sprint('cf. «~'..hyperref(true, 'glossary:'..term.voirref, term.voirlabel)..'~»')
    end
  end
  if term.ref then
    if term.desc then
      tex.print('\\newline')
      tex.sprint('\\indent ')
      tex.sprint('Voir '..hyperref(true, term.ref, 'page~'..pageref(term.ref))..'.')
    else
      tex.sprint('Voir '..hyperref(true, term.ref, 'page~'..pageref(term.ref)))
    end
  end

  -- footer
  tex.print('')
  tex.print('\\end{minipage}')
  tex.print('')
  tex.print('\\vspace{0.4cm}')
  tex.print('')
  return true
end

--[[
-- Check every term defined are used.
--]]
function luaglossary.check_use()
  for k, _ in pairs(luaglossary.data) do
    if luaglossary.mode == "main" and not (luaglossary.data[k].print or luaglossary.data[k].not_first or luaglossary.data[k].used_in_glossary) then
      warn("Glossary item '".. k .."' is defined but not used")
    end
  end
end

--[[
-- Call a term with custom formating.
--]]
function luaglossary.gl(mark_used, term_id, display)
  if not check_term(term_id) then
    return
  end
  tex.sprint(hyperref(is_link_enabled(term_id), 'glossary:'..term_id, display))
  if mark_used then
      luaglossary.data[term_id].not_first = true
  end
end

--[[
-- Call a term and format display as french singular.
--]]
function luaglossary.acrfr(term_id)
  if not check_term(term_id) then
    return
  end
  if not luaglossary.data[term_id].fr then
    tex.error("Glossary item '".. term_id .."' has no 'fr' field")
  end
  if luaglossary.data[term_id].not_first and luaglossary.data[term_id].short then
    -- already used: use short version
    tex.sprint(hyperref(is_link_enabled(term_id), 'glossary:'..term_id, luaglossary.data[term_id].short))
  elseif luaglossary.data[term_id].not_first then
    -- already used, but no short version
    tex.sprint(hyperref(is_link_enabled(term_id), 'glossary:'..term_id, luaglossary.data[term_id].fr))
  else
    -- never used: "fr (english, short)" (only when they exist)
    tex.sprint(hyperref(is_link_enabled(term_id), 'glossary:'..term_id, luaglossary.data[term_id].fr ..
      ((luaglossary.data[term_id].en or luaglossary.data[term_id].short) and '~(' or '') ..
      (luaglossary.data[term_id].en and textit(luaglossary.data[term_id].en) or '') ..
      ((luaglossary.data[term_id].en and luaglossary.data[term_id].short) and ',~' or '').. 
      (luaglossary.data[term_id].short or '') ..
      ((luaglossary.data[term_id].en or luaglossary.data[term_id].short) and ')' or '')
    ))
  end
  luaglossary.data[term_id].not_first = true
end

--[[
-- Call a term and format display as french plural.
--]]
function luaglossary.acrfrpl(term_id)
  if not check_term(term_id) then
    return
  end
  if not luaglossary.data[term_id].frpl then
    tex.error("Glossary item '".. term_id .."' has no 'frpl' field")
  end
  if luaglossary.data[term_id].not_first and luaglossary.data[term_id].shortpl then
    -- already used: use shortpl version
    tex.sprint(hyperref(is_link_enabled(term_id), 'glossary:'..term_id, luaglossary.data[term_id].shortpl))
  elseif luaglossary.data[term_id].not_first then
    -- already used, but no shortpl version
    tex.sprint(hyperref(is_link_enabled(term_id), 'glossary:'..term_id, luaglossary.data[term_id].frpl))
  else
    -- never used: "frpl (englishpl, shortpl)" (only when they exist)
    tex.sprint(hyperref(is_link_enabled(term_id), 'glossary:'..term_id, luaglossary.data[term_id].frpl ..
      ((luaglossary.data[term_id].enpl or luaglossary.data[term_id].shortpl) and '~(' or '') ..
      (luaglossary.data[term_id].enpl and textit(luaglossary.data[term_id].enpl) or '') ..
      ((luaglossary.data[term_id].enpl and luaglossary.data[term_id].shortpl) and ',~' or '').. 
      (luaglossary.data[term_id].shortpl or '') ..
      ((luaglossary.data[term_id].enpl or luaglossary.data[term_id].shortpl) and ')' or '')
    ))
  end
  luaglossary.data[term_id].not_first = true
end

--[[
-- Call a term and format display as english singular.
--]]
function luaglossary.acren(term_id)
  if not check_term(term_id) then
    return
  end
  if not luaglossary.data[term_id].en then
    tex.error("Glossary item '".. term_id .."' has no 'en' field")
  end
  if luaglossary.data[term_id].not_first and luaglossary.data[term_id].short then
    -- already used: use short version
    tex.sprint(hyperref(is_link_enabled(term_id), 'glossary:'..term_id, luaglossary.data[term_id].short))
  elseif luaglossary.data[term_id].not_first then
    -- already used, but no short version
    tex.sprint(hyperref(is_link_enabled(term_id), 'glossary:'..term_id, textit(luaglossary.data[term_id].en)))
  else
    -- never used: "en (short, fr)" (only when they exist)
    tex.sprint(hyperref(is_link_enabled(term_id), 'glossary:'..term_id, textit(luaglossary.data[term_id].en) ..
      ((luaglossary.data[term_id].short or luaglossary.data[term_id].fr) and '~(' or '') ..
      (luaglossary.data[term_id].short or '') ..
      ((luaglossary.data[term_id].short and luaglossary.data[term_id].fr) and ',~' or '').. 
      (luaglossary.data[term_id].fr or '') ..
      ((luaglossary.data[term_id].short or luaglossary.data[term_id].fr) and ')' or '')
    ))
  end
  luaglossary.data[term_id].not_first = true
end

--[[
-- Call a term and format display as english plural.
--]]
function luaglossary.acrenpl(term_id)
  if not check_term(term_id) then
    return
  end
  if not luaglossary.data[term_id].enpl then
    tex.error("Glossary item '".. term_id .."' has no 'enpl' field")
  end
  if luaglossary.data[term_id].not_first and luaglossary.data[term_id].shortpl then
    -- already used: use shortpl version
    tex.sprint(hyperref(is_link_enabled(term_id), 'glossary:'..term_id, luaglossary.data[term_id].shortpl))
  elseif luaglossary.data[term_id].not_first then
    -- already used, but no shortpl version
    tex.sprint(hyperref(is_link_enabled(term_id), 'glossary:'..term_id, textit(luaglossary.data[term_id].enpl)))
  else
    -- never used: "enpl (shortpl, frpl)" (only when they exist)
    tex.sprint(hyperref(is_link_enabled(term_id), 'glossary:'..term_id, textit(luaglossary.data[term_id].enpl) ..
      ((luaglossary.data[term_id].shortpl or luaglossary.data[term_id].frpl) and '~(' or '') ..
      (luaglossary.data[term_id].shortpl or '') ..
      ((luaglossary.data[term_id].shortpl and luaglossary.data[term_id].frpl) and ',~' or '').. 
      (luaglossary.data[term_id].frpl or '') ..
      ((luaglossary.data[term_id].shortpl or luaglossary.data[term_id].frpl) and ')' or '')
    ))
  end
  luaglossary.data[term_id].not_first = true
end

--[[
-- Display header of glossary chapter.
--]]
function luaglossary.print_glossary_header()
  tex.print('\\pagebreak')
  tex.print('\\newgeometry{bottom=3cm, left=2cm, right=1.5cm}')
  tex.print('\\chapter*{Glossaire}')
  tex.print('\\label{ch:glossary}')
  -- make sure to add to toc only **AFTER** the chapter is defined
  -- (otherwise it will link to the wrong chapter)
  tex.print('\\addstarredchapter{Glossaire}')
  tex.print('\\markboth{Glossaire}{}')
end

--[[
-- Display body/footer of glossary chapter.
--]]
function luaglossary.print_glossary_body(unsafe)
  if luaglossary.data == nil then
    tex.error("Glossary has not been initialized. Use '\\loadluaglossary{filename}' first")
  end
  tex.print('')
  tex.print('\\vspace*{1cm}')
  tex.print('')
  tex.sprint('\\par\\centerline{*\\,*\\,*}\\vspace{1cm}')
  for _, k in ipairs(luaglossary.keys) do
    if not print_def(k, luaglossary.data[k], unsafe) then
      return
    end
  end
  tex.print('\\restoregeometry')
  if not unsafe then
    luaglossary.check_use()
  end
end
# SPDX-License-Identifier: CC-BY-SA-4.0
# SPDX-FileCopyrightText: Louis Royer <infos.louis.royer@gmail.com>

.PHONY: clean 

SOURCE := $(shell find . -type f \( -iname '*.tex' -or -iname '*.pdf' -or -iname '*.lua' -or -iname '*.sty' -or -iname '*.cls' -or -iname '*.json' -or -iname '*.bib' \) -not -name 'these.pdf' -not -name 'main.pdf' -print)

these.pdf: main.bbl.done.aux
	max_print_line=120 lualatex main.tex
	cp main.pdf these.pdf

main.bbl.done.aux: main.done.aux
	biber main
	@touch main.bbl.done.aux

main.done.aux: $(SOURCE)
	max_print_line=120 lualatex main.tex
	@touch main.done.aux

clean:
	@find . -iname 'main.*' -not -name 'main.tex' -delete
	@find . -iname '*.aux' -delete
	@rm these.pdf

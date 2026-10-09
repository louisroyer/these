% SPDX-License-Identifier: CC-BY-SA-4.0
% SPDX-FileCopyrightText: Louis Royer <infos.louis.royer@gmail.com>

\newcommand\fileversion{1.0}
\newcommand\filedate{2026-03-06}
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{These}[\filedate\space Classe LaTeX pour les manuscripts de thèse (version \fileversion)]


%% Fallback
\DeclareOption*{
    \ClassWarning{These}{Unknown option '\CurrentOption'}
    \PassOptionsToClass{\CurrentOption}{book}
}

%% Traitement des options
\ProcessOptions\relax

%% Charger le package book, qui servira de base
\LoadClass[a4paper,11pt,pdftex,fleqn,openright,twoside]{book}

% Layout and Formatting
\RequirePackage{lscape}   % Supports Landscape Layout
\RequirePackage{setspace} % Define line spacing in paragraph
\RequirePackage{calc}     % To calculate vertical spacing

% Table of Contents & Appendices
\RequirePackage[nottoc]{tocbibind} % add Bibliography, List of figures and tables to contents
\RequirePackage[title,titletoc]{appendix} % add appendices

\renewcommand{\contentsname}{Table des matières}
\renewcommand{\listfigurename}{Liste des figures}
\renewcommand{\listtablename}{Liste des tableaux}

\RequirePackage[
   hidelinks,
   citecolor = red,
   breaklinks,
   pdfversion=1.7
]{hyperref}
\RequirePackage{xurl}

% avoid big spaces inside urls
\newcommand*{\urlnoskip}[1]{%
{\begingroup
\Urlmuskip=0mu\relax
\url{#1}%   
\endgroup}%
}


\RequirePackage[backend=biber,style=ieee,citestyle=numeric-comp, maxcitenames=11, datamodel=hal]{biblatex}
% remove unwanted issn field (usless because unreadable by human, and for automated use DOI is more precise)
\AtEveryBibitem{\clearfield{issn}}
\AtEveryCitekey{\clearfield{issn}}
% remove unwanted location field (it gives no relevant info)
\AtEveryBibitem{\clearlist{location}}
\AtEveryCitekey{\clearlist{location}}
% remove unwanted publisher field (it gives no relevant info)
\AtEveryBibitem{\clearlist{publisher}}
\AtEveryCitekey{\clearlist{publisher}}
% remove unwanted series field (it gives no relevant info, the book title is enough)
\AtEveryBibitem{\clearfield{series}}
\AtEveryCitekey{\clearfield{series}}
% remove unwanted isbn field (we already give doi, which is more precise)
\AtEveryBibitem{\clearfield{isbn}}
\AtEveryCitekey{\clearfield{isbn}}
% avoid having "DOI:" and the actual doi on 2 separates lines
\DeclareFieldFormat{doi}{\textsc{doi}:~\texttt{\href{https://doi.org/#1}{#1}}}
% replace default "adresse:" by "URL:"
\DeclareFieldFormat{url}{\textsc{url}:~\urlnoskip{#1}}
% add a custom field to add a hal id:
% With the exception of your own articles, use it only when *all* the conditions below are satisfied:
% - no URL is provided
% - the DOI is linking to non-free-access resource
% - the HAL entry has a document (some are simply notices, which are useless in our bibliography)
\DeclareFieldFormat{hal}{\textsc{hal}:~\texttt{\href{https://hal.science/#1}{#1}}}
\renewbibmacro*{finentry}{\newunit\newblock\printfield{hal}\finentry}

% avoid empty parenthesis when date is missing (lualatex 1.5), and display organization first
\DeclareBibliographyDriver{online}{%
\usebibmacro{bibindex}%
\usebibmacro{begentry}%
\printnames{author}%
\printlist{organization}%
\setunit{\labelnamepunct}\newblock  \printfield{title}%
\newunit\newblock  \printfield{url}%
\newunit\newblock  \printfield{note}%
\newunit\newblock  \usebibmacro{finentry}%
}


\RequirePackage[french]{babel}
\RequirePackage{fontspec}
\defaultfontfeatures{Ligatures=TeX}
\RequirePackage[inline]{enumitem}


\RequirePackage[pdftex]{graphicx}
\DeclareGraphicsExtensions{.pdf}
\RequirePackage[labelsep=space,tableposition=top]{caption}
\RequirePackage{subcaption}
\RequirePackage{booktabs}
\RequirePackage{multirow}
\RequirePackage{xargs}
\RequirePackage{tabularx}
\RequirePackage{graphicx}
\RequirePackage{wrapfig}
\RequirePackage{amsmath}
\RequirePackage{listings}

\captionsetup[table]{name=tableau}

\lstset{basicstyle=\small\ttfamily}
\lstdefinelanguage{ping}{morecomment=[l]{\#}}
\lstdefinestyle{centercomments}{
    language=ping,
    basicstyle=\ttfamily,
    commentstyle=\color{gray}\sffamily,
    alsoletter={/},
    columns=fullflexible,
    keepspaces=true
}
\renewcommand{\lstlistingname}{Capture}

% shared figure/listingscounter
%\AtBeginDocument{%
%  \let\c@figure\c@lstlisting
%  \let\thefigure\thelstlisting
%  \let\ftype@lstlisting\ftype@figure % give the floats the same precedence
%}

% shared equation/tables/listingscounter
%\AtBeginDocument{%
%  \let\c@equation\c@figure
%  \let\ftype@equation\ftype@figure % give the floats the same precedence
%  \let\c@table\c@figure
%  \let\ftype@table\ftype@figure % give the floats the same precedence
%}
%\renewcommand{\theequation}{\thefigure}
%\renewcommand{\thetable}{\thefigure}


\RequirePackage{cases}


% Pour avoir les signets vers les sections
\RequirePackage[]{bookmark}

% Mini-tables de matières par chapitres
\RequirePackage[french]{minitoc}

% Required by babel/polyglossia
\RequirePackage{csquotes}


\RequirePackage{comment}
\RequirePackage{datetime}

\RequirePackage[bottom=3.5cm, left=2cm, right=1.5cm]{geometry}

\renewcommand\baselinestretch{1.2}
\newcommand{\nocontentsline}[3]{}
\newcommand{\tochide}[2]{
	\bgroup\let
	\addcontentsline=\nocontentsline#1{#2}
	\egroup}
% Removes pagenumber appearing from TOC
\addtocontents{toc}{\protect\thispagestyle{empty}}
\setcounter{secnumdepth}{3} % allow to do subsubsections
\setcounter{tocdepth}{3} % display subsubsections titles in main TOC
% in minitocs, only display subsections (so it fits in a single page with a chapter header text) as we don't need the details: this is just an overview
\setcounter{minitocdepth}{2}

\RequirePackage{fancyhdr} % Define custom header

\newcommand{\setFancyHdr}{
    \pagestyle{fancy}
    \renewcommand{\chaptermark}[1]{\markboth {##1}{}}
    \renewcommand{\sectionmark}[1]{\markright{\thesection\ ##1}}
    \fancyhf{}
    \fancyhead[LO]{\nouppercase \rightmark}
    \fancyhead[LE,RO]{\bfseries\thepage}
    \fancyhead[RE]{\nouppercase \leftmark}
}

\setlength{\headheight}{14.5pt}
\fancypagestyle{plain}{
  \fancyhead{}
  \renewcommand{\headrulewidth}{0pt}
}

\setFancyHdr
\newenvironment{romanpages}{
    \setcounter{page}{1}
    \renewcommand{\thepage}{\roman{page}}}
{\newpage\renewcommand{\thepage}{\arabic{page}}}



\newenvironment{alwayssingle}{%
       \@restonecolfalse\if@twocolumn\@restonecoltrue\onecolumn
       \else\newpage\fi}
       {\if@restonecol\twocolumn\else\newpage\fi}

\renewcommand{\cleardoublepage}{\clearpage\if@twoside \ifodd\c@page\else%
	\hbox{}%
	\thispagestyle{empty}  % Empty header styles
	\newpage%
	\if@twocolumn\hbox{}\newpage\fi\fi\fi}

\RequirePackage{titlesec}
\newcommand{\PreContentTitleFormat}{\titleformat{\chapter}[display]{\scshape\Large}
{\Large\filleft{\chaptertitlename} \Huge\thechapter}
{1ex}{}
[\vspace{1ex}\titlerule]}
\newcommand{\ContentTitleFormat}{\titleformat{\chapter}[display]{\scshape\huge}
{\Large\filleft{\chaptertitlename} \Huge\thechapter}{1ex}
{\titlerule\vspace{1ex}\filright}
[\vspace{1ex}\titlerule]}
\newcommand{\PostContentTitleFormat}{\PreContentTitleFormat}
\titlespacing*{\chapter}{0pt}{-50pt}{40pt}

\RequirePackage{tocloft}
\setlength{\cftbeforechapskip}{1em} % Space before each chapter entry
\setlength{\cftbeforesecskip}{0.5em} % Adjusts space before section entries
\setlength{\cftbeforesubsecskip}{0.3em} % Adjusts space before subsection entries

\RequirePackage{siunitx}

\RequirePackage{tikz}
\usetikzlibrary{calc}

\RequirePackage{pdfpages} % pour ajouter la page de garde


\newcommand{\couverture}[1]{
    \renewcommand{\thepage}{Couverture} % modifie la numérotation de la page de couverture dans le lecteur PDF
    \includepdf[pages=-]{#1} % page de garde à générer sur ADUM
    \renewcommand{\thepage}{-} % le verso de la couverture
    \cleardoublepage
    \renewcommand{\thepage}{\roman{page}}
}
\newcommand{\quatriemeDeCouverture}[1]{
    \pagestyle{empty}
    \cleardoublepage
    \hbox{}\newpage % recto de la couverture
    \renewcommand{\thepage}{Fin} % modifie la numérotation de la page de couverture dans le lecteur PDF
    \includepdf[pages=-,pagecommand={}]{#1} % page de garde à générer sur ADUM
    \let\clearpage\relax
}


\newenvironment{acknowledgements}{
    \cleardoublepage
    \chapter*{\centering \Large Remerciements}
    \label{ch:acknowledgements}
    \pdfbookmark[0]{Remerciements}{ch:acknowledgements} 
    \thispagestyle{empty}
}


\newenvironment{contrib}{
    \cleardoublepage
    \chapter*{\centering \Large Publications liées à la thèse}
    \addcontentsline{toc}{chapter}{Publications liées à la thèse}
    \begin{adjustwidth}{0cm}{1.5cm}
}{
    \end{adjustwidth}
}


\newenvironment{resume}{
\newgeometry{left=2cm,right=1.5cm,top=0cm}
}{
\restoregeometry
}
\newenvironment{frresume}{
    \cleardoublepage
    \chapter*{\centering \Large Résumé}
    \label{ch:resume}
    \pdfbookmark[0]{Résumé}{ch:resume} 
    \thispagestyle{empty}
}

\newenvironment{enresume}{
    \cleardoublepage
    \vspace{-4cm}
    \begin{otherlanguage*}{english}
    \chapter*{\centering \Large Abstract}
    \label{ch:abstract}
    \pdfbookmark[0]{Abstract}{ch:abstract} 
    \markboth{Abstract}{}
    \end{otherlanguage*}
    \thispagestyle{empty}
}

\newenvironment{enresumeKeywords}{
    \vspace*{\fill}
    \hrule
    \vspace{0.2cm}
    \begin{otherlanguage*}{english}
    \par\noindent
    \begin{minipage}[t]{0.15\textwidth}\textbf{Keywords}: \end{minipage}%
    \begin{minipage}[t]{0.80\textwidth}
}%
{
    \vspace{0.2cm}
    \end{minipage}
    \end{otherlanguage*}

    \hrule
}

\newenvironment{frresumeKeywords}{
    \vspace*{\fill}
    \hrule
    \vspace{0.2cm}
    \par\noindent
    \begin{minipage}[t]{0.15\textwidth}\textbf{Mots clés}: \end{minipage}%
    \begin{minipage}[t]{0.80\textwidth}
}%
{
    \vspace{0.2cm}
    \end{minipage}

    \hrule
}

\newenvironment{licenseHeader}{
    \thispagestyle{empty}
    \phantomsection
    \label{ch:license}
    \pdfbookmark[0]{Licence}{ch:license} 
    \hspace{0pt}
    \vspace{5cm}
    
}

\newenvironment{licenseFooter}{
    \vfill
    \begin{flushright}
    
}%
{
    \end{flushright}
}

\newenvironment{citationPage}{
    \thispagestyle{empty}
    \vspace*{\fill}
    \begin{center}
    \vspace{-1cm}
    
}%
{
    \end{center}
    \vspace*{\fill}
}

\RequirePackage{luaglossary/luaglossary}
\RequirePackage{subfiles}
% if this is a numbered chapter, you can optionally pass the chapter number as argument
% this will fix the chapter numbering when compiling only this chapter.
% For example, when creating chapter 42:
%   \initSubfile[42]
\newcommand{\initSubfile}[1][]{%
\ifSubfilesClassLoaded{%
    \loadluaglossary[subfile]{../glossary.json}
    \dominitoc
    \faketableofcontents
    \def\FirstArg{#1}
        \ifx\FirstArg\empty\else
            \addtocounter{chapter}{#1}
            \addtocounter{chapter}{-1}
        \fi
    \ContentTitleFormat
    \AtEndDocument{
        \addcontentsline{toc}{chapter}{Bibliographie}
        \begin{sloppypar}
        \printbibliography
        \end{sloppypar}
    }
}{}%
}


\newcommand{\dummylabel}[2]{\ifSubfilesClassLoaded{\def\@currentlabel{#2}\label{#1}}{}}

\newenvironment{chapterHeader}{
    \minitoc
    \vspace*{\fill}
    \astersmall
    \vspace*{\fill}
    \begin{adjustwidth*}{1cm}{1cm}
}
{
\end{adjustwidth*}
    \vspace*{\fill}
    \asterthree
    \vspace*{\fill}
    \clearpage
}

\RequirePackage{float} % to force large figures to not be placed at end of chapter

\newcommand{\TODO}[1]{{\color{blue}TODO: #1}}


% tables
\RequirePackage{threeparttable, booktabs}
\RequirePackage{makecell}
\RequirePackage{changepage} % used by summary of chapters
\RequirePackage{fontawesome5} % used for licence logos

\renewcommand{\theadfont}{\small\bfseries}

% astérismes
\newcommand{\asterthree}{\par\centerline{*\,*\,*}}%
\newcommand{\astersmall}{\par{\large\centerline{*}}}

% indent \subsection*{}
\titleformat{name=\subsection,numberless}[hang]{\normalfont\bfseries}{}{1em}{}

% edit PDF TOC metadata to add a pretty numbering
\pdfstringdefDisableCommands{%
    \def\numberline#1{
    \ifnum\c@section=0%
        Chap\space#1.\space%
    \else%
        #1.\space%
    \fi%
    }
}

% filter out some useless warnings
\RequirePackage{silence}
\WarningFilter{hyperref}{Token not allowed in a PDF string (Unicode)}
\WarningFilter{latexfont}{Font shape `TU/lmr/m/scit' undefined} % smallcaps and italics (used in some chapter titles)
\WarningFilter{french.ldf}{You are relying on the legacy list code} % using the new \DocumentMetadata{} requires changes in the template and dependencies
\endinput

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{jot}[%
    2010/05/01 0.1
    (c) 2010 Damien Pollet, Inria / Univ. Lille 1, France
]

\ProcessOptions\relax

\LoadClass[10pt,twoside]{article}

\RequirePackage{keyval} % for \jotdetails
\RequirePackage{graphicx}
\RequirePackage{color}
\RequirePackage{geometry}
\RequirePackage{hyperref}
\RequirePackage{eso-pic}
% \RequirePackage[grid,texcoord]{eso-pic}
\RequirePackage{soul}

%%%% user commands
\@onlypreamble{\title}          % \title{...}
\@onlypreamble{\author}         % \author[affiliation={a1,a2}, photo=file.jpg]{First Last}{bio & contact info}
\@onlypreamble{\affiliation}    % \affiliation{a1}{description}

\@onlypreamble{\jotdetails}     % \jotdetails{key=value}
                                % possible keys:
                                % year, volume, number, doi, url, dates received/published/revised...

\@onlypreamble{\runningtitle}   % override title/author for headers
\@onlypreamble{\runningauthor}
\@onlypreamble{\pdftitle}       % override running title/author for PDF metadata
\@onlypreamble{\pdfauthor}

%%%% Publication information

\newcommand\jot@doiderefaddress{http://dx.doi.org/}
\newcommand\jot@journalname{Journal of Object Technology}
\newcommand\jot@journaldoiaddress{\jot@doiderefaddress\jot@journaldoi}
\newcommand\jot@journaladdress{http://www.jot.fm}
\newcommand\jot@journaldoi{xxx}
\newcommand{\jot@cclicenseurl}{http://creativecommons.org/licenses/by/3.0/}
\newcommand{\jot@licenseurl}{\jot@journaladdress/copyright.html}

% Initialize properties to default values
\newcommand{\jot@year}{\@empty}
\newcommand{\jot@volume}{\@empty}
\newcommand{\jot@number}{\@empty}
\newcommand{\jot@received}{\@empty}
\newcommand{\jot@published}{\@empty}
\newcommand{\jot@revised}{\@empty}
\newcommand{\jot@declaredfirstpage}{1}
\newcommand{\jot@doi}{\@empty}
\newcommand{\jot@url}{\@empty}

% Declare keys for \jotdetails
\define@key{jot@details@keys}{year}{\renewcommand{\jot@year}{#1}}
\define@key{jot@details@keys}{volume}{\renewcommand{\jot@volume}{#1}}
\define@key{jot@details@keys}{number}{\renewcommand{\jot@number}{#1}}
\define@key{jot@details@keys}{received}{\renewcommand{\jot@received}{#1}}
\define@key{jot@details@keys}{published}{\renewcommand{\jot@published}{#1}}
\define@key{jot@details@keys}{revised}{\renewcommand{\jot@revised}{#1}}
\define@key{jot@details@keys}{firstpage}{\renewcommand{\jot@declaredfirstpage}{#1}}
\define@key{jot@details@keys}{doi}{\renewcommand{\jot@doi}{#1}}
\define@key{jot@details@keys}{url}{\renewcommand{\jot@url}{#1}}

% argument is a comma seperated list of the type "volume=6,year=8,..."
% If we have details of section we are interested in, process it
\newcommand{\jotdetails}[1]{\setkeys{jot@details@keys}{#1}}


%%%% Article metadata

% metadata setters, to override default values set by \author and \title
\newcommand{\runningtitle}[1]{\renewcommand\jot@runningtitle{#1}}
\newcommand{\runningauthor}[1]{\renewcommand\jot@runningauthor{#1}}
\newcommand{\pdftitle}[1]{\renewcommand{\jot@pdftitle}{#1}}
\newcommand{\pdfauthor}[1]{\renewcommand{\jot@pdfauthor}{#1}}

\newcommand\jot@runningtitle{\@title}
\newcommand\jot@runningauthor{}
\newcommand\jot@firstpage{\getpagerefnumber{jot:firstpage}}
\newcommand\jot@lastpage{\getpagerefnumber{jot:lastpage}}
\newcommand\jot@runningcitation{%
    \href{\jot@journaldoiaddress}{%
        \jot@journalname, vol.~\jot@volume, no.~\jot@number, \jot@year.}}

% setting author info

% we're assembling the info into these token lists
\def\jot@authors{\@empty}
\def\jot@authorbios{\@empty}
\def\jot@affiliations{\@empty}
\def\jot@addto@authors{\g@addto@macro\jot@authors}
\def\jot@addto@authorbios{\g@addto@macro\jot@authorbios}

% setup counters for generating author/affiliation links
\newcounter{jot@numauthors}\setcounter{jot@numauthors}{0}
\newcounter{jot@numaffiliations}\setcounter{jot@numaffiliations}{0}
\newtoks\jot@tmp@aff
\newtoks\jot@tmp@pic

% parsing the key/val argument of \author
\define@key{jot@author@keys}{affiliation}[\@empty]{\jot@tmp@aff\expandafter{#1}}
\define@key{jot@author@keys}{photo}[\@empty]{\jot@tmp@pic\expandafter{#1}}

% declare an author: \author[photo=...,affiliation=...]{name}{bio}
\let\orig@author\author % original \author setter, for layout
\newcommand{\jot@needslong@author}[3][]{%
    \addtocounter{jot@numauthors}{1}%
    \edef\jot@tmp@id{\roman{jot@numauthors}}%
    \ifnum 1<\value{jot@numauthors} % not the 1st
        \g@addto@macro\jot@authors{\and}%
        \g@addto@macro\jot@runningauthor{\running@and}%
    \fi
    \g@addto@macro\jot@runningauthor{#2}%
    \jot@tmp@aff{\@empty}\jot@tmp@pic{\@empty}\setkeys{jot@author@keys}{#1}%
    \ifx\the\jot@tmp@aff\@empty \ClassWarning{jot.cls}{No affiliation given for #2}\fi
    \ifx\the\jot@tmp@pic\@empty \ClassWarning{jot.cls}{No photo given for #2}\fi
    % meh, I want proper quasi-quoting...
    \jot@addto@authors{\jot@format@author}%
    \expandafter\jot@addto@authors\expandafter{\expandafter{\jot@tmp@id}}%
    \jot@addto@authors{{#2}}%
    \expandafter\jot@addto@authors\expandafter{\expandafter{\the\jot@tmp@aff}}%
    \jot@addto@authors{{#3}}
    \jot@addto@authorbios{\jot@format@authorbio}%
    \expandafter\jot@addto@authorbios\expandafter{\expandafter{\jot@tmp@id}}%
    \jot@addto@authorbios{{#2}}%
    \expandafter\jot@addto@authorbios\expandafter{\expandafter{\the\jot@tmp@pic}}%
    \jot@addto@authorbios{{#3}}%
}
\long\def\author{\jot@needslong@author}

% declare an affiliation: \affiliation{id}{details}
\newcommand{\affiliation}[2]{%
    \addtocounter{jot@numaffiliations}{1}%
    \expandafter\def\csname jot@affiliation@#1\endcsname{#2}%
    \expandafter\edef\csname jot@affiliationnum@#1\endcsname{\alph{jot@numaffiliations}}%
    % \ClassWarning{jot.cls}{New affiliation \csname jot@affiliationnum@#1\endcsname: #1}
    \g@addto@macro\jot@affiliations{\jot@format@affiliation{#1}}%
    \define@key{jot@affiliation@keys}{#1}[#1]{\jot@ref@affiliation{#1}}%
}

% setting title
\let\orig@title\title
\renewcommand{\title}[2][\@empty]{%
    \ifx#1\@empty
        \renewcommand\jot@runningtitle{#2}
    \else
        \renewcommand\jot@runningtitle{#1}
    \fi
    \orig@title{#2}
}


%%%% Layout & typography

\geometry{
    % showframe,
    a4paper,
    % letterpaper,
    % asymmetric,
    body={13cm,21cm}, %golden ratio    2x ratio: body={12cm,24cm},
    top=3cm, centering,%inner=3cm,
    ignoreall, marginpar=30mm, marginparsep=5mm, %marginpar=42mm, marginparsep=6mm,
    head=10mm, headsep=10mm, foot=20mm,
}

\definecolor{internallinkcolor}{rgb}{0,0,0}
\definecolor{externallinkcolor}{rgb}{0,0,0}

\hypersetup{
    breaklinks,
    % colorlinks,
    urlcolor=externallinkcolor,
    linkcolor=internallinkcolor,
    filecolor=externallinkcolor,
    citecolor=internallinkcolor,
}

% page headers & footers
\newcommand\jot@headerlayout[1]{{\footnotesize#1}}
\newcommand\jot@footerlayout[1]{{\footnotesize#1}}

\renewcommand{\ps@headings}{%
    \renewcommand{\@oddhead}{\sffamily
        \hfil\jot@headerlayout{\jot@runningtitle}\quad\textperiodcentered\quad\thepage}%
    \renewcommand{\@evenhead}{\sffamily
        \thepage\quad\textperiodcentered\quad\jot@headerlayout{\jot@runningauthor}\hfil}%
    \renewcommand{\@oddfoot}{\sffamily\hfil\jot@footerlayout{\jot@runningcitation}\hfil}%
    \renewcommand{\@evenfoot}{\sffamily\hfil\jot@footerlayout{\jot@runningcitation}\hfil}%
}

\pagestyle{headings}
\pagenumbering{arabic}

% title page and typesetting author info

% short way to typeset \and for headers & metadata
\def\running@and{, }

\newcommand\jot@format@author[4]{% id, name, affiliations, bio
    \ifx #4\relax % meh, {} is not \@empty ??
        \relax #2
    \else
        \hyperlink{jot:authorbio:#1}{#2}
    \fi
    % list of footnote-like links to affiliations
    \ifx#3\@empty\else\setkeys{jot@affiliation@keys}{#3}\fi}

\newcommand\jot@ref@affiliation[1]{%
    \hyperlink{jot:affiliation:#1}{\,\textsuperscript{\csname jot@affiliationnum@#1\endcsname}}}
\newcommand\jot@format@affiliation[1]{% id
    \hypertarget{jot:affiliation:#1}{\textsuperscript{\csname jot@affiliationnum@#1\endcsname}\,}%
    \csname jot@affiliation@#1\endcsname\par}

\newlength{\jot@h}
\newcommand\jot@format@authorbio[4]{%
    % \settoheight{\jot@h}{\strut}%
    \ifx #4\relax % meh, {} is not \@empty ??
        \relax
    \else
        \noindent
        \ifx #3\@empty
            \hspace{2.5cm}%
        \else
            % \raisebox{0ex}{%\jot@h}{%
                \vtop{\null\hbox{\includegraphics[width=2.5cm]{#3}}}%
            % }%
        \fi
        \hspace{5mm}%
        \parbox[t]{11cm}{\hypertarget{jot:authorbio:#1}{\textbf{#2}} #4}\par
        \null\medskip
    \fi
}

\let\orig@bibliography\bibliography
\renewcommand\bibliography[1]{
    \phantomsection
    \addcontentsline{toc}{section}{\bibname}
    \orig@bibliography{#1}}
\def\@openbib@code{\itemsep\z@\RaggedRight}

\def\abouttheauthorsname{About the author\ifnum 1<\value{jot@numauthors}s\fi}
\newcommand{\abouttheauthors}{%
    \phantomsection
    \addcontentsline{toc}{section}{\abouttheauthorsname}
    \section*{\abouttheauthorsname}
    \jot@authorbios}

\newcommand\acknowledgmentsname{Acknowledgments}
\newenvironment{acknowledgments}
    {\paragraph*{\acknowledgmentsname}}
    {}

\renewcommand{\ps@plain}{%
    \let\@evenhead\relax
    \let\@oddhead\relax
    \let\@evenfoot\relax
    \let\@oddfoot\relax}

\renewcommand{\@maketitle}{%
    \setcounter{page}{\jot@declaredfirstpage}%
    \AddToShipoutPicture*{%
        \setlength\unitlength{1mm}%
        \AtPageUpperLeft{%
            \put(8,-8){\makebox(0,0)[lt]{\includegraphics[scale=.75]{jot}}}%
            \put(105,-20){\makebox(0,0)[cc]{\parbox{\textwidth}{\centering
                {\LARGE\expandafter\caps\expandafter{\jot@journalname}}\\
                \sffamily Online at \url{\jot@journaladdress}. Published by SCG?}}}}}%
    \thispagestyle{empty}
    \null
    \vskip 3em%
    \begin{center}%
        \let \footnote \thanks
        {\Huge \@title \par}%
        \vskip 1.5em%
        {\large
            \lineskip .5em%
            \begin{tabular}[t]{c}%
                \@author
            \end{tabular}\par}%
        \vskip 1em%
    \end{center}%
    \par
    \vskip 1.5em
}

\renewenvironment{abstract}
    {\small\quotation}
    {\endquotation}


% document startup
\AtBeginDocument{
    \orig@author{\jot@authors}
    \hypersetup{% Embed PDF metadata after user has set it in preamble.
        pdfauthor=\jot@runningauthor,
        pdftitle=\jot@runningtitle,
        pdfsubject=\jot@journalname,
        % pdfkeywords=xxx,
        % pdfcopyright={This document is licensed under a Creative Commons Attribution 3.0 license},
        % pdflicenseurl={\jot@cclicenseurl}
    }
    \date{}% should customize \maketitle
    \maketitle
    \begin{center}
    	\jot@affiliations
    \end{center}}

% various convenience markup
\newcommand{\email}[1]{\ttfamily\href{mailto:#1}{#1}}

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
\newcommand{\jot@declaredfirstpage}{\@empty}
\newcommand{\jot@doi}{\@empty}
\newcommand{\jot@url}{\@empty}

% Declare keys for \jotdetails
\define@key{jotdet}{year}{\renewcommand{\jot@year}{#1}}
\define@key{jotdet}{volume}{\renewcommand{\jot@volume}{#1}}
\define@key{jotdet}{number}{\renewcommand{\jot@number}{#1}}
\define@key{jotdet}{received}{\renewcommand{\jot@received}{#1}}
\define@key{jotdet}{published}{\renewcommand{\jot@published}{#1}}
\define@key{jotdet}{revised}{\renewcommand{\jot@revised}{#1}}
\define@key{jotdet}{firstpage}{\renewcommand{\jot@declaredfirstpage}{#1}}
\define@key{jotdet}{doi}{\renewcommand{\jot@doi}{#1}}
\define@key{jotdet}{url}{\renewcommand{\jot@url}{#1}}

% argument is a comma seperated list of the type "volume=6,year=8,..."
% If we have details of section we are interested in, process it
\newcommand{\jotdetails}[1]{\setkeys{jotdet}{#1}}


%%%% Article metadata

\newcommand\jot@runningtitle{\@title}
\newcommand\jot@runningauthor{}
\newcommand\jot@pdftitle{\jot@runningtitle}
\newcommand\jot@pdfauthor{\jot@runningauthor}
\newcommand\jot@firstpage{\getpagerefnumber{jot:firstpage}}
\newcommand\jot@lastpage{\getpagerefnumber{jot:lastpage}}
\newcommand\jot@runningcitation{%
    \href{\jot@journaldoiaddress}{%
        \jot@journalname, vol.~\jot@volume, no.~\jot@number, \jot@year.}}

% metadata setters, to override default values set by \author and \title
\newcommand{\runningtitle}[1]{\renewcommand\jot@runningtitle{#1}}
\newcommand{\runningauthor}[1]{\renewcommand\jot@runningauthor{#1}}
\newcommand{\pdftitle}[1]{\renewcommand{\jot@pdftitle}{#1}}
\newcommand{\pdfauthor}[1]{\renewcommand{\jot@pdfauthor}{#1}}

% setting author info
\def\jot@authors{\@empty}
\newcounter{jot@numauthors}\setcounter{jot@numauthors}{0}
\let\orig@author\author % original \author setter, for layout

\renewcommand{\author}[3]{% \author{id}{name}{affiliations}
    \expandafter\def\csname jot@authorname@#1\endcsname{#2}
    \addtocounter{jot@numauthors}{1}
    \ifnum 1<\value{jot@numauthors} % not the 1st
        \g@addto@macro\jot@authors{\and}
        \g@addto@macro\jot@runningauthor{\and}
    \fi
    \g@addto@macro\jot@authors{\jot@format@author{#1}{#2}{#3}}
    \g@addto@macro\jot@runningauthor{#2}
}

\def\jot@authorbios{\@empty}
\newcommand{\authorbio}[3]{% \authorbio{id}{photofile}{text}
    \expandafter\def\csname jot@authorphoto@#1\endcsname{#2}
    \expandafter\def\csname jot@authorbio@#1\endcsname{#3}
    \g@addto@macro\jot@authorbios{\jot@format@authorbio{#1}}
}

\newcommand\jot@affiliations\@empty
\newcounter{jot@numaffiliations}\setcounter{jot@numaffiliations}{0}
\newcommand{\affiliation}[2]{% \affiliation{id}{details}
    \addtocounter{jot@numaffiliations}{1}
    \expandafter\def\csname jot@affiliation@#1\endcsname{#2}
    \expandafter\edef\csname jot@affiliationnum@#1\endcsname{\alph{jot@numaffiliations}}
    \g@addto@macro\jot@affiliations{\jot@format@affiliation{#1}}
    \define@key{jot@affiliation@keys}{#1}[#1]{\jot@ref@affiliation{#1}}
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
    body={14cm,24.25cm}, %body={12cm,24cm},
    top=2cm, centering,%inner=3cm,
    ignoreall, marginpar=25mm, marginparsep=5mm, %marginpar=42mm, marginparsep=6mm,
    head=6mm, headsep=6mm, foot=12mm,
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
\newcommand\jot@headerlayout[1]{{\let\and\running@and \footnotesize#1}}
\newcommand\jot@footerlayout[1]{{\let\and\running@and \footnotesize#1}}

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

\newcommand\jot@format@author[3]{% id, name, affiliations
    \expandafter\ifx\csname jot@authorbio@#1\endcsname\@empty
        \hyperlink{jot:authorbio:#1}{#2}
    \else #2\fi
    % list of footnote-like links to affiliations
    \ifx#3\@empty\else\setkeys{jot@affiliation@keys}{#3}\fi}

\newcommand\jot@ref@affiliation[1]{%
    \hyperlink{jot:affiliation:#1}{\csname jot@affiliationnum@#1\endcsname}}
\newcommand\jot@format@affiliation[1]{% id
    \label{jot:affiliation:#1}%
    \csname jot@affiliationnum@#1\endcsname
    \csname jot@affiliation@#1\endcsname\par}

\newlength{\jot@h}
\newcommand\jot@format@authorbio[1]{%
    \settoheight{\jot@h}{\strut}%
    \edef\jot@photo{\csname jot@authorphoto@#1\endcsname}%
    \noindent
    \ifx\jot@photo\@empty
        \ClassWarning{jot.cls}{No photo given for author "#1"}%
        \hspace{2.5cm}%
    \else
        \raisebox{\jot@h}{%
            \vtop{\null\hbox{\includegraphics[width=2.5cm]{\jot@photo}}}}%
    \fi
    \hspace{5mm}%
    \parbox[t]{11cm}{%
        \textbf{\csname jot@authorname@#1\endcsname}
        \csname jot@authorbio@#1\endcsname
    }\par
    \null\medskip
}

\def\abouttheauthorsname{About the author\ifnum 1<\value{jot@numauthors}s\fi}
\newcommand{\abouttheauthors}{%
    \section*{\abouttheauthorsname}
    \jot@authorbios}

\newcommand\acknowledgmentsname{Acknowledgments}
\newenvironment{acknowledgments}
    {\paragraph*{\acknowledgmentsname}}
    {}

% document startup
\AtBeginDocument{
    \hypersetup{% Embed PDF metadata after user has set it in preamble.
        pdfauthor=\jot@pdfauthor,
        pdftitle=\jot@pdftitle,
        pdfsubject=\jot@journalname,
        % pdfkeywords=xxx,
        % pdfcopyright={This document is licensed under a Creative Commons Attribution 3.0 license},
        % pdflicenseurl={\jot@cclicenseurl}
    }
    \orig@author{\jot@authors}
    \date{}% should customize \maketitle
    \maketitle
    \begin{center}
    	\jot@affiliations
    \end{center}}

% various convenience markup
\newcommand{\email}[1]{\ttfamily\href{mailto:#1}{#1}}

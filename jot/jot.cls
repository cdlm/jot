\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{jot}[%
    2010/05/01 0.1
    (c) 2010 Damien Pollet, Inria / Univ. Lille 1, France
]

\ProcessOptions\relax

\LoadClass[10pt,twoside]{article}

\RequirePackage{keyval}
\RequirePackage{ifthen}
\RequirePackage{hyperref}
\RequirePackage{refcount}
\RequirePackage{geometry}
\RequirePackage{soul}
\RequirePackage{ragged2e}
\RequirePackage{graphicx}
\RequirePackage{xcolor}
\RequirePackage{eso-pic}
% \RequirePackage[grid,texcoord]{eso-pic}
\RequirePackage{placeins}
\RequirePackage{wrapfig}
\RequirePackage{calc}
% \RequirePackage{varioref}

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
\newcommand\jot@articledoiaddress{\jot@doiderefaddress\jot@doi}
\newcommand\jot@journaladdress{http://www.jot.fm}
\newcommand\jot@journaldoi{xxx}
\newcommand{\jot@cclicenseurl}{http://creativecommons.org/licenses/by/3.0/}
\newcommand{\jot@publisher}{ETH~Zurich, Chair of Software Engineering}
\newcommand{\jot@copyright}{\copyright\,JOT 2010}
\newcommand{\jot@licenseurl}{\jot@journaladdress/copyright.html}

% Initialize properties to default values
\newcommand{\jot@year}{\@empty}
\newcommand{\jot@volume}{\@empty}
\newcommand{\jot@number}{\@empty}
\newcommand{\jot@received}{\@empty}
\newcommand{\jot@published}{\@empty}
\newcommand{\jot@revised}{\@empty}
\newcommand{\jot@declaredfirstpage}{1}
\newcommand{\jot@doi}{\jot@journaldoiaddress}
\newcommand{\jot@url}{\jot@journaladdress}

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

\newcommand\jot@runningtitle{\jot@title}
\newcommand\jot@runningauthor{}
\newcommand\jot@firstpage{\getpagerefnumber{jot:firstpage}}
\newcommand\jot@lastpage{\getpagerefnumber{jot:lastpage}}
\newcommand\jot@runningcitation{%
    \href{\jot@url}{\jot@journalname, vol.~\jot@volume, no.~\jot@number, \jot@year}.}

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
\newif\ifjot@authorbio@nowrap
\define@key{jot@author@keys}{affiliation}[\@empty]{\jot@tmp@aff\expandafter{#1}}
\define@key{jot@author@keys}{photo}[\@empty]{\jot@tmp@pic\expandafter{#1}}
\define@key{jot@author@keys}{nowrap}[true]{\csname jot@authorbio@nowrap#1\endcsname}

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
    \jot@tmp@aff{\@empty}\jot@tmp@pic{\@empty}%
    \jot@authorbio@nowrapfalse
    \setkeys{jot@author@keys}{#1}%
    \ifx\the\jot@tmp@aff\@empty \ClassWarning{jot.cls}{No affiliation given for #2}\fi
    \ifx\the\jot@tmp@pic\@empty \ClassWarning{jot.cls}{No photo given for #2}\fi
    % meh, I want proper quasi-quoting...
    \jot@addto@authors{\jot@format@author}%
    \expandafter\jot@addto@authors\expandafter{\expandafter{\jot@tmp@id}}%
    \jot@addto@authors{{#2}}%
    \expandafter\jot@addto@authors\expandafter{\expandafter{\the\jot@tmp@aff}}%
    \jot@addto@authors{{#3}}
    \ifjot@authorbio@nowrap
        \jot@addto@authorbios{\jot@format@shortauthorbio}%
    \else
        \jot@addto@authorbios{\jot@format@authorbio}%
    \fi
    \expandafter\jot@addto@authorbios\expandafter{\expandafter{\jot@tmp@id}}%
    \jot@addto@authorbios{{#2}}%
    \expandafter\jot@addto@authorbios\expandafter{\expandafter{\the\jot@tmp@pic}}%
    \jot@addto@authorbios{{#3}}%
}
\long\def\author{\jot@needslong@author}
\def\thanks{\ClassWarning{jot.cls}{Use the acknowledgments environment instead of \protect\thanks}\@gobble}

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
    columnsep=5mm
}

\setlength{\intextsep}{.5ex} % for wrapfig

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

%% varioref:
% \labelformat{section}{\textsection\,#1}
% \labelformat{subsection}{\textsection\,#1}
% \labelformat{subsubsection}{\textsection\,#1}
% \labelformat{figure}{figure\,#1}
% \labelformat{table}{table\,#1}


\let\titlefamily\sffamily


% page headers & footers
\pagenumbering{arabic}

\newcommand\jot@headfootsetup{\let\thanks\@gobble\footnotesize}

\renewcommand{\ps@headings}{%
    \renewcommand{\@oddhead}{\titlefamily
        \hfil{\jot@headfootsetup\jot@runningtitle\quad\textperiodcentered\quad}\thepage}%
    \renewcommand{\@evenhead}{\titlefamily
        \thepage{\jot@headfootsetup\quad\textperiodcentered\quad\jot@runningauthor}\hfil}%
    \renewcommand{\@oddfoot}{\titlefamily\hfil{\jot@headfootsetup\jot@runningcitation}\hfil}%
    \renewcommand{\@evenfoot}{\titlefamily\hfil{\jot@headfootsetup\jot@runningcitation}\hfil}%
}

\renewcommand{\ps@plain}{%
    \renewcommand{\@evenhead}{}
    \renewcommand{\@oddhead}{}
    \renewcommand{\@evenfoot}{}
    \renewcommand{\@oddfoot}{%
        \titlefamily
        \hfil
        \begin{minipage}[t]{\textwidth}\jot@headfootsetup\raggedright
            \let\jot@format@author\jot@name@author
            \let\and\running@and
            \let\\\relax
            \jot@authors.\quad
            \emph{\jot@title}.\quad
            In \jot@runningcitation, pages~\jot@firstpage--\jot@lastpage.\quad
            Available at \url{\jot@url}
        \end{minipage}%
        \hfil
    }%
}

\pagestyle{headings}

%% sectioning

\renewcommand\section{\@startsection{section}{1}{\z@}%
        {-3.5ex \@plus -1ex \@minus -.2ex}%
        {2.3ex \@plus.2ex}%
        {\normalfont\Large\titlefamily}}
\renewcommand\subsection{\@startsection{subsection}{2}{\z@}%
        {-3.25ex\@plus -1ex \@minus -.2ex}%
        {1.5ex \@plus .2ex}%
        {\normalfont\large\titlefamily}}
\renewcommand\subsubsection{\@startsection{subsubsection}{3}{\z@}%
        {-2.5ex\@plus -1ex \@minus -.2ex}%
        {1ex \@plus .2ex}%
        {\normalfont\normalsize\titlefamily}}
\renewcommand\paragraph{\@startsection{paragraph}{4}{\z@}%
        {2.5ex \@plus1ex \@minus.2ex}%
        {-1em}%
        {\normalfont\normalsize\bfseries}}
\renewcommand\subparagraph{\@startsection{subparagraph}{5}{\parindent}%
        {3.25ex \@plus1ex \@minus .2ex}%
        {-1em}%
        {\normalfont\normalsize\bfseries}}

%% floats

\newenvironment{fullwidth}
    {\list{}{%
            \leftmargin-2cm
            \rightmargin\leftmargin}
        \item\relax}
    {\endlist}

%% captions
\def\fnum@figure{{\titlefamily\figurename\nobreakspace\thefigure}}
\def\fnum@table{{\titlefamily\tablename\nobreakspace\thetable}}

%% title page and typesetting author info

%% short way to typeset \and for headers & metadata
\def\running@and{, }

\newcommand\jot@name@author[4]{#2}
\newcommand\jot@format@author[4]{% id, name, affiliations, bio
    \ifx #4\relax % meh, {} is not \@empty ??
        \relax #2%
    \else
        \hyperlink{jot:authorbio:#1}{#2}%
    \fi
    % list of footnote-like links to affiliations
    \ifx#3\@empty\else\rlap{\setkeys{jot@affiliation@keys}{#3}}\fi}

\newcommand\jot@ref@affiliation[1]{%
    \hyperlink{jot:affiliation:#1}{\strut\textsuperscript{\csname jot@affiliationnum@#1\endcsname}}}
\newcommand\jot@format@affiliation[1]{% id
    \item[\csname jot@affiliationnum@#1\endcsname.\,]%
    \hypertarget{jot:affiliation:#1}{\csname jot@affiliation@#1\endcsname}}

\newlength{\strutheight}
\newcommand\jot@format@authorbio[4]{%
    \ifx #4\relax % meh, {} is not \@empty ??
        \relax
    \else
        \settoheight{\strutheight}{\strut}%
        \noindent
        \ifx #3\@empty\relax\else
            \begin{wrapfigure}{l}{2.5cm}%
                \raisebox{\intextsep+\strutheight-\height}
                         [\strutheight]
                         [\height-\strutheight-\intextsep]
                         {\includegraphics[width=2.5cm]{#3}}%
            \end{wrapfigure}%
        \fi
        \strut\hypertarget{jot:authorbio:#1}{\let\thanks\@gobble\textbf{#2}}\ \ignorespaces
        #4\par
        \bigskip
    \fi
}
\newcommand\jot@format@shortauthorbio[4]{%
    \ifx #4\relax % meh, {} is not \@empty ??
        \relax
    \else
        \noindent
        \ifx #3\@empty
            \hypertarget{jot:authorbio:#1}{\let\thanks\@gobble\textbf{#2}}\ \ignorespaces
            #4
        \else
            \raisebox{-\height}{\includegraphics[width=2.5cm]{#3}}%
            \hspace{5mm}%
            \raisebox{-\height}{\begin{minipage}[t]{\textwidth-3cm}
                \noindent\strut
                \hypertarget{jot:authorbio:#1}{\let\thanks\@gobble\textbf{#2}}\ \ignorespaces
                #4
            \end{minipage}}%
        \fi
        \par
        \bigskip
    \fi
}

\providecommand{\bibname}{References} % it's a babel addition
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

\renewcommand{\@maketitle}{%
    \setcounter{page}{\jot@declaredfirstpage}%
    \label{jot:firstpage}%
    \AddToShipoutPicture*{%
        \setlength\unitlength{1mm}%
        \AtPageUpperLeft{%
            % \put(8,-8){\makebox(0,0)[lt]{\includegraphics[scale=.75]{jot-sig}}}%
            % \put(175,-30){\makebox(0,0)[cc]{\includegraphics[width=3cm]{jot-uml}}}%
            \put(105,-18){\makebox(0,0)[ct]{\parbox{\textwidth}{\centering
                {\Large
                    % \raisebox{.8ex-.5\height}{\includegraphics[height=.8\baselineskip]{jot-umlsquare}}\quad
                    \null\rmfamily\caps\jot@journalname}\\
                \smallskip
                \small\sffamily Published by \jot@publisher, \href{\jot@licenseurl}{\jot@copyright}\\
                Online at \url{\jot@journaladdress}.
                }}}}}%
    \null
    \vskip 3em%
    \begin{center}%
        \let \footnote \thanks
        {\Huge\titlefamily \@title \par}%
        \vskip 1.5em%
        {\large
            \lineskip .75em%
            \begin{tabular}[t]{c}%
                \@author
            \end{tabular}\par}%
        \vskip 1em%
    \end{center}%
    \list{}{%
            \rightmargin    \leftmargin
            \advance\leftmargin 1.5em
            \listparindent  \z@
            \itemindent     \listparindent
            \labelwidth     1em%
            \labelsep       .5em%
            \parsep         \z@
            \itemsep        1ex}%
        \jot@affiliations
    \endlist
    \par
    \vskip 1.5em
}

\renewenvironment{abstract}
    {\quotation\noindent\ignorespaces}
    {\endquotation}

\newcommand{\backmatter}{%
     \FloatBarrier
     \appendix}

% document hooks
\AtBeginDocument{%
    \let\jot@title\@title
    \orig@author{\jot@authors}%
    \hypersetup{% Embed PDF metadata after user has set it in preamble.
        pdfauthor=\jot@runningauthor,
        pdftitle=\jot@runningtitle,
        pdfsubject=\jot@journalname,
        % pdfkeywords=xxx,
        % pdfcopyright={This document is licensed under a Creative Commons Attribution 3.0 license},
        % pdflicenseurl={\jot@cclicenseurl}
    }%
    \date{}% should customize \maketitle
    \maketitle
}
\AtEndDocument{%
    \label{jot:lastpage}%
    \vfill
    \centering
    \includegraphics[height=\baselineskip]{jot-umlsquare}%
}

% various convenience markup
\newcommand{\email}[1]{\href{mailto:#1}{\nolinkurl{#1}}}

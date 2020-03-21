% Style sheet to select Gonville.
%
% You can use this stylesheet with an existing Lilypond input file,
% without having to modify the input file to even add an include
% directive, by running a command like this:
%
%     lilypond -d include-settings=gonville.ily <input file>

\version "2.20"

% Reconfigure the fonts for music symbols and braces to Gonville.
\paper {
  #(define fonts (set-global-fonts #:music "gonville" #:brace "gonville"))
}

% Lilypond displays most music symbols by directly accessing the font
% file. But the parts of the music font that fit in ASCII (letters for
% dynamics, and digits for time signatures and a few other uses) are
% displayed by appealing to Pango, which means that the font in use
% also has to be on the font path known to Pango, i.e. to fontconfig.
#(ly:font-config-add-directory (dirname (ly:find-file "gonville-20.otf")))

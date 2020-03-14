% Style sheet to select Gonville.
%
% You can use this stylesheet with an existing Lilypond input file,
% without having to modify the input file to even add an include
% directive, by running a command like this:
%
%     lilypond -d include-settings=gonville.ily <input file>

\version "2.20"

\paper {
  #(define fonts (set-global-fonts #:music "gonville" #:brace "gonville"))
}

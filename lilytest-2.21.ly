% Test Lilypond file which attempts to exercise every glyph defined
% in Gonville.
%
% To obtain a list of glyphs tested, process the LilyPond PS output
% through
%
%   perl -ne '/%%EndProlog/ and $ok=1; $ok and /\s\/([^\/\s]+)( glyphshow)?\s*$/ and print "$1\n"' | sort | uniq
%
% and compare that against the output of running the .sfd through
%
%   perl -ne '/^StartChar: (\S+)$/ and print "$1\n"' | sort | uniq
%
% Putting it together, here's a pre-cooked command that lists the
% glyphs _not_ tested by this file:
%
%   comm -13 <(perl -ne '/%%EndProlog/ and $ok=1; $ok and /\s\/([^\/\s]+)( glyphshow)?\s*$/ and print "$1\n"' lilytest-2.21.ps | sort | uniq) <(perl -ne '/^StartChar: (\S+)$/ and print "$1\n"' lilysrc/gonville-20.sfd | sort | uniq)

\version "2.21"

#(use-modules (scm accreg))

\layout {
  ragged-right = ##t
}

\header {
  tagline = ##f
}

arra = \markup {
  \combine
  \musicglyph #"arrowheads.close.01"
  \combine
  \musicglyph #"arrowheads.close.11"
  \combine
  \musicglyph #"arrowheads.open.0M1"
  \musicglyph #"arrowheads.open.1M1"
}

arrb = \markup {
  \combine
  \musicglyph #"arrowheads.close.01"
  \combine
  \musicglyph #"arrowheads.open.11"
  \combine
  \musicglyph #"arrowheads.open.0M1"
  \musicglyph #"arrowheads.close.1M1"
}

arrc = \markup {
  \combine
  \musicglyph #"arrowheads.open.01"
  \combine
  \musicglyph #"arrowheads.close.11"
  \combine
  \musicglyph #"arrowheads.close.0M1"
  \musicglyph #"arrowheads.open.1M1"
}

arrd = \markup {
  \combine
  \musicglyph #"arrowheads.open.01"
  \combine
  \musicglyph #"arrowheads.open.11"
  \combine
  \musicglyph #"arrowheads.close.0M1"
  \musicglyph #"arrowheads.close.1M1"
}

accpush = \markup { \musicglyph #"accordion.push" }
accpull = \markup { \musicglyph #"accordion.pull" }
bayanbass = \markup { \musicglyph #"accordion.bayanbass" }
oldEE = \markup { \musicglyph #"accordion.oldEE" }

ouroborosA = #(make-dynamic-script "pznrffmfszfzzmzpnnmsnsfnzr")
ouroborosB = #(make-dynamic-script "rzsppssmpmrsr rrpfrnfprmmnp")

#(define testhalfopenvert (alist->hash-table
                           '((halfopenhihat cross "halfopenvertical" 5))))

fragA = {
  \key e \major
  e16 fis gis a b4
  \set TabStaff.minimumFret = #7
  e16 fis gis a b4
}

fragB = {
  \set TabStaff.minimumFret = #0
  e16 fis gis a b4
  \set TabStaff.minimumFret = #7
  e16 fis gis a b4
  \set TabStaff.minimumFret = #0
  e1
  r1*2
}

\book {
  \score {
    \new ChoirStaff <<
      \time 4/4
      \new Staff {
        \set Score.skipBars = ##t
        \clef alto
        r1
        \time 3/4
        fes2^\fermata
        f'?4^\trill
        \time 15/64
        g'8^\shortfermata \noBeam
        ais'16^\henzelongfermata \noBeam
        b'32^\verylongfermata \noBeam
        c''64^\veryshortfermata\noBeam
        \time 1/128
        d''128^\henzeshortfermata\noBeam
        \time 9/1
        r\maxima r1^\longfermata
        \time 2/2
        \clef treble
        << { r1 } \\ { d'4 e' d' e' } >>
        << { r2 r2 } \\ { e''4 f'' e'' f'' } >>
        e''8^\espressivo e''8 e''8^\segno e''8
          e''8^\coda e''8 e''8^\varcoda e''8
        << { r\breve } \\
           { e''8 e'' e'' e'' e'' e'' e'' e''
             \once \override Staff.Rest #'style = #'z r4
             r4 r2 } >>
        R1*70
        \arpeggioArrowUp <g c' e' g' c'' e'' g'' c'''>4 \arpeggio
          <d' g'\harmonic>4 \startTrillSpan
          a'4 \stopTrillSpan
          r4
        \repeat volta 3 {
          \set Score.repeatCommands = #'((volta "-1,+1"))
          a'4 b' c'' d''
          \set Score.repeatCommands = #'()
        }
        \alternative { {e''2 a'} {g'2 e'} }
        a'4 \breathe a'
          \override BreathingSign #'text = #(make-musicglyph-markup "scripts.rvarcomma") \breathe
          a'
          \override BreathingSign #'text = #(make-musicglyph-markup "scripts.lcomma") \breathe
          a'
        a'4
          \override BreathingSign #'text = #(make-musicglyph-markup "scripts.lvarcomma") \breathe
          a'
          \override BreathingSign #'text = #(make-musicglyph-markup "scripts.caesura.curved") \breathe
          a'
          \override BreathingSign #'text = #(make-musicglyph-markup "scripts.tickmark") \breathe
          a'
        \improvisationOn a'4 a' a' a' \improvisationOff
	\time 93/256
        f''8.\noBeam f''16.\noBeam f''32.\noBeam f''64.\noBeam f''128.\noBeam
	\time 4/4
	f''1
      }
      \new GrandStaff <<
        \new Staff {
          \override MultiMeasureRest #'expand-limit = 20
          \clef treble
          c''1
          r2^\fermata\sustainOn
          d''4\sustainOff
          \set Staff.pedalSustainStrings = #'("Pe" "d." "-")
          r8\sustainOn
          r16\sustainOff\sustainOn
          r32\sustainOff
          r64
          r128
          r\longa_\ouroborosA r\breve r1 r2
            \once \override Staff.Rest #'style = #'classical
          r4 r4 r1^\longfermata
          \clef bass
          a,8_\lheel a,_\ltoe a,_\staccato a,_\tenuto
            a,8_\portato a,_\marcato a,_\marcato aisis,_\staccatissimo
          e8^\prallmordent e e^\prallup e
            e^\upprall e e^\lineprall eisih^\snappizzicato
          e8^\accent e^\flageolet e^\open e^\reverseturn
            e^\stopped e^\thumb e^\trill eih^\turn
          e8^\slashturn e^\haydnturn e^\halfopen e
          e^\accpush e^\accpull e^\bayanbass e
          r1^\oldEE
          R1*70
          \arpeggioArrowDown <c, e, g, c e g c'>4 \arpeggio
          r4 r2
          \repeat volta 3 { a,4 \discant "10" b, \freeBass "1"
                            c \stdBass "Master" }
          \alternative { {e2 a,} {g2 e} }
          e4 e \override BreathingSign #'text = #(make-musicglyph-markup "scripts.caesura.straight") \breathe
          e
          \stemDown \acciaccatura d8 \stemNeutral e4
          e4 e^\arra e e^\arrb
          \improvisationOn a2 a \improvisationOff
	  \time 93/256
          r8. r16. r32. r64. r128.
	  \time 4/4
	  r1
        }
        \new Staff {
          \override MultiMeasureRest #'expand-limit = 20
          \clef bass
          c1
          c2_\fermata
          r4
          ges,8_\shortfermata \noBeam
          f,16_\henzelongfermata \noBeam
          e,32_\verylongfermata \noBeam
          g,64_\veryshortfermata\noBeam
          a,128_\henzeshortfermata\noBeam
          d\breve_\ouroborosB e\breve f\breve. g1 r1_\longfermata
          \clef alto
          e'8^\rheel e'^\rtoe e'^\staccato e'^\tenuto
            e'8^\portato e'^\flageolet e'^\marcato eeses'^\staccatissimo
          e'8^\downbow e'^\upbow e'^\prall e'
            e'^\mordent e' e'^\prallprall eeseh'
          e'8^\pralldown e' e'^\downprall e'
            e'^\upmordent e' e'^\downmordent eeh'
          << { r1 } \\ { e'8 e' e' e' e' e' e' e' } >>
          r1
          R1*70
          <c e g c' e' g' c''>4 \arpeggio
          r4 r2
          \repeat volta 3 { a4 b c' d' }
          \alternative { {e'2 a} {g2 e} }
          a4 a a \acciaccatura d8 a4
          a4 a^\arrc a a^\arrd
          \improvisationOn c'1 \improvisationOff
	  \time 93/256
          f8.\noBeam f16.\noBeam f32.\noBeam f64.\noBeam f128.\noBeam
	  \time 4/4
	  f1
        }
      >>
    >>
    \layout {}
  }
  \score {
    \new StaffGroup <<
      \new Staff { \clef "G_8" \fragA \fragB }
      \new TabStaff { \fragA \clef "tab" \fragB }
      \new DrumStaff {
        \drummode {
          bd4 sn8 bd8 r8 bd8 sn16 bd8.
          \stemUp cyms8 cyms8 \stemNeutral cyms4 cyms2 cyms1
          \clef "varpercussion"
          \stemUp cb8 cb8 \stemNeutral cb4 cb2 cb1
          \stemUp hh8 hh8 \stemNeutral hh4 hh2 hh1
          \stemUp hhho8 hhho8 \stemNeutral hhho4 hhho2
          \clef "percussion"
          \set DrumStaff.drumStyleTable = #testhalfopenvert
          hhho1
        }
      }
    >>
  }
  \score {
    <<
      \new Staff {
        \time 4/4
        \new Voice = "melody" {
          \clef "tenorG"
          c'1
          \clef "GG"
          c'2 c'
          \clef "tenorG"
          c'4 c' c' c'
          \clef "varC"
          c'1
        }
      }
      \new Lyrics {
        \lyricsto "melody" {
          a~b
          a~b c
          a~b~a~b c d e
          fooooo
        }
      }
    >>
  }
  \score {
    <<
      \new Staff {
        \time 4/4
        \clef "GG"
        c'1
        \bar "S"
        c'1

        \once \override Accidental.stencil = #ly:text-interface::print
        \once \override Accidental.text = #(make-musicglyph-markup "accidentals.flat.arrowdown")
        ces'!4
        \once \override Accidental.stencil = #ly:text-interface::print
        \once \override Accidental.text = #(make-musicglyph-markup "accidentals.flat.arrowboth")
        ces'!4
        \once \override Accidental.stencil = #ly:text-interface::print
        \once \override Accidental.text = #(make-musicglyph-markup "accidentals.flat.arrowup")
        ces'!4
        c'!4

        \once \override Accidental.stencil = #ly:text-interface::print
        \once \override Accidental.text = #(make-musicglyph-markup "accidentals.natural.arrowdown")
        c'!4
        \once \override Accidental.stencil = #ly:text-interface::print
        \once \override Accidental.text = #(make-musicglyph-markup "accidentals.natural.arrowboth")
        c'!4
        \once \override Accidental.stencil = #ly:text-interface::print
        \once \override Accidental.text = #(make-musicglyph-markup "accidentals.natural.arrowup")
        c'!4
        c'!4

        \once \override Accidental.stencil = #ly:text-interface::print
        \once \override Accidental.text = #(make-musicglyph-markup "accidentals.sharp.slashslashslash.stem")
        cis'!4
        \once \override Accidental.stencil = #ly:text-interface::print
        \once \override Accidental.text = #(make-musicglyph-markup "accidentals.sharp.slashslashslash.stemstem")
        cis'!4
        c'4
        c'4

        << { g'256 g'512 g'1024 } \\ { g256 g512 g1024 } >>
      }
      \new Staff {
        \time 4/4
        \clef "varC"
        c'1
        \bar "S"
        c'1
        \once \override Accidental.stencil = #ly:text-interface::print
        \once \override Accidental.text = #(make-musicglyph-markup "accidentals.sharp.arrowdown")
        cis'!4
        \once \override Accidental.stencil = #ly:text-interface::print
        \once \override Accidental.text = #(make-musicglyph-markup "accidentals.sharp.arrowboth")
        cis'!4
        \once \override Accidental.stencil = #ly:text-interface::print
        \once \override Accidental.text = #(make-musicglyph-markup "accidentals.sharp.arrowup")
        cis'!4
        c'!4

        \once \override Accidental.stencil = #ly:text-interface::print
        \once \override Accidental.text = #(make-musicglyph-markup "accidentals.flatflat.slash")
        ces'!4
        \once \override Accidental.stencil = #ly:text-interface::print
        \once \override Accidental.text = #(make-musicglyph-markup "accidentals.flat.slash")
        ces'!4
        \once \override Accidental.stencil = #ly:text-interface::print
        \once \override Accidental.text = #(make-musicglyph-markup "accidentals.flat.slashslash")
        ces'!4
        \once \override Accidental.stencil = #ly:text-interface::print
        \once \override Accidental.text = #(make-musicglyph-markup "accidentals.mirroredflat.backslash")
        ces'!4

        \once \override NoteHead.style = #'triangle
        g2
        \once \override NoteHead.style = #'harmonic-black
        g'4
        << { s4 } \\ {
          $(remove-grace-property 'Voice 'Stem 'direction)
          \acciaccatura { b8\stemDown }
          c'4
        } >>

        r256 r512 r1024
      }
    >>
  }
}

#!/usr/bin/env python3

# depends: Debian 'python3-fonttools' package

# Draws the LILC bounding box in red; the LILC attachment point as a
# green blob; the origin of the glyph's coordinate system as a blue
# blob.

import sys
import argparse
import subprocess
import io
from math import floor, ceil
from fontTools.ttLib import TTFont
from fontTools.pens.basePen import BasePen

class PSPen(BasePen):
    def __init__(self, fh):
        self.fh = fh
        self.bbox = (None, None, None, None)

    @staticmethod
    def minNone(x, y):
        return (y if x is None else x if y is None else min(x, y))
    @staticmethod
    def maxNone(x, y):
        return (y if x is None else x if y is None else max(x, y))

    def accumulateBbox(self, pt):
        self.bbox = (self.minNone(self.bbox[0], pt[0]),
                     self.minNone(self.bbox[1], pt[1]),
                     self.maxNone(self.bbox[2], pt[0]),
                     self.maxNone(self.bbox[3], pt[1]))

    def writeCommand(self, pts, cmd):
        for pt in pts:
            self.fh.write("{:.17g} {:.17g} ".format(pt[0], pt[1]))
            self.accumulateBbox(pt)
        self.fh.write(cmd + "\n")

    def _moveTo(self, p):
        self.writeCommand([p], "moveto")
    def _lineTo(self, p):
        self.writeCommand([p], "lineto")
    def _curveToOne(self, c0, c1, p):
        self.writeCommand([c0, c1, p], "curveto")
    def _closePath(self):
        self.writeCommand([], "closepath")

def run_guile(string):
    return subprocess.check_output(["guile", "-c", string]).decode('ASCII')

def main():
    opener = lambda mode: lambda fname: lambda: argparse.FileType(mode)(fname)
    parser = argparse.ArgumentParser(
        description='Preview a glyph from a Lilypond OTF music font.')
    parser.add_argument("fontfile", help="Pathname of an OTF font file.")
    parser.add_argument("glyphname", help="Name of the glyph to extract.")
    parser.add_argument("-o", "--output", help="Output EPS file.",
                        type=opener("w"), default=opener("w")("-"))
    args = parser.parse_args()

    font = TTFont(args.fontfile)

    LILY = font.getTableData("LILY").decode('ascii')
    LILC = font.getTableData("LILC").decode('ascii')

    try:
        out = run_guile(r'''
(let ((data '({LILY})))
    (display (cdr (assoc 'staffsize data)))
    (display "\n"))
'''.format(LILY=LILY))
    except subprocess.CalledProcessError:
        sys.exit("Couldn't get staffsize of font '{}'".format(args.fontfile))

    size = float(out.rstrip("\n"))

    try:
        out = run_guile(r'''
(let ((data (cdr (assoc '{glyphname} '({LILC})))))
    (display (cdr (assoc 'bbox data)))
    (display "\n")
    (display (cdr (assoc 'attachment data)))
    (display "\n"))
'''.format(glyphname=args.glyphname, LILC=LILC))
    except subprocess.CalledProcessError:
        sys.exit("Couldn't get details for glyph '{}' in font '{}'".format(
            args.glyphname, args.fontfile))

    outlinefh = io.StringIO()
    glyph = font.getGlyphSet()[args.glyphname]
    pen = PSPen(outlinefh)
    glyph.draw(pen)
    outline = outlinefh.getvalue().rstrip("\n")

    bboxline, attachline = [line.strip("(").rstrip(")").split(" ")
                            for line in out.splitlines()]
    bbox = tuple(map(float, bboxline))

    attach = (float(attachline[0]), float(attachline[2]))

    scale = 1000 / size

    bx0, by0, bx1, by1 = [scale * v for v in bbox]
    pen.accumulateBbox((bx0, by0))
    pen.accumulateBbox((bx1, by1))
    ax, ay = [scale * v for v in attach]
    pen.accumulateBbox((ax, ay))

    xmin = int(floor(min(pen.bbox[0], 0))) - 100
    xmax = int(ceil (max(pen.bbox[2], 0))) + 100
    ymin = int(floor(min(pen.bbox[1], 0))) - 100
    ymax = int(ceil (max(pen.bbox[3], 0))) + 100

    with args.output() as fh:
        print("""\
%!PS-Adobe-3.0
%%Pages: 1
%%BoundingBox: {xmin} {ymin} {xmax} {ymax}
%%EndComments
%%BeginProlog
%%EndProlog
%%BeginSetup
%%EndSetup
%%Page: 1 1
{outline}
0 setgray fill
newpath
   {bx0} {by0} moveto {bx0} {by1} lineto
   {bx1} {by1} lineto {bx1} {by0} lineto
closepath 0.1 setlinewidth 1 0 0 setrgbcolor stroke
newpath
  {ax} {ay} 10 0 360 arc
0 .7 0 setrgbcolor fill
newpath
  0 0 7 0 360 arc
0 .3 1 setrgbcolor fill
showpage
%%Trailer
%%EOF""".format(**locals()), file=fh)

if __name__ == '__main__':
    main()

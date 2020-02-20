%{

/*
 * Post-filter for Fontforge's SVG font file output, which removes
 * scientific notation in glyph path strings. That is, a tag of the
 * form <glyph d="xxxx">, where the xxxx includes decimal literal in
 * exponential notation such as '9.8e-5', will be rewritten so that
 * all those literals are written without an 'e', e.g. '0.000098'.
 *
 * This works around a bug in many versions of Lilypond in which
 * glyphs are extracted from SVG font files using a regex that doesn't
 * recognise a path string if it contains the letter 'e'. To avoid
 * perturbing any other detail of that regex-based parser, I use a
 * flex-based rewriter to change the input file as little as possible,
 * rather than the more obvious technique of slurping the whole file
 * into a full XML implementation like Python xml.etree.ElementTree.
 *
 * https://sourceforge.net/p/testlilyissues/issues/5779/
 */

#define PASSTHROUGH fputs(yytext, stdout)
static void unscientific(const char *text, FILE *fp);
%}

%option noyywrap
%x glyph attr d

%%

\<glyph                                 PASSTHROUGH; BEGIN(glyph);

<glyph>d=\"                             PASSTHROUGH; BEGIN(d);

<glyph>\"                               PASSTHROUGH; BEGIN(attr);
<attr>\"                                PASSTHROUGH; BEGIN(glyph);

<d>\"                                   PASSTHROUGH; BEGIN(glyph);
<d>[0-9]*(\.[0-9]*)?[eE][-+]?[0-9]+     unscientific(yytext, stdout);

<glyph>\>                               PASSTHROUGH; BEGIN(INITIAL);

.                                       PASSTHROUGH;

%%

#include <assert.h>
#include <ctype.h>
#include <stdbool.h>

#include <err.h>

static void unscientific(const char *text, FILE *fp)
{
    /*
     * Given a scientific-notation decimal literal in 'text', write a
     * non-exponential version of it to 'fp'.
     *
     * This can be done as a purely textual transformation: there's no
     * need to do a round-trip conversion to an actual float and
     * potentially change the value. We parse the input into a string
     * of digits; an indication of where the decimal point appears in
     * that string (which might be any gap between characters,
     * including the very start or end); and the exponent, which we
     * use to adjust the decimal point location for output. Leading
     * and trailing zero digits can be removed from the string if
     * present, and then we reinsert leading and trailing zeroes in
     * order to get the output location of the decimal point to be
     * within the string.
     */

    int nleading0 = 0, ntrailing0 = 0, nbeforepoint = 0, ndigits = 0;
    bool seen_point = false;
    const char *first_nonzero = NULL;

    /*
     * Step along the mantissa part of the string, counting the total
     * number of digits, the number of them that appear before the
     * point, and the number of leading and trailing 0. Also retain a
     * pointer to the first nonzero digit, which we'll start from
     * during the output loop below.
     */
    const char *p = text;
    for (;; p++) {
        if (*p == '.') {
            seen_point = true;
        } else if (isdigit((unsigned char)*p)) {
            ndigits++;
            if (!seen_point)
                nbeforepoint++;

            if (*p == '0') {
                if (!first_nonzero)
                    nleading0++;
                else
                    ntrailing0++;
            } else {
                if (!first_nonzero)
                    first_nonzero = p;
                ntrailing0 = 0;
            }
        } else {
            break;
        }
    }

    /*
     * Now we expect to be looking at the exponent. Parse it.
     */
    assert(*p == 'e' || *p == 'E');
    p++;
    int exponent = atoi(p);

    /*
     * Work out the positions, relative to the output decimal point,
     * where the digits we emit from the input string will start and
     * finish.
     */
    int textstart = exponent + nbeforepoint - nleading0;
    int textend = exponent - (ndigits - nbeforepoint) + ntrailing0;
    if (textstart == textend) {
        /* No nonzero digits at all, so reset positions to the decimal
         * point. That way we always emit 0 as "0", even if it was
         * given on input in some form like 0.0000e+20 or 0e-20. */
        textstart = textend = 0;
    }

    /*
     * Work out the positions, relative to the output decimal point,
     * where the digits we emit _at all_ will start and finish.
     */
    int startpos = textstart > 1 ? textstart : 1;
    int endpos = textend < 0 ? textend : 0;

    /*
     * Now emit all our digits, from startpos to endpos. When our
     * current position is between textstart and textend, we consume a
     * digit from the input string; when it's not, we emit a zero.
     */
    p = first_nonzero;
    for (int pos = startpos; pos > endpos; pos--) {
        char digit = '0';
        if (textstart >= pos && pos > textend) {
            digit = *p++;
            if (digit == '.')
                digit = *p++;
            assert(digit);
            assert(isdigit((unsigned char)digit));
        }

        /* The output decimal point is emitted together with the first
         * digit that follows it. That means we omit it if the units
         * digit is the lowest one we emit (i.e. if the output is an
         * integer). */
        if (pos == 0)
            fputc('.', fp);
        fputc(digit, fp);
    }
}

int main(int argc, char **argv)
{
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin)
            err(1, "%s: open", argv[1]);
    }
    while (yylex());
    return 0;
}

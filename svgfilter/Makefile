check: test.expected test.output
	cmp $^

test.output: test.input svgfilter
	./svgfilter < $< > $@

svgfilter: lex.yy.c
	gcc -g -O0 -o $@ $^

lex.yy.c: svgfilter.l
	flex $<

clean:
	rm -f svgfilter lex.yy.c test.output

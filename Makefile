IMGS = $(patsubst src/%,img/%,$(patsubst %.gv,%.png,$(wildcard src/*.gv)))
all: $(IMGS)

img/%.png : src/%.gv
	dot -Tpng -o $@ $<
	-git status img

.PHONY: toc

toc: ./README.md
	./gh-md-toc $<


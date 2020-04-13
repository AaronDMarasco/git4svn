IMGS = $(patsubst src/%,img/%,$(patsubst %.gv,%.png,$(wildcard src/*.gv)))

all: $(IMGS)
	-git status img

img/%.png : src/%.gv
	dot -Tpng -o $@ $<

.PHONY: all toc

toc: ./README.md
	./gh-md-toc $<


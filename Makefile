DIAGRAMS = docs/diagrams/er.png docs/diagrams/architecture.png docs/diagrams/backup.png docs/diagrams/scaling.png
PDF = docs/ADMBD_groupXX_it1.pdf

all: $(PDF)

docs/diagrams/%.png: docs/diagrams/%.dot
	dot -Tpng -Gdpi=170 $< -o $@

$(PDF): docs/report.md $(DIAGRAMS)
	cd docs && pandoc report.md -o $(notdir $(PDF)) --pdf-engine=xelatex \
	  --toc --number-sections -V geometry:margin=2.2cm -V fontsize=10pt \
	  -V mainfont="Arial Unicode MS" -V colorlinks=true -V linkcolor=blue

clean:
	rm -f $(DIAGRAMS) $(PDF)

.PHONY: all clean

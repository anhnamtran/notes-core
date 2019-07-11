ifndef PREFIX
	PREFIX=/usr/bin
endif

RM=rm -rf

NOTES=$(shell find "notes.d" -type f -name "*.tex" | sort)

JOB_NAME=notes
OUT_FILE=out/$(JOB_NAME).pdf

LATEX_MK=latexmk -jobname=$(JOB_NAME)

.PHONY: all clean
all: $(OUT_FILE)
notes: $(OUT_FILE)				## Compiles and creates the PDF file in out/.
$(OUT_FILE): main.tex
	$(LATEX_MK) $<

.PHONY: main.tex
main.tex: $(NOTES)
	./notes_main $^

.PHONY: public private check-privacy
public:			## Hide private contents in the generated notes file.
	sed -i 's/^\(\\privatetrue\)/%\1/g' notes.sty

private:		## Show private contents in the generated notes file.
	sed -i 's/^%\(\\privatetrue\)/\1/g' notes.sty

check-privacy:		## Checks whether the generated notes file can be distributed safely.
	@if grep '^\\privatetrue' "notes.sty" > /dev/null; then \
		echo -e "\033[0;31mNotes currently displaying private sections.\033[0m" ; \
	else \
		echo -e "\033[0;32mNotes currently hiding private sections.\033[0m" ; \
	fi

clean:	## Removes all generated files.
	$(RM) out/
	$(RM) main.tex

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

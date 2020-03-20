sources := $(wildcard *.tex)
targets := $(sources:.tex=.pdf)
RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
# .SILENT: clean
all: $(targets)
clean: 
	@for arg in $(RUN_ARGS); do \
		for i in $$(ls $$arg/ | egrep --color=never $$arg'\.(aux|bbl|blg|fdb_latexmk|fls|log|out|upa|upb)'); do \
			echo "[STATUS] removing $$arg/$$i"; \
			rm $$arg/$$i; \
		done \
	done
# do not forget to link figures in from images to the draft folder
%.pdf: %.tex
	$(eval where := $(patsubst %.pdf,%,$@))
	@echo "[STATUS] preparing $@ from $<"
	latexmk -bibtex -pdf $<
	$(eval HISTORY_FILE := $(patsubst %.tex,%.history.tex,$<))
	mkdir -p ./history
	make ./history/$(patsubst %.tex,%.history.tex,$<)
# save changes
./history/%.history.tex: %.tex
	@echo "[STATUS] saving to $@"
	python ./code/convert_latex_history.py $< $@
	@git ls-files --error-unmatch $@ 2> /dev/null; EXIT_CODE=$$?; \
	if [[ $$EXIT_CODE -ne 0 ]]; then \
		echo "[STATUS] adding new file $@"; \
		git add $@; \
		git commit -m "added file $$(date +%Y.%m.%d.%H%M%S)"; \
		echo "[STATUS] adding new file ... done"; \
	else \
		git diff --exit-code $@; EXIT_CODE=$$?; \
		if [[ $$EXIT_CODE -ne 0 ]]; then \
			echo "[STATUS] found changes to the history"; \
			git add $@; \
			git commit -m "updates $$(date +%Y.%m.%d.%H%M%S)"; \
		else echo "[STATUS] no changes to the history"; \
		fi; \
	fi

.PHONY: all
SHELL := /bin/bash

FILES := a.txt b.txt c.txt d.txt
all: $(FILES) merged.txt 3.txt

%.txt:
	@echo "Generating: $@"
	sleep 5
	echo $(basename $@) > $@

merged.txt: $(FILES)
	cat $^ | sort > $@

1.txt: job1.sh
	qsub $<

2.txt: job2.sh 1.txt
	qsub -hold_jid job1 $<

3.txt: job3.sh 2.txt
	qsub -hold_jid job2 $<

clean:
	rm -rf *.txt *.log

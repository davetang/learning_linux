.DELETE_ON_ERROR:
.PHONY: all

all: output2.txt

output1.txt:
	touch $@

output2.txt: output1.txt
	touch $@
	sleep 10
	touch $@

clean:
	rm -f output1.txt output2.txt

# README

Make has a special target `.DELETE_ON_ERROR:` that deletes targets if their recipe fails. To test it out, type `make` and then <control+c> right after you typed `make`.

```console
make
```
```
touch output1.txt
touch output2.txt
sleep 10
^Cmake: *** Deleting file 'output2.txt'
make: *** [Makefile:11: output2.txt] Interrupt
```

#!/usr/bin/env bash

>&2 printf "Not verbose\n"
make

>&2 printf "\nVerbose (command is also shown)\n"
make VERBOSE=1

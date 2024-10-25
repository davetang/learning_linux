#!/usr/bin/env bash

>&2 echo No debug
make

>&2 echo With debug
make DEBUG=1

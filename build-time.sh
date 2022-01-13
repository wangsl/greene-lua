#!/bin/bash

gcc -shared -fPIC -o time.so time.c -llua


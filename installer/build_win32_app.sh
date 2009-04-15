#!/bin/sh
rm -f ./npsnetsetup.exe
lmk -m opt -b
../../../depend/InnoSetup5/ISCC.exe npsnet.iss

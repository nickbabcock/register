#!/bin/bash

set -euo pipefail

# Download the saxon xquery java library and unzip it to the saxon directory
curl -L "https://sourceforge.net/projects/saxon/files/latest/download" > saxon9he.zip
unzip -d saxon saxon9he.zip
rm saxon9he.zip

# Store all the register data under the 'data' directory
mkdir -p data
for i in {2005..2016}; do
    if [[ ! -e FR-$i.zip ]]; then
        curl -O -L "https://www.gpo.gov/fdsys/bulkdata/FR/$i/FR-$i.zip"
    fi;
    unzip -d data FR-$i.zip
done;



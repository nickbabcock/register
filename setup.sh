#!/bin/bash

set -euo pipefail

# Download the saxon xquery java library and unzip it to the saxon directory
curl -L "https://downloads.sourceforge.net/project/saxon/Saxon-HE/9.8/SaxonHE9-8-0-5J.zip?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fsaxon%2Ffiles%2FSaxon-HE%2F9.8%2F&ts=1508275190&use_mirror=superb-sea2" > saxonhe-9.8.zip
unzip -d saxon saxonhe-9.8.zip

# Store all the register data under the 'data' directory
mkdir -p data
for i in {2005..2016}; do
    if [[ ! -e FR-$i.zip ]]; then
        curl -O -L "https://www.gpo.gov/fdsys/bulkdata/FR/$i/FR-$i.zip"
    fi;
    unzip -d data FR-$i.zip
done;


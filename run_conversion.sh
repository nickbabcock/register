#!/bin/bash

require_command () {
    if ! type "$1" &> /dev/null; then
        echo "I require $1 to be installed. Aborting"
        exit 1
    fi
}

require_command "java"
require_command "python3"

if [[ ! -e saxon/saxon9he.jar ]]; then
    echo "I require the saxon library to be installed, please see the setup script";
    exit 1;
fi

echo "$(date): starting federal register conversion process"
OUT="output-$(date +"%Y.%m.%d").csv"
java -cp saxon/saxon9he.jar net.sf.saxon.Query -dtd:off -q:"transform.xql" '!method=text' | python3 to_csv.py > "$OUT"
echo "$(date): Files combined, please see $OUT"

#!/bin/bash

TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

# If the JAVA_EXC variable is not already set (eg. someone wants to use drip
# over java, let the default be the regular java executable
: ${JAVA_EXC:=java}

require_command () {
	type "$1" &> /dev/null
    if [[ ! $? -eq 0 ]]; then
        echo "I require $1 to be installed. Aborting"
        exit 1
    fi
}

require_command "${JAVA_EXC}"
require_command "python3"
require_command "xsv"

if [[ ! -e saxon/saxon9he.jar ]]; then
    echo "I require the saxon library to be installed, please see the setup script";
    exit 1;
fi

set -euo pipefail

convert_file() {
    f="$1"
    fn="$(basename "$f" .xml).csv"
    echo "$(date): '$f' '$fn'"
    "${JAVA_EXC}" -cp saxon/saxon9he.jar net.sf.saxon.Query -s:"$1" -dtd:off -q:"transform.xql" '!method=json' | \
        ./to_csv.py > $TMP_DIR/$fn
}

export -f convert_file
export TMP_DIR
find data -iname "*.xml" -print0 | xargs -P4 -0 -I{} -n1 bash -c 'convert_file {}'
echo "$(date): Now combining all files"
xsv cat rows $TMP_DIR/* > output.csv
echo "$(date): Files combined, please see output.csv"

#!/bin/bash
set -euo pipefail

TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

convert_file() {
    f="$1"
    fn=$(basename "$f")
    echo "$(date): $f"
    java -cp saxon/saxon9he.jar net.sf.saxon.Query -s:"$1" -dtd:off -q:"transform.xql" '!method=json' | \
        python3 to_csv.py > $TMP_DIR/$fn
}

export -f convert_file
export TMP_DIR
find data -iname "*.xml" -print0 | xargs -0 -I{} -n1 bash -c 'convert_file {}'
echo "$(date): Now combining all files"
xsv cat rows $TMP_DIR/* > output.csv
echo "$(date): Files combined, please see output.csv"

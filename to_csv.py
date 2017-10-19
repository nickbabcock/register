#!/usr/bin/env python3
# This script ingests json formatted by `transform.xql` and outputs a csv.
# Execute this script under python3 as the federal register contains unicode
# data and python 3's csv writer supports unicode data.
import json
import csv
import sys

# Turn presidents json into csv
def presidents(pres):
    return ['presidential', 'presidential', pres['title'], 'the president', None, pres['docket']]

# Turn the other document types from json into csv
def rules(r, name):
    if any(map(lambda s: ';' in s, r['names'])):
        raise Exception("Can't semicolon list")

    # Some rins are written as RIN 1625-AA08; AA00 and need to be split apart
    rin = ';'.join([i for sl in r['rin'] for i in sl.split('; ')])
    return [name, r['agency'], r['subject'], ';'.join(r['names']), rin, r['docket']]

data = json.load(sys.stdin)
dt = data['date']
writer = csv.writer(sys.stdout)
writer.writerow(['date', 'type', 'agency', 'subject', 'names', 'rin', 'docket'])
writer.writerows(map(lambda p: [dt] + presidents(p), data['presidentials']))
writer.writerows(map(lambda r: [dt] + rules(r, "rule"), data['rules']))
writer.writerows(map(lambda r: [dt] + rules(r, "proposed-rule"), data['proposed-rules']))
writer.writerows(map(lambda r: [dt] + rules(r, "notice"), data['notices']))

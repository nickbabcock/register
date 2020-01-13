#!/usr/bin/env python3
# This script ingests json formatted by `transform.xql` and outputs a csv.
# Execute this script under python3 as the federal register contains unicode
# data and python 3's csv writer supports unicode data.
import json
import csv
import sys
import fileinput
import datetime

# Turn presidents json into csv
def presidents(pres):
    return ['presidential', 'presidential', None, pres['title'], 'the president', None, pres['docket']]

# Turn the other document types from json into csv
def rules(r, name):
    if any(map(lambda s: ';' in s, r['names'])):
        raise Exception("Can't semicolon list")

    # Some rins are written as RIN 1625-AA08; AA00 and need to be split apart
    rin = ';'.join([i for sl in r['rin'] for i in sl.split('; ')])
    return [name, r['agency'], r['sub_agency'], r['subject'], ';'.join(r['names']), rin, r['docket']]

last_date = datetime.date.min
writer = csv.writer(sys.stdout)
writer.writerow(['date', 'type', 'agency', 'sub agency', 'subject', 'names', 'rin', 'docket'])
for line in fileinput.input():
    data = json.loads(line)
    dt = data['date']
    processing_date = datetime.datetime.strptime(dt, "%Y-%m-%d")
    pd = processing_date.date()
    if pd - last_date > datetime.timedelta(days=30) or pd.month != last_date.month:
        print("processing {}-{}".format(pd.year, pd.month), file=sys.stderr)
        last_date = pd

    writer.writerows(map(lambda p: [dt] + presidents(p), data['presidentials']))
    writer.writerows(map(lambda r: [dt] + rules(r, "rule"), data['rules']))
    writer.writerows(map(lambda r: [dt] + rules(r, "proposed-rule"), data['proposed-rules']))
    writer.writerows(map(lambda r: [dt] + rules(r, "notice"), data['notices']))

import json
import csv
import sys

# Turn presidents json into csv
def presidents(pres):
    return ['presidential', 'presidential', pres['title'], 'the president', None]

# Turn the other document types from json into csv
def rules(r, name):
    if any(map(lambda s: ';' in s, r['names'])):
        raise Exception("Can't semicolon list")
    return [name, r['agency'], r['subject'], ';'.join(r['names']), r['rin']]

data = json.load(sys.stdin)
dt = data['date']
writer = csv.writer(sys.stdout)
writer.writerow(['date', 'type', 'agency', 'subject', 'names', 'rin'])
writer.writerows(map(lambda p: [dt] + presidents(p), data['presidentials']))
writer.writerows(map(lambda r: [dt] + rules(r, "rule"), data['rules']))
writer.writerows(map(lambda r: [dt] + rules(r, "proposed-rule"), data['proposed-rules']))
writer.writerows(map(lambda r: [dt] + rules(r, "notice"), data['notices']))

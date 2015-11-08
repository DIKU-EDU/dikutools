#!/usr/bin/env python3

# Prerequisites:
# * python3 (it's about time!)
# * beautifulsoup4 (install it using pip3)

# Usage: %s <n_people> <block> <weekday> <start> <end>
#
# For instance:
#
# $ ./findrooms.py 18 2 wednesday 13:00 15:00

BUILDINGS = [
  "Datalogisk Institut",
  "HCØ",
  "August Krogh",
  "Biocenter",
  "Rockefeller",
  "Ifi - Institut for Idræt, Nørre Allé"
]

STUDY_YEAR = "1516"

JS_PATH = r"https://skema.ku.dk/ku" + STUDY_YEAR + r"/js/filter.js"

REPORT_PATH = r"https://skema.ku.dk/KU" + STUDY_YEAR + r"/reporting/textspreadsheet?objectclass=location&idtype=id&identifier=%s&t=SWSCUST2+location+textspreadsheet&days=%s&weeks=%s&periods=5-52&template=SWSCUST2+location+textspreadsheet"

import sys, re, time
import urllib.request

from bs4 import BeautifulSoup

#### Helper functions

def toTime(timestr):
  return time.strptime(timestr, "%H:%M")

def findBigEnoughRoomsIn(building, n_people, rooms, ids):

  ROOMS_RE = re.compile(
    r"roomarray\[\d+\] \[0\] = \"((?:øv|aud) .*?\((\d+)\))\";\s+" +
    r"roomarray\[\d+\] \[1\] = \"\d+\s*-?\s*" + building + r"\";\s+" +
    r"roomarray\[\d+\] \[2\] = \"(.*?)\"",
    re.MULTILINE | re.IGNORECASE)

  for match in ROOMS_RE.finditer(js):
    room = match.group(1)
    capacity = int(match.group(2))
    if capacity < n_people:
      continue
    rooms.append(room)
    ids.append(match.group(3))

def findBigEnoughRooms(n_people):

  rooms = []
  ids = []

  for building in BUILDINGS:
    findBigEnoughRoomsIn(building, n_people, rooms, ids)

  return rooms, ids

def findWeeks(block):
  WEEKS_RE = re.compile(
    r"AddWeeks\(\"(.*?)\",\".*NAT Blok " + str(block) + r" - 7 uger .*\"")

  match = WEEKS_RE.search(js)

  return match.group(1)

def getWeekdayIndex(weekday):
  if weekday == "mandag" or weekday == "monday":
    return 1
  elif weekday == "tirsdag" or weekday == "tuesday":
    return 2
  elif weekday == "onsdag" or weekday == "wednesday":
    return 3
  elif weekday == "torsdag" or weekday == "thursday":
    return 4
  elif weekday == "fredag" or weekday == "friday":
    return 5
  else:
    raise Exception("Invalid weekday.")

def checkRoom(table):

# Cases:
# start end o_start o_end <- room is available
# o_start o_end start end <- continue
# start o_start end o_end
# start o_start o_end end
# o_start start o_end end

  for row in table.select("tr")[1:]:
    o_start = toTime(row.select("td")[3].text)
    o_end = toTime(row.select("td")[4].text)
    if end <= o_start:
      return True
    if o_end <= start:
      continue
    else:
      return False # There's an overlay.
  return True

#### Main

if len(sys.argv) < 6:
  print("Usage: %s <n_people> <block> <weekday> <start> <end>" % sys.argv[0])
  exit(2)

n_people = int(sys.argv[1])
block = int(sys.argv[2])
weekday = sys.argv[3].lower()
start = toTime(sys.argv[4])
end = toTime(sys.argv[5])

with urllib.request.urlopen(JS_PATH) as resource:
  js = resource.read().decode(resource.headers.get_content_charset())

rooms, ids = findBigEnoughRooms(n_people)

ids = "&identifier=".join(ids)
weekday = getWeekdayIndex(weekday)
weeks = findWeeks(block)

report_url = REPORT_PATH % (ids, weekday, weeks)

with urllib.request.urlopen(report_url) as resource:
  html = resource.read().decode(resource.headers.get_content_charset())

soup = BeautifulSoup(html, 'html.parser')
tables = soup.select(".spreadsheet")

# The following loop depends on two crucial assumptions about the report
# produced by skema.ku.dk: (1) rooms appear in the order given by the
# identifier list, and (2) the occupation slots for each room appear in
# chronological order.

for i, table in enumerate(tables):
  if checkRoom(table):
    print(rooms[i])

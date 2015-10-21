#!/usr/bin/env python3

# 1. Download the Assignment report HTML page(s).
# 2. Call this script, specifying the keyword and threshold (how many times the
#    keyword should occur for a student)

# Prerequisites:
# * python3 (it's about time!)
# * beautifulsoup4 (install it using pip3)

import sys

if len(sys.argv) != 4:
  print("Usage: " + sys.argv[0] +
    " <keyword> <threshold> <Assignment report.html>")
  exit(2)

keyword = str(sys.argv[1])
threshold = int(sys.argv[2])
report = sys.argv[3]

from bs4 import BeautifulSoup

html = open(report).read()
soup = BeautifulSoup(html, 'html.parser')

table = soup.select("#assignments-table")[0]

for row in table.find_all('tr')[1:]:
  cells = row.find_all('td')
  name = cells[0].a.span.text
  mail = cells[1].span.text
  accepted = 0
  for assignment in cells[2:]:
    if (keyword in assignment.span.span.text):
      accepted += 1
  if accepted >= threshold:
    print(name + " <" + mail + "@alumni.ku.dk>")

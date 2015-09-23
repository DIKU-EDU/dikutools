#!/usr/bin/env python3

# 1. Download the HTML Assignment report(s).
# 2. Call this script, specifying the threshold for acceptance.
#    a. Modify the keyword below if necessary.

# Prerequisites:
# * python3 (it's about time!)
# * beautifulsoup4 (install it using pip)

import sys

keyword = "Tilfredsstillende"

if len(sys.argv) < 3:
  print("Usage: " + sys.argv[0] + " <threshold> <Assignment report.html>")
  exit(2)

threshold = int(sys.argv[1])
report = sys.argv[2]

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

#!/usr/bin/env python3

# Uploads the given uniquely named file to Google Drive.
#
# Useful if sharing e.g. exam-number-named files via Google Drive with the
# external examiners. That is, if you feel resentful of automatic sync.
#
# Usage: ./upload.py <very-good-student.txt>
#
# Requires: PyDrive (sudo pip3 install pydrive)
#
# You will also need some credentials:
#   https://pythonhosted.org/PyDrive/quickstart.html#authentication

import sys, os.path, time

def timeString(timeObj):
  return time.strftime("%Y-%m-%dT%H:%M:%S", timeObj)

import sys, os.path, datetime

def main(filepath):
  basename = os.path.basename(filepath)
  print(basename)

  from pydrive.auth import GoogleAuth
  from pydrive.drive import GoogleDrive

  gauth = GoogleAuth()
  gauth.LocalWebserverAuth()

  drive = GoogleDrive(gauth)

  gfiles = drive.ListFile({'q':
      "title = '%s' and trashed=false" % basename
    }).GetList()
  if len(gfiles) > 1:
    print("There's more than one file called %s" % basename)
    sys.exit(1)

  gfile = gfiles[0]

  gmod = gfile['modifiedDate']

  if (gmod[-1] != "Z"):
    print("Receieved unsupported datetime from Google")
    sys.exit(1)
  gmod = time.strptime(gmod[:-1], "%Y-%m-%dT%H:%M:%S.%f")

  localmod = time.gmtime(os.path.getmtime(filepath))
  if localmod < gmod:
    print("Modification times are off..")
    print("  Local:  " + timeString(localmod))
    print("  Google: " + timeString(gmod))
    print("Covardly refusing to solve the causality problem.")
    print("Check if file hasn't been updated on Google.")
    sys.exit(1)

  gfile.SetContentFile(filepath)
  gfile.Upload()

  return gfile

if __name__ == "__main__":
  main(sys.argv[1])

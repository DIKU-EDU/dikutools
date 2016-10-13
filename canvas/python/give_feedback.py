#!/usr/bin/env python3

import os, os.path, sys, yaml

from canvas import Canvas

def _check_canvas_yaml_path(path):
  if not os.path.isfile(path):
    print("\"{}\" doesn't look like a path to a Canvas YAML file.".format(
      path))
    sys.exit(1)
  return path

def _get_assignment_id(arg):
  try:
    assignment_id = int(arg)
  except ValueError:
    print("\"{}\" doesn't look like an assignment id.")
    sys.exit(1)
  return assignment_id

def _check_subdir(subdir):
  if not os.path.isdir(subdir):
    _exit_badpath()
  return subdir

def _exit_badpath():
  print("Please give a path to a directory containing a student submission.")
  sys.exit(1)

def _find_student_id(subdir):
  for filename in os.listdir(subdir):
    if filename.count("_") >= 3:
      filename = filename.replace("_late_", "_")
      parts = filename.split("_")
      return int(parts[1])

  print("Can't find student id in \"{}\".".format(subdir))
  exit_badpath()

def _check_grade(grade):
  goodgrades = ["pass", "fail", "complete", "incomplete"]
  if not grade in goodgrades:
    try:
      x = int(grade)
    except ValueError:
      print("\"{}\" is a bad grade. Acceptable grades are: {}.".format(
        grade, ", ".join(goodgrades)))
      sys.exit(1)
  return grade

def _check_filepaths(filepaths):
  for filepath in filepaths:
    if not os.path.isfile(filepath):
      print("\"{}\" is not a file. What is this?".format(filepath))
      sys.exit(1)
  return filepaths

def get_assignment():
  with open(os.path.join("..", "canvas.yaml"), "r") as f:
    conf = yaml.load(f)
  assignment_id = conf['assignment_id']

  with open(os.path.join("..", "..", "canvas.yaml"), "r") as f:
    conf = yaml.load(f)
  course_id = conf['course_id']

  with open(os.path.join("..", "..", "token"), "r") as f:
    api_token = f.read().strip()

  assignment = Canvas(api_token).course(
    id = course_id).assignment(
      id = assignment_id)
  return assignment

def subdir_feedback(assignment, subdir, grade, filepaths):
  subdir = _check_subdir(subdir)
  grade = _check_grade(grade)
  filepaths = _check_filepaths(filepaths)

  student_id = _find_student_id(subdir)
  assignment.give_feedback(student_id, grade, filepaths)

def main():
  assignment = get_assignment()
  subdir_feedback(assignment, os.getcwd(), sys.argv[1], sys.argv[2:])

if __name__ == "__main__":
  main()

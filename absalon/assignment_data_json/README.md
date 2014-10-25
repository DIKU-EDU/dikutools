# Extract assignment information to JSON

Gathers information on students' assignments into one big JSON file. Allows
for easier analysis of how many points students have and such.

## Dependencies 

Requires a recent version of `perl`.

To install the required modules, run:

    cpan -i utf8::all DateTime HTML::Query Data::Dumper List::Util \
            syntax Syntax::Feature::Junction IO::All FindBin JSON \
            WWW::Mechanize

## Configuration

You need to create a file named `.absalon_credentials` in the same folder
as the script. Inside of that, put the credentials you have for logging
on to http://absalon.itslearning.com, in the format of:

    username:password

In the top of the file are 4 constants:

* `SITE` specifies the URL of the site to extract data from.
* `COURSE` specifies (part of) the course name. It is used for finding which course to extract data for, so it needs to be enough to uniquely identify it from the courses in your list.
* `OUTFILE` specfies the filename to output the data to.
* `GROUPRX` specfies a regex that is used for extracting the groups of the participants.

## Usage

Simply run `./assignment_data_json.pl` to create the JSON file.

If you wish to run the program in a cron job, you'll probably want to use the `-quiet` flag: `./assignment_data_json.pl -quiet`.

## Data format

The resulting JSON file consists of a dictionary containing the following
entries:

* `assignments`, a dictionary of assignment names mapped to information about that assignment.
* `students`, a list of all the students on the course with information about their assignments.
* `time`, the timestamp for when the dump was performed.

Each student contains:

* `assignments`, a dictionary of assignment names mapped to information about submission status and assessment.
* `group`, the group the student belongs to, as captured by the regex in `GROUPRX`.
* `Name`, the full name of the student.
* `Username`, the KU username of the student.

## Common problems

Make sure your Absalon interface language is set to English.

Make sure there are no filters set on the list of course participants, and
on the assignment report.

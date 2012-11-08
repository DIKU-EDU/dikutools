# Download assignments

Automated download of assignments from Absalon.

Use this if batch-downloading from the web interface breaks (the reason this script was made),
or is otherwise broken.

## Installation

Requires a recent version of `perl`.

To install required modules, run:

    cpan -i WWW::Mechanize Data::Dumper Try::Tiny URI::Escape \
            HTML::Query Text::Unidecode

## Usage

Before using, edit `download_assignments.pl`, and correct the variables in the
top of the script.

Then simply run `./download_assignments.pl`.

## Known limitations

* Does not handle multiple pages of assignments.
* Does not allow you to specify a filter; always uses whichever filter is
  currently set.

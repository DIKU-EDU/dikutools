# setup_printers.pl

## Abstract
Sets up the printers in UP-1 for printing using cups.

* UP1-2-0-02 is set up as m1b.
* UP1-2-0-02-b is set up as n2d.

## Instructions

Note, this script is only expected to work on Debian/Ubuntu-based
distributions. Your mileage may vary.

Prior to running this script, you probably need to install its dependencies:

    cpan -i WWW::Mechanize IO::Prompt

To print, either use your favorite application's print menu, or
use `lpr -P <printer> <file>`.

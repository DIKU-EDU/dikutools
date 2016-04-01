A seemingly simple student filtering script. It works directly with the HTML
produced by the Absalon "Assignment report", but should be easy to adapt to
other HTML-based reports (this script uses the BeatifulSoup library, so that's
a dependency).

Since Absalon "Assignment reports" span multiple pages for large courses, the
examples that follow consider a two-page setup.

To get all students:

    $ ./filter.py ".*" 0 1.html > 1.txt
    $ ./filter.py ".*" 0 2.html > 2.txt
    $ LC_ALL=C cat 1.txt 2.txt | sort > all.txt

To get students that got at least 4 assignments approved:

    $ ./filter.py "\(Satisfactory|Passed\)" 4 1.html > 1.txt
    $ ./filter.py "\(Satisfactory|Passed\)" 4 2.html > 2.txt
    $ LC_ALL=C cat 1.txt 2.txt | sort > approved.txt

To get the students that got exactly 3 assignments approved:

    $ ./filter.py "\(Satisfactory|Passed\)" =3 1.html > 1.txt
    $ ./filter.py "\(Satisfactory|Passed\)" =3 2.html > 2.txt
    $ LC_ALL=C cat 1.txt 2.txt | sort > almost-approved.txt

To get the dead souls (in case of 5 assignments):

    $ ./filter.py "Not submitted" 5 1.html > 1.txt
    $ ./filter.py "Not submitted" 5 2.html > 2.txt
    $ LC_ALL=C cat 1.txt 2.txt | sort > dead-souls.txt

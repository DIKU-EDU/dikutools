#!/usr/bin/env perl
use 5.012;
use warnings;
use IO::Prompt;
use WWW::Mechanize;

=pod
Sets up m1b and n2d for printing on cups.

Requirements:
* Run "cpan -i WWW::Mechanize IO::Prompt" before running the script.
* Probably only works on Debian/Ubuntu based systems.
=cut

print "Installing cups and hplip...\n";
system('sudo apt-get install -yy cups hplip');

print "Fetching printer addresses...\n";

my $mech = WWW::Mechanize->new();
$mech->get('https://webprint.science.ku.dk/driverprint.cfm?platform=linux&printmode=2');

print "In order to fetch your personal printer address, I need your KU login information.\n";
my $user = prompt("Username: ");
my $pass = prompt("Password: ", -e => '*');
$mech->submit_form(
    with_fields => {
        Username => $user,
        Password => $pass,
    },
);

my ($uristart) = $mech->response->content =~ qr{(ipp://webprint.science.ku.dk:631/ipp/[^/]+)};

die("Login failed.\n") unless $uristart;

print "Setting up UP1-2-0-02 (formerly m1b)...\n";
system("sudo /usr/sbin/lpadmin -p m1b -E -m postscript-hp:0/ppd/hplip/HP/hp-laserjet_9040_mfp-ps.ppd -L 'DIKU, UP1-2-0-02 (sort/hvid)' -v $uristart/AAB7DFC9}");
print "You can now print to m1b using: lpr -P m1b <file>\n";
print "Setting up UP1-2-0-02-b (formerly n2d)...\n";
system("sudo /usr/sbin/lpadmin -p n2d -E -L 'DIKU, UP1-2-0-02-B (farve)' -m drv:///sample.drv/generic.ppd -v $uristart/3F88D181}");
print "You can now print to m1b using: lpr -P n2d <file>\n";

print "All done.\n";


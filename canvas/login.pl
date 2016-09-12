#!/usr/bin/env perl

# When running this script, make sure you have a file "credentials" in your
# current directory containing your KU login information in this format:
# 'abc123:password'.

use strict;
use warnings;
use utf8::all;
use IO::All -utf8;
use WWW::Mechanize;
use LWP::Protocol::https;
use HTTP::Cookies;

use constant SITE => 'https://absalon.ku.dk/';

my $mech = WWW::Mechanize->new(cookie_jar => HTTP::Cookies::Netscape->new(
  file => "cookies.txt", autosave => 1));
$mech->agent_alias('Windows Mozilla');

main($mech);

sub login {
    my ($mech, $site, $user, $pass) = @_;

    $mech->get($site);
    print $mech->submit_form(
        form_id => 'logonForm',
        fields => {
            'username' => $user,
            'password' => $pass
        }
    )->status_line;
    print "\n";
    print $mech->submit_form(
        form_name => 'hiddenform')->status_line;
    print "\n";
}


sub main {
    my $mech = shift;

    my ($USERNAME, $PASSWORD) = io("credentials")->slurp =~ /^(\w+):(\w+)$/;

    login($mech, SITE, $USERNAME, $PASSWORD);
}

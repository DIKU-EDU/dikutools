#!/usr/bin/env perl

use strict;
use warnings;
use WWW::Mechanize;
use LWP::Protocol::https;
use HTTP::Cookies;

use constant SITE => 'https://absalon.ku.dk/';

# Absalon username
my $USERNAME = 'dfz719';
# Absalon password
my $PASSWORD = 'hamster';

my $mech = WWW::Mechanize->new(cookie_jar => HTTP::Cookies->new(file => "cookies.txt"));
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


sub main {
    my $mech = shift;

    login($mech, SITE, $USERNAME, $PASSWORD);
}



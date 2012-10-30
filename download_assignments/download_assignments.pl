#!/usr/bin/env perl
use strict;
use warnings;
use WWW::Mechanize;
use Data::Dumper;
use Try::Tiny;
use URI::Escape;
use HTML::Query qw(Query);
use Text::Unidecode;

use constant SITE => 'https://absalon.itslearning.com/';

# Assignments will be saved in this folder.
my $ASSIGNMENT_FOLDER = 'Gruppeopg_5';
# Name of the course on Absalon
my $COURSE_NAME = 'Introduktion til programmering';
# Name of the assignment to download assignments from.
my $ASSIGNMENT_NAME = 'Gruppeaflevering uge 5';

# Absalon username
my $USERNAME = 'enterusernamehere';
# Absalon password
my $PASSWORD = 'enterpasswordhere';

my $mech = WWW::Mechanize->new();
$mech->agent_alias('Windows Mozilla');

main($mech);

sub login {
    my ($mech, $site, $user, $pass) = @_;

    $mech->get($site);
    $mech->submit_form(
        form_id => 'Form',
        fields => {
            '__EVENTTARGET'              => 'ctl03$Login$loginbtn',
            'ctl03$Login$username$input' => $user,
            'ctl03$Login$password$input' => $pass,
        }
    );
}

sub followLink {
    my ($mech, $text) = @_;

    escapeFrames($mech);
    $mech->follow_link( text_regex => qr/$text/ );

    print "Followed link to ${$mech->uri()}\n";
}

sub escapeFrames {
    my $mech = shift;

    $mech->follow_link( url_regex => qr/ContentArea.aspx/ );
    $mech->follow_link( name => 'mainmenu' );
    print "Escaped frames to ${$mech->uri()}\n";

}

sub gotoAssignmentSubmission {
    my ($mech, $site, $id) = @_;

    $mech->get($site . 'essay/answer_essay.aspx?EssayID=' . $id);

    print "Went to assignment submission page: ${$mech->uri()}\n";
}

sub downloadAssignment {
    my ($mech, $url) = @_;

    $mech->get($url);
    my $q = Query( text => $mech->content );
    my ($participants,) = grep { $_->as_text =~ /Participants/ } @{$q->query('div.formtable tr td')->get_elements()};
    my ($title, $name) = $participants->content_list();

    if (ref $name) {
        my $pq = Query( text => $name->as_HTML );
        $name = join("_-_", map { $_->as_text } $pq->query('td:first-child option')->get_elements());
    }

    my @files = grep { $_->attr('href') =~ qr{/File/download.aspx} } $q->query('div.formtable tr td a.iconandlink')->get_elements();

    $name = unidecode($name);
    $name =~ s/[^\w\d-]/_/gi;

    mkdir("$ASSIGNMENT_FOLDER/$name");
    for my $file (@files) {
        $mech->get(SITE . $file->attr('href'),
                   ':content_file' => "$ASSIGNMENT_FOLDER/$name/" . $file->as_text);
    }

    print "Assignment by $name: " . join(", ", map { $_->as_text } @files) . "\n";
}

sub main {
    my $mech = shift;

    login($mech, SITE, $USERNAME, $PASSWORD);
    followLink($mech, $COURSE_NAME);
    followLink($mech, $ASSIGNMENT_NAME);

    mkdir($ASSIGNMENT_FOLDER);

    my @assignments = map { SITE . $_->url } $mech->find_all_links(text => 'Show');
    downloadAssignment($mech, $_) for @assignments;
}



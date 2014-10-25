#!/usr/bin/env perl
use 5.012;
use warnings;
use utf8::all;

use DateTime;
use WWW::Mechanize;
use HTML::Query qw(Query);
use Data::Dumper;
use List::Util qw/min max/;
use syntax qw/junction/;
use IO::All -utf8;
use FindBin qw/$Bin/;
use JSON qw/to_json/;

use constant SITE => 'https://absalon.itslearning.com/';
use constant COURSE => '5100-B1-1E14;Introduktion';
use constant OUTFILE => 'data.json';
use constant GROUPRX => qr/Øvehold (\d+)/;

my ($USERNAME, $PASSWORD) = io("$Bin/.absalon_credentials")->slurp =~ /^([^:]+):(.*)$/;

die(<<END) unless $USERNAME;
Place a file named '.absalon_credentials' in the folder you run the program from.
In it, put username:password for absalon.itslearning.com login.
END

chomp $USERNAME;
chomp $PASSWORD;

my $quiet = @ARGV >= 1 && $ARGV[0] eq '-quiet';

my $mech = WWW::Mechanize->new();
$mech->agent_alias('Windows Mozilla');

local $| = 1;

main($mech);

sub getHTML {
    my $mech = shift;
    return $mech->response->decoded_content;
}

sub login {
    my ($mech, $site) = @_;

    $mech->get($site);
    $mech->submit_form(
        with_fields => {
            '__EVENTTARGET' => 'ctl00$ContentPlaceHolder1$nativeLoginButton',
            'ctl00$ContentPlaceHolder1$Username$input' => $USERNAME,
            'ctl00$ContentPlaceHolder1$Password$input' => $PASSWORD,
        },
    );
}

sub followFavoriteLink {
    my ($mech, $text) = @_;

    my $q = Query( text => getHTML($mech) );
    my @es = $q->query('#ctl00_BottomNavigationBar_Shortcuts_ShortcutsList_M a')->get_elements;
    my @links = grep { $_->as_text =~ /$text/ } @es;

    my $url = SITE . $links[0]->attr('href');
    $mech->get($url);

    #print "Navigated to $url from top menu\n";
}

sub followMenuLink {
    my ($mech, $text) = @_;

    my ($url) = getHTML($mech) =~ m{(https://[^']*processfolder\.aspx\?FolderID=\d+)};
    $mech->get($url);

    $mech->follow_link( text_regex => qr/$text/ );

    #print "Followed link to ${$mech->uri()}\n";
}

sub gotoStatusAndFollowup {
    my ($mech) = @_;

    my ($url) = getHTML($mech) =~ m{(/Status/StatusMenu\.aspx\?CourseId=\d+)};
    $mech->get(SITE . $url);
}

sub gotoParticipants {
    my ($mech) = @_;

    my ($url) = getHTML($mech) =~ m{(/Course/Participants\.aspx\?CourseID=\d+)};
    $mech->get(SITE . $url);
}

sub followLink {
    my ($mech, $text) = @_;

#    escapeFrames($mech);
    $mech->follow_link( text_regex => qr/$text/ );

    #print "Followed link to ${$mech->uri()}\n";
}

sub escapeFrames {
    my $mech = shift;

    $mech->follow_link( url_regex => qr/ContentArea.aspx/ );
    $mech->follow_link( name => 'mainmenu' );
    #print "Escaped frames to ${$mech->uri()}\n";
}

sub parsePersons {
    my ($mech, $persons) = @_;

    my $q = Query( text => getHTML($mech) );
    my @header = map { $_->as_text } ($q->query('thead tr th')->get_elements);
    my ($groupIdx) = grep { $header[$_] =~ /Group/ } (0 .. $#header);
    my ($nameIdx) = grep { $header[$_] =~ /Name/ } (0 .. $#header);

    my @students = ($q->query('tr')->get_elements);
    for my $student (@students) {
        my $sq = Query($student);
        my @row = map { $_->as_text } ($sq->query('td')->get_elements);

        my ($group) = ($row[$groupIdx] // '') =~ GROUPRX;
        next unless $group;
        $persons->{ $row[$nameIdx] } = $group;
    }
}

sub trim {
    my ($res) = shift =~ /^\s*(.*?)\s*$/;
    return $res;
}

sub parseTable {
    my ($mech, $persons, $groups, $res) = @_;

    my $q = Query( text => getHTML($mech) );
    my @header = ($q->query('tr th')->get_elements);

    for my $head (@header) {
        next unless (($head->attr('class') // '') eq 'grade-book-item-header');

        my $hd = Query($head);
        my $title = trim(($hd->query('a')->get_elements)[0]->as_text);

        my $assignment = {};

        my @maxAss = $hd->query('.gb-maxscore')->get_elements;
        if (@maxAss) {
            $assignment->{maxAssessment} = $maxAss[0]->as_text;
        }

        $res->{assignments}->{$title} = $assignment;
    }

    for my $student ($q->query('tbody tr')->get_elements) {
        my $sq = Query($student);
        my @row = ($sq->query('td')->get_elements);
        my $studres = { assignments => {} };

        for (my $i = 0; $i < @row; $i++) {
            my $answer = $row[$i];
            my $head   = $header[$i];

            my $title;

            # Not an assignment
            if (($head->attr('class') // '') ne 'grade-book-item-header') {
                $title = trim($head->as_text);
                my $value = trim($answer->as_text);
                $studres->{$title} = $value;

                if ($title eq 'Name') {
                    my $group = $persons->{$value};
                    $studres->{group} = $group if $group;
                }
                next;
            }

            my $assdata = {};

            my $hd = Query($head);
            $title = trim(($hd->query('a')->get_elements)[0]->as_text);

            my $bd = Query($answer);
            my $status = trim(($bd->query('span.status-container')->get_elements)[0]->as_text);
            my $ass = trim(($bd->query('span.assessmentcontainer')->get_elements)[0]->as_text);

            $assdata->{status} = $status // "";
            $assdata->{assessment} = $ass // "";

            $studres->{assignments}->{$title} = $assdata;
        }

        push(@{$res->{students}}, $studres);
    }
}

sub getNextTablePage {
    my $mech = shift;

    return 0 unless my $link = $mech->find_link( text_regex => qr/»/ );
    my ($page) = $link->attrs->{onclick} =~ /goToPage\((\d+)\)/;
    print STDERR "Next page is $page\n" unless $quiet;
    $mech->form_id('aspnetForm');
    $mech->set_fields('__EVENTTARGET' => 'ctl00$ContentPlaceHolder$GridPager');
    $mech->set_fields('__EVENTARGUMENT' => "PageNumber_$page");
    $mech->submit_form();

    return 1;
}

sub getNextPersonPage {
    my $mech = shift;

    return 0 unless my $link = $mech->find_link( text_regex => qr/»/ );
    my ($page) = $link->attrs->{onclick} =~ /goToPage\((\d+)\)/;
    print STDERR "Next page is $page\n" unless $quiet;
    $mech->form_id('aspnetForm');
    $mech->set_fields('ctl00$ContentPlaceHolder$ParticipantsGrid$HPN' => $page);
    $mech->submit_form();

    return 1;
}

sub initializeResult {
    my $time = DateTime->now( time_zone => 'local' );

    return (
        assignments => {},
        students    => [],
        time        => "$time",
    );
}

sub main {
    my $mech = shift;

    print STDERR "Logging in...\n" unless $quiet;
    login($mech, SITE);
    print STDERR "Fetching participant list...\n" unless $quiet;
    followFavoriteLink($mech, COURSE);
    my $course_url = $mech->uri;
    gotoParticipants($mech);
    my %persons;
    do {
        print STDERR "Parsing one page of persons.\n" unless $quiet;
        print STDERR "Followed link to ${$mech->uri()}\n" unless $quiet;
        parsePersons($mech, \%persons);
    } while (getNextPersonPage($mech));
    print STDERR "Done with parsing persons.\n" unless $quiet;
    print STDERR sprintf("Found %d persons.\n", scalar(keys %persons)) unless $quiet;

    print STDERR "Fetching assignment list...\n" unless $quiet;
    $mech->get($course_url);
    followFavoriteLink($mech, COURSE);
    gotoStatusAndFollowup($mech);
    followLink($mech, "Assignment report");

    my %groups;
    my %res = initializeResult();

    do {
        print STDERR "Parsing one page of assignments.\n" unless $quiet;
        parseTable($mech, \%persons, \%groups, \%res);
    } while (getNextTablePage($mech));
    print STDERR "Done with parsing assignments.\n" unless $quiet;

    open(my $outfile, '>', OUTFILE);
    select($outfile);
    print to_json(\%res);
    close($outfile);
    print STDERR "Done with HTML output.\n" unless $quiet;
}

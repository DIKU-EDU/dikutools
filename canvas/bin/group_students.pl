#!/usr/bin/env perl
use 5.022;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use DIKUtools::Canvas;
use Mojo::UserAgent;
use YAML::Tiny;

########### XXX: Change these ###########
my $courseid = '16199';
my @groups = (
    [ qw( bns895 djc280 mzd885 ) ], # Sebbe, kriztw, Athas
    [ qw( dfz719 njf941 )        ], # oleks, ngws
);

my $group_name = 'Test af scriptoprettelse';
#########################################

my $config = YAML::Tiny->read("$Bin/../config.yaml")->[0];
my $token = $config->{token} // die("Specify an access token in config.yaml");

my $canvas = DIKUtools::Canvas->new( token => $token);


# Map username => student hashref
sub lookup_student {
	my ($students, $username) = @_;

	my $login_id = lc("$username\@ku.dk");
	my ($student) = grep { $_->{sis_login_id} =~ qr/^\Q$login_id\E$/ } @$students;
	warn("Couldn't find student with id $username") unless $student;
	return $student;
}

my @students = $canvas->course_users($courseid); #, 'enrollment_type[]' => 'student' );

# Look up user objects
@groups = map { [ map { lookup_student(\@students, $_) } @$_ ] } @groups;

my $group_cat = $canvas->create_group_category($courseid, $group_name);

my @group_res = map { $canvas->create_group( $group_cat, $_ ) } @groups;

use Data::Dumper; say Dumper( @group_res );

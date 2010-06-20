#! /usr/bin/perl
use strict;
use warnings;
use Lazyness ':all';
use Test::More 'no_plan';
use YAML;

my ( @input, $got, $expected );
# 
# @input    = qw/ test toto tata tutu et le reste /;
# $got      = [collect takeWhile { /^t/ } sub { shift @input }];
# $expected = [qw/ test toto tata tutu /];
# 
# is_deeply( $got, $expected, "takeWhile works");

# sub begins_with_t ($) { takeWhile { /^t/ } shift }
# my @t = qw/ toto tata aha /;
# print "$_\n" for collect begins_with_t sub { shift @t }

sub test_it {
    my ( $f, $input, $expected, $desc ) = @_;
    my $got = [collect $f->( sub { shift @$input } ) ];
    is_deeply( $got, $expected, $desc )
	or diag YAML::Dump
	{ got      => $got
	, expected => $expected
	}
    ;
}

for my $test (

    [ sub { takeWhile { /^t/ } shift }
    , [qw/ toto tata haha got /]
    , [qw/ toto tata /]
    , "takeWhile ok"
    ],

    [ sub { take 2, shift }
    , [qw/ foo bar pan bing /]
    , [qw/ foo bar /]
    , "take ok"
    ],

    [ sub { filter { /a/ } shift }
    , [qw/ foo bar pan bing /]
    , [qw/ bar pan /]
    , "filter ok"
    ],

) { test_it @$test }

# @input    = qw/ this is a test for lazy_grep indeed /;
# $got      = lgrep { /i/ } sub { shift @input };
# $expected = [qw/ this is indeed /];
# is_deeply( $got, $expected, "lgrep works" );




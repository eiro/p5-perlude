#! /usr/bin/perl
use Perlude;
use Test::More tests => 1;

my $got = [
    fold concatMap {
        my @r = ($_)x2;
        sub { shift @r }
    } unfold [1..3]
];

my $expected = [ map { ($_)x2 } 1..3 ];

is_deeply( $got, $expected, "concatMap works" );

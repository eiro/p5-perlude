#! /usr/bin/perl
use Perlude;
use Test::More tests => 1;

my @expected = (1..3)x3;
my @got      = fold take 9, cycle [1..3];

is_deeply
( \@got, \@expected, "cycle works" );

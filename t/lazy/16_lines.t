#! /usr/bin/perl
use Modern::Perl;
use Test::More 'no_plan';
use Perlude::Lazy;
use autodie;

my @seed = qw/ toto tata tutu /;
my $file = '/tmp/perlude-test-lines-data';

open F,'>',$file;
say F $_ for @seed;
close F;

is_deeply
( [fold lines $file]
, [map { "$_\n" } @seed]
, "raw lines" );

is_deeply
( [fold lines chomp => $file]
, \@seed
, "chomped lines" );

unlink $file;

#! /usr/bin/perl
use strict;
use warnings;
use Test::More 'no_plan';
use Perlude::Lazy;

my @seed = qw/ toto tata tutu /;
my $file = 't/perlude-test-lines-data';

open F,'>',$file or die "can't create test file";
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

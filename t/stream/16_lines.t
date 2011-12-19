#! /usr/bin/perl
use Modern::Perl;
use Perlude;
use autodie;
use Test::More skip_all => 'deprecate line ? records instead ?';

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

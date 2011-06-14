#! /usr/bin/perl
use strict;
use warnings;
use Perlude;
use Test::More skip_all => "takeWhile can't be fixed";

my ( @input, $got, $expected );

my $doubles = do { 
    my $seed = 0;
    sub { $seed+=2 } 
};

my @first  = fold takeWhile { $_ < 5 } $doubles;
my ($next) = fold take 1, $doubles;

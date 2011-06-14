#! /usr/bin/perl
use YAML;
use Perlude;
use Test::More tests => 1;

my $expected = [1..100];
my $got;

$got = [ fold concat [ map { unfold [$_] } @$expected ] ];
is_deeply( $got, $expected, "contact works with clean input")
    or diag YAML::Dump { got => $got };

#! /usr/bin/perl
use Modern::Perl;
use YAML;
use Lazyness ':all';
use Test::More tests => 1;

my $expected = [1..100];
my $got;

$got = [fold unfold [@$expected] ];
is_deeply( $got, $expected, "unfold . fold => id")
    or diag YAML::Dump { got => $got };

$got = [fold concat [ map { unfold [$_] } @$expected ]];
is_deeply( $got, $expected, "contact works with clean input")
    or diag YAML::Dump { got => $got };

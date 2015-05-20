#! /usr/bin/perl
use Perlude;
use Test::More;
use strict;
use warnings;

my $expected = [ romanes => '' => qw( eunt domus ) => '' ];

for
( ['direct call of &lines' => [fold lines qw( <:utf8 t/data/brian )]]
, ['lines via as_open'     => [fold lines as_open qw( <:utf8 t/data/brian )]]
, ['lines via CORE::open'  => do {
        open my $fh, '<:utf8', 't/data/brian';
        [fold lines $fh]
    } ]
) { my ( $desc, $got ) = @$_;
    is_deeply $got, $expected, $desc;
}

done_testing;


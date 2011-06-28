#! /usr/bin/perl
use Modern::Perl;
use Test::More;
use Perlude;

my @tests =
( []
, [undef] 
, [1..10] 
, ['']
, ["haha"]
);

plan tests => 0+2*@tests;

for my $t (@tests) {
    is_deeply
    ( [fold unfold @$t]
    , $t
    , "fold unfold => id"
    )
}

# fold in void context
for my $t (@tests) {
    my @l = @$t;
    my $n = 1+@l;
    #fold apply { $n--; @_ } unfold @$t;
    fold sub { $n--; @l ? (shift @l) : () };
    is $n, 0;
}


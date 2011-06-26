#! /usr/bin/perl
use Modern::Perl;
use YAML;
use Perlude;
use Test::More;

my @tests =
( []
, [undef] 
, [1..10] 
, ['']
, ["haha"]
);

plan tests => 0+@tests;

for my $t (@tests) {
    is_deeply
    ( [fold unfold @$t]
    , $t
    , "fold unfold => id"
    )
}

# for my $t (@tests) {
#     is_deeply
#     ( [fold unfold @$t]
#     , $t
#     , "fold unfold => id"
#     )
# }

#! /usr/bin/perl
use Modern::Perl;
use Perlude;
use Test::More;

my $limit = 10_000;
my %function =
( filter => \&filter
, apply  => \&apply
);

my @tests =
( [ filter => sub { $_ % 2 }, unfold( 1, 2, 3 ), [1,3] ]
, [ filter => sub { $_ % 2 }, sub { state $n=0; $n++ }, [grep { $_ % 2 } 0..(2 * $limit) ] ]
, [ apply  => sub { $_ % 2 }, unfold( 1, 2, 3 ), [1,0,1] ]
, [ apply  => sub { $_ % 2 }, sub { state $n=0; $n++ }, [fold take $limit, cycle 0,1 ] ]
);

plan tests => 0
+ @tests
;

for my $t (@tests) {
    my ( $name, $code, $i, $out ) = @$t;
    local $"=',';
    is_deeply
    ( [ fold take $limit, $function{$name}->( \&$code, $i ) ]
    , $out
    , "filter"
    )
}

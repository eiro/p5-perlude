use Modern::Perl;
use Test::More;
use Perlude;

sub sum { my $sum = 0; traverse { $sum += $_ } shift }

my @tests =
( [ 0  => sub {} ]
, [ 10 => take 10, sub {1} ]
, [ 15 => unfold 1 .. 5 ]
, [ 0  => take 10, cycle -1, 1 ]
);

plan tests => 0+ @tests;

for my $t (@tests) {
    is( sum( $t->[1] ), $t->[0], "sum = $t->[0]" );
}


use Test::More;
use strict;
use warnings;
use Perlude;

my @pass =
( [ 3, sub { } ]
, [ 4, unfold( 0 .. 10 ), [ 0 .. 3 ], [ 4 .. 7 ], [ 8 .. 10 ] ]
# , [ 2.5, unfold( 0 .. 6 ), [ 0 .. 2 ], [ 3 .. 5 ], [ 6 ] ]
);

my @fail = ();
# ( [ 0, sub { } ]
# , [ -1, unfold( 0 .. 10 ) ]
# , [ 'a', unfold( 0 .. 10 ) ]
# );

plan tests => @pass + 2 * @fail;

for my $t (@pass) {
    my ( $n, $i, @r ) = @$t;
    is_deeply( [ fold splitEvery $n, \&$i ], \@r, "splitEvery $n" );
}

for my $t (@fail) {
    my ( $n, $i ) = @$t;
    ok( !eval { splitEvery $n, \&$i; 1 }, "splitEvery $n FAIL" );
    like(
        $@,
        qr/^\Q$n\E is not a valid parameter for splitEvery\(\) at /,
        "error message for splitEvery $n"
    );
}


use Modern::Perl;
use Test::More;
use Perlude;

plan 'no_plan';

# very basic test
my $l = enlist { state $n; $n++ };
is( ref $l, 'CODE', 'enlist returns a coderef' );

# check some values
my @v;
( $l, @v ) = $l->();
is_deeply( \@v, [0], 'first item' );
( $l, @v ) = $l->(1);    # peek at the next value
is_deeply( \@v, [1], 'peek at the next item' );
( $l, @v ) = $l->();
is_deeply( \@v, [1], 'next item' );

# peek at a lot of values at once
my $n = int 1000 * rand;
( $l, @v ) = $l->($n);
is( scalar @v, $n, "Peeked at $n items" );
is( $v[-1], 1 + $n, "Last item is " . ( $n + 1 ) );
( $l, @v ) = $l->();
is_deeply( \@v, [2], 'next item' );

# corner cases
( $l, @v ) = $l->(0);
is( scalar @v, 0, 'peek at nothing' );
( $l, @v ) = $l->();
is_deeply( \@v, [3], 'next item' );

( $l, @v ) = $l->(-1);
is( scalar @v, 0, 'peek at nothing (-1)' );
( $l, @v ) = $l->();
is_deeply( \@v, [4], 'next item' );

# bounded list
$l = unfold 0 .. 5;
( $l, @v ) = $l->(6);
is( scalar @v, 6, 'peek at the remaining items' );
( $l, @v ) = $l->();
is_deeply( \@v, [0], 'next item' );
( $l, @v ) = $l->(7);
is( scalar @v, 5, 'peek at more than the remaining total' );
( $l, @v ) = $l->();
is_deeply( \@v, [1], 'next item' );


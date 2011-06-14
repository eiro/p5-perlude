#! /usr/bin/perl
use Perlude;
use Test::More tests => 1;

is
( (sumR range(1, 3))
, 6 
, "sumR works, so collectR" 
)

__END__

sub fib {
    my @seed = @_;
    sub {
	push @seed, $seed[0]  + $seed[1]; 
	shift @seed
    }
}

mapM_ {say} take 10, fib 1,1;

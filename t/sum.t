#! /usr/bin/perl
use Modern::Perl;
use YAML;
use Lazyness ':all';
use Test::More tests => 1;

is
( (sumM range(1, 3))
, 6 
, "sumM works, so collectM" 
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

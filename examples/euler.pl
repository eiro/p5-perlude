#! /usr/bin/perl
use Modern::Perl;
use autodie;
use YAML ();
use Perlude;
use Perlude::Stuff ':math';

sub fibo {
    my @seed = @_;
    enlist {
        push @seed, $seed[0] + $seed[1];
        shift @seed;
    }
}

say sum whileBelow 1000, fibo 1,1;

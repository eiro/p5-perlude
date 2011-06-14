package Perlude;
use warnings;
use strict;
use 5.10.0;
use Carp;

use parent 'Exporter';
our @EXPORT = qw/
    drop take takeWhile
    fold unfold
    filter mapC mapR 
    cycle range
    concat concatC concatMap
    collectR sumR productR
/;

# TODO:
# - UTs for records, lines, stream
# - Documentations and examples
# - examples

our $VERSION = '0.42';

sub take {
    my ( $want_more, $some ) = @_;
    sub { $want_more-- > 0 ?  $some->() : undef }
}

sub drop {
    my ( $remove, $some ) = @_; 
    sub {
        while ( $remove-- > 0 ) { $some->() or return }
        $some->();
    }   
}

sub takeWhile (&;$) {
    my ( $test, $list ) = @_;
    sub {
        my $block = $list || shift;
        local $_ = $block->();
        defined or return undef;
        $test->() ? $_ : undef;
    }
}

sub fold ($) {
    my ( $list ) = @_;
    my @r;
    while ( defined ( local $_ = $list->() ) ) { push @r,$_ }
    @r;
}

sub mapR  (&;$) {
    my ( $code, $list ) = @_;
    $code->() while defined ( local $_ = $list->() );
    ();
}

sub _apply {
    my ( $filter, $block, $list ) = @_;
    sub {
        my $next = $list || shift;
        while ( defined ( local $_ = $next->() ) ) {
            if ( $filter ) { $block->() and return $_ }
            else { return $block->() }
        }
        return;
    }
}

sub concat {
    my $streams = shift or return sub { undef };
    sub {
        while ( @$streams ) {
            my $r;
            defined ( $r = $$streams[0]() ) and return $r;
            shift @$streams;
        }
        return
    }
}

sub concatC {
    my $streams  = shift or return sub { undef };
    my $s        = $streams->();
    my $running = 1;
    sub {
        my $r;
        while ($running) {
            defined ( $r = $s->() ) and return $r;
            defined ( $s = $streams->() ) or $running = 0;
        }
        undef;
    }
}

sub mapC        (&;$) {         _apply ( 0, @_ ) }
sub concatMap   (&;$) { concatC _apply ( 0, @_ ) }
sub filter      (&;$) { _apply         ( 1, @_ ) }

sub cycle {
    my $cycle = shift;
    my $index = 0;
    sub {
        my $r = $$cycle[$index];
        if ( ++$index > $#$cycle ) { $index = 0 }
        $r
    };
}

sub range {
    my ( $min, $max, $step ) = @_;
    defined $max or die "range without max";
    $step ||= 1;
    sub {
        my $r = $min;
        if ( $max >= $r ) {
            $min+=$step;
            $r;
        } else { undef }
    }
}

sub unfold {
    my $array = shift;
    sub { shift @$array }
}

sub collectR (&$) {
    my ( $code, $stream ) = @_;
    my $r;
    while ( defined ( local $_ = $stream->() )) { $r = $code->() }
    $r;
}

sub sumR     { collectR { state $sum = 0; $sum+=$_ } shift }
sub productR { collectR { state $sum = 1; $sum*=$_ } shift }

sub records {
    my ($source) = @_;
    sub { <$source> }
}

sub lines {
    open my $fh,shift;
    if ($@) {
	if ($_[0] ~~ 'chomp') {
	    sub {
		my $v = <$fh>;
		chomp $v;
		$v
	    }
	} else {
	    croak 'your arguments iz invalid:'
	    , join ',', @_
	}
    }
    else { records $fh }
}

sub stream {
    my $source = shift;
    my $method = shift;
    my @args   = @_;
    sub { $source->$method(@args) }
}

=head1 NAME

Perlude - a prelude for perl

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

Perlude functions are filters and consumers for generators (Closures). It
adds keywords stolen from the haskell world and introduce some perl specific
ones.

=head1 Rules, naming and conventions

A generator is a closure

* a scalar as a next element

* undef when exhausted

The list of every potential elements of a generator is called "the stream".

sub that takes and returns a closures is a filter, its name is postfixed with a C (mapC, ...).

sub that takes a closure and consume (read) it is a Reader, its name is prefixed with a R (mapR,reduceR,sumR,productR, ...)

keywords stolen from haskell are exceptions to the naming convention (filter,fold,unfold,...)

from haskell: take, takeWhile, filter, fold, (unfold?) concat ...

=head2 Notes for haskell users

As perl doesn't have monads, M and M_ functions are replaced by C (for Closure)
and R (for Reader). so 

    mapM_ print    => mapR {say}
    mapM  print    => mapC {say}
    map (* 2)      => mapC { $_ * 2 }


=head1 EXPORT

=head1 FUNCTIONS

=head2 take $n, $C

take $n elements from $C

    fold take 10, sub { state $x=0; $x++ }
    #  => 0..9

=head2 takeWhile $test, $C

take all the first elements from the closure that matches $test.

    fold takeWhile { $_ < 100 } fibonacci
    # returns every terms of the fibonacci sequence under 100

=head2 filter $test, $C

remove any elements that matches $test from the steam (as grep does with arrays)

    filter { /3/ } fibonacci

removes every terms of fibonacci sequence that contains the digit 3 

=head2 fold $C

fold every terms of the steam into an array

    my @c4 = fold  take 50 filter {/4/} nat;

@c4 is the array of the first 50 naturals that contains the 4 digit

=head2 unfold $array_ref

stream the array elements

    mapR {say if /5/ } unfold [1..5];
    is like
    map {say if /5/} 1..5;


=head1 AUTHOR

Marc Chantreux, C<< <khatar at phear.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-lazyness at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Lazyness>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Perlude


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Lazyness>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Lazyness>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Lazyness>

=item * Search CPAN

L<http://search.cpan.org/dist/Lazyness>

=back

=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2010 Marc Chantreux, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Lazyness

package Perlude;
use Modern::Perl;
use Carp qw< croak >;
use Exporter qw< import >;
our @EXPORT = qw<

    enlist unfold
    fold
    takeWhile take drop
    filter apply
    traverse
    cycle range
    tuple

>;

use Carp;

our $VERSION = '0.50';

# private helpers
sub _buffer ($) {
    my ($l) = @_;
    my @b;
    sub {
        return ( $l, shift @b ) if @b;
        ( undef, @b ) = $l->();
        return ( $l, @b ? shift @b : () );
    }
}

# interface with the Perl world
sub enlist (&) {
    my ($l) = @_;
    my $g; $g = sub { ( $g, $l->() ) };
}

sub unfold (@) {
    my @array = @_;
    enlist sub { @array ? shift @array : () };
}

sub fold ($) {
    my ($l) = @_;
    my @v;
    unless (wantarray) {
        if ( defined wantarray ) {
            my $n = 0;
            $n += @v while 1 < ( ( undef, @v ) = $l->() );
            return $n;
        }
        else {
            undef while 1 < ( ( undef, @v ) = $l->() );
            return;
        }
    }
    my @r;
    push @r, @v while 1 < ( ( undef, @v ) = $l->() );
    @r;
}

# stream consumers (lazy)
sub takeWhile (&$) {
    my ( $cond, $l ) = @_;
    sub {
        1 < ( ( undef, my @v ) = $l->() ) or return $l;
        return $cond->() ? ( $l, @v ) : ($l) for @v;
    };
}

sub filter (&$) {
    my ( $cond, $l ) = @_;
    $l = _buffer $l;
    sub {
        while (1) {
            1 < ( ( undef, my @v ) = $l->() ) or return $l;
            $cond->() and return ($l, @v) for @v;
        }
    };
}

sub take ($$) {
    my ( $n, $l ) = @_;
    $l = _buffer $l;
    sub {
        $n-- > 0 or return $l;
        1 < ( ( undef, my @v ) = $l->() ) or return $l;
        ( $l, @v );
    }
}

sub drop ($$) {
    my ( $n, $i ) = @_;
    $i = _buffer $i;
    fold take $n, $i;
    $i;
}

sub apply (&$) {
    my ( $code, $i ) = @_;
    sub {
        ( my @v = $i->() ) or return;
        map $code->(), @v;
    }
}

# stream consumers (exhaustive)
sub traverse (&$) {
    my ( $code, $i ) = @_;
    my @b;
    while (1) {
        ( my @v = $i->() ) or return pop @b;
        @b = map $code->(), @v;
    }
}

# stream generators
sub cycle (@) {
    (my @ring = @_) or return sub {};
    my $index = -1;
    sub { $ring[ ( $index += 1 ) %= @ring ] }
}

sub range ($$;$) {
    my $begin = shift // croak "range begin undefined";
    my $end   = shift;
    my $step  = shift // 1;

    return sub { () } if $step == 0;

    $begin -= $step;
    if (defined $end) {
        if ($step > 0) {
            sub { (($begin += $step) <= $end) ? ($begin) : () }
        } else {
            sub { (($begin += $step) >= $end) ? ($begin) : () }
        }
    } else {
        sub { ($begin += $step) }
    }
}


sub tuple ($$) {
    my ( $n, $i ) = @_;
    croak "$n is not a valid parameter for tuple()" if $n <= 0;
    $i = _buffer $i;
    sub {
        my @v = fold take $n, $i;
        @v ? \@v : ();
    }
}

1;

=head1 NAME

Perlude - Lazy lists for Perl

=head1 AUTHORS

=over 4

=item *

Philippe Bruhat (BooK)

=item *

Marc Chantreux (eiro)

=item *

Olivier MenguE<eacute> (dolmen)

=back

=head1 ACKNOWLEDGMENTS 

=over 4

=item *

High five with StE<eacute>phane Payrard (cognominal)

=item *

French Perl Workshop 2011

=item *

Chartreuse Verte

=back

=cut



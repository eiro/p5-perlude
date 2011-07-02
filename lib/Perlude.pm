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
    my ( $g, @b );
    $g = sub {
print "b = @b | _ = @_\n";
        return @_
            ? do { @b = @_; $g }
            : ( $g, @b ? ( @b, @b = () ) : $l->() );
    };
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
        local $_ = shift @v;
        $cond->() ? ( ( @v ? $l->(@v) : $l ), $_ ) : ( $l->( $_, @v ) );
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
    my ( $n, $l ) = @_;
    $l = _buffer $l;
    fold take $n, $l;
    $l;
}

sub apply (&$) {
    my ( $code, $l ) = @_;
    sub {
        1 < ( ( undef, my @v ) = $l->() ) or return $l;
        ( $l, map $code->(), @v );
    };
}

# stream consumers (exhaustive)
sub traverse (&$) {
    my ( $code, $l ) = @_;
    my @b;
    while (1) {
        1 < ( ( undef, my @v ) = $l->() ) or return pop @b;
        @b = map $code->(), @v;
    }
}

# stream generators
sub cycle (@) {
    (my @ring = @_) or return sub {};
    my $index = -1;
    enlist sub { $ring[ ( $index += 1 ) %= @ring ] }
}

sub range ($$;$) {
    my $begin = shift // croak "range begin undefined";
    my $end   = shift;
    my $step  = shift // 1;

    return sub { () } if $step == 0;

    $begin -= $step;
    my $l;
    return $l = defined $end
        ? $step > 0
            ? sub { ( ( $begin += $step ) <= $end ) ? ( $l, $begin ) : ($l) }
            : sub { ( ( $begin += $step ) >= $end ) ? ( $l, $begin ) : ($l) }
        : sub { ( $l, $begin += $step ) };
}


sub tuple ($$) {
    my ( $n, $l ) = @_;
    croak "$n is not a valid parameter for tuple()" if $n <= 0;
    $l = _buffer $l;
    sub {
        my @v = fold take $n, $l;
        ( $l, @v ? \@v : () );
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



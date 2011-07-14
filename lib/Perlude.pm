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

sub NIL() {
    sub { (undef) }
}

# interface with the Perl world
sub enlist (&) {
    my ($i) = @_;
    my ( $l, @b );
    $l = sub {
        if (@_) {
            my $n = shift;
            return ( $l, @b[ 0 .. $n - 1 ] ) if @b >= $n;    # there's enough
            push @b, my @v = $i->();                         # need more
            push @b, @v = $i->() while @b < $n && @v;        # MOAR
            return ( $l, @b < $n ? @b : @b[ 0 .. $n - 1 ] ); # give it a peek
        }
        else {
            return ( $l, shift @b ) if @b;    # use the buffer first
            push @b, $i->();                  # obtain more items
            return @b ? ( $l, shift @b ) : NIL;
        }
    };
}

sub unfold (@) {
    my @array = @_;
    enlist { @array ? shift @array : () };
}

sub fold ($) {
    my ($l) = @_;
    my @v;
    unless (wantarray) {
        if ( defined wantarray ) {
            my $n = 0;
            $n += @v while 1 < ( ( $l, @v ) = $l->() );
            return $n;
        }
        else {
            # The real lazy one: when called in scalar context, values are
            # ignored:
            #     undef while defined ( $l = $l->() );
            # But producers must be able to handle that
            # So keep that for later and use the eager implementation for now
            undef while 1 < ( ( $l, @v ) = $l->() );
            return;
        }
    }
    my @r;
    push @r, @v while 1 < ( ( $l, @v ) = $l->() );
    @r;
}

# stream consumers (lazy)
sub takeWhile (&$) {
    my ( $cond, $l ) = @_;
    my $m;
    $m = sub {
        1 < ( ( $l, my @v ) = $l->() ) or return ($l);
        return $cond->() ? ( $m, @v ) : ( sub { ( $l, @v ) } ) for @v;
    };
}

sub filter (&$) {
    my ( $cond, $l ) = @_;
    my $m;
    $m = sub {
        while (1) {
            1 < ( ( $l, my @v ) = $l->() ) or return ($l);
            $cond->() and return ($m, @v) for @v;
        }
    };
}

sub take ($$) {
    my ( $n, $l ) = @_;
    my $m;
    $m = sub {
        $n-- > 0 or return ($l);
        1 < ( ( $l, my @v ) = $l->() ) or return ($l);
        ( $m, @v );
    }
}

sub drop ($$) {
    my ( $n, $l ) = @_;
    fold take $n, $l;
    $l;
}

sub apply (&$) {
    my ( $code, $l ) = @_;
    my $m;
    $m = sub {
        1 < ( ( $l, my @v ) = $l->() ) or return $l;
        ( $m, map $code->(), @v );
    }
}

# stream consumers (exhaustive)
sub traverse (&$) {
    my ( $code, $l ) = @_;
    my @b;
    while (1) {
        1 < ( ( $l, my @v ) = $l->() ) or return ($l, pop @b);
        @b = map $code->(), @v;
    }
}

# stream generators
sub cycle (@) {
    (my @ring = @_) or return NIL;
    my $index = -1;
    enlist { $ring[ ( $index += 1 ) %= @ring ] }
}

sub range ($$;$) {
    my $begin = shift // croak "range begin undefined";
    my $end   = shift;
    my $step  = shift // 1;

    return NIL if $step == 0;

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
    my $m;
    $m = sub {
        $l = take $n, $l;
        my (@r, @v);
        push @r, @v while 1 < ( ( $l, @v ) = $l->() );
        @r ? ( $m, \@r ) : ( $l )
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



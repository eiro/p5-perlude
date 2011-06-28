package Perlude;
use Modern::Perl;
use Exporter qw< import >;
our @EXPORT = qw<

    fold unfold 
    takeWhile take drop
    filter apply
    traverse
    cycle tuple

>; 

use Carp;

our $VERSION = '0.50';

# interface with the Perl world
sub unfold (@) {
    my @array = @_;
    sub { @array ? shift @array : () }
}

sub fold ($) {
    my ( $i ) = @_;
    my @v;
    unless (wantarray) {
        if (defined wantarray) {
            my $n = 0;
            $n++ while @v = $i->();
            return $n;
        } else {
            undef while @v = $i->();
            return;
        }
    }
    my @r;
    push @r, @v while @v = $i->();
    @r;
}

# stream consumers (lazy)
sub takeWhile (&$) {
    my ($cond, $i ) = @_;
    sub {
        ( my @v = $i->() ) or return;
        return $cond->() ? @v : () for @v;
    }
}

sub filter (&$) {
    my ( $cond, $i ) = @_;
    sub {
        while (1) {
            ( my @v = $i->() ) or return;
            $cond->() and return @v for @v;
        }
    }
}

sub take ($$) {
    my ( $n, $i ) = @_;
    sub {
        $n-- > 0 or return;
        $i->()
    }
}

sub drop ($$) {
    my ( $n, $i ) = @_;
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

sub tuple ($$) {
    my ( $n, $i ) = @_;
    croak "$n is not a valid parameter for tuple()" if $n <= 0;
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



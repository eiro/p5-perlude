package Perlude;
use Modern::Perl;
use Carp qw< croak >;
use Exporter qw< import >;
our @EXPORT = qw<
    fold unfold 
    takeWhile take drop
    filter apply
    now
    cycle range
    tuple
    concat concatC concatM
    records lines 

>; 

use Carp;

our $VERSION = '0.51';

# private helpers
sub _buffer ($) {
    my ($i) = @_;
    my @b;
    sub {
        return shift @b if @b;
        @b = ( $i->() );
        return @b ? shift @b : ();
    }
}

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
            $n += @v while @v = $i->();
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
    $i = _buffer $i;
    sub {
        while (1) {
            ( my @v = $i->() ) or return;
            $cond->() and return @v for @v;
        }
    }
}

sub take ($$) {
    my ( $n, $i ) = @_;
    $i = _buffer $i;
    sub {
        $n-- > 0 or return;
        $i->()
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
        (map $code->(), @v)[0];
    }
}

# stream consumers (exhaustive)
sub now (&$) {
    my ( $code, $i ) = @_;
    my @b;
    while (1) {
        ( my @v = $i->() ) or return pop @b;
        @b = map $code->(), @v;
    }
}

sub records {
    my $source = shift;
    sub { <$source> // () }
}

sub lines ($) {
    open my( $fh ), shift;
    apply {chomp; $_} records $fh;
}

sub concat {
    my ($s, @ss) = @_; # streams
    my @v;
    sub {
        while (1) {
            @v = $s->() and return @v;
            $s = shift @ss or return ();
        }
    }
}

sub concatC ($) {
    my $ss = shift; # stream
    my ($s) = $ss->() or return sub {()};
    my @v;
    sub {
        while (1) {
            @v = $s->() and return @v;
            $s = $ss->() or return ();
        }
    }
}

sub concatM (&$) {
    my ( $apply, $stream ) = @_;
    concatC apply {$apply->()} $stream;
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

=head1 WARNING

API Changes in version 0.51, please read the Changes file

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



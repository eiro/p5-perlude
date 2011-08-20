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
    lines
    concat

>;

use Carp;

our $VERSION = '0.50';

# End-of-list value: always return itself, with no data
{
    my $NIL;
    $NIL = sub { $NIL };
    sub NIL() { $NIL }
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

sub concat {
    my ($l, @ls)= @_;
    my @v;
    my $r;
    $r = sub {
        while ($l) {
            ( $l, @v ) = $l->();
            return ($r,@v) if @v;
            $l = shift @ls;
        }
    };
    $r
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
        1 < ( ( $l, my @v ) = $l->() ) or return pop @b;
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

sub lines {
    # private sub that coerce path to handles
    state $fh_coerce = sub {
        my $v = shift;
        return $v if ref $v;
        open my ($fh),$v;
        $fh;
    };
    my $fh = $fh_coerce->( pop );

    # only 2 forms accepted for the moment
    # form 1: lines 'file'
    @_ or return enlist { <$fh> // () };

    # confess if not 2nd form
    $_[0] ~~ 'chomp' or confess 'cannot handle parameters ' , join ',', @_ ;

    # lines chomp => 'file'
    enlist {
        defined (my $v = <$fh>) or return;
        chomp $v;
        $v;
    }

}

1;

=head1 NAME

Perlude - an attempt to port a part of Haskell prelude in Perl

=head1 SYNOPSIS

Haskell prelude miss you when you write perl stuff? Perlude is a port of the
most common keywords. Some other keywords where added when there is no haskell
equivalent.

Example: in haskell you can write

    nat        = [0..]
    is_even x  = ( x `mod` 2 ) == 0
    evens      = filter is_even
    main       =  mapM_ print
        $ take 10
        $ evens nat

in perlude, the same code will be:

    use Perlude;
    my $nat = enlist { state $x = 0; $x++ };
    sub is_even { ($_ % 2) == 0 }
    sub evens   { filter {is_even} shift }
    traverse {say} take 10, evens $nat

=head1 FUNCTIONS

=head2 relations between the computation world and perl

=head3 enlist

enlist transform a coderef to a lazy list.

    my $nat = enlist { state $x = 0; $x++ }

$nat is a lazy list of the naturals.

=head3 fold

consume a lazy list in an array

    my @top10nat =
        fold take 10,
        enlist { state $x=0; $x++ }

=head3 unfold

the conterpart of fold

=head3 take

take the n first elements of a lazy list

=head3 takeWhile

returns the head of a lazy list that matches a crteria.

    sub below { takeWhile { $_ < 1000 } shift }
    say for fold below 1000, enlist { state $x=0; $x++ }

=head3 drop, dropWhile

like take and takeWhile but remove elements instead of returning them


=head3 filter, apply

grep and map alike on lazy lists

    sub double { apply  { $_*2 } shift }
    sub evens  { filter { ($_ % 2) == 0 } shift }

=head3 traverse 

eval the block for every element of the list.

    traverse {say} take 10, unfold 0..13;

=head3 concat

bind lazy list together.

    traverse {say} take 10, concat
    ( unfold(1..5)
    , unfold(20..67)
    );

=head3 misc. functions

definitely need other namespaces for them!

    cycle range tuple lines

=head3 missing functions

    foldl foldr

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

High five with StE<eacute>phane Payrard (cognominal) and thanks to Nicolas Pouillard (#haskell-fr@freenode) for his help about haskell lazyness.

=item *

French Perl Workshop 2011

=item *

Chartreuse Verte

=back

=cut



package Perlude;
# use Perlude::Open;
use strict;
use warnings;
use 5.10.0;
use Carp qw< croak >;
use Exporter qw< import >;
our @EXPORT = qw<
    fold unfold 
    takeWhile take drop
    filter apply
    now
    cycle range
    splitEvery
    concat concatC concatM
    records lines 
    pairs
    nth
    chunksOf
    as_open
>; 

# ABSTRACT: Shell and Powershell pipes, haskell keywords mixed with the awesomeness of perl. forget shell scrpting now! 

use Carp;

our $VERSION = '0.61';

sub pairs ($) {
    my ( $ref ) = @_;
    my $isa = ref $ref or die "'$ref' isn't a ref";

    # TODO: use reftypes here!
    if ($isa eq 'HASH') {
        sub {
            my @pair;
            while ( @pair = each %$ref ) { return \@pair }
            ()
        }
    }
    # elsif ($isa eq 'ARRAY') {
    #     my $index = 1;
    #     sub {
    #         return if $index > @$ref;
    #         my $r =
    #             [ $$ref[$index-1]
    #             , $$ref[$index] ];
    #         $index+=2;
    #         $r;
    #     }
    # }
    else { die "can't pair this kind of ref: $isa" }
}

# sub pairs (&$) {
#     my ( $do, $on ) = @_;
#     sub {
# 	while ( @$_ = each %$on ) { return $do->() }
# 	()
#     }
# }

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

sub as_open {

    # arguments must please CORE::open

    # nothing to be done if $_[0] is a filehandle already
    my ($path) = map {return $_ if ref } shift || $_;
    if ( ref $_[0] ) {
        # more actions there ? 
        # this could be Path::Tiny inspired ? 
        # what about IO::All2 ?
        # use Perl IO instead ?
        # what if i can write
        # my $fh = as_open qw( <:locked:utf-8:gzip'  /tmp/foo.zip ); 
        ...
    }

    &CORE::open(my $fh, @_);
    $fh 
}

sub lines {
    my $fh = &as_open;
    my $line;
    sub {
        return unless defined ( $line = <$fh> );
        chomp $line;
        $line;
    }
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

sub range {
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
    warn "tuple is deprecated in flavor of splitEvery";
    &splitEvery
}

sub splitEvery ($$) {
    my ( $n, $i ) = @_;
    croak "$n is not a valid parameter for splitEvery()" if $n <= 0;
    $i = _buffer $i;
    sub {
        my @v = fold take $n, $i;
        @v ? \@v : ();
    }
}

sub nth {
    my ( $n, $s ) = @_;
    $n--;
    take 1, drop $n, $s 
}

sub chunksOf ($$;$) {

    my ( $n, $src, $offset ) = @_;
    $n > 1 or die "chunksOf must be at least 1 (don't forget unfold)";
    $offset //= 0;

    my  ( $end   , $exhausted , $from, $to )
    =   ( $#$src , 0 );

    sub {
        return if $exhausted;

        ( $from   , $offset      )=
        ( $offset , $offset + $n );

        $end <= ($to = $offset - 1) and do {
            $exhausted=1;
            $to = $end;
        };

        [ @{$src}[$from..$to] ];
    }
}


1;


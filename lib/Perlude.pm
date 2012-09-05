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
    pairs
>; 

use Carp;

our $VERSION = '0.52';

sub pairs ($) {
    my ( $hash ) = @_;
    sub {
	while ( @$_ = each %$hash ) { return $_ }
	()
    }
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

sub lines (_) {
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

=head1 BASICS and TERMS

Perlude is a brunch of functions (mainly stolen from the haskell perlude) that ease programming with iterators by showing them as a steam (list of values that may be computed) instead of a sequence of calls. If you're used to a functionnal langage, the unix shell or the powershell: you're at home!

See a basic example (explanations and definition right after the code)

    sub seq { # the generator

        my $max = shift;
        my $x   = 1;

        sub { # the iterator construction

            # returning an empty list means that the stream is exhausted
            return if $x > $max;

            # else, return the next value of the stream
            # (undef is a valid value!)
            $x++;
        }
    }

    my $to5 = seq 5; # the iterator
    # remaining $to5 stream = 1, 2, 3, 4, 5

    say "first iteration: ", $to5->();
    # prints 1
    # remaining $to5 stream = 2, 3, 4, 5

    say join ', ', map $to5->(), 1..100;
    # call the remaining stream: exhaustion

    say to5->();
    # says nothing: $to5 is an exhausted stream

    # folding: store a stream in a array

    $to5 = seq 75;

    # fold 50 first values
    my @first = map $to5->(), 1..50;

    # fold 25 last  values
    my @last = map $to5->(), 1..50;

C<seq> is a "generator": a function that returns a an iterator.

C<$to5> is an "iterator": is a function can compute a complete list by the mean of releasing one element by call.

An "iteration" is the action of calling an iterator.

Folding a stream is the action of releasing a set of the stream values in an array.

We can see an empty list as a tail of any list as all those notations are equivalent

    1, 2, 3, 4, 5
    1, 2, 3, 4, 5,
    1, 2, 3, 4, 5, ()

So the empty list is used as convention to say that the stream is exhausted. Note that undef is a valid element of a stream. That's why is C<()> maybe called "bound" in this documentation. Note that Perlude functions are using array context to read the iterators so 

    return unless $something_to_release

will return () which is a valid way to end the stream

=head1 SYNOPSIS

    use Perlude;
    use strictures;
    use 5.10.0;

    # iterator on a glob matches stolen from Perlude::Sh module
    sub ls {
        my $glob = glob shift;
        my $match;
        sub {
            return $match while $match = <$glob>;
            ();
        }
    }

    # show every txt files in /tmp
    now {say} ls "/tmp/*txt

    # remove empty files from tmp
    
    now { unlink if -f && ! -s } ls "/tmp/*"

    # something more reusable/readable ? 

    sub is_empty_file { -f && ! -s }
    sub empty_files_of { filter {is_empty_file} shift }
    sub mv { now {unlink} shift }

    mv empty_files_of ls "/tmp/*./txt";


=head1 Functions

=head2 Generators

=head3 range $begin, [ $end, [ $step ] ]

A range of numbers from $begin to $end (infinity if $end isn't set) $step by $step. 

    range 5     # from 5 to infinity
    range 5,9   # 5, 6, 7, 8, 9
    range 5,9,2 # 5, 7, 9

=head3 cycle @set

infinitly loop on a set of values

    cycle 1,4,7

    # 1,4,7,1,4,7,1,4,7,1,4,7,1,4,7,...

=head3 records $ref

given any kind of ref that implements the "<>" iterator, returns a Perlude compliant iterator.

    now {print if /data/} records do {
        open my $fh,"foo";
        $fh;
    };

=head3 lines

same as records but chomp all records before release.

    now {say if /data/} records do {
        open my $fh,"foo";
        $fh;
    };


=head2 filters

# =head2 Exhausters
# 
# =over
# 
# =item now {actions} $xs 
# 
# http://hackage.haskell.org/packages/archive/base/latest/doc/html/Prelude.html#v:take
# 
# =item take $n, $xs
# 
# applied to a list xs, returns the prefix of xs of length n, or xs itself if n > length xs
# 
#     take 5, range 1,10; # 1..5
# 
#     fold unfold 
#     takeWhile take drop
#     filter apply
#     now
#     tuple
#     concat concatC concatM
# 
# =over
# 
# 
# =head1 functions 
# 
# =head2 Consumers
# 
# =head3 now
# 
# C<now> makes the list ti be eager and returns the last element (eager would be better?).
# 
# =head3 fold
# 
# return an array of all computed elements
# 
# =head2 filters
# 
# =head3 transforming 
# 
#     fold unfold 
#     takeWhile take drop
#     filter apply
#     now
#     cycle range
#     tuple
#     concat concatC concatM
#     records lines 
# 
# =head1 AUTHORS
# 
# =over 4
# 
# =item *
# 
# Philippe Bruhat (BooK)
# 
# =item *
# 
# Marc Chantreux (eiro)
# 
# =item *
# 
# Olivier MenguE<eacute> (dolmen)
# 
# =head1 ACKNOWLEDGMENTS 
# 
# =over 4
# 
# =item *
# 
# During the French Perl Workshop 2011, dolmen suggested to use () as stream terminator. So we (Book, dolmen and me) rewrote Perlude in one night, drinking a bottle of Chartreuse with the support of cognominal. 
# 
# =back
# 
# 

package Lazyness;
use warnings;
use strict;

use parent 'Exporter';
our %EXPORT_TAGS =
( haskell      => [qw/ take takeWhile filter fold mapM mapM_ cycle drop concat /]
, experimental => [qw/ range /]
, dbi          => [qw/ prepare_sth dbi_stream /]
, step         => [qw/ stepBy byPairs /] 
);
our @EXPORT_OK = map {@$_} values %EXPORT_TAGS;
$EXPORT_TAGS{all} = \@EXPORT_OK; 

our $VERSION = '0.01';

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
    while ( defined ( local $_ = $list->() ) ) {
	push @r,$_
    }
    @r;
}

sub mapM_  (&;$) {
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
sub mapM   (&;$) { _apply( 0, @_ ) }
sub filter (&;$) { _apply( 1, @_ ) }

sub cycle {
    my @cycle = @_;
    my $index = 0;
    sub {
	my $r = $cycle[$index];
	if ( ++$index > $#cycle ) { $index = 0 }
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

sub concat {
    my $streams = shift or return sub { undef };
    sub {
	while ( @$streams ) {
	    my $r;
	    defined ( $r = $$streams[0]() )
		and return $r;
	    shift @$streams;
	}
	return
    }
}

sub _stepBy {
    my $code = shift;
    my $step = shift;
    my @r;
    while ( @_ ) {
	@_ > 1 or die "odd number of arguments in pairs";
	local $_ = [ splice @_, 0, $step ];
	push @r, $code->();
    }
    @r;
}

sub stepBy (&$@) { _stepBy @_ }
sub byPairs (&@) {
    my $code = shift;
    _stepBy $code, 2, @_;
}

sub prepare_sth {
    my ( $dbh, $query,@args ) = @_;
    my $sth = $dbh->prepare( $query );
    $sth->execute(@args);
    $sth;
}

sub stream_dbi {
    my $method = shift;
    my $sth = prepare_sth(@_);
    sub {
	defined ( my $cmd = shift )
	    or return $sth->$method;
	if ( $cmd eq 'finish' ) { undef $sth }
    }
}

sub stream_fh {
    open my $fh, shift or die "$!";
    sub {
	defined ($_ = <$fh>) or return;
	chomp; $_;
    }
}

# example: 
#
# my %author;
# mapM_ {
#     mapM_ { /\s\(\s*(.*?)\s+[0-9]{4}/ && $author{$1}++ }
#     stream_fh "git blame $_|"
# } stream_fh "git ls-files|";


# sub lgrep (&;$) {
#     my ( $sub, $list ) = @_;
#     fold filter $sub, $list;
# }

=head1 NAME

Lazyness - a taste of haskell in perl

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

Lazyness is an implementation of haskell functions using closures as
parameters. 

from haskell: take, takeWhile, filter, fold, mapM
( can closures be compared with haskell monads? )

from myself : stepBy, byPairs
( can be renamed following haskell terminology )

dbi_stream and prepare_sth to create streams from dbi
( TODO:  doc and tests )

    use strict;
    use warnings;
    use Lazyness ':all';

    say for fold take 10, sub { 1 }
    say for fold
	takeWhile { $_ < 300 }
	do { my $x = 6; sub { $x*= 6 } }

    my $pow6 = 
	takeWhile { $_ < 300 }
	do { my $x = 6; sub { $x*= 6 } }
    ;
    while ( my $x = &$pow6 ) { say $x }

    # all numbers from $x to infinity
    sub to_infinity_from {
	my $start = shift;
	sub { $start++ }
    }

    # all evens from 1 to infinity
    sub list_of_positive_evens {
	filter { not ( $_ % 2  ) } to_infinity_from(1);
    }

    # prints the 10 first evens
    my $list = take 10, list_of_positive_evens;
    while ( my $x = &$list ) { say $x }

    # also prints the 10 first evens
    sub first_positive_evens { fold take shift, list_of_positive_evens }
    say for first_positive_evens(10);

    # also prints the 10 first evens
    sub top_10 { fold take 10, shift }
    say for top_10 list_of_positive_evens;

    # also all evens under 20
    sub under_20 { fold takeWhile { $_ < 20} shift }
    say for under_20 list_of_positive_evens;

So in the real world, you can write

    #! /usr/bin/perl
    use 5.10.0;
    use Lazyness ':all';
    use Text::CSV;

    ( my $csv_parser = Text::CSV->new({ qw/ binary 1 sep_char : / })
	    or die Text::CSV->error_diag
    )->column_names(qw/ login passwd uid gid gecos home shell /);
    # root:x:0:0:root:/root:/bin/bash

    open my $passwd_entries,'getent passwd |' or die $!;

    sub is_user {
	has_primary_group( sub { $_ > 1000 })
	&& $$_{login} ne 'nobody'
    }

    # has_primary_group [0,1000]
    # has_primary_group 100
    # has_primary_group ( sub { $_ > 1000 } )
    sub has_primary_group  { shift ~~ $$_{gid} }

    sub all_bofh_friends (&) { filter { is_user } shift }

    say join ' = ', @$_{qw/login uid gid /}
    for fold all_bofh_friends
	{ $csv_parser->getline_hr( $passwd_entries ) }

=head1 EXPORT

=head1 FUNCTIONS

=head2 take $n, $closures

takes $n elements to the closure

=cut

=head2 takeWhile $test, $closures

takes elements of the closure while test is true 

=cut


=head2 filter $test, $closures

takes all elements of the closure that matches the $test

=cut

=head2 fold $closure

transform a closure to an array

=cut

=head2 lgrep (does't work)

shortcut for fold filter 

=cut

=head1 AUTHOR

Marc Chantreux, C<< <khatar at phear.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-lazyness at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Lazyness>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Lazyness


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

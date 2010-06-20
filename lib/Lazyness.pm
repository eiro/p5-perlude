package Lazyness;
use warnings;
use strict;
use parent 'Exporter';
our @EXPORT_OK = qw/ take takeWhile filter collect /;
our %EXPORT_TAGS = ( all =>  \@EXPORT_OK );

our $VERSION = '0.01';

sub take {
    my ( $want_more, $some ) = @_;
    sub { $want_more-- > 0 ?  $some->() : undef }
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

sub filter (&;$) {
    my ( $test, $list ) = @_;
    sub {
	my $block = $list || shift;
	while ( defined ( local $_ = $block->() ) ) {
	    $test->() and return $_
	}
	undef;
    }
}

sub collect ($) {
    my ( $list ) = @_;
    my @r; 
    while ( defined ( my $element = $list->() ) ) {
	push @r,$element
    }
    @r;
}

# sub lgrep (&;$) {
#     my ( $sub, $list ) = @_;
#     collect filter $sub, $list;
# }



=head1 NAME

Lazyness - a taste of haskell in perl

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS

Lazyness is an implementation of haskell functions using closures as
parameters. 

stolen from haskell: take, takeWhile, filter
stolen from ruby: collect

    use strict;
    use warnings;
    use Lazyness ':all';

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
    sub first_positive_evens { collect take shift, list_of_positive_evens }
    say for first_positive_evens(10);

    # also prints the 10 first evens
    sub top_10 { collect take 10, shift }
    say for top_10 list_of_positive_evens;

    # also all evens under 20
    sub under_20 { collect takeWhile { $_ < 20} shift }
    say for under_20 list_of_positive_evens;

So in the real world, you can write

    use Lazyness ':all';
    use Text::CSV;
    use YAML;

    # everyone with a birth year < 1992 is an adult 
    sub all_adults (&) {
	filter {
	    $$_{birthdate} ~~ /(?<year>\d{4})-/
		and $+{year} < 1992
	} shift
    }

    sub get_an_adult_exemple { take 1, all_adults }

    # opening CSV file 
    ( my $csv = Text::CSV->new({qw/ binary 1 sep_char : /})
	    or die Text::CSV->error_diag
    )->column_names(qw/firstname lastname birthdate login /);
    open my $fh,'users.csv' or die "$!";

    # make a YAML dump of an adult example 
    say YAML::Dump [ get_an_adult_exemple { $csv->getline_hr($fh) } ];

    # the $fh stopped at the next line. you can still use it

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

=head2 collect $closure

transform a closure to an array

=cut

=head2 lgrep (does't work)

shortcut for collect filter 

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

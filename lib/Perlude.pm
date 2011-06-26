package Perlude;
use Modern::Perl;
use Exporter qw< import >;
our @EXPORT = qw<

    fold unfold 
    takeWhile take drop
    filter apply
    funnel

>; 

sub unfold (@) {
    my @array = @_;
    sub { @array ? shift @array : () }
}

sub fold ($) {
    my ( $i ) = @_;
    my (@r, @v);
    push @r, @v while @v = $i->();
    @r;
}

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
    takeWhile { $n-- > 0 } $i;
}

sub drop ($$) {
    my ( $n, $i ) = @_;
    take $n, $i;
    $i;
}

sub apply (&$) {
    my ( $code, $i ) = @_;
    sub {
	( my @v = $i->() ) or return;
	map $code->(), @v;
    }
}

sub cycle {
    (my @ring = @_) or return sub {};
    my $index = 0;
    sub { $ring[ $index++ % @ring ] }
}

1;

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


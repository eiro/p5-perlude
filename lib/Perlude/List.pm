package Perlude::List;

use strict;
use warnings;

sub TIEARRAY
{
    my ($class, $i) = @_;
    bless [ $i ], $class;
}

sub SHIFT
{
    my $self = shift;
    $self->[0]->()
}

sub UNSHIFT
{
    my $self = shift;
    push @{$self}, \@_;
    bless $self, 'Perlude::List::Unshift';
    undef
}

package Perlude::List::Unshift;

our @ISA = 'Perlude::List';

sub TIEARRAY
{
    die;
}

sub SHIFT
{
    my $self = shift;
    #warn "# Perlude::List::Unshift::SHIFT\n";
    my $v = shift @{$self->[1]};
    unless (@{$self->[1]}) {
        delete $self->[1];
        bless $self, 'Perlude::List';
    }
    $v
}

sub UNSHIFT
{
    my $self = shift;
    unshift @{$self->[1]}, @_;
}

BEGIN {
    *DEBUG = $ENV{PERL_PERLUDE_LIST_DEBUG} ? sub () { 1 } : sub() { 0 };
}

# Looks like that at least Perl 5.10.1 needs this for unshift on a Perlude::List
sub FETCHSIZE
{
    warn "FETCHSIZE\n" if DEBUG;
    0;
}

1;

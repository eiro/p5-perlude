package Perlude::List;

use strict;
use warnings;

sub TIEARRAY
{
    my ($class, $i) = @_;
    bless $i, $class;
}

sub SHIFT
{
    my $self = shift;
    $self->()
}

1;

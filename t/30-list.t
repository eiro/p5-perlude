use strict;
use warnings;
use Test::More tests => 3;

use Perlude;
use Perlude::List;

{
    tie my @list, Perlude::List::, range(1, undef);
    is((shift @list), 1);
    is((shift @list), 2);
    is((shift @list), 3);
}



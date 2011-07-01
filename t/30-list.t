use strict;
use warnings;
use Test::More tests => 5;

use Perlude;
use Perlude::List;

{
    tie my @list, Perlude::List::, range(1, undef);
    isa_ok tied(@list), 'Perlude::List', 'isa';
    is((shift @list), 1);
    is((shift @list), 2);
    is((shift @list), 3);
    isa_ok tied(@list), 'Perlude::List', 'isa';
}



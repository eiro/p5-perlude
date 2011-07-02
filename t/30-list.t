use strict;
use warnings;
use Test::More tests => 17;

use Perlude;
use Perlude::List;

{
    tie my @list, Perlude::List::, range(1, undef);
    isa_ok tied(@list), 'Perlude::List', 'isa';
    is((shift @list), 1);
    is((shift @list), 2);
    is((shift @list), 3);
    isa_ok tied(@list), 'Perlude::List', 'isa';
    unshift @list, 482;
    isa_ok tied(@list), 'Perlude::List::Unshift', 'isa';
    is((shift @list), 482);
    isa_ok tied(@list), 'Perlude::List', 'isa';
    is((shift @list), 4);
    isa_ok tied(@list), 'Perlude::List', 'isa';
    unshift @list, 327, 624;
    isa_ok tied(@list), 'Perlude::List::Unshift', 'isa';
    is((shift @list), 327);
    isa_ok tied(@list), 'Perlude::List::Unshift', 'isa';
    is((shift @list), 624);
    isa_ok tied(@list), 'Perlude::List', 'isa';
    is((shift @list), 5);
    isa_ok tied(@list), 'Perlude::List', 'isa';
}



#!perl -T

use Test::More tests => 1;
BEGIN { use_ok( 'Perlude' ) }
diag( "Testing Perlude $Perlude::VERSION, Perl $], $^X" );

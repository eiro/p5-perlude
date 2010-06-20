#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Lazyness' );
}

diag( "Testing Lazyness $Lazyness::VERSION, Perl $], $^X" );

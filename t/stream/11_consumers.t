use strict;
use warnings;
use 5.10.0;
use Test::More skip_all => "rewrite everything";
use Perlude;
# 
# my $limit = 10_000;
# 
# my $try;
# 
# sub try {$try = shift}
# 
# sub with {
#     my ($fn, $in, $expected, $filter ) = @_;
#     is_deeply [fold $filter, unfold @$in ]
#     , $expected
#     , "$fn : $try";
# }
# 
# my @wierds = (undef,0,'');
# 
# for my $w (@wierds) {
# 
#     my $str = $w // "undef";
#     try "with $str somewhere"; 
# 
#     # testing         # with         # exect      # trying
#     with takeWhile => [1, $w, 10]    => [1,$w]    =>  takeWhile {$_ < 10} ;
#     with take      => [1, $w, 10]    => [1,$w]    =>  take 2              ;
# 
# }
# 
# done_testing;
# 
# # [ "with a 0 somewhere" =>
# #     [ [11,0,23], [11] => takeWhile => sub {$_> 10} 
# # 
# # 
# #     ]
# # 
# #     [ [1] 
# #     , takeWhile => sub {$_ < 10}
# #     , unfold(1,10,4) ]
# #     [ [ [1]
# #     , takeWhile => sub {$_ < 10}
# #     , unfold(1,10,4) ]
# # 
# # , "with undef somewhere" =>
# # 
# # , "take care of the test" =>
# # 
# # , "generator exhausts first" => 
# # 
# #     [ [ [1]
# #     , takeWhile => sub {$_ < 10}
# #     , unfold(1,10,4) ]
# #     [ [ [1]
# #     , takeWhile => sub {$_ < 10}
# #     , unfold(1,10,4) ]
# # 
# # , "filter exhausts first" => 
# # 
# # ]
# # 
# # take => 
# # 
# # ( "don't take too much" =>
# # 
# #     [ [ [1]
# #         , takeWhile => sub {$_ < 10}
# #         ,  unfold(1,10,4) ]
# # 
# #     [ [ [1]
# #         , takeWhile => sub {$_ < 10}
# #         ,  unfold(1,10,4) ]
# # 
# #     ]
# # 
# # 
# # )
# # 
# # my @tests =
# # ( [ takeWhile => "don't miss the condition" => [1]
# #     , sub { $_ < 10 }
# # 
# # , [ takeWhile => "empty is empty" => []
# #     , sub { $_ < 10 }
# #     , unfold() ]
# # 
# # , [ takeWhile => "empty when first element match" => []
# #     , sub { $_ < 10 }
# #     , unfold(10) ]
# # 
# # , [ take => "don't take too much" => [1,2]
# #     , 2 
# #     , unfold( 1 .. 30 ) ]
# # 
# # , [ take => "take everything" => [0,1]
# #     , 2
# #     , unfold( 0, 1 ) ]
# # 
# # , [ take => "0 is also a number" => [0,1]
# #     , 2
# #     , unfold( 0, 1, 2 ) ]
# # 
# # , [ take => "empty is empty" => []
# #     , 3
# #     , unfold() ]
# # 
# # , [ take => "take exact count" => [1]
# #     , 3
# #     , unfold(1) ]
# # 
# # , [ take => "undef if fine as a member of the stream" => [undef, 2]
# #     , 3
# #     , unfold( undef, 2 ) ]
# # 
# # # , [ take => 0, unfold( undef, 2 ), [] ]
# # # , [ take => 0.5, sub { state $n; $n++ }, [ 0 ] ]
# # # , [ drop => 2, unfold( 1 .. 30 ), [ 3 .. 30 ] ]
# # # , [ drop => 2, unfold( 0, 1 ), [] ]
# # # , [ drop => 2, unfold( 0, 1, 2 ), [2] ]
# # # , [ drop => 3, unfold(),  [] ]
# # # , [ drop => 3, unfold(1), [] ]
# # # , [ drop => 3, unfold( undef, 2 ), [] ]
# # # , [ drop => 0, unfold( undef, 2 ), [ undef, 2 ] ]
# # # , [ drop => 0.1, unfold( 1 .. 3 ), [ 2, 3 ] ]
# # # , [ filter => sub { $_ % 2 }, unfold( 1, 2, 3 ), [1,3] ]
# # # , [ filter => sub { $_ % 2 }, sub { state $n = 0; $n++ }
# # #   , [ grep { $_ % 2 } 0 .. ( 2 * $limit ) ]
# # #   ]
# # # , [ apply  => sub { $_ % 2 }, unfold( 1, 2, 3 ), [1,0,1] ]
# # # , [ apply  => sub { $_ % 2 }, sub { state $n = 0; $n++ }
# # #   , [ fold take $limit, cycle 0, 1 ]
# # #   ]
# # );
# # 
# # plan tests => 0+ @tests;
# # 
# # for (@tests) {
# #     my ( $fn, $test, $expected, @args ) = @$_;
# #     no strict 'refs';
# # 
# #     is_deeply
# #     ( [fold &$fn(@args)]
# #     , $expected
# #     , "$fn : $test");
# # 
# # }
# # 
# # # , [ take => -1, unfold( undef, 2 ), [] ]
# # # , [ take => 'ABC', sub { state $n; $n++ }, [] ]
# # # , [ drop => -1, unfold( undef, 2 ), [ undef, 2 ] ]
# # # , [ drop => "ABC", unfold( 1 .. 3 ), [ 1 .. 3 ] ]

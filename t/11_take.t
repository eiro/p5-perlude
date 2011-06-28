#! /usr/bin/perl
use Modern::Perl;
use Test::More;
use Perlude;

my @takeWhile =
( [ sub { $_ < 10 }, [ 1 , 10, 4 ], [1] ]
, [ sub { $_ < 10 }, [], [] ]
, [ sub { $_ < 10 }, [10], [] ]
);

my @take =
( [ 2,  [1..30], [1,2] ]
, [ 2,  [0,1], [0,1]  ]
, [ 2,  [0,1,2], [0,1] ]
, [ 3,  [], []        ]
, [ 3,  [1], [1]      ]
, [ 3,  [undef,2], [undef,2]      ]
, [ 0,  [undef,2], []      ]
, [ -1, [undef,2], []      ]
);

my @drop =
( [ 2,  [1..30], [3..30] ]
, [ 2,  [0,1], []  ]
, [ 2,  [0,1,2], [2] ]
, [ 3,  [], []        ]
, [ 3,  [1], []      ]
, [ 3,  [undef,2], []      ]
, [ 0,  [undef,2], [undef,2]      ]
, [ -1, [undef,2], [undef,2]      ]
);

plan tests
=> @takeWhile
+  @take
+  @drop
;

for my $t (@takeWhile) {
    my ( $cond, $in, $out ) = @$t;
    local $"=',';
    is_deeply
    ( [ fold takeWhile \&$cond, unfold @$in ]
    , $out
    , "takewhile @$in"
    )
}

for my $t (@take) {
    my ( $n, $in, $out ) = @$t;
    is_deeply
    ( [fold take $n, unfold @$in ]
    , $out
    , "take"
    )
}

for my $t (@drop) {
    my ( $n, $in, $out ) = @$t;
    is_deeply
    ( [fold drop $n, unfold @$in ]
    , $out
    , "drop"
    )
}

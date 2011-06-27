use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new
( qw{
    module_name Perlude
    dist_version_from lib/Perlude.pm
    license perl
    }
, dist_author         => 'Marc Chantreux <marc.chantreux@biblibre.com>'
, build_requires => {qw{
	Test::Pod   1.22
	Test::More  0
	YAML        0
    }}
, add_to_cleanup      => [ 'Lazyness-*' ],
, meta_add =>
    { homepage => 'https://github.com/eiro/p5-perlude'
    , repository => 'https://github.com/eiro/p5-perlude.git'
    , bugtracker => 'https://rt.cpan.org/Dist/Display.html?Queue=Perlude',
    }
);

$builder->create_build_script();

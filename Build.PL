use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new
( qw{
    module_name Perlude
    dist_version_from lib/Perlude.pm
    create_makefile_pl traditional
    license perl
    }
, dist_author         => 'Marc Chantreux <marc.chantreux@biblibre.com>'
, build_requires => {qw{
	Test::Pod   1.22
	Test::More  0
	YAML        0
    }}
, add_to_cleanup      => [ 'Lazyness-*' ],
);

$builder->create_build_script();

use strict;
use warnings;

use Test::More;
use Test::Exception;
use lib qw(t/lib);
use DBICTest;

my $schema = DBICTest->init_schema();

my $cds_by_artist = $schema->resultset('Artist')
                            ->find({ artistid => 1 })
                             ->cds;

my $cds_and_tracks = $schema->resultset('CD')->search (
  { cdid => { -in => $cds_by_artist->get_column ('cdid')->as_query } },
  { prefetch => 'tracks' },
);

use Data::Dumper;
die $cds_and_tracks->hri_dump;

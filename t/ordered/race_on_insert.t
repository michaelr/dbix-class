use strict;
use warnings;

use Test::More;
use Test::Exception;
use Time::HiRes qw/time sleep/;
use lib qw(t/lib);
use DBICTest;

my $schema = DBICTest->init_schema( sqlite_use_file => 1 );
my $cd = $schema->resultset('CD')->next;
ok( $cd, 'Found a CD' );

my $track_rs = $cd->tracks;
ok ($track_rs->count, 'CD has some tracks');

my $last_position = $track_rs->search ({}, { order_by => { -desc => 'position' } } )->next->pos;
ok ($last_position, 'got last ordered position');

# Make sure that we can force a duplicate key violation
throws_ok( sub {
  $track_rs->create( {
    position => $last_position,
    title    => 'Bad last track',
  });
}, qr/not unique/, 'Received expected duplicate key violation' );

$schema->storage->debug(1);

my $children = 5;
my $inserts_per_child = 3;

# naturally doesn't work
#my $next_pos = undef;

# works like a charm...
my $next_pos = $track_rs->get_column('position')->max_rs->as_query;
$$next_pos->[0] = "$$next_pos->[0] + 1";

my @pids;
for ( 1 .. $children ) {
  push @pids, fork();

  next if $pids[-1];
  die 'failed to fork' unless defined $pids[-1];

  # wait until next-second-and-a-tenth
  # synchronizes all children to start working at the same time
  my $t = time();
  sleep (int ($t) + 1.1 - $t);

  for ( 1 .. $inserts_per_child ) {
    $track_rs->create( { title => "$$ $_", position => $next_pos } );
  }

  exit 0; # normal exit
}

for my $pid (@pids) {
    waitpid ($pid, 0);
    ok (! $?, "Child $pid exit ok");
}

done_testing;

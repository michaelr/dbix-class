use strict;
use warnings;

use Test::More;

use lib qw(t/lib);
use DBIx::Class::SQLAHacks::Oracle;
use DBICTest;
use DBIC::SqlMakerTest;

my $sql_maker = new DBIx::Class::SQLAHacks::Oracle;

{
  # my ($self, $table, $data, $options) = @_;
  my ($sql, @bind) = $sql_maker->insert(
    'artist',
    {
      'name' => 'Testartist',
    },
    {
      'returning' => [ 'artistid' ],
    },
  );

  is_same_sql_bind(
    $sql, \@bind,
    q/INSERT INTO artist (name) VALUES (?) RETURNING artistid INTO :artistid/,
      [ 'Testartist' ],
    'sql_maker generates insert returning'
  );
}

done_testing;


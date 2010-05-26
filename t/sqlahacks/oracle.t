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
    'sql_maker generates insert returning for one column'
  );
}

{
  my ($sql, @bind) = $sql_maker->insert(
    'computed_column_test',
    {
      'a_timestamp' => '2010-05-26 18:22:00',
    },
    {
      'returning' => [ 'id', 'a_computed_column', 'charfield' ],
    },
  );

  is_same_sql_bind(
    $sql, \@bind,
    q/INSERT INTO computed_column_test (a_timestamp) VALUES (?) RETURNING id, a_computed_column, charfield INTO :id, :a_computed_column, :charfield/,
      [ '2010-05-26 18:22:00' ],
    'sql_maker generates insert returning for multiple columns'
  );
}

done_testing;

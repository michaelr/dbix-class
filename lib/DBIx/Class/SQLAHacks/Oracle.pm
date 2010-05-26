package # Hide from PAUSE
  DBIx::Class::SQLAHacks::Oracle;

use base qw( DBIx::Class::SQLAHacks );
use Carp::Clan qw/^DBIx::Class|^SQL::Abstract/;

#
# Oracle has a different INSERT...RETURNING syntax
#

sub _generate_bind_param_name {
  my ($self, $colname) = @_;

  return ":$colname";
}

sub _insert_returning {
  my ($self, $fields) = @_;

  my $f = $self->_SWITCH_refkind($fields, {
    ARRAYREF     => sub {join ', ', map { $self->_quote($_) } @$fields;},
    SCALAR       => sub {$self->_quote($fields)},
    SCALARREF    => sub {$$fields},
  });
  
  my $bind_f = $self->_SWITCH_refkind($fields, {
    ARRAYREF     => sub {join ', ', map { $self->_generate_bind_param_name($_) } @$fields;},
    SCALAR       => sub {$self->_generate_bind_param_name($fields)},
    SCALARREF    => sub {$self->_generate_bind_param_name($$fields)},
  });
  
  return join (' ', $self->_sqlcase(' returning'), $f, $self->_sqlcase('into'), $bind_f);
}

1;

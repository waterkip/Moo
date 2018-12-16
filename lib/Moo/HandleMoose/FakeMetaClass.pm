package Moo::HandleMoose::FakeMetaClass;
use Moo::_strictures;
use Carp ();
BEGIN { our @CARP_NOT = qw(Moo::HandleMoose) }

sub DESTROY { }

sub AUTOLOAD {
  my ($meth) = (our $AUTOLOAD =~ /([^:]+)$/);
  my $self = shift;
  Carp::croak "Can't call $meth without object instance"
    if !ref $self;
  Carp::croak "Can't inflate Moose metaclass with Moo::sification disabled"
    if $Moo::sification::disabled;
  require Moo::HandleMoose;
  Moo::HandleMoose::inject_real_metaclass_for($self->{name}, $self)->$meth(@_);
}

sub can {
  my $self = shift;
  return $self->SUPER::can(@_)
    if !ref $self or @_ != 1 or !defined $_[0] or !length $_[0] or $Moo::sification::disabled;

  {
    no strict 'refs';
    return \&{$_[0]}
      if defined &{$_[0]};
  }

  require Moo::HandleMoose;
  Moo::HandleMoose::inject_real_metaclass_for($self->{name}, $self)->can(@_);
}

sub isa {
  my $self = shift;
  return $self->SUPER::isa(@_)
    if !ref $self or $Moo::sification::disabled;
  require Moo::HandleMoose;
  Moo::HandleMoose::inject_real_metaclass_for($self->{name}, $self)->isa(@_);
}

sub does_role {
  require Moo::Role;
  my ($self, $role) = @_;
  Moo::Role::does_role($self->{name}, $role);
}

sub make_immutable { $_[0] }

1;

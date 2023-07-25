package CheckWutHealth::NTI;
our @ISA = qw(CheckWutHealth::Device);
use strict;

sub init {
  my ($self) = @_;
  if ($self->implements_mib('ENVIROMUX5D')) {
    $self->rebless('CheckWutHealth::NTI::ENVIROMUX5D');
  }
  if (ref($self) ne "CheckWutHealth::NTI") {
    $self->init();
  } else {
    $self->no_such_mode();
  }
}


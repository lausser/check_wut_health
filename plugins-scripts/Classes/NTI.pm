package Classes::NTI;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my ($self) = @_;
  if ($self->implements_mib('ENVIROMUX5D')) {
    $self->rebless('Classes::NTI::ENVIROMUX5D');
  }
  if (ref($self) ne "Classes::NTI") {
    $self->init();
  } else {
    $self->no_such_mode();
  }
}


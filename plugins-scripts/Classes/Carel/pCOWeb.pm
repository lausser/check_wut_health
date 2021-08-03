package Classes::Carel::pCOWeb;
use strict;
our @ISA = qw(Classes::Carel);


sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor/) {
    $self->analyze_and_check_sensor_subsystem('Classes::Carel::pCOWeb::Component::SensorSubsystem');
  } else {
    $self->no_such_mode();
  }
}




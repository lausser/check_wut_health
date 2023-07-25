package CheckWutHealth::Carel::pCOWeb;
use strict;
our @ISA = qw(CheckWutHealth::Carel);


sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor/) {
    $self->analyze_and_check_sensor_subsystem('CheckWutHealth::Carel::pCOWeb::Component::SensorSubsystem');
  } else {
    $self->no_such_mode();
  }
}




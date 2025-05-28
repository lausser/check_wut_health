package CheckWutHealth::Carel::Boss;
use strict;
our @ISA = qw(CheckWutHealth::Carel);


sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor/) {
    $self->analyze_and_check_sensor_subsystem('CheckWutHealth::Carel::Boss::Component::SensorSubsystem');
  } elsif ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem('CheckWutHealth::Carel::Boss::Component::EnvironmentalSubsystem');
  } else {
    $self->no_such_mode();
  }
}




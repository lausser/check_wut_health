package CheckWutHealth::Emerson::KnuerrDCL;
our @ISA = qw(CheckWutHealth::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_sensor_subsystem("CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem");
    $self->reduce_messages_short('all sensors are ok');
  } elsif ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_diag_subsystem("CheckWutHealth::Emerson::KnuerrDCL::Component::EnvironmentalSubsystem");
    $self->reduce_messages_short('no active alarms');
  } else {
    $self->no_such_mode();
  }
}



package CheckWutHealth::Raritan::PDU2;
our @ISA = qw(CheckWutHealth::Raritan);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem('CheckWutHealth::Raritan::PDU2::Component::EnvironmentalSubsystem');
    $self->reduce_messages_short('environmental hardware working fine');
  } elsif ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_sensor_subsystem("CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem");
    $self->reduce_messages_short("all sensors are within configured ranges");
  } else {
    $self->no_such_mode();
  }
}


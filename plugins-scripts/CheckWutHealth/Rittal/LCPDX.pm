package CheckWutHealth::Rittal::LCPDX;
our @ISA = qw(CheckWutHealth::Rittal);
use strict;

sub init {
  my ($self) = @_;
  if ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem('CheckWutHealth::Rittal::LCPDX::Component::EnvironmentalSubsystem');
    $self->reduce_messages('environmental hardware working fine, no alarms');
  } elsif ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_battery_subsystem('CheckWutHealth::Rittal::LCPDX::Component::SensorSubsystem');
    $self->reduce_messages('sensors are ok');
  } else {
    $self->no_such_mode();
  }
}


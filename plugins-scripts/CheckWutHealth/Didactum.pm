package CheckWutHealth::Didactum;
our @ISA = qw(CheckWutHealth::Device);
use strict;

sub init {
  my ($self) = @_;
  if ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem('CheckWutHealth::Didactum::Components::EnvironmentalSubsystem');
    $self->reduce_messages_short('environmental hardware working fine');
  } elsif ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_battery_subsystem('CheckWutHealth::Didactum::Components::SensorSubsystem');
    $self->reduce_messages_short('sensors are ok, no alarms');
  } else {
    $self->no_such_mode();
  }
}

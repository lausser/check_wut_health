package Classes::Liebert;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my ($self) = @_;
  if ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem('Classes::Liebert::Components::EnvironmentalSubsystem');
  } elsif ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_battery_subsystem('Classes::Liebert::Components::SensorSubsystem');
  } else {
    $self->no_such_mode();
  }
}

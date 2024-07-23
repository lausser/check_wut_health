package CheckWutHealth::Rittal::LCPDX;
our @ISA = qw(CheckWutHealth::Rittal);
use strict;

sub init {
  my ($self) = @_;
  if ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem('CheckWutHealth::Rittal::LCPDX::Component::EnvironmentalSubsystem');
    my $num_alarms = $self->{components}->{environmental_subsystem}->{num_alarms};
    $self->reduce_messages(
        sprintf 'environmental hardware working fine, no alarms (checked %d)',
        $num_alarms);
  } elsif ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_battery_subsystem('CheckWutHealth::Rittal::LCPDX::Component::SensorSubsystem');
    $self->reduce_messages('sensors are ok');
  } else {
    $self->no_such_mode();
  }
}


package CheckWutHealth::HWG;
our @ISA = qw(CheckWutHealth::Device);

package CheckWutHealth::HWG::WLD;
our @ISA = qw(CheckWutHealth::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_sensor_subsystem("CheckWutHealth::HWG::WLD::Component::SensorSubsystem");
  } else {
    $self->no_such_mode();
  }
}

package CheckWutHealth::HWG::WLD::Component::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables("HWg-WLD-MIB", [
      ["sensors", "sensTable", "CheckWutHealth::HWG::WLD::Component::SensorSubsystem::Sensor"],
  ]);
}

package CheckWutHealth::HWG::WLD::Component::SensorSubsystem::Sensor;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf "%s has state %s (%s)",
      $self->{wldName}, $self->{wldState}, $self->{wldValue});
  if ($self->{wldState} eq "invalid") {
    $self->add_unknown();
  } elsif ($self->{wldState} eq "alarm") {
    $self->add_critical();
  } else {
    $self->add_ok();
  }
}




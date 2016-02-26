package Classes::Raritan::EMD;
our @ISA = qw(Classes::Raritan);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_sensor_subsystem("Classes::Raritan::EMD::Component::SensorSubsystem");
  } else {
    $self->no_such_mode();
  }
}

package Classes::Raritan::EMD::Component::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_objects("EMD-MIB", qw(deviceName hardwareVersion
      firmwareVersion externalSensorCount managedExternalSensorCount
      serverCount model
  ));
  $self->get_snmp_tables("EMD-MIB", [
      ["sensors", "externalSensorConfigurationTable", "Monitoring::GLPlugin::SNMP::TableItem"],
      ["devices", "peripheralDevicePackageTable", "Monitoring::GLPlugin::SNMP::TableItem"],
      ["servers", "serverReachabilityTable", "Monitoring::GLPlugin::SNMP::TableItem"],
      ["sensorlogs", "externalSensorLogTable", "Monitoring::GLPlugin::SNMP::TableItem"],
      ["measurements", "externalSensorMeasurementsTable", "Monitoring::GLPlugin::SNMP::TableItem"],
  ]);
}

package Classes::Raritan::EMD::Component::SensorSubsystem::Sensor;
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


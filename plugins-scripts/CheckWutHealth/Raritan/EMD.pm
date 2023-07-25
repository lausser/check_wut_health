package CheckWutHealth::Raritan::EMD;
our @ISA = qw(CheckWutHealth::Raritan);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_sensor_subsystem("CheckWutHealth::Raritan::EMD::Component::SensorSubsystem");
  } else {
    $self->no_such_mode();
  }
}

package CheckWutHealth::Raritan::EMD::Component::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_objects("EMD-MIB", qw(deviceName hardwareVersion
      firmwareVersion externalSensorCount managedExternalSensorCount
      serverCount model
  ));
  $self->get_snmp_tables("EMD-MIB", [
      ["sensors", "externalSensorConfigurationTable", "CheckWutHealth::Raritan::EMD::Component::SensorSubsystem::Sensor"],
      #["devices", "peripheralDevicePackageTable", "CheckWutHealth::Raritan::EMD::Component::SensorSubsystem::Device"],
      #["servers", "serverReachabilityTable", "CheckWutHealth::Raritan::EMD::Component::SensorSubsystem::Server"],
      #["logindexes", "logIndexTable", "CheckWutHealth::Raritan::EMD::Component::SensorSubsystem::LogIndex"],
      #["logtimestamps", "logTimeStampTable", "CheckWutHealth::Raritan::EMD::Component::SensorSubsystem::LogTimeStamp"],
      #["sensorlogs", "externalSensorLogTable", "CheckWutHealth::Raritan::EMD::Component::SensorSubsystem::ExternalSensorlog"],
      ["measurements", "externalSensorMeasurementsTable", "CheckWutHealth::Raritan::EMD::Component::SensorSubsystem::ExternalSensorMeasurement"],
      #["actuators", "actuatorControlTable", "CheckWutHealth::Raritan::EMD::Component::SensorSubsystem::ActuatorControl"],
  ]);
  $self->join_table($self->{sensors}, $self->{measurements});
}

sub check {
  my ($self) = @_;
  $self->SUPER::check();
  $self->reduce_messages();
}


package CheckWutHealth::Raritan::EMD::Component::SensorSubsystem::Sensor;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  $self->{externalSensorEnabledThresholds} = 
      unpack("B8", $self->{externalSensorEnabledThresholds});
  if ($self->{externalSensorType} eq "onOff") {
    bless $self, "CheckWutHealth::Raritan::EMD::Component::SensorSubsystem::Sensor::onOff";
  }
}

sub check {
  my $self = shift;
  $self->add_info(sprintf "%s sensor %s has state %s",
      $self->{externalSensorType},
      $self->{externalSensorName},
      $self->{measurementsExternalSensorState}); 
  if ($self->{measurementsExternalSensorState} ne "normal") {
    $self->add_critical();
  } else {
    $self->add_ok();
  }
}

package CheckWutHealth::Raritan::EMD::Component::SensorSubsystem::Sensor::onOff;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf "%s sensor %s has state %s",
      $self->{externalOnOffSensorSubtype},
      $self->{externalSensorName},
      $self->{measurementsExternalSensorState}); 
  if ($self->{measurementsExternalSensorState} =~ /^(alarmed|on)$/) {
    $self->add_critical();
  } elsif ($self->{measurementsExternalSensorState} eq "normal") {
    $self->add_ok();
  } else {
    $self->add_unknown();
  }
}


package CheckWutHealth::Raritan::EMD::Component::SensorSubsystem::Device;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package CheckWutHealth::Raritan::EMD::Component::SensorSubsystem::Server;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package CheckWutHealth::Raritan::EMD::Component::SensorSubsystem::LogIndexTable;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package CheckWutHealth::Raritan::EMD::Component::SensorSubsystem::LogTimeStamp;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  $self->{logTimeStampLocal} = 
      scalar localtime $self->{logTimeStamp};
}

package CheckWutHealth::Raritan::EMD::Component::SensorSubsystem::ExternalSensorlog;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package CheckWutHealth::Raritan::EMD::Component::SensorSubsystem::ExternalSensorMeasurement;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  $self->{measurementsExternalSensorTimeStampLocal} = 
      scalar localtime $self->{measurementsExternalSensorTimeStamp};
}

package CheckWutHealth::Raritan::EMD::Component::SensorSubsystem::ActuatorControl;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;



__END__

serverCount: 8

[DEVICE_1]
peripheralDevicePackageFirmwareTimeStamp: 0
peripheralDevicePackageFirmwareVersion: 0.0
peripheralDevicePackageMinFirmwareVersion: 0
peripheralDevicePackageModel: DPX-CC2-TR
peripheralDevicePackagePosition: DEVICE-1WIREPORT:2
peripheralDevicePackageSerialNumber: PRC4900193
peripheralDevicePackageState: operational


DPX-CC2-TR

Dual contact closure sensor for use with third-party Normally Closed (NC) or Normally Open (NO) switches such as door open or closed, door locked or unlocked, smoke present or absent, etc.



[LOGTIMESTAMP_1]
logTimeStamp: 1456153260

[LOGTIMESTAMP_10]  --> INDEX         { logIndex  }
logTimeStamp: 1456153800
 
1..120

[EXTERNALSENSORMEASUREMENT_1]  INDEX         { sensorID  }
measurementsExternalSensorIsAvailable: true
measurementsExternalSensorState: normal
measurementsExternalSensorTimeStamp: 1456157428
measurementsExternalSensorValue: 0

[EXTERNALSENSORMEASUREMENT_16]
measurementsExternalSensorIsAvailable: true
measurementsExternalSensorState: alarmed
measurementsExternalSensorTimeStamp: 1456157429
measurementsExternalSensorValue: 0

[EXTERNALSENSORLOG_1.1]  --> INDEX         { sensorID, logIndex  }
logExternalSensorAvgValue: 0
logExternalSensorDataAvailable: true
logExternalSensorMaxValue: 0
logExternalSensorMinValue: 0
logExternalSensorState: normal

1..120

_[1..16].[1..120]

[SENSOR_1]
externalOnOffSensorSubtype: contact
externalSensorAccuracy: 0
externalSensorChannelNumber: 1
externalSensorDecimalDigits: 0
externalSensorDescription:
externalSensorEnabledThresholds: ^@
externalSensorHysteresis: 0
externalSensorIsActuator: 2
externalSensorLowerCriticalThreshold: 0
externalSensorLowerWarningThreshold: 0
externalSensorMaximum: 0
externalSensorMinimum: 0
externalSensorName: Not In Use
externalSensorPort: ONBOARD:CC1
externalSensorResolution: 0
externalSensorSerialNumber: PRC4550135
externalSensorStateChangeDelay: 0
externalSensorTolerance: 0
externalSensorType: onOff
externalSensorUnits: none
externalSensorUpperCriticalThreshold: 0
externalSensorUpperWarningThreshold: 0
externalSensorXCoordinate:
externalSensorYCoordinate:
externalSensorZCoordinate:

1..15

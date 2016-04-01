package Classes::Stulz::WIB8000;
our @ISA = qw(Classes::Stulz);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_sensor_subsystem("Classes::Stulz::WIB8000::Component::SensorSubsystem");
  } else {
    $self->no_such_mode();
  }
}

package Classes::Stulz::WIB8000::Component::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_objects("STULZ-WIB8000", qw(wibUnitname wibTempUnit
      wibFirmware wibsettingAuxInLow wibsettingAuxInHigh wibsettingAuxInState
  ));
  $self->get_snmp_tables("STULZ-WIB8000", [
      ["wibindexes", "wibIndexTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::WibIndex"],
      ["alarmmails", "alarmMailTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::AlarmMail"],
      ["units", "unitTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Unit"],
      ["unitstates", "unitstateTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::UnitState"],
      ["states", "StateTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::State"],
      ["logunits", "logUnitTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::LogUnit"],
      ["humidities", "infoValHumidityTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Humidity"],
      ["temperatures", "infoValTemperatureTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Temperature"],
      ["pressures", "infoValPressureTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Pressure"],
      ["waters", "infoValWaterTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Water"],
      #["refrigerants", "infoValRefrigerantTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      #["aecontrols", "infoValAEcontrolTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      #["miscs", "infoValMiscellaneousTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      #["modulefuncs", "infoModulefunctionsComponenTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      #["coolings", "infoCoolingTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      ["compressors", "infoCompressorTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Compressor"],
      #["valves", "infoValvesTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Valve"],
      #["suctionvalves", "infoSuctionvalvesTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
  ]);
  foreach my $unit (@{$self->{units}}) {
    $unit->{temperatures} = [map {
      $_->{name} = $unit->{unitsettingName}.'.'.$_->{indices}->[2]; $_;
    } grep {
        $_->{indices}->[0] eq $unit->{indices}->[0] &&
        $_->{indices}->[1] eq $unit->{indices}->[1] 
    } @{$self->{temperatures}}];
    $unit->{humidities} = [map {
      $_->{name} = $unit->{unitsettingName}.'.'.$_->{indices}->[2]; $_;
    } grep {
        $_->{indices}->[0] eq $unit->{indices}->[0] &&
        $_->{indices}->[1] eq $unit->{indices}->[1] 
    } @{$self->{humidities}}];
  }
  delete $self->{temperatures};
  delete $self->{humidities};
}

package Classes::Stulz::WIB8000::Component::SensorSubsystem::WibIndex;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package Classes::Stulz::WIB8000::Component::SensorSubsystem::AlarmMail;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package Classes::Stulz::WIB8000::Component::SensorSubsystem::UnitState;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package Classes::Stulz::WIB8000::Component::SensorSubsystem::Unit;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;
# INDEX { wibBusNumber, wibDeviceAddress }

sub finish {
  my $self = shift;
  $self->{unitsettingName} =~ s/\s+$//g;
  # unitsettingHwType: 7 = airconditioner? 
  $self->{unitsettingHwType} = "GE1" if $self->{unitsettingHwType} == 7;
}

sub check {
  my $self = shift;
  $self->add_info(sprintf 'device %s %s', $self->{unitsettingName},
      $self->{unitsettingHasFailure} ? 'failed' : 'is ok');
  if ($self->{unitsettingHasFailure}) {
    $self->add_critical();
  }
  foreach (@{$self->{temperatures}}) {
    $_->check();
  }
  foreach (@{$self->{humidities}}) {
    $_->check();
  }
}

package Classes::Stulz::WIB8000::Component::SensorSubsystem::LogUnit;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package Classes::Stulz::WIB8000::Component::SensorSubsystem::Humidity;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my $self = shift;
  foreach (qw(unitHumidity unitSetpointHumidityCorrected unitReturnAirHumidity
      unitSupplyAirHumidity fCBRoomAirHumidity fCBOutsideAirHumidity)) {
    if (exists $self->{$_}) {
      $self->{$_} /= 10;
    }
  }
}

sub check {
  my $self = shift;
  $self->add_info(sprintf 'humidity %s is %.2fC',
      $self->{name}, $self->{unitReturnAirTemperature});
  $self->set_thresholds(metric => $self->{name}, warning => '40:60', critical => '35:65');
  $self->add_message($self->check_thresholds(metric => $self->{name}, value => $self->{unitReturnAirHumidity}));
  $self->add_perfdata_....
}

package Classes::Stulz::WIB8000::Component::SensorSubsystem::Temperature;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;
# INDEX { wibBusNumber, wibDeviceAddress, wibModuleNumber }

sub finish {
  my $self = shift;
  foreach (qw(unitAirTemperature unitEmergencyTemperature
      unitSetpointAirTratureCorrected unitReturnAirTemperature
      unitSupplyAirTemperature)) {
    if (exists $self->{$_}) {
      $self->{$_} /= 10;
    }
  }
}

sub check {
  my $self = shift;
  $self->add_info(sprintf 'return air temperature %s is %.2fC',
      $self->{name}, $self->{unitReturnAirTemperature});
  $self->set_thresholds(metric => $self->{name}, warning => 25, critical => 28);
  $self->add_message($self->check_thresholds(metric => $self->{name}, value => $self->{unitReturnAirTemperature}));
}

package Classes::Stulz::WIB8000::Component::SensorSubsystem::Pressure;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package Classes::Stulz::WIB8000::Component::SensorSubsystem::Water;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package Classes::Stulz::WIB8000::Component::SensorSubsystem::Compressor;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package Classes::Stulz::WIB8000::Component::SensorSubsystem::Valve;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;



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
  #foreach (qw(wibIndexTable alarmMailTable unitTable logUnitTable infoValTemperatureTable infoValHumidityTable infoValPressureTable infoValWaterTable)) {
  foreach (qw(infoValTemperatureTable)) {
    $self->get_snmp_tables("STULZ-WIB8000", [
        #["arsch", "infoValTemperatureTable", "Monitoring::GLPlugin::TableItem"]
        [$_, $_, "Monitoring::GLPlugin::TableItem"]
    ]);
  }
  my $tables = [
      ["temperatures", "infoValTemperatureTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      ["alarmmails", "alarmMailTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      ["units", "unitTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      ["logunits", "logUnitTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      ["humidities", "infoValHumidityTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      ["pressures", "infoValPressureTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      ["waters", "infoValWaterTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      ["refrigerants", "infoValRefrigerantTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      ["aecontrols", "infoValAEcontrolTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      ["miscs", "infoValMiscellaneousTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      ["modulefuncs", "infoModulefunctionsComponenTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      ["coolings", "infoCoolingTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      ["compressors", "infoCompressorTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      ["valves", "infoValvesTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      ["suctionvalves", "infoSuctionvalvesTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      ["waters", "infoValWaterTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
  ];
  $self->xget_snmp_tables("STULZ-WIB8000", $tables);
  
  $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'STULZ-WIB8000'}->{'infoTable'} = "1.3.6.1.4.1.29462.10.2.1";
  $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'STULZ-WIB8000'}->{'infoEntry'} = "1.3.6.1.4.1.29462.10.2.1.1";
  $self->get_snmp_tables("STULZ-WIB8000", [
    #["infos", "infoTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
  ]);
}

package Classes::Stulz::WIB8000::Component::SensorSubsystem::Info;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub xfinish {
  my $self = shift;
  if (exists $self->{unitAirTemperature}) {
    bless $self, "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info";
  }
}


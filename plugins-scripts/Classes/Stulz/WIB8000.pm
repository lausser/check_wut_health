package Classes::Stulz::WIB8000;
our @ISA = qw(Classes::Stulz);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor::status/) {
    $Monitoring::GLPlugin::SNMP::session->timeout(60) if $Monitoring::GLPlugin::SNMP::session;
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
  $self->bulk_is_baeh(3); # mit dem default von 20 zerlegts das ding
  $self->get_snmp_objects("STULZ-WIB8000-MIB", qw(wibUnitname wibTempUnit
      wibFirmware wibsettingAuxInLow wibsettingAuxInHigh wibsettingAuxInState
  ));
  $self->get_snmp_tables("STULZ-WIB8000-MIB", [
      ["unitalarms", "unitAlarmsTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Alarm", undef, ["commonAlarm"]],
     #["wibindexes", "wibIndexTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::WibIndex"],
      #["alarmmails", "alarmMailTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::AlarmMail"],
      ["units", "unitTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Unit", undef, ["unitsettingName", "unitsettingHwType", "unitsettingHasFailure"]],
      ["unitoverview", "overviewTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::UnitOverview", undef, ["unitOnOff"]],
      #["unitstates", "unitstateTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::UnitState"],
      #["states", "StateTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::State"],
      #["logunits", "logUnitTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::LogUnit"],
      ["humidities", "infoValHumidityTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Humidity", undef, [qw(unitReturnAirHumidity)]],
      ["temperatures", "infoValTemperatureTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Temperature", undef, [qw(unitReturnAirTemperature)]],
      #["pressures", "infoValPressureTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Pressure"],
      #["waters", "infoValWaterTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Water"],
      #["refrigerants", "infoValRefrigerantTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      #["aecontrols", "infoValAEcontrolTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      #["miscs", "infoValMiscellaneousTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      #["modulefuncs", "infoModulefunctionsComponenTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      #["coolings", "infoCoolingTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Info"],
      #["compressors", "infoCompressorTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Compressor"],
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
  $self->{num_units} = scalar(@{$self->{unitoverview}});
  $self->{num_on_units} = scalar(grep { $_->{unitOnOff} eq "on" } @{$self->{unitoverview}});
  if ($self->opts->warningx || $self->opts->criticalx) {
    my $warningx = $self->opts->warningx;
    my $criticalx = $self->opts->criticalx;
    if (exists $warningx->{num_on_units} || exists $criticalx->{num_on_units}) {
      $self->set_thresholds(
          metric => 'num_on_units',
          warning => $warningx->{num_on_units},
          critical => $criticalx->{num_on_units},
      );
      $self->add_message(
          $self->check_thresholds(metric => 'num_on_units', value => $self->{num_on_units}),
          sprintf "%d of %d units are on", $self->{num_on_units}, $self->{num_units}
      );
      $self->add_perfdata(
          label => 'num_on_units',
          value => $self->{num_on_units},
          warning => $warningx->{num_on_units},
          critical => $criticalx->{num_on_units},
      );
    }
  }
}

package Classes::Stulz::WIB8000::Component::SensorSubsystem::WibIndex;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package Classes::Stulz::WIB8000::Component::SensorSubsystem::Alarm;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf 'wib bus %s device %s module %s has %s alarm',
      $self->{indices}->[0],
      $self->{indices}->[1],
      $self->{indices}->[2],
      $self->{commonAlarm} ? 'an' : 'no');
  if ($self->{commonAlarm}) {
    $self->add_critical();
  }
}

package Classes::Stulz::WIB8000::Component::SensorSubsystem::AlarmMail;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package Classes::Stulz::WIB8000::Component::SensorSubsystem::UnitState;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package Classes::Stulz::WIB8000::Component::SensorSubsystem::UnitOverview;
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
  foreach (qw(unitReturnAirHumidity)) {
    if (exists $self->{$_}) {
      $self->{$_} /= 10;
    }
  }
}

sub check {
  my $self = shift;
  $self->add_info(sprintf 'humidity %s is %.2f%%',
      $self->{name}, $self->{unitReturnAirHumidity});
  my $metric = 'hum_'.$self->{name};
  $self->set_thresholds(metric => $metric, warning => '40:60', critical => '35:65');
  $self->add_message($self->check_thresholds(metric => $metric, value => $self->{unitReturnAirHumidity}));
  $self->add_perfdata(
      label => $metric,
      value => $self->{unitReturnAirHumidity},
      uom => '%',
  );
}

package Classes::Stulz::WIB8000::Component::SensorSubsystem::Temperature;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;
# INDEX { wibBusNumber, wibDeviceAddress, wibModuleNumber }

sub finish {
  my $self = shift;
  foreach (qw(unitReturnAirTemperature)) {
    if (exists $self->{$_}) {
      $self->{$_} /= 10;
    }
  }
}

sub check {
  my $self = shift;
  $self->add_info(sprintf 'return air temperature %s is %.2fC',
      $self->{name}, $self->{unitReturnAirTemperature});
  my $metric = 'temp_'.$self->{name};
  $self->set_thresholds(metric => $metric, warning => 25, critical => 28);
  $self->add_message($self->check_thresholds(metric => $metric, value => $self->{unitReturnAirTemperature}));
  $self->add_perfdata(
      label => $metric,
      value => $self->{unitReturnAirTemperature},
  );
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



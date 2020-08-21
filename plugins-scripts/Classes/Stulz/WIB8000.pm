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
  $self->bulk_is_baeh(1); # mit dem default von 20 zerlegts das ding
  # aber nachher eine verschnaufpause von > 60s lassen
  $self->get_snmp_objects("STULZ-WIB8000-MIB", qw(wibUnitname wibTempUnit
      wibFirmware wibsettingAuxInLow wibsettingAuxInHigh wibsettingAuxInState
  ));
  my $timeout = $Monitoring::GLPlugin::SNMP::session->timeout();
  $Monitoring::GLPlugin::SNMP::session->timeout(5);
  $self->get_snmp_tables("STULZ-WIB8000-MIB", [
      ["units", "unitTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Unit", undef, ["unitsettingName", "unitsettingHwType", "unitsettingHasFailure"]],
      # INDEX { wibBusNumber, wibDeviceAddress, wibModuleNumber }
      # braucht man alle drei fuer die Temperaturen. Leider, die zwei Indices
      # von der unitTable reichen nicht. overviewTable ist eine Zicke.
      ["overview", "overviewTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::UnitOverview"],
  ]);
  $Monitoring::GLPlugin::SNMP::session->timeout($timeout);
  @{$self->{bus_device_module}} = ();
  foreach (@{$self->{overview}}) {
    push(@{$self->{bus_device_module}}, {
        bus => $_->{indices}->[0],
        device => $_->{indices}->[1],
        module => $_->{indices}->[2],
    });
  }
  # bus,device identifizieren eine unit
  # unitTable INDEX { wibBusNumber, wibDeviceAddress }
  $self->protect_value("bus_device_module", "bus_device_module", sub {
      my $bus_device_module_list = shift;
      # damit sich das Drecksteil vom Schock des letzten Walks erholen kann.
      if (! @{$bus_device_module_list}) {
        sleep 15;
      }
      return @{$bus_device_module_list} ? 1 : 0;
  });

  # snmpget based walk over the unitTable
  # as this returns the result immediately we call it above in get_snmp_tables
  # this here is just for the know how
  #$self->{units} = [];
  #my %seen = ();
  #foreach (grep {
  #        ! $seen{$_->{bus}.$_->{device}};
  #    } map {
  #        my $tmp = {}; %{$tmp} = %{$_};
  #        delete $tmp->{module};
  #        $tmp;
  #    } @{$self->{bus_device_module}}) {
  #    # unique bus + device
  #  my $index = join(".", ($_->{bus}, $_->{device}));
  #  my $unitsettingName =
  #      $self->get_snmp_object("STULZ-WIB8000-MIB", "unitsettingName", $index);
  #  my $unitsettingHwType =
  #      $self->get_snmp_object("STULZ-WIB8000-MIB", "unitsettingHwType", $index);
  #  my $unitsettingHasFailure =
  #      $self->get_snmp_object("STULZ-WIB8000-MIB", "unitsettingHasFailure", $index);
  #  my $unit = Classes::Stulz::WIB8000::Component::SensorSubsystem::Unit->new(
  #      indices => [split(/\./, $index)],
  #      flat_indices => $index,
  #      bus => $_->{bus},
  #      device => $_->{device},
  #      unitsettingName => $unitsettingName,
  #      unitsettingHwType => $unitsettingHwType,
  #      unitsettingHasFailure => $unitsettingHasFailure,
  #  );
  #  push(@{$self->{units}}, $unit);
  #}
  foreach my $unit (@{$self->{units}}) {
    foreach my $bdm (@{$self->{bus_device_module}}) {
      if ($bdm->{bus} == $unit->{bus} && $bdm->{device} == $unit->{device}) {
        $bdm->{expect_a_temperature} = $unit->{expect_a_temperature};
      }
    }
  }

  $timeout = $Monitoring::GLPlugin::SNMP::session->timeout();
  $Monitoring::GLPlugin::SNMP::session->timeout(15);
  foreach (@{$self->{bus_device_module}}) {
    my $index = join(".", ($_->{bus}, $_->{device}, $_->{module}));
    foreach my $oid (qw(unitSupplyAirTemperature)) {
      next if ! $_->{expect_a_temperature};
      my $value = $self->get_snmp_object("STULZ-WIB8000-MIB", $oid, $index);
      my $temp =
          Classes::Stulz::WIB8000::Component::SensorSubsystem::Temperature->new(
              indices => [split(/\./, $index)],
              flat_indices => $index,
              value => $value,
              description => $oid,
          );
      $temp->protect_value($oid.".".$index, "value", sub {
          my $tval = shift;
          return defined $tval ? 1 : 0;
      });
      push(@{$self->{temperatures}}, $temp);
    }
    #foreach my $oid (qw(unitOutsideAirHumidity)) {
    foreach my $oid (qw(unitSupplyAirHumidity)) {
      next if ! $_->{expect_a_temperature};
      my $value = $self->get_snmp_object("STULZ-WIB8000-MIB", $oid, $index);
      my $hum =
          Classes::Stulz::WIB8000::Component::SensorSubsystem::Humidity->new(
              indices => [split(/\./, $index)],
              flat_indices => $index,
              value => $value,
              description => $oid,
          );
      $hum->protect_value($oid.".".$index, "value", sub {
          my $hval = shift;
          return defined $hval ? 1 : 0;
      });
      push(@{$self->{humidities}}, $hum);
    }
    my $this_alarm = {};
    foreach my $oid (qw(commonAlarm)) {
      next if ! $_->{expect_a_temperature};
      my $value = $self->get_snmp_object("STULZ-WIB8000-MIB", $oid, $index);
      if (defined $value) {
        $this_alarm->{$oid} = $value;
      }
      #$hum->protect_value($oid.".".$index, "value", sub {
      #    my $hval = shift;
      #    return defined $hval ? 1 : 0;
      #});
    }
    if (%{$this_alarm}) {
      $this_alarm->{indices} = [split(/\./, $index)];
      $this_alarm->{flat_indices} = $index;
      push(@{$self->{unitalarms}},
          Classes::Stulz::WIB8000::Component::SensorSubsystem::Alarm->new(%{$this_alarm}));
    }
  }
  $Monitoring::GLPlugin::SNMP::session->timeout($timeout);

  my @scheise = ([
      ["unitalarms", "unitAlarmsTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Alarm", undef, ["commonAlarm"]],
     #["wibindexes", "wibIndexTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::WibIndex"],
      #["alarmmails", "alarmMailTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::AlarmMail"],
      ["units", "unitTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Unit", undef, ["unitsettingName", "unitsettingHwType", "unitsettingHasFailure"]],
      #["unitstates", "unitstateTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::UnitState"],
      #["states", "StateTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::State"],
      #["logunits", "logUnitTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::LogUnit"],
      ["humidityblocks", "infoValHumidityTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::Humidity", undef, [qw(unitReturnAirHumidity)]],
      #["temperatureblocks", "infoValTemperatureTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::TemperatureBlock", undef, [qw(unitReturnAirTemperature unitAirTemperature unitEmergencyTemperature unitSetpointAirTratureCorrected unitReturnAirTemperature unitSupplyAirTemperature unitOutsideAirTemperature unitOutsideAirHumidity unitSupplyAirTemperature3 unitReturnAirTemperature2 unitReturnAirTemperature3 unitReturnAirTemrnAirTemperature unitSupplyAirTemlyAirTemperature unitSupplyAirTemperature2 condensorTemperature supplyTemperature1 supplyTemperature2 fCBRoomAirTemperature supplyAirTemperatureComfortUnit1 supplyAirTemperatureComfortUnit2 fCBOutsideAirTemperature)]],
      ["temperatureblocks", "infoValTemperatureTable", "Classes::Stulz::WIB8000::Component::SensorSubsystem::TemperatureBlock", undef, [qw(unitSupplyAirTemperature unitSupplyAirTemperature3 unitSupplyAirTemlyAirTemperature unitSupplyAirTemperature2 condensorTemperature supplyTemperature1 supplyTemperature2 fCBRoomAirTemperature supplyAirTemperatureComfortUnit1 supplyAirTemperatureComfortUnit2 fCBOutsideAirTemperature)]],
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
      $_->{name} = $unit->{unitsettingName}.'.'.$_->{indices}->[2].' '.$_->{description}; $_;
    } grep {
        $_->{indices}->[0] eq $unit->{indices}->[0] &&
        $_->{indices}->[1] eq $unit->{indices}->[1]
    } @{$self->{temperatures}}];
    $unit->{humidities} = [map {
      $_->{name} = $unit->{unitsettingName}.'.'.$_->{indices}->[2].' '.$_->{description}; $_;
    } grep {
        $_->{indices}->[0] eq $unit->{indices}->[0] &&
        $_->{indices}->[1] eq $unit->{indices}->[1]
    } @{$self->{humidities}}];
  }
  delete $self->{temperatures};
  delete $self->{humidities};
  delete $self->{bus_device_module};
  $self->{num_units} = scalar(@{$self->{overview}});
  $self->{num_on_units} = scalar(grep { $_->{unitOnOff} eq "on" } @{$self->{overview}});
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

package Classes::Stulz::WIB8000::Component::SensorSubsystem::Overview;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

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

sub finish {
  my $self = shift;
  if (! defined $self->{unitOnOff}) {
    $self->{unitOnOff} = "on"; # Optimismus, meine Herren!
  }
}

package Classes::Stulz::WIB8000::Component::SensorSubsystem::Unit;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;
# INDEX { wibBusNumber, wibDeviceAddress }

sub finish {
  my $self = shift;
  $self->{bus} = $self->{indices}->[0];
  $self->{device} = $self->{indices}->[1];
  $self->{unitsettingName} =~ s/\s+$//g;
  # unitsettingHwType: 7 = airconditioner? 
  $self->{unitsettingHwType} = "GE1" if $self->{unitsettingHwType} == 7;
  if ($self->{unitsettingHwType} eq"GE1") {
    $self->{expect_a_temperature} = 1;
  } else {
    $self->{expect_a_temperature} = 0;
  }
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
  my ($self) = @_;
  if (defined $self->{value}) {
    $self->{value} /= 10;
  }
}

sub check {
  my $self = shift;
  $self->add_info(sprintf '%s is %.2f%%',
      $self->{name}, $self->{value});
  my $metric = 'hum_'.$self->{name};
  $self->set_thresholds(metric => $metric, warning => '40:60', critical => '35:65');
  $self->add_message($self->check_thresholds(metric => $metric, value => $self->{value}));
  $self->add_perfdata(
      label => $metric,
      value => $self->{value},
      uom => '%',
  );
}

package Classes::Stulz::WIB8000::Component::SensorSubsystem::Temperature;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  if (defined $self->{value}) {
    $self->{value} /= 10;
  }
}

sub check {
  my $self = shift;
  $self->add_info(sprintf '%s is %.2fC',
      $self->{name}, $self->{value});
  my $metric = 'temp_'.$self->{name};
  $self->set_thresholds(metric => $metric, warning => 25, critical => 28);
  $self->add_message($self->check_thresholds(metric => $metric, value => $self->{value}));
  $self->add_perfdata(
      label => $metric,
      value => $self->{value},
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



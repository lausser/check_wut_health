package CheckWutHealth::Stulz::C1002;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  @{$self->{o_infos}} = qw(unitType unitFamily systemName unitName);
  @{$self->{o_temperatures}} = qw(unitReturnAirTemperature
      unitReturnAirTemperature2 unitReturnAirTemperature3);
  @{$self->{o_temperaturessp}} = qw(unitSetpointTemperatureDay
      limitReturnAirTempTooHighAlarm limitReturnAirTempTooLowAlarm);
  @{$self->{o_humidities}} = qw(unitReturnAirHumidity);
  @{$self->{o_humiditiessp}} = qw(unitSetpointHumidity
      limitReturnAirHumidTooHighAlarm
      limitReturnAirHumidTooLowAlarm);
  @{$self->{o_runners}} = qw(compr1Running elecHeating1Running
      elecHeating2Running humidifier1Running dehumidificationRunning
      fan1Running);
  @{$self->{o_states}} = qw(unitOnOff remoteUPS localUPS);
  @{$self->{o_doors}} = qw(louver1Open);
  @{$self->{o_valves}} = qw(gECWValveOpeningGrade1);
  @{$self->{o_voltages}} = qw(dCPowerSupplyVoltage);
  foreach my $oid (@{$self->{o_infos}}, @{$self->{o_temperatures}},
      @{$self->{o_temperaturessp}}, @{$self->{o_humidities}},
      @{$self->{o_humiditiessp}}, @{$self->{o_runners}}, @{$self->{o_doors}},
      @{$self->{o_valves}}, @{$self->{o_voltages}}, @{$self->{o_states}}) {
    my $value = $self->get_snmp_object("STULZ-WIB8000-MIB", $oid, $self->{flat_indices});
    if (defined $value) {
      $self->{$oid} = $value;
    } else {
      $self->debug("dead metric: ".$oid);
    }
  }
  foreach my $oid (@{$self->{o_temperatures}}, @{$self->{o_temperaturessp}},
      @{$self->{o_humidities}}, @{$self->{o_humiditiessp}}) {
    $self->{$oid} /= 10 if exists $self->{$oid};
  }
}

sub check {
  my ($self) = @_;
  foreach my $oid (@{$self->{o_temperatures}}) {
    next if ! defined $self->{$oid};
    my $label = $oid."_".$self->{flat_indices};
    my $name = $self->{unitsettingName} ?
        $self->{unitsettingName}." ".$oid :
        $oid."_".$self->{flat_indices};
    $self->add_info(sprintf "%s is %.2fC", $name, $self->{$oid});
    $self->set_thresholds(metric => $label,
        warning => $self->{limitReturnAirTempTooLowAlarm}.":".$self->{limitReturnAirTempTooHighAlarm},
        critical => $self->{limitReturnAirTempTooLowAlarm}.":".$self->{limitReturnAirTempTooHighAlarm},
    );
    $self->add_message($self->check_thresholds(metric => $label,
        value => $self->{$oid}));
    $self->add_perfdata(label => $label,
        value => $self->{$oid});
  }
  foreach my $oid (@{$self->{o_humidities}}) {
    next if ! defined $self->{$oid};
    my $label = $oid."_".$self->{flat_indices};
    my $name = $self->{unitsettingName} ?
        $self->{unitsettingName}." ".$oid :
        $oid."_".$self->{flat_indices};
    $self->add_info(sprintf "%s is %.2f%%", $name, $self->{$oid});
    $self->set_thresholds(metric => $label,
        warning => $self->{limitReturnAirHumidTooLowAlarm}.":".$self->{limitReturnAirHumidTooHighAlarm},
        critical => $self->{limitReturnAirHumidTooLowAlarm}.":".$self->{limitReturnAirHumidTooHighAlarm},
    );
    $self->add_message($self->check_thresholds(metric => $label,
        value => $self->{$oid}));
    $self->add_perfdata(label => $label,
        value => $self->{$oid},
        uom => "%");
  }
}


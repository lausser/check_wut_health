package Classes::Stulz::Unit;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  @{$self->{o_infos}} = qw(unitType);
  # unitFamily dauert 10s, dann kommt nix
  # systemName dauert 10s, dann kommt nix
  # unitName dauert 10s, dann kommt nix
  # 30s fuer nix und wieder nix
  @{$self->{o_alarms}} = qw(commonAlarm);
  @{$self->{o_temperatures}} = qw(unitSupplyAirTemperature
      unitReturnAirTemperature);
  @{$self->{o_temperaturessp}} = qw(unitSetpointTemperatureDay
      limitReturnAirTempTooHighAlarm limitReturnAirTempTooLowAlarm
      limitSupplyAirTempTooHighAlarm limitSupplyAirTempTooLowAlarm);
  @{$self->{o_humidities}} = qw(unitSupplyAirHumidity
      unitReturnAirHumidity);
  @{$self->{o_humiditiessp}} = qw(unitSetpointHumidity
      limitReturnAirHumidTooHighAlarm limitReturnAirHumidTooLowAlarm
      limitSupplyAirHumidTooHighAlarm limitSupplyAirHumidTooLowAlarm);
  @{$self->{o_states}} = qw(unitOnOff remoteUPS localUPS);
  foreach my $oid (@{$self->{o_infos}}, @{$self->{o_temperatures}},
      @{$self->{o_temperaturessp}}, @{$self->{o_humidities}},
      @{$self->{o_humiditiessp}}, @{$self->{o_states}}, @{$self->{o_alarms}}) {
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
  if (defined $self->{commonAlarm} && $self->{commonAlarm}) {
    $self->add_info(sprintf 'wib bus %s device %s module %s has %s alarm',
      $self->{bus}, $self->{device}, $self->{module},
      $self->{commonAlarm} ? 'an' : 'no');
    if ($self->{commonAlarm}) {
      $self->add_critical();
    }
  }
}


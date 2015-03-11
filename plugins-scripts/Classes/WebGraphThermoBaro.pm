package Classes::WebGraphThermoBaro;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_sensor_subsystem("Classes::WebGraphThermoBaro::SensorSubsystem");
  } elsif ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_diag_subsystem("Classes::WebGraphThermoBaro::DiagSubsystem");
  } else {
    $self->no_such_mode();
  }
}


package Classes::WebGraphThermoBaro::DiagSubsystem;
our @ISA = qw(GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_objects("WebGraph-Thermo-Hygro-Barometer-MIB", 
      qw(wtWebGraphThermoBaroDiagErrorCount wtWebGraphThermoBaroDiagErrorMessage));
}

sub check {
  my $self = shift;
  if ($self->{wtWebGraphThermoBaroDiagErrorCount}) {
    $self->add_info(sprintf "diag error count is %d (%s)",
        $self->{wtWebGraphThermoBaroDiagErrorCount},
        $self->{wtWebGraphThermoBaroDiagErrorMessage});
    $self->add_critical();
  } else {
    $self->add_ok("environmental hardware working fine");
  }
}

package Classes::WebGraphThermoBaro::SensorSubsystem;
our @ISA = qw(GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $GLPlugin::SNMP::session->translate([
    '-octetstring' => 0x1,
    # force wtWebGraphThermoBaroAlarmTrigger in a 0xstring format
  ]);
  $self->get_snmp_objects("WebGraph-Thermo-Hygro-Barometer-MIB",
      qw(wtWebGraphThermoBaroSensors wtWebGraphThermoBaroAlarmCount wtWebGraphThermoBaroPorts));
  $self->get_snmp_tables("WebGraph-Thermo-Hygro-Barometer-MIB", [
      ["sensors", "wtWebGraphThermoBaroBinaryTempValueTable", "Classes::WebGraphThermoBaro::SensorSubsystem::Sensor"],
      ["alarms", "wtWebGraphThermoBaroAlarmTable", "Classes::WebGraphThermoBaro::SensorSubsystem::Alarm"],
      ["alarmsf", "wtWebGraphThermoBaroAlarmIfTable", "Classes::WebGraphThermoBaro::SensorSubsystem::AlarmIf"],
      ["ports", "wtWebGraphThermoBaroPortTable", "Classes::WebGraphThermoBaro::SensorSubsystem::Port"],
  ]);
  @{$self->{sensors}} = grep { $self->filter_name($_->{flat_indices}) } @{$self->{sensors}};
  foreach my $sensor (@{$self->{sensors}}) {
    $sensor->{wtWebGraphThermoBaroBinaryTempValue} /= 10;
    $sensor->{alarms} = [];
    foreach my $alarm (@{$self->{alarms}}) {
      if ($alarm->belongs_to() eq $sensor->{flat_indices}) {
        push(@{$sensor->{alarms}}, $alarm);
      }
    }
    foreach my $port (@{$self->{ports}}) {
      if ($port->{flat_indices} eq $sensor->{flat_indices}) {
        $sensor->{wtWebGraphThermoBaroPortName} = $port->{wtWebGraphThermoBaroPortName};
        if ($sensor->{wtWebGraphThermoBaroPortName} =~ /^0x/) {
          $sensor->{wtWebGraphThermoBaroPortName} =~ s/\s//g;
          $sensor->{wtWebGraphThermoBaroPortName} =~ s/0x(([0-9a-f][0-9a-f])+)/pack('H*', $1)/ie;
        }elsif ($sensor->{wtWebGraphThermoBaroPortName} =~ /^(?:[0-9a-f]{2} )+[0-9a-f]{2}$/i) {
          $sensor->{wtWebGraphThermoBaroPortName} =~ s/\s//g;
          $sensor->{wtWebGraphThermoBaroPortName} =~ s/(([0-9a-f][0-9a-f])+)/pack('H*', $1)/ie;
        }
        $sensor->{wtWebGraphThermoBaroPortName} = $self->accentfree($sensor->{wtWebGraphThermoBaroPortName});
      }
    }
    $sensor->rebless();
  }
}


package Classes::WebGraphThermoBaro::SensorSubsystem::Sensor;
our @ISA = qw(GLPlugin::SNMP::TableItem);
use strict;

sub rebless {
  my $self = shift;
  if ($self->{wtWebGraphThermoBaroPortName} =~ /temp/i) {
    bless $self, "Classes::WebGraphThermoBaro::SensorSubsystem::Sensor::Temperature";
  } elsif ($self->{wtWebGraphThermoBaroPortName} =~ /humi/i) {
    bless $self, "Classes::WebGraphThermoBaro::SensorSubsystem::Sensor::Humidity";
  } elsif ($self->{wtWebGraphThermoBaroPortName} =~ /press/i) {
    bless $self, "Classes::WebGraphThermoBaro::SensorSubsystem::Sensor::Pressure";
  }
}

sub check {
  my $self = shift;
  if (scalar(@{$self->{alarms}})) {
    foreach my $alarm (@{$self->{alarms}}) {
      $self->set_thresholds(
          metric => $self->{label}."_".$self->{wtWebGraphThermoBaroPortName},
          warning => $alarm->{wtWebGraphThermoBaroAlarmMin}.":".$alarm->{wtWebGraphThermoBaroAlarmMax},
          critical => $alarm->{wtWebGraphThermoBaroAlarmMin}.":".$alarm->{wtWebGraphThermoBaroAlarmMax});
      if ($self->check_thresholds(
          metric => $self->{label}."_".$self->{wtWebGraphThermoBaroPortName},
          value => $self->{wtWebGraphThermoBaroBinaryTempValue})) {
        $self->add_message($self->check_thresholds(
          metric => $self->{label}."_".$self->{wtWebGraphThermoBaroPortName},
          value => $self->{wtWebGraphThermoBaroBinaryTempValue}),
          sprintf "%s %s is out of range: [%s..._%s_...%s] (%s)",
            $self->{label},
            $self->{wtWebGraphThermoBaroPortName},
            defined $alarm->{wtWebGraphThermoBaroAlarmMin} ? $alarm->{wtWebGraphThermoBaroAlarmMin} : "-",
            $self->{wtWebGraphThermoBaroBinaryTempValue},
            defined $alarm->{wtWebGraphThermoBaroAlarmMax} ? $alarm->{wtWebGraphThermoBaroAlarmMax} : "-",
            $alarm->{wtWebGraphThermoBaroAlarmMailText});
      } else {
        $self->add_ok(sprintf "%s %s is in range: [%s..._%s_...%s]",
            $self->{label},
            $self->{wtWebGraphThermoBaroPortName},
            defined $alarm->{wtWebGraphThermoBaroAlarmMin} ? $alarm->{wtWebGraphThermoBaroAlarmMin} : "-",
            $self->{wtWebGraphThermoBaroBinaryTempValue},
            defined $alarm->{wtWebGraphThermoBaroAlarmMax} ? $alarm->{wtWebGraphThermoBaroAlarmMax} : "-");
      }
      $self->add_perfdata(
          label => $self->{label}."_".$self->{wtWebGraphThermoBaroPortName},
          value => $self->{wtWebGraphThermoBaroBinaryTempValue},
          uom => $self->{units},
          min => $alarm->{wtWebGraphThermoBaroAlarmMin},
          max => $alarm->{wtWebGraphThermoBaroAlarmMax},
          warning => ($self->get_thresholds(metric => $self->{label}."_".$self->{wtWebGraphThermoBaroPortName}))[0],
          critical => ($self->get_thresholds(metric => $self->{label}."_".$self->{wtWebGraphThermoBaroPortName}))[1],
      );
    }
  } else {
    $self->set_thresholds(
        metric => $self->{label}."_".$self->{wtWebGraphThermoBaroPortName},
        warning => undef,
        critical => undef);
    $self->add_message($self->check_thresholds(
          metric => $self->{label}."_".$self->{wtWebGraphThermoBaroPortName},
          value => $self->{wtWebGraphThermoBaroBinaryTempValue}), sprintf "%s is %s%s",
        $self->{wtWebGraphThermoBaroPortName},
        $self->{wtWebGraphThermoBaroBinaryTempValue}, $self->{units});
    $self->add_perfdata(
        label => $self->{label}."_".$self->{wtWebGraphThermoBaroPortName},
        value => $self->{wtWebGraphThermoBaroBinaryTempValue},
        warning => ($self->get_thresholds(metric => $self->{label}."_".$self->{wtWebGraphThermoBaroPortName}))[0],
        critical => ($self->get_thresholds(metric => $self->{label}."_".$self->{wtWebGraphThermoBaroPortName}))[1],
        uom => $self->{units},
    );
  }
}

package Classes::WebGraphThermoBaro::SensorSubsystem::Alarm;
our @ISA = qw(GLPlugin::SNMP::TableItem);

sub finish {
  my $self = shift;
  if ($self->{wtWebGraphThermoBaroAlarmMailText} =~ /^0x(.*)/) {
    $self->{wtWebGraphThermoBaroAlarmMailText} = $1;
    $self->{wtWebGraphThermoBaroAlarmMailText} =~ s/([a-fA-F0-9][a-fA-F0-9])/chr(hex($1))/eg;
    $self->{wtWebGraphThermoBaroAlarmMailText} =~ s/[[:cntrl:]]+//g;
    $self->{wtWebGraphThermoBaroAlarmMailText} =~ s/\|/ /g;
  }
}

sub belongs_to {
  my $self = shift;
  my $trigger = $self->{wtWebGraphThermoBaroAlarmTrigger};
  if ($trigger !~ /^0x/) {
    if ($trigger !~ /^[0-9a-zA-Z ]+/) {
      $trigger = "0x".unpack("H*", $trigger);
    } else {
      $trigger = "0x".$trigger;
    }
  }
  $trigger =~ s/\s//g;
  if (oct($trigger) & oct("0b00000000000000000000000000000001")) {
    return 1;
  } elsif (oct($trigger) & oct("0b00000000000000000000000000000010")) {
    return 2;
  } elsif (oct($trigger) & oct("0b00000000000000000000000000000100")) {
    return 3;
  } elsif (oct($trigger) & oct("0b00000000000000000000000000001000")) {
    return 4;
  } elsif (oct($trigger) & oct("0b00000000000000000000000000010000")) {
    return 5;
  } elsif (oct($trigger) & oct("0b00000000000000000000000000100000")) {
    return 6;
  } elsif (oct($trigger) & oct("0b00000000000000000000000001000000")) {
    return 7;
  } elsif (oct($trigger) & oct("0b00000000000000000000000010000000")) {
    return 8;
  } else {
    return 0;
  }
}

package Classes::WebGraphThermoBaro::SensorSubsystem::AlarmIf;
our @ISA = qw(GLPlugin::SNMP::TableItem);


package Classes::WebGraphThermoBaro::SensorSubsystem::Port;
our @ISA = qw(GLPlugin::SNMP::TableItem);


package Classes::WebGraphThermoBaro::SensorSubsystem::Sensor::Temperature;
our @ISA = qw(Classes::WebGraphThermoBaro::SensorSubsystem::Sensor);

sub check {
  my $self = shift;
  $self->{label} = "temperature";
  $self->{units} = "";
  $self->SUPER::check();
}

package Classes::WebGraphThermoBaro::SensorSubsystem::Sensor::Humidity;
our @ISA = qw(Classes::WebGraphThermoBaro::SensorSubsystem::Sensor);

sub check {
  my $self = shift;
  $self->{label} = "humidity";
  $self->{units} = "%";
  $self->SUPER::check();
}


package Classes::WebGraphThermoBaro::SensorSubsystem::Sensor::Pressure;
our @ISA = qw(Classes::WebGraphThermoBaro::SensorSubsystem::Sensor);

sub check {
  my $self = shift;
  $self->{label} = "air pressure";
  $self->{units} = "";
  $self->SUPER::check();
}




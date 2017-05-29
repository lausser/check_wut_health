package Classes::WebGraphThermoBaroUS;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_sensor_subsystem("Classes::WebGraphThermoBaroUS::SensorSubsystem");
  } elsif ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_diag_subsystem("Classes::WebGraphThermoBaroUS::DiagSubsystem");
  } else {
    $self->no_such_mode();
  }
}


package Classes::WebGraphThermoBaroUS::DiagSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_objects("WebGraph-Thermo-Hygro-Barometer-US-MIB", 
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

package Classes::WebGraphThermoBaroUS::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->session_translate([
    '-octetstring' => 0x1,
    # force wtWebGraphThermoBaroAlarmTrigger in a 0xstring format
  ]);
  $self->get_snmp_objects("WebGraph-Thermo-Hygro-Barometer-US-MIB",
      qw(wtWebGraphThermoBaroSensors wtWebGraphThermoBaroAlarmCount wtWebGraphThermoBaroPorts));
  $self->get_snmp_tables("WebGraph-Thermo-Hygro-Barometer-US-MIB", [
      ["sensors", "wtWebGraphThermoBaroBinaryTempValueTable", "Classes::WebGraphThermoBaroUS::SensorSubsystem::Sensor"],
      ["alarms", "wtWebGraphThermoBaroAlarmTable", "Classes::WebGraphThermoBaroUS::SensorSubsystem::Alarm"],
      ["alarmsf", "wtWebGraphThermoBaroAlarmIfTable", "Classes::WebGraphThermoBaroUS::SensorSubsystem::AlarmIf"],
      ["ports", "wtWebGraphThermoBaroPortTable", "Classes::WebGraphThermoBaroUS::SensorSubsystem::Port"],
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
        $sensor->{wtWebGraphThermoBaroPortName} =~ s/[^[:ascii:]]//g; 
      }
    }
    $sensor->rebless();
  }
}


package Classes::WebGraphThermoBaroUS::SensorSubsystem::Sensor;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;


sub rebless {
  my $self = shift;
  # achtung, die name koennen auch so lauten: Temperatura, Humedad Relativa, Presischmiern Atmosfschmier
  if ($self->{wtWebGraphThermoBaroPortName} =~ /^temp/i) {
    bless $self, "Classes::WebGraphThermoBaroUS::SensorSubsystem::Sensor::Temperature";
  } elsif ($self->{wtWebGraphThermoBaroPortName} =~ /^hum/i) {
    bless $self, "Classes::WebGraphThermoBaroUS::SensorSubsystem::Sensor::Humidity";
  } elsif ($self->{wtWebGraphThermoBaroPortName} =~ /^pres/i) {
    bless $self, "Classes::WebGraphThermoBaroUS::SensorSubsystem::Sensor::Pressure";
  }
}

sub check {
  my $self = shift;
  if (scalar(@{$self->{alarms}})) {
    foreach my $alarm (@{$self->{alarms}}) {
      my $min = defined $alarm->{wtWebGraphThermoBaroAlarmMin} &&
          $alarm->{wtWebGraphThermoBaroAlarmMin} ne "" ?
          $alarm->{wtWebGraphThermoBaroAlarmMin} : $alarm->{wtWebGraphThermoBaroAlarmRHMin};
      my $max = defined $alarm->{wtWebGraphThermoBaroAlarmMax} &&
          $alarm->{wtWebGraphThermoBaroAlarmMax} ne "" ?
          $alarm->{wtWebGraphThermoBaroAlarmMax} : $alarm->{wtWebGraphThermoBaroAlarmRHMax};
      $self->set_thresholds(
          metric => $self->{label}."_".$self->{wtWebGraphThermoBaroPortName},
          warning => $min.":".$max,
          critical => $min.":".$max);
      if ($self->check_thresholds(
          metric => $self->{label}."_".$self->{wtWebGraphThermoBaroPortName},
          value => $self->{wtWebGraphThermoBaroBinaryTempValue})) {
        $self->add_message($self->check_thresholds(
          metric => $self->{label}."_".$self->{wtWebGraphThermoBaroPortName},
          value => $self->{wtWebGraphThermoBaroBinaryTempValue}),
          sprintf "%s %s is out of range: [%s..._%s_...%s] (%s)",
            $self->{label},
            $self->{wtWebGraphThermoBaroPortName},
            defined $min ? $min : "-",
            $self->{wtWebGraphThermoBaroBinaryTempValue},
            defined $max ? $max : "-",
            $alarm->{wtWebGraphThermoBaroAlarmMailText});
      } else {
        $self->add_ok(sprintf "%s %s is %s%s",
            $self->{wtWebGraphThermoBaroPortName},
            $self->{label},
            $self->{wtWebGraphThermoBaroBinaryTempValue},
            $self->{units},
        );
      }
      $self->add_perfdata(
          label => $self->{label}."_".$self->{wtWebGraphThermoBaroPortName},
          value => $self->{wtWebGraphThermoBaroBinaryTempValue},
          uom => $self->{units},
          min => $min,
          max => $max,
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

package Classes::WebGraphThermoBaroUS::SensorSubsystem::Alarm;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my $self = shift;
  if ($self->{wtWebGraphThermoBaroAlarmMailText} =~ /^0x(.*)/) {
    $self->{wtWebGraphThermoBaroAlarmMailText} = $1;
    $self->{wtWebGraphThermoBaroAlarmMailText} =~ s/([a-fA-F0-9][a-fA-F0-9])/chr(hex($1))/eg;
    $self->{wtWebGraphThermoBaroAlarmMailText} =~ s/[[:cntrl:]]+//g;
    $self->{wtWebGraphThermoBaroAlarmMailText} =~ s/\|/ /g;
  }
  if ($self->{wtWebGraphThermoBaroAlarmTrigger} !~ /^0x/) {
    if ($self->{wtWebGraphThermoBaroAlarmTrigger} !~ /^[0-9a-zA-Z ]+/) {
      $self->{wtWebGraphThermoBaroAlarmTrigger} =
          "0x".unpack("H*", $self->{wtWebGraphThermoBaroAlarmTrigger});
    } else {
      $self->{wtWebGraphThermoBaroAlarmTrigger} =
          "0x".$self->{wtWebGraphThermoBaroAlarmTrigger};
    }
  }
  $self->{wtWebGraphThermoBaroAlarmTrigger} =~ s/\s//g;
}

sub belongs_to {
  my $self = shift;
  my $trigger = $self->{wtWebGraphThermoBaroAlarmTrigger};
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

package Classes::WebGraphThermoBaroUS::SensorSubsystem::AlarmIf;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);


package Classes::WebGraphThermoBaroUS::SensorSubsystem::Port;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);


package Classes::WebGraphThermoBaroUS::SensorSubsystem::Sensor::Temperature;
our @ISA = qw(Classes::WebGraphThermoBaroUS::SensorSubsystem::Sensor);

sub check {
  my $self = shift;
  $self->{label} = "temperature";
  $self->{units} = "";
  $self->SUPER::check();
}

package Classes::WebGraphThermoBaroUS::SensorSubsystem::Sensor::Humidity;
our @ISA = qw(Classes::WebGraphThermoBaroUS::SensorSubsystem::Sensor);

sub check {
  my $self = shift;
  $self->{label} = "humidity";
  $self->{units} = "%";
  $self->SUPER::check();
}


package Classes::WebGraphThermoBaroUS::SensorSubsystem::Sensor::Pressure;
our @ISA = qw(Classes::WebGraphThermoBaroUS::SensorSubsystem::Sensor);

sub check {
  my $self = shift;
  $self->{label} = "air pressure";
  $self->{units} = "";
  $self->SUPER::check();
}




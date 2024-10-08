# WebGraph-Thermo-Hygro-Barometer-MIB und WebGraph-Thermo-Hygro-Barometer-US-MIB
# 1.3.6.1.4.1.5040.1.2.16                 1.3.6.1.4.1.5040.1.2.37
# sind so gut wie identisch
# 
package CheckWutHealth::WebGraphThermoHygro;
our @ISA = qw(CheckWutHealth::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_sensor_subsystem("CheckWutHealth::WebGraphThermoHygro::SensorSubsystem");
  } elsif ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_diag_subsystem("CheckWutHealth::WebGraphThermoHygro::DiagSubsystem");
  } else {
    $self->no_such_mode();
  }
}


package CheckWutHealth::WebGraphThermoHygro::DiagSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_objects("WEBGRAPH-THERMO-HYGROMETER-MIB", 
      qw(wtWebGraphThermHygroDiagErrorCount wtWebGraphThermHygroDiagErrorMessage));
}

sub check {
  my $self = shift;
  if ($self->{wtWebGraphThermHygroDiagErrorCount}) {
    $self->add_info(sprintf "diag error count is %d (%s)",
        $self->{wtWebGraphThermHygroDiagErrorCount},
        $self->{wtWebGraphThermHygroDiagErrorMessage});
    if ($self->{wtWebGraphThermHygroDiagErrorMessage} =~ /OK\s*$/) {
      $self->add_ok();
    } else {
      $self->add_critical();
    }
  } else {
    $self->add_ok("environmental hardware working fine");
  }
}

package CheckWutHealth::WebGraphThermoHygro::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->session_translate([
    '-octetstring' => 0x1,
    # force wtWebGraphThermHygroAlarmTrigger in a 0xstring format
  ]);
  $self->get_snmp_objects("WEBGRAPH-THERMO-HYGROMETER-MIB",
      qw(wtWebGraphThermHygroSensors wtWebGraphThermHygroAlarmCount wtWebGraphThermHygroPorts));
  $self->get_snmp_tables("WEBGRAPH-THERMO-HYGROMETER-MIB", [
      ["sensors", "wtWebGraphThermHygroBinaryTempValueTable", "CheckWutHealth::WebGraphThermoHygro::SensorSubsystem::Sensor"],
      ["alarms", "wtWebGraphThermHygroAlarmTable", "CheckWutHealth::WebGraphThermoHygro::SensorSubsystem::Alarm"],
      ["alarmsf", "wtWebGraphThermHygroAlarmIfTable", "CheckWutHealth::WebGraphThermoHygro::SensorSubsystem::AlarmIf"],
      ["ports", "wtWebGraphThermHygroPortTable", "CheckWutHealth::WebGraphThermoHygro::SensorSubsystem::Port"],
  ]);
  @{$self->{sensors}} = grep { $self->filter_name($_->{flat_indices}) } @{$self->{sensors}};
  $self->finish();
}

sub finish {
  my ($self) = @_;
  foreach my $sensor (@{$self->{sensors}}) {
    $sensor->{wtWebGraphThermHygroBinaryTempValue} /= 10;
    $sensor->{alarms} = [];
    foreach my $alarm (@{$self->{alarms}}) {
      if ($alarm->belongs_to() eq $sensor->{flat_indices}) {
        push(@{$sensor->{alarms}}, $alarm);
      }
    }
    foreach my $port (@{$self->{ports}}) {
      if ($port->{flat_indices} eq $sensor->{flat_indices}) {
        $sensor->{wtWebGraphThermHygroPortName} = $port->{wtWebGraphThermHygroPortName};
        if ($sensor->{wtWebGraphThermHygroPortName} =~ /^0x/) {
          $sensor->{wtWebGraphThermHygroPortName} =~ s/\s//g;
          $sensor->{wtWebGraphThermHygroPortName} =~ s/0x(([0-9a-f][0-9a-f])+)/pack('H*', $1)/ie;
        }elsif ($sensor->{wtWebGraphThermHygroPortName} =~ /^(?:[0-9a-f]{2} )+[0-9a-f]{2}$/i) {
          $sensor->{wtWebGraphThermHygroPortName} =~ s/\s//g;
          $sensor->{wtWebGraphThermHygroPortName} =~ s/(([0-9a-f][0-9a-f])+)/pack('H*', $1)/ie;
        }
        $sensor->{wtWebGraphThermHygroPortName} = $self->accentfree($sensor->{wtWebGraphThermHygroPortName});
        $sensor->{wtWebGraphThermHygroPortName} =~ s/[^[:ascii:]]//g; 
      }
    }
    $sensor->rebless();
  }
}


package CheckWutHealth::WebGraphThermoHygro::SensorSubsystem::Sensor;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;


sub rebless {
  my $self = shift;
  # achtung, die name koennen auch so lauten: Temperatura, Humedad Relativa, Presischmiern Atmosfschmier
  if ($self->{wtWebGraphThermHygroPortName} =~ /^temp/i) {
    bless $self, "CheckWutHealth::WebGraphThermoHygro::SensorSubsystem::Sensor::Temperature";
  } elsif ($self->{wtWebGraphThermHygroPortName} =~ /^hum/i) {
    bless $self, "CheckWutHealth::WebGraphThermoHygro::SensorSubsystem::Sensor::Humidity";
  } elsif ($self->{wtWebGraphThermHygroPortName} =~ /rel.*feuchte/i) {
    bless $self, "CheckWutHealth::WebGraphThermoHygro::SensorSubsystem::Sensor::Humidity";
  } elsif ($self->{wtWebGraphThermHygroPortName} =~ /(^pres|Air Pressure)/i) {
    bless $self, "CheckWutHealth::WebGraphThermoHygro::SensorSubsystem::Sensor::Pressure";
  } elsif ($self->{wtWebGraphThermHygroPortName} =~ /Luftdruck/i) {
    bless $self, "CheckWutHealth::WebGraphThermoHygro::SensorSubsystem::Sensor::Pressure";
  }
}

sub check {
  my $self = shift;
  if (scalar(@{$self->{alarms}})) {
    foreach my $alarm (@{$self->{alarms}}) {
      my $min = defined $alarm->{wtWebGraphThermHygroAlarmMin} &&
          $alarm->{wtWebGraphThermHygroAlarmMin} ne "" ?
          $alarm->{wtWebGraphThermHygroAlarmMin} : $alarm->{wtWebGraphThermHygroAlarmRHMin};
      my $max = defined $alarm->{wtWebGraphThermHygroAlarmMax} &&
          $alarm->{wtWebGraphThermHygroAlarmMax} ne "" ?
          $alarm->{wtWebGraphThermHygroAlarmMax} : $alarm->{wtWebGraphThermHygroAlarmRHMax};
      $self->set_thresholds(
          metric => $self->{label}."_".$self->{wtWebGraphThermHygroPortName},
          warning => $min.":".$max,
          critical => $min.":".$max);
      if ($self->check_thresholds(
          metric => $self->{label}."_".$self->{wtWebGraphThermHygroPortName},
          value => $self->{wtWebGraphThermHygroBinaryTempValue})) {
        $self->add_message($self->check_thresholds(
          metric => $self->{label}."_".$self->{wtWebGraphThermHygroPortName},
          value => $self->{wtWebGraphThermHygroBinaryTempValue}),
          sprintf "%s %s is out of range: [%s..._%s_...%s] (%s)",
            $self->{label},
            $self->{wtWebGraphThermHygroPortName},
            defined $min ? $min : "-",
            $self->{wtWebGraphThermHygroBinaryTempValue},
            defined $max ? $max : "-",
            $alarm->{wtWebGraphThermHygroAlarmMailText});
      } else {
        $self->add_ok(sprintf "%s %s is %s%s",
            $self->{wtWebGraphThermHygroPortName},
            $self->{label},
            $self->{wtWebGraphThermHygroBinaryTempValue},
            $self->{units},
        );
      }
      $self->add_perfdata(
          label => $self->{label}."_".$self->{wtWebGraphThermHygroPortName},
          value => $self->{wtWebGraphThermHygroBinaryTempValue},
          uom => $self->{units},
          min => $min,
          max => $max,
          warning => ($self->get_thresholds(metric => $self->{label}."_".$self->{wtWebGraphThermHygroPortName}))[0],
          critical => ($self->get_thresholds(metric => $self->{label}."_".$self->{wtWebGraphThermHygroPortName}))[1],
      );
    }
  } else {
    $self->set_thresholds(
        metric => $self->{label}."_".$self->{wtWebGraphThermHygroPortName},
        warning => undef,
        critical => undef);
    $self->add_message($self->check_thresholds(
          metric => $self->{label}."_".$self->{wtWebGraphThermHygroPortName},
          value => $self->{wtWebGraphThermHygroBinaryTempValue}), sprintf "%s is %s%s",
        $self->{wtWebGraphThermHygroPortName},
        $self->{wtWebGraphThermHygroBinaryTempValue}, $self->{units});
    $self->add_perfdata(
        label => $self->{label}."_".$self->{wtWebGraphThermHygroPortName},
        value => $self->{wtWebGraphThermHygroBinaryTempValue},
        warning => ($self->get_thresholds(metric => $self->{label}."_".$self->{wtWebGraphThermHygroPortName}))[0],
        critical => ($self->get_thresholds(metric => $self->{label}."_".$self->{wtWebGraphThermHygroPortName}))[1],
        uom => $self->{units},
    );
  }
}

package CheckWutHealth::WebGraphThermoHygro::SensorSubsystem::Alarm;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my $self = shift;
  if ($self->{wtWebGraphThermHygroAlarmMailText} =~ /^0x(.*)/) {
    $self->{wtWebGraphThermHygroAlarmMailText} = $1;
    $self->{wtWebGraphThermHygroAlarmMailText} =~ s/([a-fA-F0-9][a-fA-F0-9])/chr(hex($1))/eg;
    $self->{wtWebGraphThermHygroAlarmMailText} =~ s/[[:cntrl:]]+//g;
    $self->{wtWebGraphThermHygroAlarmMailText} =~ s/\|/ /g;
  }
  if ($self->{wtWebGraphThermHygroAlarmTrigger} !~ /^0x/) {
    if ($self->{wtWebGraphThermHygroAlarmTrigger} !~ /^[0-9a-zA-Z ]+/) {
      $self->{wtWebGraphThermHygroAlarmTrigger} =
          "0x".unpack("H*", $self->{wtWebGraphThermHygroAlarmTrigger});
    } else {
      $self->{wtWebGraphThermHygroAlarmTrigger} =
          "0x".$self->{wtWebGraphThermHygroAlarmTrigger};
    }
  }
  $self->{wtWebGraphThermHygroAlarmTrigger} =~ s/\s//g;
}

sub belongs_to {
  my $self = shift;
  my $trigger = $self->{wtWebGraphThermHygroAlarmTrigger};
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

package CheckWutHealth::WebGraphThermoHygro::SensorSubsystem::AlarmIf;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);


package CheckWutHealth::WebGraphThermoHygro::SensorSubsystem::Port;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);


package CheckWutHealth::WebGraphThermoHygro::SensorSubsystem::Sensor::Temperature;
our @ISA = qw(CheckWutHealth::WebGraphThermoHygro::SensorSubsystem::Sensor);

sub check {
  my $self = shift;
  $self->{label} = "temperature";
  $self->{units} = "";
  $self->SUPER::check();
}

package CheckWutHealth::WebGraphThermoHygro::SensorSubsystem::Sensor::Humidity;
our @ISA = qw(CheckWutHealth::WebGraphThermoHygro::SensorSubsystem::Sensor);

sub check {
  my $self = shift;
  $self->{label} = "humidity";
  $self->{units} = "%";
  $self->SUPER::check();
}


package CheckWutHealth::WebGraphThermoHygro::SensorSubsystem::Sensor::Pressure;
our @ISA = qw(CheckWutHealth::WebGraphThermoHygro::SensorSubsystem::Sensor);

sub check {
  my $self = shift;
  $self->{label} = "air pressure";
  $self->{units} = "";
  $self->SUPER::check();
}


package CheckWutHealth::WebGraphThermoHygroUS;
our @ISA = qw(CheckWutHealth::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_sensor_subsystem("CheckWutHealth::WebGraphThermoHygroUS::SensorSubsystem");
  } elsif ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_diag_subsystem("CheckWutHealth::WebGraphThermoHygroUS::DiagSubsystem");
  } else {
    $self->no_such_mode();
  }
}


package CheckWutHealth::WebGraphThermoHygroUS::DiagSubsystem;
our @ISA = qw(CheckWutHealth::WebGraphThermoHygro::DiagSubsystem);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_objects("WEBGRAPH-THERMO-HYGROMETER-US-MIB", 
      qw(wtWebGraphThermoHygroDiagErrorCount wtWebGraphThermoHygroDiagErrorMessage));
}


package CheckWutHealth::WebGraphThermoHygroUS::SensorSubsystem;
our @ISA = qw(CheckWutHealth::WebGraphThermoHygro::SensorSubsystem);
use strict;

sub init {
  my $self = shift;
  $self->session_translate([
    '-octetstring' => 0x1,
    # force wtWebGraphThermoHygroAlarmTrigger in a 0xstring format
  ]);
  $self->get_snmp_objects("WEBGRAPH-THERMO-HYGROMETER-US-MIB",
      qw(wtWebGraphThermoHygroSensors wtWebGraphThermoHygroAlarmCount wtWebGraphThermoHygroPorts));
  $self->get_snmp_tables("WEBGRAPH-THERMO-HYGROMETER-US-MIB", [
      ["sensors", "wtWebGraphThermoHygroBinaryTempValueTable", "CheckWutHealth::WebGraphThermoHygroUS::SensorSubsystem::Sensor"],
      ["alarms", "wtWebGraphThermoHygroAlarmTable", "CheckWutHealth::WebGraphThermoHygroUS::SensorSubsystem::Alarm"],
      ["alarmsf", "wtWebGraphThermoHygroAlarmIfTable", "CheckWutHealth::WebGraphThermoHygroUS::SensorSubsystem::AlarmIf"],
      ["ports", "wtWebGraphThermoHygroPortTable", "CheckWutHealth::WebGraphThermoHygroUS::SensorSubsystem::Port"],
  ]);
  @{$self->{sensors}} = grep { $self->filter_name($_->{flat_indices}) } @{$self->{sensors}};
  $self->finish();
}


sub finish {
  my ($self) = @_;
  foreach my $sensor (@{$self->{sensors}}) {
    $sensor->{wtWebGraphThermoHygroBinaryTempValue} /= 10;
    $sensor->{alarms} = [];
    foreach my $alarm (@{$self->{alarms}}) {
      if ($alarm->belongs_to() eq $sensor->{flat_indices}) {
        push(@{$sensor->{alarms}}, $alarm);
      }
    }
    foreach my $port (@{$self->{ports}}) {
      if ($port->{flat_indices} eq $sensor->{flat_indices}) {
        $sensor->{wtWebGraphThermoHygroPortName} = $port->{wtWebGraphThermoHygroPortName};
        if ($sensor->{wtWebGraphThermoHygroPortName} =~ /^0x/) {
          $sensor->{wtWebGraphThermoHygroPortName} =~ s/\s//g;
          $sensor->{wtWebGraphThermoHygroPortName} =~ s/0x(([0-9a-f][0-9a-f])+)/pack('H*', $1)/ie;
        }elsif ($sensor->{wtWebGraphThermoHygroPortName} =~ /^(?:[0-9a-f]{2} )+[0-9a-f]{2}$/i) {
          $sensor->{wtWebGraphThermoHygroPortName} =~ s/\s//g;
          $sensor->{wtWebGraphThermoHygroPortName} =~ s/(([0-9a-f][0-9a-f])+)/pack('H*', $1)/ie;
        }
        $sensor->{wtWebGraphThermoHygroPortName} = $self->accentfree($sensor->{wtWebGraphThermoHygroPortName});
        $sensor->{wtWebGraphThermoHygroPortName} =~ s/[^[:ascii:]]//g;
      }
    }
    $sensor->rebless();
  }
}


package CheckWutHealth::WebGraphThermoHygroUS::SensorSubsystem::Sensor;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;


sub rebless {
  my $self = shift;
  # achtung, die name koennen auch so lauten: Temperatura, Humedad Relativa, Presischmiern Atmosfschmier
  if ($self->{wtWebGraphThermoHygroPortName} =~ /^temp/i) {
    bless $self, "CheckWutHealth::WebGraphThermoHygroUS::SensorSubsystem::Sensor::Temperature";
  } elsif ($self->{wtWebGraphThermoHygroPortName} =~ /^hum/i) {
    bless $self, "CheckWutHealth::WebGraphThermoHygroUS::SensorSubsystem::Sensor::Humidity";
  } elsif ($self->{wtWebGraphThermoHygroPortName} =~ /rel.*feuchte/i) {
    bless $self, "CheckWutHealth::WebGraphThermoHygroUS::SensorSubsystem::Sensor::Humidity";
  } elsif ($self->{wtWebGraphThermoHygroPortName} =~ /(^pres|Air Pressure)/i) {
    bless $self, "CheckWutHealth::WebGraphThermoHygroUS::SensorSubsystem::Sensor::Pressure";
  } elsif ($self->{wtWebGraphThermoHygroPortName} =~ /Luftdruck/i) {
    bless $self, "CheckWutHealth::WebGraphThermoHygroUS::SensorSubsystem::Sensor::Pressure";
  }
}

sub check {
  my $self = shift;
  if (scalar(@{$self->{alarms}})) {
    foreach my $alarm (@{$self->{alarms}}) {
      my $min = defined $alarm->{wtWebGraphThermoHygroAlarmMin} &&
          $alarm->{wtWebGraphThermoHygroAlarmMin} ne "" ?
          $alarm->{wtWebGraphThermoHygroAlarmMin} : $alarm->{wtWebGraphThermoHygroAlarmRHMin};
      my $max = defined $alarm->{wtWebGraphThermoHygroAlarmMax} &&
          $alarm->{wtWebGraphThermoHygroAlarmMax} ne "" ?
          $alarm->{wtWebGraphThermoHygroAlarmMax} : $alarm->{wtWebGraphThermoHygroAlarmRHMax};
      $self->set_thresholds(
          metric => $self->{label}."_".$self->{wtWebGraphThermoHygroPortName},
          warning => $min.":".$max,
          critical => $min.":".$max);
      if ($self->check_thresholds(
          metric => $self->{label}."_".$self->{wtWebGraphThermoHygroPortName},
          value => $self->{wtWebGraphThermoHygroBinaryTempValue})) {
        $self->add_message($self->check_thresholds(
          metric => $self->{label}."_".$self->{wtWebGraphThermoHygroPortName},
          value => $self->{wtWebGraphThermoHygroBinaryTempValue}),
          sprintf "%s %s is out of range: [%s..._%s_...%s] (%s)",
            $self->{label},
            $self->{wtWebGraphThermoHygroPortName},
            defined $min ? $min : "-",
            $self->{wtWebGraphThermoHygroBinaryTempValue},
            defined $max ? $max : "-",
            $alarm->{wtWebGraphThermoHygroAlarmMailText});
      } else {
        $self->add_ok(sprintf "%s %s is %s%s",
            $self->{wtWebGraphThermoHygroPortName},
            $self->{label},
            $self->{wtWebGraphThermoHygroBinaryTempValue},
            $self->{units},
        );
      }
      $self->add_perfdata(
          label => $self->{label}."_".$self->{wtWebGraphThermoHygroPortName},
          value => $self->{wtWebGraphThermoHygroBinaryTempValue},
          uom => $self->{units},
          min => $min,
          max => $max,
          warning => ($self->get_thresholds(metric => $self->{label}."_".$self->{wtWebGraphThermoHygroPortName}))[0],
          critical => ($self->get_thresholds(metric => $self->{label}."_".$self->{wtWebGraphThermoHygroPortName}))[1],
      );
    }
  } else {
    $self->set_thresholds(
        metric => $self->{label}."_".$self->{wtWebGraphThermoHygroPortName},
        warning => undef,
        critical => undef);
    $self->add_message($self->check_thresholds(
          metric => $self->{label}."_".$self->{wtWebGraphThermoHygroPortName},
          value => $self->{wtWebGraphThermoHygroBinaryTempValue}), sprintf "%s is %s%s",
        $self->{wtWebGraphThermoHygroPortName},
        $self->{wtWebGraphThermoHygroBinaryTempValue}, $self->{units});
    $self->add_perfdata(
        label => $self->{label}."_".$self->{wtWebGraphThermoHygroPortName},
        value => $self->{wtWebGraphThermoHygroBinaryTempValue},
        warning => ($self->get_thresholds(metric => $self->{label}."_".$self->{wtWebGraphThermoHygroPortName}))[0],
        critical => ($self->get_thresholds(metric => $self->{label}."_".$self->{wtWebGraphThermoHygroPortName}))[1],
        uom => $self->{units},
    );
  }
}

package CheckWutHealth::WebGraphThermoHygroUS::SensorSubsystem::Alarm;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my $self = shift;
#printf "ALARM %s\n", Data::Dumper::Dumper($self);
  if ($self->{wtWebGraphThermoHygroAlarmMailText} =~ /^0x(.*)/) {
    $self->{wtWebGraphThermoHygroAlarmMailText} = $1;
    $self->{wtWebGraphThermoHygroAlarmMailText} =~ s/([a-fA-F0-9][a-fA-F0-9])/chr(hex($1))/eg;
    $self->{wtWebGraphThermoHygroAlarmMailText} =~ s/[[:cntrl:]]+//g;
    $self->{wtWebGraphThermoHygroAlarmMailText} =~ s/\|/ /g;
  }
  if ($self->{wtWebGraphThermoHygroAlarmTrigger} !~ /^0x/) {
    if ($self->{wtWebGraphThermoHygroAlarmTrigger} !~ /^[0-9a-zA-Z ]+/) {
      $self->{wtWebGraphThermoHygroAlarmTrigger} =
          "0x".unpack("H*", $self->{wtWebGraphThermoHygroAlarmTrigger});
    } else {
      $self->{wtWebGraphThermoHygroAlarmTrigger} =
          "0x".$self->{wtWebGraphThermoHygroAlarmTrigger};
    }
  }
  $self->{wtWebGraphThermoHygroAlarmTrigger} =~ s/\s//g;
}

sub belongs_to {
  my $self = shift;
  my $trigger = $self->{wtWebGraphThermoHygroAlarmTrigger};
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

package CheckWutHealth::WebGraphThermoHygroUS::SensorSubsystem::AlarmIf;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);


package CheckWutHealth::WebGraphThermoHygroUS::SensorSubsystem::Port;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);


package CheckWutHealth::WebGraphThermoHygroUS::SensorSubsystem::Sensor::Temperature;
our @ISA = qw(CheckWutHealth::WebGraphThermoHygroUS::SensorSubsystem::Sensor);

sub check {
  my $self = shift;
  $self->{label} = "temperature";
  $self->{units} = "";
  $self->SUPER::check();
}

package CheckWutHealth::WebGraphThermoHygroUS::SensorSubsystem::Sensor::Humidity;
our @ISA = qw(CheckWutHealth::WebGraphThermoHygroUS::SensorSubsystem::Sensor);

sub check {
  my $self = shift;
  $self->{label} = "humidity";
  $self->{units} = "%";
  $self->SUPER::check();
}


package CheckWutHealth::WebGraphThermoHygroUS::SensorSubsystem::Sensor::Pressure;
our @ISA = qw(CheckWutHealth::WebGraphThermoHygroUS::SensorSubsystem::Sensor);

sub check {
  my $self = shift;
  $self->{label} = "air pressure";
  $self->{units} = "";
  $self->SUPER::check();
}



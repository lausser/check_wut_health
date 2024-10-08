# WebGraph-Thermo-Hygro-Barometer-MIB und WebGraph-Thermo-Hygro-Barometer-US-MIB
# 1.3.6.1.4.1.5040.1.2.16                 1.3.6.1.4.1.5040.1.2.37
# sind so gut wie identisch
#
package CheckWutHealth::WebGraphThermoHygroBaro;
our @ISA = qw(CheckWutHealth::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_sensor_subsystem("CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem");
  } elsif ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_diag_subsystem("CheckWutHealth::WebGraphThermoHygroBaro::DiagSubsystem");
  } else {
    $self->no_such_mode();
  }
}


package CheckWutHealth::WebGraphThermoHygroBaro::DiagSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_objects("WebGraph-Thermo-Hygro-Barometer-MIB",
      qw(wtWebGraphThermoHygroBaroDiagErrorCount wtWebGraphThermoHygroBaroDiagErrorMessage));
}

sub check {
  my $self = shift;
  if ($self->{wtWebGraphThermoHygroBaroDiagErrorCount}) {
    $self->add_info(sprintf "diag error count is %d (%s)",
        $self->{wtWebGraphThermoHygroBaroDiagErrorCount},
        $self->{wtWebGraphThermoHygroBaroDiagErrorMessage});
    $self->add_critical();
  } else {
    $self->add_ok("environmental hardware working fine");
  }
}

package CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->session_translate([
    '-octetstring' => 0x1,
    # force wtWebGraphThermoHygroBaroAlarmTrigger in a 0xstring format
  ]);
  $self->get_snmp_objects("WebGraph-Thermo-Hygro-Barometer-US-MIB",
      qw(wtWebGraphThermoHygroBaroSensors wtWebGraphThermoHygroBaroAlarmCount wtWebGraphThermoHygroBaroPorts));
  $self->get_snmp_tables("WebGraph-Thermo-Hygro-Barometer-US-MIB", [
      ["sensors", "wtWebGraphThermoHygroBaroBinaryTempValueTable", "CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem::Sensor"],
      ["alarms", "wtWebGraphThermoHygroBaroAlarmTable", "CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem::Alarm"],
      ["alarmsf", "wtWebGraphThermoHygroBaroAlarmIfTable", "CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem::AlarmIf"],
      ["ports", "wtWebGraphThermoHygroBaroPortTable", "CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem::Port"],
  ]);
  @{$self->{sensors}} = grep { $self->filter_name($_->{flat_indices}) } @{$self->{sensors}};
  $self->finish();
}

sub finish {
  my ($self) = @_;
  foreach my $sensor (@{$self->{sensors}}) {
    $sensor->{wtWebGraphThermoHygroBaroBinaryTempValue} /= 10;
    $sensor->{alarms} = [];
    foreach my $alarm (@{$self->{alarms}}) {
      if ($alarm->belongs_to() eq $sensor->{flat_indices}) {
        push(@{$sensor->{alarms}}, $alarm);
      }
    }
    foreach my $port (@{$self->{ports}}) {
      if ($port->{flat_indices} eq $sensor->{flat_indices}) {
        $sensor->{wtWebGraphThermoHygroBaroPortName} = $port->{wtWebGraphThermoHygroBaroPortName};
        if ($sensor->{wtWebGraphThermoHygroBaroPortName} =~ /^0x/) {
          $sensor->{wtWebGraphThermoHygroBaroPortName} =~ s/\s//g;
          $sensor->{wtWebGraphThermoHygroBaroPortName} =~ s/0x(([0-9a-f][0-9a-f])+)/pack('H*', $1)/ie;
        }elsif ($sensor->{wtWebGraphThermoHygroBaroPortName} =~ /^(?:[0-9a-f]{2} )+[0-9a-f]{2}$/i) {
          $sensor->{wtWebGraphThermoHygroBaroPortName} =~ s/\s//g;
          $sensor->{wtWebGraphThermoHygroBaroPortName} =~ s/(([0-9a-f][0-9a-f])+)/pack('H*', $1)/ie;
        }
        $sensor->{wtWebGraphThermoHygroBaroPortName} = $self->accentfree($sensor->{wtWebGraphThermoHygroBaroPortName});
        $sensor->{wtWebGraphThermoHygroBaroPortName} =~ s/[^[:ascii:]]//g;
      }
    }
    $sensor->rebless();
  }
}


package CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem::Sensor;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;


sub rebless {
  my $self = shift;
  # achtung, die name koennen auch so lauten: Temperatura, Humedad Relativa, Presischmiern Atmosfschmier
  if ($self->{wtWebGraphThermoHygroBaroPortName} =~ /^temp/i) {
    bless $self, "CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem::Sensor::Temperature";
  } elsif ($self->{wtWebGraphThermoHygroBaroPortName} =~ / grados/i) {
    # Camara FyV 14 grados  (FyV = Frío y Vapor)
    bless $self, "CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem::Sensor::Temperature";
  } elsif ($self->{wtWebGraphThermoHygroBaroPortName} =~ /^hum/i) {
    bless $self, "CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem::Sensor::Humidity";
  } elsif ($self->{wtWebGraphThermoHygroBaroPortName} =~ /rel.*feuchte/i) {
    bless $self, "CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem::Sensor::Humidity";
  } elsif ($self->{wtWebGraphThermoHygroBaroPortName} =~ /(^pres|Air Pressure)/i) {
    bless $self, "CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem::Sensor::Pressure";
  } elsif ($self->{wtWebGraphThermoHygroBaroPortName} =~ /Luftdruck/i) {
    bless $self, "CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem::Sensor::Pressure";
  }
}

sub check {
  my $self = shift;
  if (scalar(@{$self->{alarms}})) {
    foreach my $alarm (@{$self->{alarms}}) {
      my $min = defined $alarm->{wtWebGraphThermoHygroBaroAlarmMin} &&
          $alarm->{wtWebGraphThermoHygroBaroAlarmMin} ne "" ?
          $alarm->{wtWebGraphThermoHygroBaroAlarmMin} : $alarm->{wtWebGraphThermoHygroBaroAlarmRHMin};
      my $max = defined $alarm->{wtWebGraphThermoHygroBaroAlarmMax} &&
          $alarm->{wtWebGraphThermoHygroBaroAlarmMax} ne "" ?
          $alarm->{wtWebGraphThermoHygroBaroAlarmMax} : $alarm->{wtWebGraphThermoHygroBaroAlarmRHMax};
      $self->set_thresholds(
          metric => $self->{label}."_".$self->{wtWebGraphThermoHygroBaroPortName},
          warning => $min.":".$max,
          critical => $min.":".$max);
      if ($self->check_thresholds(
          metric => $self->{label}."_".$self->{wtWebGraphThermoHygroBaroPortName},
          value => $self->{wtWebGraphThermoHygroBaroBinaryTempValue})) {
        $self->add_message($self->check_thresholds(
          metric => $self->{label}."_".$self->{wtWebGraphThermoHygroBaroPortName},
          value => $self->{wtWebGraphThermoHygroBaroBinaryTempValue}),
          sprintf "%s %s is out of range: [%s..._%s_...%s] (%s)",
            $self->{label},
            $self->{wtWebGraphThermoHygroBaroPortName},
            defined $min ? $min : "-",
            $self->{wtWebGraphThermoHygroBaroBinaryTempValue},
            defined $max ? $max : "-",
            $alarm->{wtWebGraphThermoHygroBaroAlarmMailText});
      } else {
        $self->add_ok(sprintf "%s %s is %s%s",
            $self->{wtWebGraphThermoHygroBaroPortName},
            $self->{label},
            $self->{wtWebGraphThermoHygroBaroBinaryTempValue},
            $self->{units},
        );
      }
      $self->add_perfdata(
          label => $self->{label}."_".$self->{wtWebGraphThermoHygroBaroPortName},
          value => $self->{wtWebGraphThermoHygroBaroBinaryTempValue},
          uom => $self->{units},
          min => $min,
          max => $max,
          warning => ($self->get_thresholds(metric => $self->{label}."_".$self->{wtWebGraphThermoHygroBaroPortName}))[0],
          critical => ($self->get_thresholds(metric => $self->{label}."_".$self->{wtWebGraphThermoHygroBaroPortName}))[1],
      );
    }
  } else {
    $self->set_thresholds(
        metric => $self->{label}."_".$self->{wtWebGraphThermoHygroBaroPortName},
        warning => undef,
        critical => undef);
    $self->add_message($self->check_thresholds(
          metric => $self->{label}."_".$self->{wtWebGraphThermoHygroBaroPortName},
          value => $self->{wtWebGraphThermoHygroBaroBinaryTempValue}), sprintf "%s is %s%s",
        $self->{wtWebGraphThermoHygroBaroPortName},
        $self->{wtWebGraphThermoHygroBaroBinaryTempValue}, $self->{units});
    $self->add_perfdata(
        label => $self->{label}."_".$self->{wtWebGraphThermoHygroBaroPortName},
        value => $self->{wtWebGraphThermoHygroBaroBinaryTempValue},
        warning => ($self->get_thresholds(metric => $self->{label}."_".$self->{wtWebGraphThermoHygroBaroPortName}))[0],
        critical => ($self->get_thresholds(metric => $self->{label}."_".$self->{wtWebGraphThermoHygroBaroPortName}))[1],
        uom => $self->{units},
    );
  }
}

package CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem::Alarm;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my $self = shift;
  if ($self->{wtWebGraphThermoHygroBaroAlarmMailText} =~ /^0x(.*)/) {
    $self->{wtWebGraphThermoHygroBaroAlarmMailText} = $1;
    $self->{wtWebGraphThermoHygroBaroAlarmMailText} =~ s/([a-fA-F0-9][a-fA-F0-9])/chr(hex($1))/eg;
    $self->{wtWebGraphThermoHygroBaroAlarmMailText} =~ s/[[:cntrl:]]+//g;
    $self->{wtWebGraphThermoHygroBaroAlarmMailText} =~ s/\|/ /g;
  }
  if ($self->{wtWebGraphThermoHygroBaroAlarmTrigger} !~ /^0x/) {
    if ($self->{wtWebGraphThermoHygroBaroAlarmTrigger} !~ /^[0-9a-zA-Z ]+/) {
      $self->{wtWebGraphThermoHygroBaroAlarmTrigger} =
          "0x".unpack("H*", $self->{wtWebGraphThermoHygroBaroAlarmTrigger});
    } else {
      $self->{wtWebGraphThermoHygroBaroAlarmTrigger} =
          "0x".$self->{wtWebGraphThermoHygroBaroAlarmTrigger};
    }
  }
  $self->{wtWebGraphThermoHygroBaroAlarmTrigger} =~ s/\s//g;
}

sub belongs_to {
  my $self = shift;
  my $trigger = $self->{wtWebGraphThermoHygroBaroAlarmTrigger};
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

package CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem::AlarmIf;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);


package CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem::Port;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);


package CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem::Sensor::Temperature;
our @ISA = qw(CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem::Sensor);

sub check {
  my $self = shift;
  $self->{label} = "temperature";
  $self->{units} = "";
  $self->SUPER::check();
}

package CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem::Sensor::Humidity;
our @ISA = qw(CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem::Sensor);

sub check {
  my $self = shift;
  $self->{label} = "humidity";
  $self->{units} = "%";
  $self->SUPER::check();
}


package CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem::Sensor::Pressure;
our @ISA = qw(CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem::Sensor);

sub check {
  my $self = shift;
  $self->{label} = "air pressure";
  $self->{units} = "";
  $self->SUPER::check();
}


package CheckWutHealth::WebGraphThermoHygroBaroUS;
our @ISA = qw(CheckWutHealth::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_sensor_subsystem("CheckWutHealth::WebGraphThermoHygroBaroUS::SensorSubsystem");
  } elsif ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_diag_subsystem("CheckWutHealth::WebGraphThermoHygroBaroUS::DiagSubsystem");
  } else {
    $self->no_such_mode();
  }
}


package CheckWutHealth::WebGraphThermoHygroBaroUS::DiagSubsystem;
our @ISA = qw(CheckWutHealth::WebGraphThermoHygroBaro::DiagSubsystem);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_objects("WebGraph-Thermo-Hygro-Barometer-US-MIB",
      qw(wtWebGraphThermoHygroBaroDiagErrorCount wtWebGraphThermoHygroBaroDiagErrorMessage));
}


package CheckWutHealth::WebGraphThermoHygroBaroUS::SensorSubsystem;
our @ISA = qw(CheckWutHealth::WebGraphThermoHygroBaro::SensorSubsystem);
use strict;

sub init {
  my $self = shift;
  $self->session_translate([
    '-octetstring' => 0x1,
    # force wtWebGraphThermoHygroBaroAlarmTrigger in a 0xstring format
  ]);
  $self->get_snmp_objects("WebGraph-Thermo-Hygro-Barometer-US-MIB",
      qw(wtWebGraphThermoHygroBaroSensors wtWebGraphThermoHygroBaroAlarmCount wtWebGraphThermoHygroBaroPorts));
  $self->get_snmp_tables("WebGraph-Thermo-Hygro-Barometer-US-MIB", [
      ["sensors", "wtWebGraphThermoHygroBaroBinaryTempValueTable", "CheckWutHealth::WebGraphThermoHygroBaroUS::SensorSubsystem::Sensor"],
      ["alarms", "wtWebGraphThermoHygroBaroAlarmTable", "CheckWutHealth::WebGraphThermoHygroBaroUS::SensorSubsystem::Alarm"],
      ["alarmsf", "wtWebGraphThermoHygroBaroAlarmIfTable", "CheckWutHealth::WebGraphThermoHygroBaroUS::SensorSubsystem::AlarmIf"],
      ["ports", "wtWebGraphThermoHygroBaroPortTable", "CheckWutHealth::WebGraphThermoHygroBaroUS::SensorSubsystem::Port"],
  ]);
  @{$self->{sensors}} = grep { $self->filter_name($_->{flat_indices}) } @{$self->{sensors}};
  $self->finish();
}



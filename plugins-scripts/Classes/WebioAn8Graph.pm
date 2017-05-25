package Classes::WebioAn8Graph;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_sensor_subsystem("Classes::WebioAn8Graph::SensorSubsystem");
  } elsif ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_diag_subsystem("Classes::WebioAn8Graph::DiagSubsystem");
  } else {
    $self->no_such_mode();
  }
}


package Classes::WebioAn8Graph::DiagSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_objects("WebGraph-8xThermometer-MIB", 
      qw(wtWebioAn8GraphDiagErrorCount wtWebioAn8GraphDiagErrorMessage wtWebioAn8GraphAlarmCount));
}

sub check {
  my $self = shift;
  if ($self->{wtWebioAn8GraphDiagErrorCount}) {
    $self->add_info(sprintf "diag error count is %d (%s)", 
        $self->{wtWebioAn8GraphDiagErrorCount},
        $self->{wtWebioAn8GraphDiagErrorMessage});
    $self->add_critical();
  } else {
    $self->add_ok("environmental hardware working fine");
  }
}

package Classes::WebioAn8Graph::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->session_translate([
    '-octetstring' => 0x1,
    # force wtWebioAn8GraphAlarmTrigger in a 0xstring format
  ]);
  $self->get_snmp_objects("WebGraph-8xThermometer-MIB",
      qw(wtWebioAn8GraphSensors wtWebioAn8GraphAlarmCount wtWebioAn8GraphPorts));
  $self->get_snmp_tables("WebGraph-8xThermometer-MIB", [
      ["sensors", "wtWebioAn8GraphBinaryTempValueTable", "Classes::WebioAn8Graph::SensorSubsystem::Sensor"],
      ["alarms", "wtWebioAn8GraphAlarmTable", "Classes::WebioAn8Graph::SensorSubsystem::Alarm"],
      ["alarmsf", "wtWebioAn8GraphAlarmIfTable", "Classes::WebioAn8Graph::SensorSubsystem::AlarmIf"],
      ["ports", "wtWebioAn8GraphPortTable", "Classes::WebioAn8Graph::SensorSubsystem::Port"],
  ]);
  @{$self->{sensors}} = grep {
      $_->{wtWebioAn8GraphBinaryTempValue} != 327670
  } grep {
      $self->filter_name($_->{flat_indices})
  } @{$self->{sensors}};
  foreach my $sensor (@{$self->{sensors}}) {
    $sensor->{wtWebioAn8GraphBinaryTempValue} /= 10;
    $sensor->{alarms} = [];
    foreach my $alarm (@{$self->{alarms}}) {
      if ($alarm->belongs_to($sensor->{flat_indices})) {
        push(@{$sensor->{alarms}}, $alarm) if
            $alarm->{wtWebioAn8GraphAlarmType} !~ /Sensor lost/;
      }
    }
    foreach my $port (@{$self->{ports}}) {
      if ($port->{flat_indices} eq $sensor->{flat_indices}) {
        $sensor->{wtWebioAn8GraphPortName} = $port->{wtWebioAn8GraphPortName};
        if ($sensor->{wtWebioAn8GraphPortName} =~ /^0x/) {
          $sensor->{wtWebioAn8GraphPortName} =~ s/\s//g;
          $sensor->{wtWebioAn8GraphPortName} =~ s/0x(([0-9a-f][0-9a-f])+)/pack('H*', $1)/ie;
        } elsif ($sensor->{wtWebioAn8GraphPortName} =~ /^(?:[0-9a-f]{2} )+[0-9a-f]{2}$/i) {
          $sensor->{wtWebioAn8GraphPortName} =~ s/\s//g;
          $sensor->{wtWebioAn8GraphPortName} =~ s/(([0-9a-f][0-9a-f])+)/pack('H*', $1)/ie;
        }
        $sensor->{wtWebioAn8GraphPortName} = $self->accentfree($sensor->{wtWebioAn8GraphPortName});
      }
    }
  }
}


package Classes::WebioAn8Graph::SensorSubsystem::Sensor;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  if (scalar(@{$self->{alarms}})) {
    foreach my $alarm (@{$self->{alarms}}) {
      $self->set_thresholds(
          metric => "temp_".$self->{wtWebioAn8GraphPortName}, 
          warning => $alarm->{wtWebioAn8GraphAlarmMin}.":".$alarm->{wtWebioAn8GraphAlarmMax},
          critical => $alarm->{wtWebioAn8GraphAlarmMin}.":".$alarm->{wtWebioAn8GraphAlarmMax});
      if ($self->check_thresholds(
          metric => "temp_".$self->{wtWebioAn8GraphPortName}, 
          value => $self->{wtWebioAn8GraphBinaryTempValue})) {
        if ($alarm->{wtWebioAn8GraphAlarmMailText} =~ /^0x/) {
          $alarm->{wtWebioAn8GraphAlarmMailText} =~ s/^0x//g;
          $alarm->{wtWebioAn8GraphAlarmMailText} =~ s/([a-fA-F0-9][a-fA-F0-9])/chr(hex($1))/eg;
        }
        $alarm->{wtWebioAn8GraphAlarmMailText} =~ s/\n/ /g;
        $alarm->{wtWebioAn8GraphAlarmMailText} =~ s/\s{2,}/ /g;
        $self->add_message($self->check_thresholds(
          metric => "temp_".$self->{wtWebioAn8GraphPortName},
          value => $self->{wtWebioAn8GraphBinaryTempValue}),
          sprintf "temperature %s is out of range: [%s..._%s_...%s] (%s)",
            $self->{wtWebioAn8GraphPortName},
            defined $alarm->{wtWebioAn8GraphAlarmMin} ? $alarm->{wtWebioAn8GraphAlarmMin} : "-",
            $self->{wtWebioAn8GraphBinaryTempValue},
            defined $alarm->{wtWebioAn8GraphAlarmMax} ? $alarm->{wtWebioAn8GraphAlarmMax} : "-",
            $alarm->{wtWebioAn8GraphAlarmMailText});
      } else {
        $self->add_ok(sprintf "temperature %s is in range: [%s..._%s_...%s]",
            $self->{wtWebioAn8GraphPortName},
            defined $alarm->{wtWebioAn8GraphAlarmMin} ? $alarm->{wtWebioAn8GraphAlarmMin} : "-",
            $self->{wtWebioAn8GraphBinaryTempValue},
            defined $alarm->{wtWebioAn8GraphAlarmMax} ? $alarm->{wtWebioAn8GraphAlarmMax} : "-");
      }
      $self->add_perfdata(
          label => "temp_".$self->{wtWebioAn8GraphPortName},
          value => $self->{wtWebioAn8GraphBinaryTempValue},
          min => $alarm->{wtWebioAn8GraphAlarmMin},
          max => $alarm->{wtWebioAn8GraphAlarmMax},
          warning => ($self->get_thresholds(metric => "temp_".$self->{wtWebioAn8GraphPortName}))[0],
          critical => ($self->get_thresholds(metric => "temp_".$self->{wtWebioAn8GraphPortName}))[1],
      );
    }
  } else {
    $self->set_thresholds(
        metric => "temp_".$self->{wtWebioAn8GraphPortName}, 
        warning => undef,
        critical => undef);
    $self->add_message($self->check_thresholds(
          metric => "temp_".$self->{wtWebioAn8GraphPortName},
          value => $self->{wtWebioAn8GraphBinaryTempValue}), sprintf "temperature %s is %s",
        $self->{wtWebioAn8GraphPortName},
        $self->{wtWebioAn8GraphBinaryTempValue});
    $self->add_perfdata(
        label => "temp_".$self->{wtWebioAn8GraphPortName},
        value => $self->{wtWebioAn8GraphBinaryTempValue},
        warning => ($self->get_thresholds(metric => "temp_".$self->{wtWebioAn8GraphPortName}))[0],
        critical => ($self->get_thresholds(metric => "temp_".$self->{wtWebioAn8GraphPortName}))[1],
    );
  }
}

package Classes::WebioAn8Graph::SensorSubsystem::Alarm;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my ($self) = @_;
  my $trigger = $self->{wtWebioAn8GraphAlarmTrigger};
  if ($trigger =~ /^0x/ && $trigger =~ /^[\da-zA-Z]+$/) {
  } elsif (unpack('H*', $trigger) !~ /^0x/ && unpack('H*', $trigger) =~ /^[\da-z
A-Z]+$/) {
    $trigger = "0x".unpack('H*', $trigger);
  }
  $trigger =~ s/\s//g;
  my $type = '';
  $type .= 'Timer_'
      if (oct($trigger) & oct("0b00000000000000000000000100000000"));
  $type .= 'ColdStart_'
      if (oct($trigger) & oct("0b00000000000000000000001000000000"));
  $type .= 'WarmStart_'
      if (oct($trigger) & oct("0b00000000000000000000010000000000"));
  $type .= 'Sensor lost_'
      if (oct($trigger) & oct("0b00000000000000000000100000000000"));
  $self->{wtWebioAn8GraphAlarmType} = $type;
}

sub belongs_to {
  my ($self, $sensor) = @_;
  my $trigger = $self->{wtWebioAn8GraphAlarmTrigger};
  if ($trigger =~ /^0x/ && $trigger =~ /^[\da-zA-Z]+$/) {
  } elsif (unpack('H*', $trigger) !~ /^0x/ && unpack('H*', $trigger) =~ /^[\da-z
A-Z]+$/) {
    $trigger = "0x".unpack('H*', $trigger);
  }
  $trigger =~ s/\s//g;
  my @sensors = ();
  push(@sensors, 1)
      if (oct($trigger) & oct("0b00000000000000000000000000000001"));
  push(@sensors, 2)
      if (oct($trigger) & oct("0b00000000000000000000000000000010"));
  push(@sensors, 3)
      if (oct($trigger) & oct("0b00000000000000000000000000000100"));
  push(@sensors, 4)
      if (oct($trigger) & oct("0b00000000000000000000000000001000"));
  push(@sensors, 5)
      if (oct($trigger) & oct("0b00000000000000000000000000010000"));
  push(@sensors, 6)
      if (oct($trigger) & oct("0b00000000000000000000000000100000"));
  push(@sensors, 7)
      if (oct($trigger) & oct("0b00000000000000000000000001000000"));
  push(@sensors, 8)
      if (oct($trigger) & oct("0b00000000000000000000000010000000"));
  if (grep { $sensor == $_ } @sensors) {
    return 1;
  } else {
    return 0;
  }
}

package Classes::WebioAn8Graph::SensorSubsystem::AlarmIf;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);


package Classes::WebioAn8Graph::SensorSubsystem::Port;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);



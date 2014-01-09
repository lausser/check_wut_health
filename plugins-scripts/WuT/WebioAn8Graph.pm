package WuT::WebioAn8Graph;
our @ISA = qw(WuT::Device);

use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

sub init {
  my $self = shift;
  $self->SUPER::init();
  if ($self->mode =~ /device::sensor::status/) {
    $self->analyze_sensor_subsystem();
    $self->check_sensor_subsystem();
  } elsif ($self->mode =~ /device::hardware::health/) {
    $self->analyze_diag_subsystem();
    $self->check_diag_subsystem();
  } else {
    $self->no_such_mode();
  }
}

sub analyze_diag_subsystem {
  my $self = shift;
  $self->{components}->{diag_subsystem} =
      WuT::WebioAn8Graph::DiagSubsystem->new();
}

sub analyze_sensor_subsystem {
  my $self = shift;
  $self->{components}->{sensor_subsystem} =
      WuT::WebioAn8Graph::SensorSubsystem->new();
}


package WuT::WebioAn8Graph::DiagSubsystem;
our @ISA = qw(GLPlugin::Item WuT::WebioAn8Graph);

use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

sub init {
  my $self = shift;
  $self->get_snmp_objects("WebGraph-8xThermometer-MIB", qw(wtWebioAn8GraphDiagErrorCount));
  $self->get_snmp_objects("WebGraph-8xThermometer-MIB", qw(wtWebioAn8GraphDiagErrorMessage));
}

sub check {
  my $self = shift;
  if ($self->{wtWebioAn8GraphDiagErrorCount}) {
    $self->add_message(CRITICAL,
        sprintf "diag error count is %d (%s)", 
        $self->{wtWebioAn8GraphDiagErrorCount},
        $self->{wtWebioAn8GraphDiagErrorMessage});
  } else {
    $self->add_message(OK, "environmental hardware working fine");
  }
}

package WuT::WebioAn8Graph::SensorSubsystem;
our @ISA = qw(GLPlugin::Item WuT::WebioAn8Graph);

use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

sub init {
  my $self = shift;
  $GLPlugin::SNMP::session->translate([
    '-octetstring' => 0x1,
    # force wtWebioAn8GraphAlarmTrigger in a 0xstring format
  ]);
  $self->get_snmp_objects("WebGraph-8xThermometer-MIB", qw(wtWebioAn8GraphSensors));
  $self->get_snmp_objects("WebGraph-8xThermometer-MIB", qw(wtWebioAn8GraphAlarmCount));
  $self->get_snmp_objects("WebGraph-8xThermometer-MIB", qw(wtWebioAn8GraphPorts));
  $self->get_snmp_tables("WebGraph-8xThermometer-MIB", [
      ["sensors", "wtWebioAn8GraphBinaryTempValueTable", "WuT::WebioAn8Graph::SensorSubsystem::Sensor"],
      ["alarms", "wtWebioAn8GraphAlarmTable", "WuT::WebioAn8Graph::SensorSubsystem::Alarm"],
      ["alarmsf", "wtWebioAn8GraphAlarmIfTable", "WuT::WebioAn8Graph::SensorSubsystem::AlarmIf"],
      ["ports", "wtWebioAn8GraphPortTable", "WuT::WebioAn8Graph::SensorSubsystem::Port"],
  ]);
  @{$self->{sensors}} = grep { $self->filter_name($_->{flat_indices}) } @{$self->{sensors}};
  foreach my $sensor (@{$self->{sensors}}) {
    $sensor->{wtWebioAn8GraphBinaryTempValue} /= 10;
    $sensor->{alarms} = [];
    foreach my $alarm (@{$self->{alarms}}) {
      if ($alarm->belongs_to() eq $sensor->{flat_indices}) {
        push(@{$sensor->{alarms}}, $alarm);
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

sub check {
  my $self = shift;
  foreach (@{$self->{sensors}}) {
    $_->check();
  }
}

sub dump {
  my $self = shift;
  printf "[SENSORS]\n";
  foreach (qw(wtWebioAn8GraphSensors wtWebioAn8GraphAlarmCount)) {
    printf "%s: %s\n", $_, $self->{$_};
  }
  foreach (@{$self->{sensors}}) {
    $_->dump();
  }
  foreach (@{$self->{alarms}}) {
    $_->dump();
  }
  foreach (@{$self->{ports}}) {
    $_->dump();
  }
}


package WuT::WebioAn8Graph::SensorSubsystem::Sensor;
our @ISA = qw(GLPlugin::TableItem);

use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

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
        $self->add_message($self->check_thresholds(
          metric => "temp_".$self->{wtWebioAn8GraphPortName},
          value => $self->{wtWebioAn8GraphBinaryTempValue}),
          sprintf "temperature %s is out of range: [%s..._%s_...%s] (%s)",
            $self->{wtWebioAn8GraphPortName},
            defined $alarm->{wtWebioAn8GraphAlarmMin} ? $alarm->{wtWebioAn8GraphAlarmMin} : "-",
            $self->{wtWebioAn8GraphBinaryTempValue},
            defined $alarm->{wtWebioAn8GraphAlarmMax} ? $alarm->{wtWebioAn8GraphAlarmMax} : "-",
            $self->{wtWebioAn8GraphAlarmMailText});
      } else {
        $self->add_message(OK, sprintf "temperature %s is in range: [%s..._%s_...%s]",
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

package WuT::WebioAn8Graph::SensorSubsystem::Alarm;
our @ISA = qw(GLPlugin::TableItem);

sub belongs_to {
  my $self = shift;
  my $trigger = $self->{wtWebioAn8GraphAlarmTrigger};
  if ($trigger !~ /^0x/) {
    $trigger = "0x ".$trigger;
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

package WuT::WebioAn8Graph::SensorSubsystem::AlarmIf;
our @ISA = qw(GLPlugin::TableItem);


package WuT::WebioAn8Graph::SensorSubsystem::Port;
our @ISA = qw(GLPlugin::TableItem);




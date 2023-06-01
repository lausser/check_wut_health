package Classes::Liebert::Components::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("LIEBERT-GP-SYSTEM-MIB", qw(
      lgpSysState
  ));
  $self->mult_snmp_max_msg_size(2);
  $self->get_snmp_tables("LIEBERT-GP-ENVIRONMENTAL-MIB", [
    ["sensors", "lgpEnvRemoteSensorTable", "Classes::Liebert::Components::SensorSubsystem::RemoteSensor", sub { shift->{lgpEnvRemoteSensorMode} ne 'disable'; } ],
  ]);
  $self->get_snmp_tables("LIEBERT-GP-FLEXIBLE-MIB", [
#    ["debugflexibles", "lgpFlexibleBasicTable", "Monitoring::GLPlugin::SNMP::TableItem"],
    ["flexibles", "lgpFlexibleBasicTable", "Classes::Liebert::Components::SensorSubsystem::Flexible", sub {
      my $o = shift;
      return 0 if exists $o->{lgpFlexibleEntryValue} && $o->{lgpFlexibleEntryValue} eq 'Unavailable';
      return 0 if exists $o->{lgpFlexibleEntryValue} && $o->{lgpFlexibleEntryValue} eq 'Remote';
      return 0 if exists $o->{lgpFlexibleEntryValue} && $o->{lgpFlexibleEntryValue} eq 'Average';
      return 0 if exists $o->{lgpFlexibleEntryValue} && $o->{lgpFlexibleEntryValue} eq 'Supply';
      return 0 if exists $o->{lgpFlexibleEntryValue} && $o->{lgpFlexibleEntryValue} eq 'enabled';
      return 0 if exists $o->{lgpFlexibleEntryValue} && $o->{lgpFlexibleEntryValue} eq 'Alarm';
      return 0 if exists $o->{lgpFlexibleEntryDataLabel} && $o->{lgpFlexibleEntryDataLabel} =~ /Sensor Order Identifier/;
      return 0 if exists $o->{lgpFlexibleEntryDataLabel} && $o->{lgpFlexibleEntryDataLabel} =~ / Set Point/;
      return 0 if exists $o->{lgpFlexibleEntryDataLabel} && $o->{lgpFlexibleEntryDataLabel} =~ / Band/;
      return 1;
    }],
  ]);
  foreach my $flexible (@{$self->{flexibles}}) {
    if (ref($flexible) eq "Classes::Liebert::Components::SensorSubsystem::Flexible::TemperatureThreshold") {
      foreach my $temperature (grep {
          ref($_) eq "Classes::Liebert::Components::SensorSubsystem::Flexible::Temperature";
      } @{$self->{flexibles}}) {
        if ($flexible->{lgpFlexibleEntryDataLabel} =~ /High (.*) Threshold/ &&
            $1 eq $temperature->{lgpFlexibleEntryDataLabel}) {
            $temperature->{lgpFlexibleEntryHighThreshold} = $flexible->{lgpFlexibleEntryValue};
            $flexible->{invalid} = 1;
        } elsif ($flexible->{lgpFlexibleEntryDataLabel} =~ /Low (.*) Threshold/ &&
            $1 eq $temperature->{lgpFlexibleEntryDataLabel}) {
            $temperature->{lgpFlexibleEntryLowThreshold} = $flexible->{lgpFlexibleEntryValue};
            $flexible->{invalid} = 1;
        }
      }
    }
  }
  @{$self->{flexibles}} = grep { ! exists $_->{invalid} || $_->{invalid} != 1 } @{$self->{flexibles}};
}


package Classes::Liebert::Components::SensorSubsystem::RemoteSensor;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  $self->{label} = $self->{lgpEnvRemoteSensorUsrLabel} || $self->{lgpEnvRemoteSensorId};
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf 'remote temperature %s is %.2fC',
      $self->{label}, $self->{lgpEnvRemoteSensorTempMeasurementDegC});
  $self->add_ok();
  $self->add_perfdata(
      label => 'temp_remote_'.$self->{label},
      value => $self->{lgpEnvRemoteSensorTempMeasurementDegC},
  );
}

package Classes::Liebert::Components::SensorSubsystem::Flexible;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  if ($self->{lgpFlexibleEntryDataLabel} =~ /Status$/) {
    bless $self, 'Classes::Liebert::Components::SensorSubsystem::Flexible::Status';
  } elsif ($self->{lgpFlexibleEntryValue} =~ /Event Control$/) {
    bless $self, 'Classes::Liebert::Components::SensorSubsystem::Flexible::EventControl';
  } elsif ($self->{lgpFlexibleEntryValue} =~ /Event Type$/) {
    bless $self, 'Classes::Liebert::Components::SensorSubsystem::Flexible::EventType';
  } elsif ($self->{lgpFlexibleEntryValue} =~ /Event$/) {
    bless $self, 'Classes::Liebert::Components::SensorSubsystem::Flexible::Event';
  } elsif ($self->{lgpFlexibleEntryDataLabel} =~ /(^Fan|Fan Speed)/) {
    bless $self, 'Classes::Liebert::Components::SensorSubsystem::Flexible::Fan';
  } elsif ($self->{lgpFlexibleEntryUnitsOfMeasure} && $self->{lgpFlexibleEntryUnitsOfMeasure} eq "%") {
    bless $self, 'Classes::Liebert::Components::SensorSubsystem::Flexible::Percent';
  } elsif ($self->{lgpFlexibleEntryDataLabel} =~ /Temperature Threshold/) {
    bless $self, 'Classes::Liebert::Components::SensorSubsystem::Flexible::TemperatureThreshold';
  } elsif ($self->{lgpFlexibleEntryDataLabel} =~ /Temperature/) {
    bless $self, 'Classes::Liebert::Components::SensorSubsystem::Flexible::Temperature';
  } elsif ($self->{lgpFlexibleEntryUnitsOfMeasure} && $self->{lgpFlexibleEntryUnitsOfMeasure} eq "deg F") {
    bless $self, 'Classes::Liebert::Components::SensorSubsystem::Flexible::Temperature';
  } elsif ($self->{lgpFlexibleEntryUnitsOfMeasure} && $self->{lgpFlexibleEntryUnitsOfMeasure} eq "deg C") {
    bless $self, 'Classes::Liebert::Components::SensorSubsystem::Flexible::Temperature';
  } elsif ($self->{lgpFlexibleEntryUnitsOfMeasure} && $self->{lgpFlexibleEntryUnitsOfMeasure} eq "% RH") {
    bless $self, 'Classes::Liebert::Components::SensorSubsystem::Flexible::Humidity';
  }
  if (ref($self) ne 'Classes::Liebert::Components::SensorSubsystem::Flexible') {
    $self->finish();
  } else {
    $self->{invalid} = 1;
  }
}

sub check {
  my ($self) = @_;
}

package Classes::Liebert::Components::SensorSubsystem::Flexible::Status;
our @ISA = qw(Classes::Liebert::Components::SensorSubsystem::Flexible);
use strict;

sub finish {
  my ($self) = @_;
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf '%s is %s', $self->{lgpFlexibleEntryDataLabel}, $self->{lgpFlexibleEntryValue});
  if ($self->{lgpFlexibleEntryValue} !~ /^(Normal Operation|OK)$/) {
    $self->warning();
  }
}


package Classes::Liebert::Components::SensorSubsystem::Flexible::EventType;
our @ISA = qw(Classes::Liebert::Components::SensorSubsystem::Flexible);
use strict;

sub finish {
  my ($self) = @_;
}

package Classes::Liebert::Components::SensorSubsystem::Flexible::EventControl;
our @ISA = qw(Classes::Liebert::Components::SensorSubsystem::Flexible);
use strict;

sub finish {
  my ($self) = @_;
}

package Classes::Liebert::Components::SensorSubsystem::Flexible::Event;
our @ISA = qw(Classes::Liebert::Components::SensorSubsystem::Flexible);
use strict;

sub finish {
  my ($self) = @_;
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf '%s %s (%s)', $self->{lgpFlexibleEntryValue},
      $self->{flat_indices}, $self->{lgpFlexibleEntryDataLabel});
  if ($self->{lgpFlexibleEntryValue} =~ /^active/i) {
    $self->add_warning();
  }
}

package Classes::Liebert::Components::SensorSubsystem::Flexible::Temperature;
our @ISA = qw(Classes::Liebert::Components::SensorSubsystem::Flexible);
use strict;

sub finish {
  my ($self) = @_;
  if ($self->{lgpFlexibleEntryDataLabel} =~ /(Minimum|Average|Maximum) Temperature/) {
    $self->{invalid} = 1;
    return;
  }
  if (! defined $self->{lgpFlexibleEntryValue} || $self->{lgpFlexibleEntryValue} !~ /^[\d\.]+$/) {
    $self->{invalid} = 1;
    return;
  }
  if (abs($self->{lgpFlexibleEntryValue}) > 32700) {
    $self->{invalid} = 1;
    return;
  }
  if ($self->{lgpFlexibleEntryUnitsOfMeasure} eq "deg F") {
    $self->{lgpFlexibleEntryValue} = ($self->{lgpFlexibleEntryValue} - 32) * 5 / 9;
    $self->{lgpFlexibleEntryUnitsOfMeasure} = "deg C";
    # fuehrt dazu, dass die sensoren doppelt erscheinen. ich gehe jetzt mal davon aus
    # dass es _immer_ sowohl C als auch F gibt:
    $self->{invalid} = 1;
  }
  if ($self->{lgpFlexibleEntryDataLabel} eq "Remote Sensor Temperature") {
    $self->{lgpFlexibleEntryDataLabel} .= " ".@{$self->{indices}}[-1];
  }
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf 'temperature %s is %.2fC', $self->{lgpFlexibleEntryDataLabel},
      $self->{lgpFlexibleEntryValue});
  $self->add_ok();
  $self->add_perfdata(
      label => 'temp_'.$self->{lgpFlexibleEntryDataLabel},
      value => $self->{lgpFlexibleEntryValue},
  );
}

package Classes::Liebert::Components::SensorSubsystem::Flexible::TemperatureThreshold;
our @ISA = qw(Classes::Liebert::Components::SensorSubsystem::Flexible);
use strict;

sub finish {
  my ($self) = @_;
  if (! defined $self->{lgpFlexibleEntryValue} || $self->{lgpFlexibleEntryValue} !~ /^[\d\.]+$/) {
    $self->{invalid} = 1;
    return;
  }
  if ($self->{lgpFlexibleEntryUnitsOfMeasure} eq "deg F") {
    $self->{lgpFlexibleEntryValue} = ($self->{lgpFlexibleEntryValue} - 32) * 5 / 9;
    $self->{lgpFlexibleEntryUnitsOfMeasure} = "deg C";
  }
}

package Classes::Liebert::Components::SensorSubsystem::Flexible::Percent;
our @ISA = qw(Classes::Liebert::Components::SensorSubsystem::Flexible);
use strict;

sub finish {
  my ($self) = @_;
  if (! defined $self->{lgpFlexibleEntryValue} || $self->{lgpFlexibleEntryValue} !~ /^[\d\.]+$/) {
    $self->{invalid} = 1;
    return;
  }
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf '%s is %.2f%%', $self->{lgpFlexibleEntryDataLabel},
      $self->{lgpFlexibleEntryValue});
  $self->add_ok();
  $self->add_perfdata(
      label => 'pct_'.$self->{lgpFlexibleEntryDataLabel},
      value => $self->{lgpFlexibleEntryValue},
      uom => '%',
      max => 100,
      min => 0,
  );
}

package Classes::Liebert::Components::SensorSubsystem::Flexible::Fan;
our @ISA = qw(Classes::Liebert::Components::SensorSubsystem::Flexible::Percent);
use strict;

sub finish {
  my ($self) = @_;
  if ($self->{lgpFlexibleEntryDataLabel} !~ /speed/i) {
    $self->{invalid} = 1;
    return;
  }
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf '%s is %.2f%%', $self->{lgpFlexibleEntryDataLabel},
      $self->{lgpFlexibleEntryValue});
  $self->add_ok();
  $self->add_perfdata(
      label => 'fan_'.$self->{lgpFlexibleEntryDataLabel},
      value => $self->{lgpFlexibleEntryValue},
      uom => '%',
      max => 100,
      min => 0,
  );
}

package Classes::Liebert::Components::SensorSubsystem::Flexible::Humidity;
our @ISA = qw(Classes::Liebert::Components::SensorSubsystem::Flexible);
use strict;

sub finish {
  my ($self) = @_;
  if ($self->{lgpFlexibleEntryDataLabel} =~ /(Proportional Band|Set Point)/) {
    $self->{invalid} = 1;
    return;
  }
  if (! defined $self->{lgpFlexibleEntryValue} || $self->{lgpFlexibleEntryValue} !~ /^[\d\.]+$/) {
    $self->{invalid} = 1;
    return;
  }
  if (abs($self->{lgpFlexibleEntryValue}) > 32700) {
    $self->{invalid} = 1;
    return;
  }
  if ($self->{lgpFlexibleEntryDataLabel} eq "Supply Sensor Humidity") {
    $self->{lgpFlexibleEntryDataLabel} .= " ".@{$self->{indices}}[-1];
  }
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf 'humidity %s is %.2f%%', $self->{lgpFlexibleEntryDataLabel},
      $self->{lgpFlexibleEntryValue});
  $self->set_thresholds(
      metric => 'hum_'.$self->{lgpFlexibleEntryDataLabel},
      warning => 70,
      critical => 80,
  );
  $self->add_message($self->check_thresholds(
      metric => 'hum_'.$self->{lgpFlexibleEntryDataLabel},
      value => $self->{lgpFlexibleEntryValue},
  ));
  $self->add_perfdata(
      label => 'hum_'.$self->{lgpFlexibleEntryDataLabel},
      value => $self->{lgpFlexibleEntryValue},
      uom => "%",
  );
}



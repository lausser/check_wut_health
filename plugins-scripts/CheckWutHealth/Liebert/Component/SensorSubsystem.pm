package CheckWutHealth::Liebert::Components::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("LIEBERT-GP-SYSTEM-MIB", qw(
      lgpSysState
  ));
  $self->mult_snmp_max_msg_size(2);
  $self->get_snmp_tables("LIEBERT-GP-ENVIRONMENTAL-MIB", [
    ["sensors", "lgpEnvRemoteSensorTable", "CheckWutHealth::Liebert::Components::SensorSubsystem::RemoteSensor", sub { shift->{lgpEnvRemoteSensorMode} ne 'disable'; } ],
  ]);
  $self->get_snmp_tables("LIEBERT-GP-FLEXIBLE-MIB", [
#    ["debugflexibles", "lgpFlexibleBasicTable", "Monitoring::GLPlugin::SNMP::TableItem"],
    ["flexibles", "lgpFlexibleBasicTable", "CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible", sub {
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
  # Remote Sensor Temperature 1
  # Remote Sensor Temperature 2
  # ...
  # Remote Sensor Over Temp Threshold
  # Remote Sensor Under Temp Threshold
  #
  # Ext Air Sensor A Temperature
  # Ext Air Sensor B Temperature
  # Ext Air Sensor A Over Temp Threshold
  # Ext Air Sensor A Under Temp Threshold
  # Ext Air Sensor A Humidity
  # Ext Air Sensor B Humidity
  # Ext Air Sensor A High Humidity Threshold
  # Ext Air Sensor A Low Humidity Threshold
  foreach my $flexible (@{$self->{flexibles}}) {
    my $f_index = $flexible->{flat_indices};
    $f_index =~ s/^1\.3\.6\.1\.4\.1\.476\.1\.42\.3\.9\.20\.1\.10\.1//;
    $f_index =~ s/^(\d+\.\d+\.\d+).*/$1/;
    if (ref($flexible) eq "CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::TemperatureThreshold") {
      # .1.3.6.1.4.1.476.1.42.3.9.20.1.10.1.2.1.5002 = STRING: "Supply Air Temperature"
      # .1.3.6.1.4.1.476.1.42.3.9.20.1.10.1.2.1.5014 = STRING: "High Supply Air Temperature Threshold"
      # .1.3.6.1.4.1.476.1.42.3.9.20.1.10.1.2.1.5018 = STRING: "Low Supply Air Temperature Threshold"
      # .1.3.6.1.4.1.476.1.42.3.9.20.1.10.1.2.2.5002 = STRING: "Supply Air Temperature"
      # .1.3.6.1.4.1.476.1.42.3.9.20.1.10.1.2.2.5014 = STRING: "High Supply Air Temperature Threshold"
      # .1.3.6.1.4.1.476.1.42.3.9.20.1.10.1.2.2.5018 = STRING: "Low Supply Air Temperature Threshold"
      foreach my $temperature (grep {
          ref($_) eq "CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::Temperature";
      } @{$self->{flexibles}}) {
        my $t_index = $temperature->{flat_indices};
        $t_index =~ s/^1\.3\.6\.1\.4\.1\.476\.1\.42\.3\.9\.20\.1\.10\.1//;
        $t_index =~ s/^(\d+\.\d+\.\d+).*/$1/;
        if ($flexible->{lgpFlexibleEntryDataLabel} =~ /High (.*) Threshold/ &&
            index($temperature->{lgpFlexibleEntryDataLabel}, $1) == 0 &&
            $t_index eq $f_index) {
            $temperature->{lgpFlexibleEntryHighThreshold} = $flexible->{lgpFlexibleEntryValue};
            $flexible->{invalid} = 1;
        } elsif ($flexible->{lgpFlexibleEntryDataLabel} =~ /Low (.*) Threshold/ &&
            index($temperature->{lgpFlexibleEntryDataLabel}, $1) == 0 &&
            $t_index eq $f_index) {
            $temperature->{lgpFlexibleEntryLowThreshold} = $flexible->{lgpFlexibleEntryValue};
            $flexible->{invalid} = 1;
        } elsif ($flexible->{lgpFlexibleEntryDataLabel} =~ /(.*) Over Temp Threshold/ &&
            index($temperature->{lgpFlexibleEntryDataLabel}, $1." Temperature") == 0 &&
            $t_index eq $f_index) {
            $temperature->{lgpFlexibleEntryHighThreshold} = $flexible->{lgpFlexibleEntryValue};
            $flexible->{invalid} = 1;
        } elsif ($flexible->{lgpFlexibleEntryDataLabel} =~ /(.*) Under Temp Threshold/ &&
            index($temperature->{lgpFlexibleEntryDataLabel}, $1." Temperature") == 0 &&
            $t_index eq $f_index) {
            $temperature->{lgpFlexibleEntryLowThreshold} = $flexible->{lgpFlexibleEntryValue};
            $flexible->{invalid} = 1;
        }
      }
    } elsif (ref($flexible) eq "CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::HumidityThreshold") {
      foreach my $humidity (grep {
          ref($_) eq "CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::Humidity";
      } @{$self->{flexibles}}) {
        my $h_index = $humidity->{flat_indices};
        $h_index =~ s/^1\.3\.6\.1\.4\.1\.476\.1\.42\.3\.9\.20\.1\.10\.1//;
        $h_index =~ s/^(\d+\.\d+\.\d+).*/$1/;
        if ($flexible->{lgpFlexibleEntryDataLabel} =~ /High (.*) Threshold/ &&
            $1 eq $humidity->{lgpFlexibleEntryDataLabel} &&
            $h_index eq $f_index) {
            $humidity->{lgpFlexibleEntryHighThreshold} = $flexible->{lgpFlexibleEntryValue};
            $flexible->{invalid} = 1;
        } elsif ($flexible->{lgpFlexibleEntryDataLabel} =~ /Low (.*) Threshold/ &&
            $1 eq $humidity->{lgpFlexibleEntryDataLabel} &&
            $h_index eq $f_index) {
            $humidity->{lgpFlexibleEntryLowThreshold} = $flexible->{lgpFlexibleEntryValue};
            $flexible->{invalid} = 1;
        }
      }
    } elsif (ref($flexible) eq "CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::FanThreshold") {
      foreach my $fan (grep {
          ref($_) eq "CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::Fan";
      } @{$self->{flexibles}}) {
        # Condenser Fan Speed (gibt es mehrmals)
        # Condenser Low Noise Mode Max Fan Speed
        # Condenser Normal Mode Max Fan Speed
        my $h_index = $fan->{flat_indices};
        $h_index =~ s/^1\.3\.6\.1\.4\.1\.476\.1\.42\.3\.9\.20\.1\.10\.1//;
        $h_index =~ s/^(\d+\.\d+\.\d+).*/$1/;
        if ($flexible->{lgpFlexibleEntryDataLabel} =~ /(.*) Low Noise Mode Max Fan Speed/ &&
            $1." Fan Speed" eq $fan->{lgpFlexibleEntryDataLabel} &&
            $h_index eq $f_index) {
            $fan->{lgpFlexibleEntryLowThreshold} = $flexible->{lgpFlexibleEntryValue};
            $flexible->{invalid} = 1;
        } elsif ($flexible->{lgpFlexibleEntryDataLabel} =~ /(.*) Normal Mode Max Fan Speed/ &&
            $1." Fan Speed" eq $fan->{lgpFlexibleEntryDataLabel} &&
            $h_index eq $f_index) {
            $fan->{lgpFlexibleEntryHighThreshold} = $flexible->{lgpFlexibleEntryValue};
            $flexible->{invalid} = 1;
        }
      }
    }
  }
#foreach (sort { $a->{lgpFlexibleEntryDataLabel} cmp $b->{lgpFlexibleEntryDataLabel}} @{$self->{flexibles}}) {
 #printf "->%s %s\n", $_->{invalid} ? "-":"+", $_->{lgpFlexibleEntryDataLabel};
#}
  @{$self->{flexibles}} = grep { ! exists $_->{invalid} || $_->{invalid} != 1 } @{$self->{flexibles}};
}


package CheckWutHealth::Liebert::Components::SensorSubsystem::RemoteSensor;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
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

package CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  if ($self->{lgpFlexibleEntryDataLabel} =~ /Status$/) {
    bless $self, 'CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::Status';
  } elsif ($self->{lgpFlexibleEntryValue} =~ /Event Control$/) {
    bless $self, 'CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::EventControl';
  } elsif ($self->{lgpFlexibleEntryValue} =~ /Event Type$/) {
    bless $self, 'CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::EventType';
  } elsif ($self->{lgpFlexibleEntryValue} =~ /Event$/) {
    bless $self, 'CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::Event';
  } elsif ($self->{lgpFlexibleEntryDataLabel} =~ /Max Fan Speed/ && $self->{lgpFlexibleEntryUnitsOfMeasure} && $self->{lgpFlexibleEntryUnitsOfMeasure} eq "%") {
    bless $self, 'CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::FanThreshold';
  } elsif ($self->{lgpFlexibleEntryDataLabel} =~ /(^Fan|Fan Speed)/ && $self->{lgpFlexibleEntryUnitsOfMeasure} && $self->{lgpFlexibleEntryUnitsOfMeasure} eq "%") {
    bless $self, 'CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::Fan';
  } elsif ($self->{lgpFlexibleEntryUnitsOfMeasure} && $self->{lgpFlexibleEntryUnitsOfMeasure} eq "%") {
    bless $self, 'CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::Percent';
  } elsif ($self->{lgpFlexibleEntryDataLabel} =~ /Temp(erature)* Threshold/) {
    bless $self, 'CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::TemperatureThreshold';
  } elsif ($self->{lgpFlexibleEntryDataLabel} =~ /Temperature/) {
    bless $self, 'CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::Temperature';
  } elsif ($self->{lgpFlexibleEntryUnitsOfMeasure} && $self->{lgpFlexibleEntryUnitsOfMeasure} eq "deg F") {
    bless $self, 'CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::Temperature';
  } elsif ($self->{lgpFlexibleEntryUnitsOfMeasure} && $self->{lgpFlexibleEntryUnitsOfMeasure} eq "deg C") {
    bless $self, 'CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::Temperature';
  } elsif ($self->{lgpFlexibleEntryUnitsOfMeasure} && $self->{lgpFlexibleEntryUnitsOfMeasure} eq "% RH" && $self->{lgpFlexibleEntryDataLabel} =~ /Threshold/) {
    bless $self, 'CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::HumidityThreshold';
  } elsif ($self->{lgpFlexibleEntryUnitsOfMeasure} && $self->{lgpFlexibleEntryUnitsOfMeasure} eq "% RH") {
    bless $self, 'CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::Humidity';
  }
  if (ref($self) ne 'CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible') {
    $self->finish();
  } else {
    $self->{invalid} = 1;
  }
  # lgpFlexibleEntryDataLabel: Today's High Air Temperature
  $self->{label} = $self->{lgpFlexibleEntryDataLabel} =~ s/'//r;
}

sub check {
  my ($self) = @_;
}

package CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::Status;
our @ISA = qw(CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible);
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


package CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::EventType;
our @ISA = qw(CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible);
use strict;

sub finish {
  my ($self) = @_;
}

package CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::EventControl;
our @ISA = qw(CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible);
use strict;

sub finish {
  my ($self) = @_;
}

package CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::Event;
our @ISA = qw(CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible);
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

package CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::Temperature;
our @ISA = qw(CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible);
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
    $self->{label} = $self->{lgpFlexibleEntryDataLabel} =~ s/'//r;
  }
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf 'temperature %s is %.2fC', $self->{label},
      $self->{lgpFlexibleEntryValue});
  my $device_threshold = "";
  if (exists $self->{lgpFlexibleEntryLowThreshold} and
      exists $self->{lgpFlexibleEntryHighThreshold}) {
    $device_threshold = $self->{lgpFlexibleEntryLowThreshold}.":".$self->{lgpFlexibleEntryHighThreshold};
  } elsif (exists $self->{lgpFlexibleEntryLowThreshold}) {
    $device_threshold = $self->{lgpFlexibleEntryLowThreshold}.":";
  } elsif (exists $self->{lgpFlexibleEntryHighThreshold}) {
    $device_threshold = $self->{lgpFlexibleEntryHighThreshold};
  }
  if ($device_threshold) {
    $self->set_thresholds(
        metric => 'temp_'.$self->{label},
        warning => $device_threshold,
        critical => $device_threshold,
    );
  } else {
    $self->set_thresholds(
        metric => 'temp_'.$self->{label},
        warning => "",
        critical => "",
    );
  }
  $self->add_message($self->check_thresholds(
      metric => 'temp_'.$self->{label},
      value => $self->{lgpFlexibleEntryValue},
  ));
  $self->add_perfdata(
      label => 'temp_'.$self->{label},
      value => $self->{lgpFlexibleEntryValue},
  );
}

package CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::TemperatureThreshold;
our @ISA = qw(CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible);
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

package CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::Percent;
our @ISA = qw(CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible);
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
  $self->add_info(sprintf '%s is %.2f%%', $self->{label},
      $self->{lgpFlexibleEntryValue});
  $self->add_ok();
  $self->add_perfdata(
      label => 'pct_'.$self->{label},
      value => $self->{lgpFlexibleEntryValue},
      uom => '%',
      max => 100,
      min => 0,
  );
}

package CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::Fan;
our @ISA = qw(CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible);
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
  $self->add_info(sprintf '%s is %.2f%%', $self->{label},
      $self->{lgpFlexibleEntryValue});
  my $w_threshold = undef;
  my $c_threshold = undef;
  if (exists $self->{lgpFlexibleEntryLowThreshold}) {
    $w_threshold = $self->{lgpFlexibleEntryLowThreshold};
  }
  if (exists $self->{lgpFlexibleEntryHighThreshold}) {
    $c_threshold = $self->{lgpFlexibleEntryHighThreshold};
  }
  if ($w_threshold || $c_threshold) {
    $self->set_thresholds(
        metric => 'fan_'.$self->{label},
        warning => $w_threshold,
        critical => $c_threshold,
    );
  }
  $self->add_message($self->check_thresholds(
      metric => 'fan_'.$self->{label},
      value => $self->{lgpFlexibleEntryValue}
  ));
  $self->add_perfdata(
      label => 'fan_'.$self->{label},
      value => $self->{lgpFlexibleEntryValue},
      uom => '%',
      max => 100,
      min => 0,
  );
}

package CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::FanThreshold;
our @ISA = qw(CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible);
use strict;

sub finish {
  my ($self) = @_;
  if (! defined $self->{lgpFlexibleEntryValue} || $self->{lgpFlexibleEntryValue} !~ /^[\d\.]+$/) {
    $self->{invalid} = 1;
    return;
  }
}

package CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::Humidity;
our @ISA = qw(CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible);
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
  $self->add_info(sprintf 'humidity %s is %.2f%%', $self->{label},
      $self->{lgpFlexibleEntryValue});
  my $device_threshold = "";
  if (exists $self->{lgpFlexibleEntryLowThreshold} and
      exists $self->{lgpFlexibleEntryHighThreshold}) {
    $device_threshold = $self->{lgpFlexibleEntryLowThreshold}.":".$self->{lgpFlexibleEntryHighThreshold};
  } elsif (exists $self->{lgpFlexibleEntryLowThreshold}) {
    $device_threshold = $self->{lgpFlexibleEntryLowThreshold}.":";
  } elsif (exists $self->{lgpFlexibleEntryHighThreshold}) {
    $device_threshold = $self->{lgpFlexibleEntryHighThreshold};
  }
  if ($device_threshold) {
    $self->set_thresholds(
        metric => 'hum_'.$self->{label},
        warning => $device_threshold,
        critical => $device_threshold,
    );
  } elsif ($self->{label} !~ /Today/) {
    $self->set_thresholds(
        metric => 'hum_'.$self->{label},
        warning => 70,
        critical => 80,
    );
  }
  $self->add_message($self->check_thresholds(
      metric => 'hum_'.$self->{label},
      value => $self->{lgpFlexibleEntryValue},
  ));
  $self->add_perfdata(
      label => 'hum_'.$self->{label},
      value => $self->{lgpFlexibleEntryValue},
      uom => "%",
  );
}

package CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible::HumidityThreshold;
our @ISA = qw(CheckWutHealth::Liebert::Components::SensorSubsystem::Flexible);
use strict;

sub finish {
  my ($self) = @_;
  if (! defined $self->{lgpFlexibleEntryValue} || $self->{lgpFlexibleEntryValue} !~ /^[\d\.]+$/) {
    $self->{invalid} = 1;
    return;
  }
}


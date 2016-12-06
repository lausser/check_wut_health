package Classes::Liebert::Components::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("LIEBERT-GP-SYSTEM-MIB", qw(
      lgpSysState
  ));
  $self->get_snmp_tables("LIEBERT-GP-ENVIRONMENTAL-MIB", [
    ["sensors", "lgpEnvRemoteSensorTable", "Classes::Liebert::Components::SensorSubsystem::Sensor", sub { shift->{lgpEnvRemoteSensorMode} ne 'disable'; } ],
  ]);
  $self->get_snmp_tables("LIEBERT-GP-FLEXIBLE-MIB", [
#    ["debugflexibles", "lgpFlexibleBasicTable", "Monitoring::GLPlugin::SNMP::TableItem"],
    ["flexibles", "lgpFlexibleBasicTable", "Classes::Liebert::Components::SensorSubsystem::Flexible", sub {
      my $o = shift;
      return 0 if exists $o->{lgpFlexibleEntryValue} && $o->{lgpFlexibleEntryValue} eq 'Unavailable';
      return 0 if exists $o->{lgpFlexibleEntryValue} && $o->{lgpFlexibleEntryValue} eq 'Remote';
      return 0 if exists $o->{lgpFlexibleEntryValue} && $o->{lgpFlexibleEntryValue} eq 'Average';
      return 0 if exists $o->{lgpFlexibleEntryDataLabel} && $o->{lgpFlexibleEntryDataLabel} =~ /Sensor Order Identifier/;
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

sub xcheck {
  my ($self) = @_;
  $self->add_info(sprintf 'system state is %s', $self->{lgpSysState});
  if ($self->{lgpSysState} eq 'startUp' ||
      $self->{lgpSysState} eq 'normalOperation') {
    $self->add_ok();
  } elsif ($self->{lgpSysState} eq 'normalWithWarning') {
    $self->add_warning();
  } else {
    $self->add_critical();
  }
  if (! $self->implements_mib('UPS-MIB')) {
    $self->set_thresholds( metric => 'remaining_time', warning => '15:', critical => '10:');
    if ($self->{lgpPwrSensorTimeRemaining} == 65535) {
      $self->add_info(sprintf 'system is not capable of providing the remaining battery run time (but is not operating on battery now)');
      $self->add_ok();
    } else {
      $self->add_info(sprintf 'remaining battery run time is %.2fmin', $self->{lgpPwrSensorTimeRemaining});
      $self->add_message($self->check_thresholds(
          value => $self->{lgpPwrSensorTimeRemaining}, metric => 'remaining_time')
      );
      $self->add_perfdata(
          label => 'remaining_time',
          value => $self->{lgpPwrSensorTimeRemaining},
      );
    }
  }
  $self->add_info(sprintf 'battery capacity status is %s', $self->{lgpPwrSensorCapacityStatus});
  if ($self->{lgpPwrSensorCapacityStatus} eq 'batteryLow') {
    $self->add_warning();
  } elsif ($self->{lgpPwrSensorCapacityStatus} eq 'batteryDepleted') {
    $self->add_critical();
  }
}


package Classes::Liebert::Components::SensorSubsystem::Sensor;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  $self->{label} = $self->{lgpEnvRemoteSensorUsrLabel} || $self->{lgpEnvRemoteSensorId};
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf 'temperature %s is %.2fC',
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
  if ($self->{lgpFlexibleEntryValue} =~ /Event Control$/) {
    bless $self, 'Classes::Liebert::Components::SensorSubsystem::Flexible::EventControl';
  } elsif ($self->{lgpFlexibleEntryValue} =~ /Event Type$/) {
    bless $self, 'Classes::Liebert::Components::SensorSubsystem::Flexible::EventType';
  } elsif ($self->{lgpFlexibleEntryValue} =~ /Event/) {
    bless $self, 'Classes::Liebert::Components::SensorSubsystem::Flexible::Event';
  } elsif ($self->{lgpFlexibleEntryDataLabel} =~ /Temperature Threshold/) {
    bless $self, 'Classes::Liebert::Components::SensorSubsystem::Flexible::TemperatureThreshold';
  } elsif ($self->{lgpFlexibleEntryDataLabel} =~ /Temperature/) {
    bless $self, 'Classes::Liebert::Components::SensorSubsystem::Flexible::Temperature';
  } elsif ($self->{lgpFlexibleEntryUnitsOfMeasure} && $self->{lgpFlexibleEntryUnitsOfMeasure} eq "deg F") {
    bless $self, 'Classes::Liebert::Components::SensorSubsystem::Flexible::Temperature';
  } elsif ($self->{lgpFlexibleEntryUnitsOfMeasure} && $self->{lgpFlexibleEntryUnitsOfMeasure} eq "%") {
    bless $self, 'Classes::Liebert::Components::SensorSubsystem::Flexible::Percent';
  }
  if (ref($self) ne 'Classes::Liebert::Components::SensorSubsystem::Flexible') {
    $self->finish();
  }
}

sub check {
  my ($self) = @_;
}

package Classes::Liebert::Components::SensorSubsystem::Flexible::EventType;
our @ISA = qw(Classes::Liebert::Components::SensorSubsystem::Flexible);
use strict;

package Classes::Liebert::Components::SensorSubsystem::Flexible::EventControl;
our @ISA = qw(Classes::Liebert::Components::SensorSubsystem::Flexible);
use strict;

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
  if ($self->{lgpFlexibleEntryValue} =~ /^(Remote|Average)/) {
    $self->{invalid} = 1;
    return;
  }
  if ($self->{lgpFlexibleEntryUnitsOfMeasure} eq "deg F") {
    $self->{lgpFlexibleEntryValue} = ($self->{lgpFlexibleEntryValue} - 32) * 5 / 9;
    $self->{lgpFlexibleEntryUnitsOfMeasure} = "deg C";
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
  if ($self->{lgpFlexibleEntryValue} =~ /^(Remote|Average)/) {
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
      label => 'temp_'.$self->{lgpFlexibleEntryDataLabel},
      value => $self->{lgpFlexibleEntryValue},
  );
}



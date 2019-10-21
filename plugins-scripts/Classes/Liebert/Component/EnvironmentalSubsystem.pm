package Classes::Liebert::Components::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("LIEBERT-GP-SYSTEM-MIB", qw(
      lgpSysState lgpSysControlOperationOnOff
  ));
  $self->get_snmp_objects("LIEBERT-GP-ENVIRONMENTAL-MIB", qw(
      lgpEnvStateSystem
  ));
  $self->get_snmp_objects("LIEBERT-GP-CONDITIONS-MIB", qw(
      lgpConditionsPresent
  ));
  $self->get_snmp_tables("LIEBERT-GP-ENVIRONMENTAL-MIB", [
    ["temperatures", "lgpEnvTemperatureDegCTable", "Classes::Liebert::Components::EnvironmentalSubsystem::Temperature", sub { return defined shift->{lgpEnvTemperatureMeasurementTenthsDegC} ? 1 : 0; }],
    ["humidities", "lgpEnvHumidityRelTable", "Classes::Liebert::Components::EnvironmentalSubsystem::Humidity", sub { return defined shift->{lgpEnvHumidityMeasurementRelTenths} ? 1 : 0; }],
  ]);
  $self->get_snmp_tables("LIEBERT-GP-FLEXIBLE-MIB", [
    ["flexentries", "lgpFlexibleBasicTable", "Classes::Liebert::Components::EnvironmentalSubsystem::FlexibleBasic"],
    ["flexextended", "lgpFlexibleExtendedTable", "Classes::Liebert::Components::EnvironmentalSubsystem::FlexibleExtended"],
  ]);
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf 'system state is %s/%s', $self->{lgpSysState},
      $self->{lgpEnvStateSystem});
  if ($self->{lgpSysState} eq 'normalWithWarning') {
    $self->add_warning();
  } elsif ($self->{lgpEnvStateSystem} eq 'off') {
    $self->add_warning();
  } elsif ($self->{lgpSysState} eq 'startUp' ||
      $self->{lgpSysState} eq 'normalOperation') {
    $self->add_ok();
  } else {
    $self->add_critical();
  }
  $self->SUPER::check();
}


package Classes::Liebert::Components::EnvironmentalSubsystem::FlexibleBasic;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
package Classes::Liebert::Components::EnvironmentalSubsystem::FlexibleExtended;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);


package Classes::Liebert::Components::EnvironmentalSubsystem::Humidity;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  foreach (qw(lgpEnvHumidityMeasurementRelTenths lgpEnvHumidityHighThresholdRelTenths
      lgpEnvHumidityLowThresholdRelTenths)) {
    if (exists $self->{$_} && ($self->{$_} == 32768 || $self->{$_} == 2147483647)) {
      $self->{$_} = undef;
    } elsif (exists $self->{$_} && $self->{$_} =~ /[\d\.]+/) {
      $self->{$_} /= 10;
    }
  }
  if ($self->{lgpEnvHumidityDescrRel} =~ /^[\.\d]+$/) {
    $self->{name} = $self->get_symbol(
        "LIEBERT-GP-ENVIRONMENTAL-MIB",
        $self->{lgpEnvHumidityDescrRel}
    );
  }
  if ($self->{name}) {
    $self->{name} =~ s/^lgpEnv//g;
    $self->{name} =~ s/Humidity//g;
    $self->{name} =~ s/(?:\b|(?<=([a-z])))([A-Z][a-z]+)/(defined($1) ? "_" : "") . lc($2)/eg;
  } else {
    $self->{name} = $self->{flat_indices};
  }
  $self->{name} = $self->{name};
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf 'humidity %s is %.2f%%',
      $self->{name}, $self->{lgpEnvHumidityMeasurementRelTenths});
  my $thresholds = (defined $self->{lgpEnvHumidityLowThresholdRelTenths} ?
      $self->{lgpEnvHumidityLowThresholdRelTenths}.":" : "").
      (defined $self->{lgpEnvHumidityHighThresholdRelTenths} ?
      $self->{lgpEnvHumidityHighThresholdRelTenths} : "");
  $thresholds = "" if ! $thresholds;
  $self->set_thresholds(
      metric => 'hum_'.$self->{name},
      warning => $thresholds,
      critical => $thresholds
  );
  $self->add_message($self->check_thresholds(
      metric => 'hum_'.$self->{name},
      value => $self->{lgpEnvHumidityMeasurementRelTenths},
  ));
  $self->add_perfdata(
      label => 'hum_'.$self->{name},
      value => $self->{lgpEnvHumidityMeasurementRelTenths},
      max => 100,
      min => 0,
  );
}


package Classes::Liebert::Components::EnvironmentalSubsystem::Temperature;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  foreach (qw(lgpEnvTemperatureMeasurementTenthsDegC lgpEnvTemperatureHighThresholdTenthsDegC
      lgpEnvTemperatureLowThresholdTenthsDegC)) {
    if (exists $self->{$_} && ($self->{$_} == 32768 || $self->{$_} == 2147483647)) {
      $self->{$_} = undef;
    } elsif (exists $self->{$_} && $self->{$_} =~ /[\d\.]+/) {
      $self->{$_} /= 10;
    }
  }
  if ($self->{lgpEnvTemperatureDescrDegC} =~ /^[\.\d]+$/) {
    $self->{name} = $self->get_symbol(
        "LIEBERT-GP-ENVIRONMENTAL-MIB",
        $self->{lgpEnvTemperatureDescrDegC}
    );
  }
  if ($self->{name}) {
    $self->{name} =~ s/^lgpEnv//g;
    $self->{name} =~ s/Temperature//g;
    $self->{name} =~ s/(?:\b|(?<=([a-z])))([A-Z][a-z]+)/(defined($1) ? "_" : "") . lc($2)/eg;
  } else {
    $self->{name} = $self->{flat_indices};
  }
  $self->{name} = $self->{name};
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf 'temperature %s is %.2fC',
      $self->{name}, $self->{lgpEnvTemperatureMeasurementTenthsDegC});
  my $thresholds = (defined $self->{lgpEnvTemperatureLowThresholdTenthsDegC} ?
      $self->{lgpEnvTemperatureLowThresholdTenthsDegC}.":" : "").
      (defined $self->{lgpEnvTemperatureHighThresholdTenthsDegC} ?
      $self->{lgpEnvTemperatureHighThresholdTenthsDegC} : "");
  $thresholds = "" if ! $thresholds;
  $self->set_thresholds(
      metric => 'temp_'.$self->{name},
      warning => $thresholds,
      critical => $thresholds
  );
  $self->add_message($self->check_thresholds(
      metric => 'temp_'.$self->{name},
      value => $self->{lgpEnvTemperatureMeasurementTenthsDegC},
  ));
  $self->add_perfdata(
      label => 'temp_'.$self->{name},
      value => $self->{lgpEnvTemperatureMeasurementTenthsDegC},
  );
}


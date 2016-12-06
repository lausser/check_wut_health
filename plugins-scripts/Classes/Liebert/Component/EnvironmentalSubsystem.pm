package Classes::Liebert::Components::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("LIEBERT-GP-SYSTEM-MIB", qw(
      lgpSysState
  ));
  $self->get_snmp_objects("LIEBERT-GP-CONDITIONS-MIB", qw(
      lgpConditionsPresent
  ));
  $self->get_snmp_tables("LIEBERT-GP-ENVIRONMENTAL-MIB", [
    ["temperatures", "lgpEnvTemperatureDegCTable", "Classes::Liebert::Components::EnvironmentalSubsystem::Temperature", sub { return defined shift->{lgpEnvTemperatureMeasurementTenthsDegC} ? 1 : 0; }],
    ["humidities", "lgpEnvHumidityRelTable", "Classes::Liebert::Components::EnvironmentalSubsystem::Humidity", sub { return defined shift->{lgpEnvHumidityMeasurementRelTenths} ? 1 : 0; }],
  ]);
}

sub check {
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
  $self->SUPER::check();
}


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
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf 'humidity %s is %.2f%%',
      $self->{flat_indices}, $self->{lgpEnvHumidityMeasurementRelTenths});
  $self->add_ok();
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
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf 'temperature %s is %.2fC',
      $self->{flat_indices}, $self->{lgpEnvTemperatureMeasurementTenthsDegC});
  $self->add_ok();
}

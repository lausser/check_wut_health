package Classes::Geist::V4::Components::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("GEIST-V4-MIB", qw(
      productTitle productVersion productFriendlyName deviceCount
      temperatureUnits 
  ));
  $self->get_snmp_tables("GEIST-V4-MIB", [
    ["internals", "internalTable", "Classes::Geist::V4::Components::EnvironmentalSubsystem::Internal", sub { my $o = shift; $o->{temperatureUnits} = $self->{temperatureUnits}; 1; } ],
  ]);
}


package Classes::Geist::V4::Components::EnvironmentalSubsystem::Internal;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  $self->{internalTemp} /= 10;
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s state is %s",
      $self->{internalName}, $self->{internalAvail});
  if ($self->{internalAvail} eq "Available") {
    $self->add_ok();
  } elsif ($self->{internalAvail} eq "Unavailable") {
    $self->add_critical();
  } elsif ($self->{internalAvail} eq "Partially Unavailable") {
    $self->add_warning();
  }
  $self->add_message($self->check_thresholds(metric => 'int_temp',
      value => $self->{internalTemp}),
      sprintf("intern. temp. %.1f%s", $self->{internalTemp}, $self->{temperatureUnits}));
  $self->add_message($self->check_thresholds(metric => 'int_hum',
      value => $self->{internalHumidity}),
      sprintf("intern. hum. %.1f%%", $self->{internalHumidity}));
  $self->set_thresholds(metric => 'int_temp',
      warning => '0:50',
      critical => '0:70',
  );
  $self->set_thresholds(metric => 'int_hum',
      warning => '70',
      critical => '80',
  );
  $self->add_perfdata(label => 'int_temp',
      value => $self->{internalTemp});
  $self->add_perfdata(label => 'int_hum',
      value => $self->{internalHumidity});
}


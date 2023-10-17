package CheckWutHealth::Raritan::PDU2::Component::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  my @tables = (qw(unitConfigurationTable unitSensorConfigurationTable
      unitSensorControlTable unitSensorMeasurementsTable));
  foreach (@tables) {
    my $package_name = "CheckWutHealth::Raritan::PDU2::Component::EnvironmentalSubsystem::".$_;
    {
      no strict "refs";
      @{ "${package_name}::ISA" } = ("Monitoring::GLPlugin::SNMP::TableItem");

    }
    $self->get_snmp_tables('PDU2-MIB', [
      [$_, $_, 'CheckWutHealth::Raritan::PDU2::Component::EnvironmentalSubsystem::'.$_],
    ]);
  }
  $self->merge_tables("unitSensorConfigurationTable", "unitSensorControlTable",
      "unitSensorMeasurementsTable");
}

sub check {
  my $self = shift;
  foreach (@{$self->{unitConfigurationTable}}) {
    $_->check();
  }
  foreach (@{$self->{unitSensorConfigurationTable}}) {
    $_->check();
  }
}


package CheckWutHealth::Raritan::PDU2::Component::EnvironmentalSubsystem::unitConfigurationTable;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check { 
  my $self = shift; 
  $self->add_info(sprintf "%s %s",
      $self->{productType}, $self->{pduName});
  $self->add_ok();
}


package CheckWutHealth::Raritan::PDU2::Component::EnvironmentalSubsystem::unitSensorConfigurationTable;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check { 
  my $self = shift; 
  $self->add_info(sprintf "unit sensor %s has status %s", 
      $self->{flat_indices}, 
      $self->{measurementsUnitSensorState});
  if ($self->{measurementsUnitSensorState} eq "ok") {
    $self->add_ok();
  } else {
    $self->add_critical();
  }
  # die dinger haben einen non-accessible sensorStatus (in der unitSensorConfigurationTable)
  # weiss der Geier, wie man da an den Typ und die Werte kommt.
}


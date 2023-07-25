package CheckWutHealth::NTI::ENVIROMUX5D::Components::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("ENVIROMUX5D", qw(
      firmwareVersion deviceModel devSerialNum devHardwareRev devManufacturer
  ));
  $self->get_snmp_tables("ENVIROMUX5D", [
      ["powersupplies", "pwrSupplyTable", "CheckWutHealth::NTI::ENVIROMUX5D::Components::EnvironmentalSubsystem::Powersupply"],
  ]);
}


package CheckWutHealth::NTI::ENVIROMUX5D::Components::EnvironmentalSubsystem::Powersupply;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my($self) = @_;
  $self->add_info(sprintf "powersupply %s has status %s",
      $self->{pwrSupplyIndex}, $self->{pwrSupplyStatus});
  if ($self->{pwrSupplyStatus} eq "ok") {
    $self->add_ok();
  } elsif ($self->{pwrSupplyStatus} eq "failed") {
    $self->add_warning();
  }
}


package CheckWutHealth::Emerson::KnuerrDCL::Component::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("KNUERR-DCL-MIB", [
    ["globalstates", "dclGlobalStateTable", "CheckWutHealth::Emerson::KnuerrDCL::Component::EnvironmentalSubsystem::GlobalState"],
    ["alarmglobals", "alarmGlobalTable", "CheckWutHealth::Emerson::KnuerrDCL::Component::EnvironmentalSubsystem::GlobalAlarm"],
    # irrelevant, besagt, was bei einem alarm passieren soll, sms, trap,...
    #["alarmcontrols", "alarmControlTable", "Monitoring::GLPlugin::SNMP::TableItem"],
  ]);
}

package CheckWutHealth::Emerson::KnuerrDCL::Component::EnvironmentalSubsystem::GlobalState;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "global state is: %s, %s",
      $self->{dclGlobalStateHealth}, $self->{dclGlobalStateActive});
  if ($self->{dclGlobalStateHealth} ne "online") {
    $self->add_critical();
  } else {
    $self->add_ok();
  }
}

package CheckWutHealth::Emerson::KnuerrDCL::Component::EnvironmentalSubsystem::GlobalAlarm;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  $self->{alarmGlobalIndex} = $self->{indices}->[0];
  $self->{alarmGlobalSource} = $self->{indices}->[1];
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s alarm found",
      $self->{alarmGlobalType});

  if ($self->{alarmGlobalPriority} eq "warning") {
    $self->add_warning();
  } else {
    $self->add_critical();
  }
}


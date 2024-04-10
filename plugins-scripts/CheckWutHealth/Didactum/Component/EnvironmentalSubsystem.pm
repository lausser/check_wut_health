package CheckWutHealth::Didactum::Components::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("DIDACTUM-SYSTEM-MIB", qw(
      systemDevType systemState systemCpuUsage systemMemUsage
  ));
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf '%s state is %s', $self->{systemDevType},
      $self->{systemState}
  );
  if ($self->{systemState} eq 'normal') {
    $self->add_ok();
  } else {
    $self->add_critical();
  }
  $self->{systemCpuUsage} =~ s/%$//g;
  $self->{systemMemUsage} =~ s/%$//g;
  $self->add_perfdata(
      label => 'cpu_usage',
      value => $self->{systemCpuUsage},
      uom => "%",
  );
  $self->add_perfdata(
      label => 'memory_usage',
      value => $self->{systemMemUsage},
      uom => "%",
  );
}


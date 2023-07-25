package CheckWutHealth::Rittal::LCPDX::Component::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  # alarm-output DESCRIPTION "General Alarm Contact" (ist 1, aber gui sagt ok)
  @{$self->{infooids}} = (qw(
    comp-on
  ));
  @{$self->{alarmoids}} = (qw(
    comp-overload high-pressure alarm-inverter alarm-off-line
    comp-on0 comp-on1 comp-on2 bms-res-alarm 
    al-envelope al-start-fail-lock mal-start-failure-msk 
    mal-discharge-ht mal-dp-startup mal-dp-lubrification-oil 
    mal-b1 alarm-server-in-temp1 alarm-server-in-temp2 alarm-server-in-temp3 
    mal-b5 alarm-server-out-temp1 alarm-server-out-temp2 alarm-server-out-temp3 
    alarm-comp-discharge-temp alarm-comp-suction-temp 
    alarm-comp-discharge-pressure alarm-comp-suction-pressure 
  ));
  $self->get_snmp_objects("RITTAL-LCP-DX-MIB", (@{$self->{alarmoids}}, @{$self->{infooids}}));
}

sub check {
  my ($self) = @_;
  foreach (grep { defined $self->{$_} } @{$self->{alarmoids}}) {
    $self->add_info(sprintf 'alarm %s is %sset', $_, $self->{$_} ? "" : "not");
    if ($self->{$_}) {
      $self->add_critical();
    }
  }
  delete $self->{alarmoids};
}


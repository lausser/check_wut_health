package Classes::Papouch;
our @ISA = qw(Classes::Device);

sub init {
  my $self = shift;
  if ($self->get_snmp_object('MIB-2-MIB', 'sysDescr', 0) =~ /TH2E/i) {
    bless $self, 'Classes::Papouch::TH2E';
    $self->debug('using Classes::Papouch::TH2E');
  }
  if (ref($self) ne "Classes::Papouch") {
    $self->init();
  } else {
    $self->no_such_mode();
  }
}


package Classes::Papouch::TH2E;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_sensor_subsystem("Classes::Papouch::TH2E::Component::SensorSubsystem");
  } else {
    $self->no_such_mode();
  }
}

package Classes::Papouch::TH2E::Component::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables("THE_V01-MIB", [
      ["channels", "channelTable", "Classes::Papouch::TH2E::Component::SensorSubsystem::Channel"],
      ["values", "watchValTable", "Classes::Papouch::TH2E::Component::SensorSubsystem::Value"],
  ]);
}

package Classes::Papouch::TH2E::Component::SensorSubsystem::Channel;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package Classes::Papouch::TH2E::Component::SensorSubsystem::Value;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub xcheck {
  my $self = shift;
  $self->add_info(sprintf "%s has state %s (%s)",
      $self->{wldName}, $self->{wldState}, $self->{wldValue});
  if ($self->{wldState} eq "invalid") {
    $self->add_unknown();
  } elsif ($self->{wldState} eq "alarm") {
    $self->add_critical();
  } else {
    $self->add_ok();
  }
}




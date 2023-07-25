package CheckWutHealth::Papouch;
our @ISA = qw(CheckWutHealth::Device);

sub init {
  my $self = shift;
  if ($self->get_snmp_object('MIB-2-MIB', 'sysDescr', 0) =~ /TH2E/i) {
    bless $self, 'CheckWutHealth::Papouch::TH2E';
    $self->debug('using CheckWutHealth::Papouch::TH2E');
  }
  if (ref($self) ne "CheckWutHealth::Papouch") {
    $self->init();
  } else {
    $self->no_such_mode();
  }
}


package CheckWutHealth::Papouch::TH2E;
our @ISA = qw(CheckWutHealth::Device);
use strict;

sub init {
  my ($self) = @_;
  if ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_sensor_subsystem("CheckWutHealth::Papouch::TH2E::Component::SensorSubsystem");
  } else {
    $self->no_such_mode();
  }
}

package CheckWutHealth::Papouch::TH2E::Component::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("THE_V01-MIB", qw(
    deviceName psAlarmString
  ));
  $self->get_snmp_tables("THE_V01-MIB", [
      ["channels", "channelTable", "CheckWutHealth::Papouch::TH2E::Component::SensorSubsystem::Channel"],
      ["values", "watchValTable", "CheckWutHealth::Papouch::TH2E::Component::SensorSubsystem::Value"],
  ]);
  $self->merge_tables("channels", "values");
}

sub check {
  my ($self) = @_;
  $self->SUPER::check();
  if ($self->{psAlarmString}) {
    $self->add_ok($self->{psAlarmString});
  }
}

package CheckWutHealth::Papouch::TH2E::Component::SensorSubsystem::Channel;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  $self->{inChValue} /= 10;
}

sub check {
  my ($self) = @_;
  my $name = 'channel_'.$self->{flat_indices};
  if ($self->{modeWatch} eq 'active') {
    $self->add_info(sprintf '%s value is %.2f%s, status is %s',
        $name, $self->{inChValue}, $self->{inChUnits}, $self->{inChStatus}
    );
    $self->set_thresholds(metric => $name,
        warning => $self->{limitLo}.':'.$self->{limitHi},
        critical => $self->{limitLo}.':'.$self->{limitHi},
    );
    $self->add_message($self->check_thresholds(metric => $name,
        value => $self->{inChValue}
    ));
    $self->add_perfdata(label => $name,
        value => $self->{inChValue},
        uom => $self->{inChUnits} eq 'percent' ? '%' : '',
    );
  }
}

package CheckWutHealth::Papouch::TH2E::Component::SensorSubsystem::Value;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  $self->{limitHi} /= 10;
  $self->{limitLo} /= 10;
}



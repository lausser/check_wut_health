package Classes::Emerson::RDU::Component::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("ENP-RDU-MIB", qw(
      identManufacturer identModel systemstatus runningconfigtype
      outgoingalarmblocked
  ));
  $self->get_snmp_objects("ENP-AC-PACC-MIB", qw(
      systemoperatingstate
  ));
  my @sic_dreck = (qw(
      sensor0 temp0 hum0 temp0alarmstatus hum0alarmstatus
      sensor1 temp1 hum1 temp1alarmstatus hum1alarmstatus
      sensor2 temp2 hum2 temp2alarmstatus hum2alarmstatus
      sensor3 temp3 hum3 temp3alarmstatus hum3alarmstatus
      sensor0-a
      door01 door02 warter0 smoke0
      sensor1-a
      door11 door12 warter1 smoke1
      communicationstatus
      uninstalldi0 uninstalldi1
      hightemp0alarmlimit lowtemp0alarmlimit highhum0alarmlimit lowhum0alarmlimit
      hightemp1alarmlimit lowtemp1alarmlimit highhum1alarmlimit lowhum1alarmlimit
      hightemp2alarmlimit lowtemp2alarmlimit highhum2alarmlimit lowhum2alarmlimit
      hightemp3alarmlimit lowtemp3alarmlimit highhum3alarmlimit lowhum3alarmlimit
      door01criterion door02criterion warter0criterion smoke0criterion
      door11criterion door12criterion warter1criterion smoke1criterion
  ));
  $self->get_snmp_objects("ENP-ENV-SIC-MIB", @sic_dreck);
  @{$self->{sensors}} = ();
  for my $sensornum (0..3) {
    my $sensor = Classes::Emerson::RDU::Component::EnvironmentalSubsystem::DrecksSensor->new();
    $sensor->{name} = "sensor".$sensornum;
    $sensor->{number} = $sensornum;
    $sensor->{type} = $self->{"sensor".$sensornum};
    if ($sensor->{type} eq "temphumsensor") {
      $sensor->{temp} = $self->{"temp".$sensornum} / 10;
      $sensor->{tempalarmstatus} = $self->{"temp".$sensornum."alarmstatus"};
      $sensor->{lowtempalarm} = $self->{"lowtemp".$sensornum."alarmlimit"} / 10;
      $sensor->{hightempalarm} = $self->{"hightemp".$sensornum."alarmlimit"} / 10;
      $sensor->{hum} = $self->{"hum".$sensornum} / 10;
      $sensor->{humalarmstatus} = $self->{"hum".$sensornum."alarmstatus"};
      $sensor->{lowhumalarm} = $self->{"lowhum".$sensornum."alarmlimit"} / 10;
      $sensor->{highhumalarm} = $self->{"highhum".$sensornum."alarmlimit"} / 10;
    } elsif ($sensor->{type} eq "tempsensor") {
      $sensor->{temp} = $self->{"temp".$sensornum} / 10;
      $sensor->{tempalarmstatus} = $self->{"temp".$sensornum."alarmstatus"};
      $sensor->{lowtempalarm} = $self->{"lowtemp".$sensornum."alarmlimit"} / 10;
      $sensor->{hightempalarm} = $self->{"hightemp".$sensornum."alarmlimit"} / 10;
    } elsif ($sensor->{type} eq "4digitalinputsensor") {
    } elsif ($sensor->{type} eq "invalidequip") {
    }
    push(@{$self->{sensors}}, $sensor);
  }
  # sensor0-a und sensor1-a interessiert mich nicht. Macht euren Dreck alleine.
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf 'system status is %s, runningconfig type is %s, operating state is %s',
      $self->{systemstatus},
      $self->{runningconfigtype},
      $self->{systemoperatingstate});
  if ($self->{systemstatus} eq 'alarm') {
    $self->add_critical();
  } else {
    $self->add_ok();
  }
  $self->SUPER::check();
  foreach (qw(smoke0 smoke1 warter0 warter1 door01 door02 door11 door12)) {
    $self->add_info(sprintf "%s has status %s", $_, $self->{$_});
    if ($self->{$_} eq "alarm") {
      $self->add_critical();
    }
  }
}

package Classes::Emerson::RDU::Component::EnvironmentalSubsystem::DrecksSensor;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my ($self) = @_;
  if (exists $self->{tempalarmstatus}) {
    $self->add_info(sprintf "%s temperature is %.2fC, status %s",
        $self->{name}, $self->{temp}, $self->{tempalarmstatus});
    $self->add_perfdata(label => $self->{name}."_temp",
        value => $self->{temp},
        warning => $self->{lowtempalarm}.":".$self->{hightempalarm},
        critical => $self->{lowtempalarm}.":".$self->{hightempalarm},
    );
    if ($self->{tempalarmstatus} eq "normal") {
    } elsif ($self->{tempalarmstatus} eq "hightemp") {
      $self->add_critical();
    } elsif ($self->{tempalarmstatus} eq "lowtemp") {
      $self->add_critical();
    } elsif ($self->{tempalarmstatus} eq "invalid") {
      $self->add_unknown();
    }
  }
  if (exists $self->{humalarmstatus}) {
    $self->add_info(sprintf "%s humidity is %.2f%%, status %s",
        $self->{name}, $self->{hum}, $self->{humalarmstatus});
    $self->add_perfdata(label => $self->{name}."_hum",
        value => $self->{hum},
        warning => $self->{lowhumalarm}.":".$self->{highhumalarm},
        critical => $self->{lowhumalarm}.":".$self->{highhumalarm},
        uom => "%",
    );
    if ($self->{humalarmstatus} eq "normal") {
    } elsif ($self->{humalarmstatus} eq "highhum") {
      $self->add_critical();
    } elsif ($self->{humalarmstatus} eq "lowhum") {
      $self->add_critical();
    } elsif ($self->{humalarmstatus} eq "invalid") {
      $self->add_unknown();
    }
  }
}


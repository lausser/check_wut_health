package CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("ENVIROMUX5D", qw(
      firmwareVersion deviceModel devSerialNum devHardwareRev devManufacturer
  ));
  $self->get_snmp_tables("ENVIROMUX5D", [
      ["intsensors", "intSensorTable", "CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Intsensor"],
      ["auxsensors", "auxSensorTable", "CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Auxsensor"],
      ["aux2sensors", "aux2SensorTable", "CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Aux2sensor"],
      ["extsensors", "extSensorTable", "CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Extsensor"],
      ######["extsensorsaclm", "extSensorAclmTable", "CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::ExtsensorAclm"],
      ["allexternalsensors", "allExternalSensorTable", "CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::AllExtsensor"],
      ######["allexternalaclmsensors", "allExternalSensorAclmTable", "Monitoring::GLPlugin::SNMP::TableItem"],
      ["tacsensors", "tacSensorTable", "CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Tacsensor"],
      ["diginputs", "digInputTable", "CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::DigInput"],
      ["remoteinputs", "remoteInputTable", "CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::RemoteInput"],
      ["ipdevices", "ipDeviceTable", "CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Ipdevice"],
      ["events", "eventTable", "CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Event"],
      ["smartalerts", "smartAlertTable", "CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Smartalert"],
      ["smokedetectors", "smokeDetectorTable", "CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Smokedetector"],
      ["ipsensors", "ipSensorTable", "CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Ipsensor"],
  ]);
}

package CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my($self) = @_;
  my $prefix = $self->{sensorPrefix};
  if ($self->{$prefix."SensorValue"} =~ /^[\d\.\-]+$/) {
    $self->{is_numeric} = 1;
    $self->{$prefix."SensorValue"} /= 10.0;
    $self->{$prefix."SensorMaxThreshold"} /= 10.0;
    $self->{$prefix."SensorMaxWarnThreshold"} /= 10.0;
    $self->{$prefix."SensorMinThreshold"} /= 10.0;
    $self->{$prefix."SensorMinWarnThreshold"} /= 10.0;
  } else {
    $self->{is_numeric} = 0;
  }
}

sub check {
  my($self) = @_;
  my $prefix = $self->{sensorPrefix};
  if ($self->{$prefix."SensorStatus"} eq "notconnected") {
    return;
  }
  $self->add_info(sprintf "%s has status %s and value %s%s",
      $self->{$prefix."SensorDescription"},
      $self->{$prefix."SensorStatus"},
      $self->{$prefix."SensorValue"},
      $self->{$prefix."SensorUnitName"},
  );
  $self->add_mapped_status();
  if ($self->{is_numeric}) {
    $self->set_thresholds(metric => lc $prefix."_".$self->{$prefix."SensorDescription"},
        warning => $self->{$prefix."SensorMinWarnThreshold"}.":".$self->{$prefix."SensorMaxWarnThreshold"},
        critical => $self->{$prefix."SensorMinThreshold"}.":".$self->{$prefix."SensorMaxThreshold"},
    );
    $self->add_perfdata(label => lc $prefix."_".$self->{$prefix."SensorDescription"},
        value => $self->{$prefix."SensorValue"},
        uom => $self->{$prefix."SensorUnitName"} eq "%" ? "%" : undef,
    );
  }
}

sub add_mapped_status {
  my($self) = @_;
  my $prefix = $self->{sensorPrefix};
  my $status = $self->{$prefix."SensorStatus"};
  if ($status eq "normal") {
    $self->add_ok();
  } elsif ($status eq "prealert") {
    $self->add_warning();
  } elsif ($status eq "alert") {
    $self->add_critical();
  } elsif ($status eq "acknowledged") {
    $self->add_ok();
  } elsif ($status eq "dismissed") {
    $self->add_ok();
  } elsif ($status eq "disconnected") {
    $self->add_unknown();
  } elsif ($status eq "notApplicable") {
    $self->add_unknown();
  }
}

package CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Input;
our @ISA = qw(CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor);
use strict;

sub check {
  my($self) = @_;
  my $prefix = $self->{inputPrefix};
  if ($self->{$prefix."InputStatus"} eq "notconnected") {
    return;
  }
  $self->add_info(sprintf "%s has status %s (%s%s)",
      $self->{$prefix."InputDescription"},
      $self->{$prefix."InputStatus"},
      $self->{$prefix."InputValue"},
      ($self->{$prefix."InputValue"} ne $self->{$prefix."InputNormalValue"} ? " instead of ".$self->{$prefix."InputNormalValue"} : ""),
  );
  $self->{sensorPrefix} = $prefix;
  $self->{$prefix."SensorStatus"} = $self->{$prefix."InputStatus"};
  $self->add_mapped_status();
}


package CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Intsensor;
our @ISA = qw(CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor);
use strict;

sub finish {
  my($self) = @_;
  $self->{sensorPrefix} = "int";
  $self->SUPER::finish();
}


package CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Auxsensor;
our @ISA = qw(CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor);
use strict;

sub finish {
  my($self) = @_;
  $self->{sensorPrefix} = "aux";
  $self->SUPER::finish();
}


package CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Aux2sensor;
our @ISA = qw(CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor);
use strict;

sub finish {
  my($self) = @_;
  $self->{sensorPrefix} = "aux2";
  $self->SUPER::finish();
}


package CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Extsensor;
our @ISA = qw(CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor);
use strict;

sub finish {
  my($self) = @_;
  $self->{sensorPrefix} = "ext";
  $self->SUPER::finish();
}


package CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Allexternalsensor;
our @ISA = qw(CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor);
use strict;

sub finish {
  my($self) = @_;
  $self->{sensorPrefix} = "allExternal";
  $self->SUPER::finish();
}


package CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Allexternalaclmsensor;
our @ISA = qw(CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor);
use strict;

package CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Tacsensor;
our @ISA = qw(CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor);
use strict;

sub finish {
  my($self) = @_;
  $self->{sensorPrefix} = "tac";
}


package CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::DigInput;
our @ISA = qw(CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Input);
use strict;

sub finish {
  my($self) = @_;
  $self->{inputPrefix} = "dig";
}


package CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::RemoteInput;
our @ISA = qw(CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Input);
use strict;

sub finish {
  my($self) = @_;
  $self->{inputPrefix} = "remote";
}


package CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Ipdevice;
our @ISA = qw(CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor);
use strict;

package CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::GenericEvent;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my($self) = @_;
  my $prefix = $self->{eventPrefix};
  $self->add_info(sprintf "Event %s has status %s",
      $self->{$prefix."Description"},
      $self->{$prefix."Status"},
  );
  if ($self->{$prefix."Status"} eq "alert") {
    $self->add_critical();
  }
}


package CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Event;
our @ISA = qw(CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::GenericEvent);
use strict;

sub finish {
  my($self) = @_;
  $self->{eventPrefix} = "event";
}


package CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Smartalert;
our @ISA = qw(CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::GenericEvent);
use strict;

sub finish {
  my($self) = @_;
  $self->{eventPrefix} = "smartAlert";
}


package CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Smokedetector;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my($self) = @_;
  if ($self->{smokeDetectorStatus} eq "notconnected") {
    return;
  }
  $self->add_info(sprintf "%s has status %s",
      $self->{smokeDetectorDescription},
      $self->{smokeDetectorValue},
  );
  if ($self->{smokeDetectorStatus} eq "alert") {
    $self->add_critical();
  } elsif ($self->{smokeDetectorStatus} eq "prealert") {
    $self->add_warning();
  } else {
    $self->add_ok();
  }
}

package CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Ipsensor;
our @ISA = qw(CheckWutHealth::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor);
use strict;

sub finish {
  my($self) = @_;
  $self->{sensorPrefix} = "ip";
}


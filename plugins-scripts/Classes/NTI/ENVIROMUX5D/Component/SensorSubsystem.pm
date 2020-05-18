package Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("ENVIROMUX5D", qw(
      firmwareVersion deviceModel devSerialNum devHardwareRev devManufacturer
  ));
  $self->get_snmp_tables("ENVIROMUX5D", [
      ["intsensors", "intSensorTable", "Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Intsensor"],
      ["auxsensors", "auxSensorTable", "Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Auxsensor"],
      ["aux2sensors", "aux2SensorTable", "Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Aux2sensor"],
      ["extsensors", "extSensorTable", "Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Extsensor"],
      ######["extsensorsaclm", "extSensorAclmTable", "Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::ExtsensorAclm"],
      ["allexternalsensors", "allExternalSensorTable", "Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::AllExtsensor"],
      ######["allexternalaclmsensors", "allExternalSensorAclmTable", "Monitoring::GLPlugin::SNMP::TableItem"],
      ["tacsensors", "tacSensorTable", "Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Tacsensor"],
      ["diginputs", "digInputTable", "Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::DigInput"],
      ["remoteinputs", "remoteInputTable", "Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::RemoteInput"],
      ["ipdevices", "ipDeviceTable", "Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Ipdevice"],
      ["events", "eventTable", "Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Event"],
      ["smartalerts", "smartAlertTable", "Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Smartalert"],
      ["smokedetectors", "smokeDetectorTable", "Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Smokedetector"],
      ["ipsensors", "ipSensorTable", "Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Ipsensor"],
  ]);
}

package Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor;
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

package Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Input;
our @ISA = qw(Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor);
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


package Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Intsensor;
our @ISA = qw(Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor);
use strict;

sub finish {
  my($self) = @_;
  $self->{sensorPrefix} = "int";
  $self->SUPER::finish();
}


package Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Auxsensor;
our @ISA = qw(Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor);
use strict;

sub finish {
  my($self) = @_;
  $self->{sensorPrefix} = "aux";
  $self->SUPER::finish();
}


package Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Aux2sensor;
our @ISA = qw(Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor);
use strict;

sub finish {
  my($self) = @_;
  $self->{sensorPrefix} = "aux2";
  $self->SUPER::finish();
}


package Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Extsensor;
our @ISA = qw(Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor);
use strict;

sub finish {
  my($self) = @_;
  $self->{sensorPrefix} = "ext";
  $self->SUPER::finish();
}


package Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Allexternalsensor;
our @ISA = qw(Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor);
use strict;

sub finish {
  my($self) = @_;
  $self->{sensorPrefix} = "allExternal";
  $self->SUPER::finish();
}


package Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Allexternalaclmsensor;
our @ISA = qw(Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor);
use strict;

package Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Tacsensor;
our @ISA = qw(Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor);
use strict;

sub finish {
  my($self) = @_;
  $self->{sensorPrefix} = "tac";
}


package Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::DigInput;
our @ISA = qw(Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Input);
use strict;

sub finish {
  my($self) = @_;
  $self->{inputPrefix} = "dig";
}


package Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::RemoteInput;
our @ISA = qw(Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Input);
use strict;

sub finish {
  my($self) = @_;
  $self->{inputPrefix} = "remote";
}


package Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Ipdevice;
our @ISA = qw(Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor);
use strict;

package Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::GenericEvent;
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


package Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Event;
our @ISA = qw(Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::GenericEvent);
use strict;

sub finish {
  my($self) = @_;
  $self->{eventPrefix} = "event";
}


package Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Smartalert;
our @ISA = qw(Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::GenericEvent);
use strict;

sub finish {
  my($self) = @_;
  $self->{eventPrefix} = "smartAlert";
}


package Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Smokedetector;
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

package Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Ipsensor;
our @ISA = qw(Classes::NTI::ENVIROMUX5D::Components::SensorSubsystem::Sensor);
use strict;

sub finish {
  my($self) = @_;
  $self->{sensorPrefix} = "ip";
}


package CheckWutHealth::Didactum::Components::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("DIDACTUM-SYSTEM-MIB", [
    ["modules", "ctlUnitModulesTable", "CheckWutHealth::Didactum::Components::SensorSubsystem::Module", sub {
      my $o = shift; return $self->filter_name($o->{ctlUnitModuleName});
    } ],
  ]);
  my @module_ids = map {
    $_->{ctlUnitModuleId};
  } @{$self->{modules}};

  $self->get_snmp_tables("DIDACTUM-SYSTEM-MIB", [
    ["elements", "ctlUnitElementsTable", "CheckWutHealth::Didactum::Components::SensorSubsystem::Element", sub {
        my $o = shift; grep { $_ == $o->{ctlUnitElementModule} } @module_ids;
    }],
    ["discretes", "ctlInternalSensorsDiscretsTable", "CheckWutHealth::Didactum::Components::SensorSubsystem::InternalSensorDiscrete", sub {
        my $o = shift; grep { $_ == $o->{ctlInternalSensorsDiscretModule} } @module_ids;
    }],
    ["analogs", "ctlInternalSensorsAnalogsTable", "CheckWutHealth::Didactum::Components::SensorSubsystem::SensorAnalog", sub {
        my $o = shift; grep { $_ == $o->{ctlInternalSensorsAnalogModule} } @module_ids;
    }],
    ["outlets", "ctlInternalSensorsOutletsTable", "CheckWutHealth::Didactum::Components::SensorSubsystem::InternalSensorOutlet", sub {
        my $o = shift; grep { $_ == $o->{ctlInternalSensorsOutletModule} } @module_ids;
    }],
    ["canalogs", "ctlCANSensorsAnalogsTable", "CheckWutHealth::Didactum::Components::SensorSubsystem::CANSensorAnalog", sub {
        my $o = shift; grep { $_ == $o->{ctlCANSensorsAnalogModule} } @module_ids;
    }],
  ]);
  # wenn man die auskommentierten Tabellen abfraegt, dann sieht man, dass
  # alle Komponenten, seien es analoge oder diskrete Sensoren etc. unter der
  # Tabelle ctlUnitElementsTable in einheitlicher Form auftauchen.
  # Allerdings bieten die speziellen Tabellen,
  # z.b. ctlInternalSensorsAnalogsTable zusaetzlich Schwellwerte und
  # Min/Max-Werte.
  # Wir schmeissen also alle Eintraege aus elements, fuer die es spezialisierte
  # Objekte gibt.
  my @specialized_ids = ();
  push(@specialized_ids, map {
      $_->{ctlInternalSensorsDiscretId}
  } @{$self->{discretes}});
  push(@specialized_ids, map {
      $_->{ctlInternalSensorsAnalogId}
  } @{$self->{analogs}});
  push(@specialized_ids, map {
      $_->{ctlInternalSensorsOutletId}
  } @{$self->{outlets}});
  push(@specialized_ids, map {
      $_->{ctlCANSensorsAnalogId}
  } @{$self->{canalogs}});
  my @element_ids = map { $_->{ctlUnitElementId} } @{$self->{elements}};
  @{$self->{elements}} = grep {
    my $element_id = $_->{ctlUnitElementId};
    if (grep { $_ == $element_id } @specialized_ids) {
      0;
    } else {
      1;
    }
  } @{$self->{elements}};
}



package CheckWutHealth::Didactum::Components::SensorSubsystem::Module;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package CheckWutHealth::Didactum::Components::SensorSubsystem::InternalSensorOutlet;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my ($self) = @_;
  $self->add_info(sprintf '%s %s state is %s',
      $self->{ctlInternalSensorsOutletType},
      $self->{ctlInternalSensorsOutletName},
      $self->{ctlInternalSensorsOutletState});
  if ($self->{ctlInternalSensorsOutletType} eq "strobo" and
      $self->{ctlInternalSensorsOutletState} eq "off") {
    # strobo = irgendein blinklicht
    $self->add_ok();
  } elsif ($self->{ctlInternalSensorsOutletType} eq "relay" and
      $self->{ctlInternalSensorsOutletState} eq "on") {
    # relay (z.b. fuer Analog sensor power reset, muss wohl on sein
    $self->add_ok();
  } else {
    $self->add_critical();
  }
}


package CheckWutHealth::Didactum::Components::SensorSubsystem::InternalSensorDiscrete;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my ($self) = @_;
  $self->add_info(sprintf '%s value %.2f is %s',
      $self->{ctlInternalSensorsDiscretName},
      $self->{ctlInternalSensorsDiscretValue},
      $self->{ctlInternalSensorsDiscretState});
  if ($self->{ctlInternalSensorsDiscretState} eq "normal") {
    $self->add_ok();
  } else {
    $self->add_critical();
  }
}


package CheckWutHealth::Didactum::Components::SensorSubsystem::Element;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  $self->{label} = lc $self->{ctlUnitElementName};
  $self->{label} =~ s/[ -]/_/g;
  if ($self->{ctlUnitElementClass} eq "discrete") {
    bless $self, "CheckWutHealth::Didactum::Components::SensorSubsystem::ElementDiscrete";
  } elsif ($self->{ctlUnitElementClass} eq "analog") {
    bless $self, "CheckWutHealth::Didactum::Components::SensorSubsystem::ElementAnalog";
  }
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf '%s is %s',
      $self->{ctlUnitElementName},
      $self->{ctlUnitElementState});
  if ($self->{ctlUnitElementState} eq "normal") {
    $self->add_ok();
  } else {
    $self->add_critical();
  }
}

package CheckWutHealth::Didactum::Components::SensorSubsystem::ElementAnalog;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my ($self) = @_;
  $self->add_info(sprintf '%s value %.2f is %s',
      $self->{ctlUnitElementName},
      $self->{ctlUnitElementValue},
      $self->{ctlUnitElementState});
  if ($self->{ctlUnitElementState} eq "normal") {
    $self->add_ok();
  } else {
    $self->add_critical();
  }
  if ($self->{ctlUnitElementType} eq "humidity") {
    $self->add_perfdata(
        label => $self->{label},
        value => $self->{ctlUnitElementValue},
        uom => "%",
    );
  } else {
    $self->add_perfdata(
        label => $self->{label},
        value => $self->{ctlUnitElementValue},
    );
  }
}


package CheckWutHealth::Didactum::Components::SensorSubsystem::ElementDiscrete;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my ($self) = @_;
  $self->add_info(sprintf '%s state is %s',
      $self->{ctlUnitElementName},
      $self->{ctlUnitElementState});
  if ($self->{ctlUnitElementState} eq "normal") {
    $self->add_ok();
  } else {
    $self->add_critical();
  }
}


package CheckWutHealth::Didactum::Components::SensorSubsystem::SensorAnalog;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  $self->{label} = lc $self->{ctlInternalSensorsAnalogName};
  $self->{label} =~ s/[ -]/_/g;
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf '%s value %.2f is %s',
      $self->{ctlInternalSensorsAnalogName},
      $self->{ctlInternalSensorsAnalogValue},
      $self->{ctlInternalSensorsAnalogState});
  if ($self->{ctlInternalSensorsAnalogState} eq "normal") {
    $self->add_ok();
  } else {
    $self->add_critical();
  }
  $self->add_perfdata(
      label => $self->{label},
      value => $self->{ctlInternalSensorsAnalogValueInt} / 100.0,
      warning => $self->{ctlInternalSensorsAnalogLowWarning}.":".$self->{ctlInternalSensorsAnalogHighWarning},
      critical => $self->{ctlInternalSensorsAnalogLowAlarm}.":".$self->{ctlInternalSensorsAnalogHystHighAlarm},
      min => $self->{ctlInternalSensorsAnalogMin},
      max => $self->{ctlInternalSensorsAnalogMax},
      uom => ($self->{ctlInternalSensorsAnalogType} eq "humidity" ? "%" : ""),
  );
}

package CheckWutHealth::Didactum::Components::SensorSubsystem::CANSensorAnalog;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  $self->{label} = lc $self->{ctlCANSensorsAnalogName};
  $self->{label} =~ s/[ -]/_/g;
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf '%s value %.2f is %s',
      $self->{ctlCANSensorsAnalogName},
      $self->{ctlCANSensorsAnalogValue},
      $self->{ctlCANSensorsAnalogState});
  if ($self->{ctlCANSensorsAnalogState} eq "normal") {
    $self->add_ok();
  } else {
    $self->add_critical();
  }
  $self->add_perfdata(
      label => $self->{label},
      value => $self->{ctlCANSensorsAnalogValueInt} / 100.0,
      warning => $self->{ctlCANSensorsAnalogLowWarning}.":".$self->{ctlCANSensorsAnalogHighWarning},
      critical => $self->{ctlCANSensorsAnalogLowAlarm}.":".$self->{ctlCANSensorsAnalogHighAlarm},
      uom => ($self->{ctlCANSensorsAnalogType} eq "humidity" ? "%" : ""),
      min => $self->{ctlCANSensorsAnalogMin},
      max => $self->{ctlCANSensorsAnalogMax},
  );
}


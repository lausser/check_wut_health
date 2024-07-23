package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  my @collections = (qw(dclgateways));
  $self->get_snmp_tables("KNUERR-DCL-MIB", [
    ["globalsettingslimits", "dclGlobalSettingsLimitsTable", "Monitoring::GLPlugin::SNMP::TableItem"],
    ["dclgateways", "dclGatewayCtrlTable", "CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::Gateway"],
  ]);
  foreach (qw(A101 A102 A103 A105 A106 A107 A110 A405 A406)) {
    $self->get_snmp_tables("KNUERR-DCL-MIB", [
      [sprintf("dcl%sfanmodules", $_), sprintf("dclFanModule%sTable", $_), sprintf("CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::FanModule%s", $_)],
    ]);
    push(@collections, sprintf("dcl%sfanmodules", $_));
  }
  # dclTemperaturesAR3A203 OBJECT IDENTIFIER        ::= { dclModulesPort2 7 }
  # 
  #         dclTemperaturesAR3A203Table OBJECT-TYPE
  #           SYNTAX SEQUENCE OF DclTemperaturesAR3A203Entry
  #         DclTemperaturesAR3A203Entry ::= SEQUENCE {
  #                 dclTemperaturesAR3A203Index CoolCons,
  # 
  # davon gibt es mehrere
  # aber der tanzt aus der Reihe.
  # dclTemperaturesAR1A203 OBJECT IDENTIFIER        ::= { dclModulesPort2 3 }
  # 
  #         dclTemperaturesAR1A203Table OBJECT-TYPE^M
  #           SYNTAX SEQUENCE OF DclTemperatureModule203Entry
  #         DclTemperatureModule203Entry ::= SEQUENCE {
  #                 dclTemperaturesAR1A203Index     CoolCons,
  # 
  # warum die eine (von den OIDs her identische) Table aus ModuleEntries
  # besteht, weiss der Knuerr.
  foreach (qw(AR1A203 AR2A203 AR3A203 AR4A203)) {
    $self->get_snmp_tables("KNUERR-DCL-MIB", [
      [sprintf("dcl%stemperatures", $_), sprintf("dclTemperatures%sTable", $_), sprintf("CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::Temperatures%s", $_)],
    ]);
    push(@collections, sprintf("dcl%stemperatures", $_));
  }
  foreach (qw(A104 A108 A111 A407 A408)) {
    $self->get_snmp_tables("KNUERR-DCL-MIB", [
      [sprintf("dcl%svalvemodules", $_), sprintf("dclValveModule%sTable", $_), sprintf("CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::ValveModule%s", $_)],
    ]);
    push(@collections, sprintf("dcl%svalvemodules", $_));
  }
  foreach (qw(A109 AR3A208 AR4A208 A409)) {
    $self->get_snmp_tables("KNUERR-DCL-MIB", [
      [sprintf("dcl%sanalogues", $_), sprintf("dclAnalogue%sTable", $_), sprintf("CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::AnalogueModule%s", $_)],
    ]);
    push(@collections, sprintf("dcl%sanalogues", $_));
  }
  $self->{collections} = \@collections;
}

sub check {
  my ($self) = @_;
  my $count = 0;
  map {
    if ($self->{$_}) {
      $count += scalar(@{$self->{$_}});
    }
  } @{$self->{collections}};
  delete $self->{collections};
  $self->add_ok(sprintf "checked %d modules/sensors", $count);
  $self->SUPER::check();
}

package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::FanModule;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  my $class = ref($self);
  $class =~ /::FanModuleA(\d+)/;
  my $number = $1;
  foreach my $attr (qw(Name Health State Speed1 Speed2 SupplyAir ReturnAir)) {
    if (exists $self->{'dclFanModuleA'.$number.$attr}) {
      $self->{'dclFanModule'.$attr} = $self->{'dclFanModuleA'.$number.$attr};
    }
  }
  foreach my $attr (qw(Name Health State Speed1 Speed2 SupplyAir ReturnAir)) {
    delete $self->{'dclFanModuleA'.$number.$attr};
  }
  $self->{dclFanModuleSpeed1} /= 10 if $self->{dclFanModuleSpeed1};
  $self->{dclFanModuleSpeed2} /= 10 if $self->{dclFanModuleSpeed2};
  $self->{dclFanModuleSupplyAir} /= 10 if $self->{dclFanModuleSupplyAir};
  $self->{dclFanModuleReturnAir} /= 10 if $self->{dclFanModuleReturnAir};
  $self->{label} = lc $self->{dclFanModuleName};
  $self->{label} =~ s/[- ]/_/g;
  # Temperatur -30 duefte ein Ersatz sein fuer "nicht verbaut"
}

sub check {
  my ($self) = @_;
  # dclFanModuleHealth "If an error is occured."
  # dclFanModuleState "State of fans."
  # example
  # dclFanModuleHealth: online
  # dclFanModuleName: Fan Module A101 dev-1
  # dclFanModuleReturnAir: 21.4
  # dclFanModuleSpeed1: 33.8
  # dclFanModuleSpeed2: 34.3
  # dclFanModuleState: fan2Fault,standAloneRun
  # dclFanModuleSupplyAir: 19.9
  #
  # I guess, if standAloneRun is set, then there is intentionally just
  # one fan and one dan*Fault can be tolerated.
  # But why are there two speed values?
  my $state = {
      fan1Fault => 0,
      fan2Fault => 0,
      emergencyRun => 0,
      standAloneRun => 0,
      sensorFaultK => 0,
      sensorFaultW => 0,
      busOk => 0,
  };
  foreach my $statekey (split /,/, $self->{dclFanModuleState}) {
    $state->{$statekey} = 1;
  }
  %{$self->{state}} = %{$state};
  $self->add_info(sprintf "%s is %s", $self->{dclFanModuleName},
      $self->{dclFanModuleHealth});
  if ($self->{dclFanModuleHealth} ne "online") {
    $self->add_warning();
  }
  # dclValveModuleHealth: online
  # dclValveModuleName: Valve Module A104 dev-1
  # dclValveModulePosition1: 0
  # dclValveModulePosition2: 37.7
  # dclValveModuleState: standAloneRun,sensorFault2
  # tja, und jetzt?
  # dclValveModuleTemperature1: 19.4
  # dclValveModuleTemperature2: -30
  # dclValveModuleTemperature3: -30
  # keine Auswertung, macht doch, was ihr wollt
  $self->add_perfdata(
    label => $self->{label}."_return_air",
    value => $self->{dclFanModuleReturnAir},
  ) if $self->{dclFanModuleReturnAir} != -30 ;
  $self->add_perfdata(
    label => $self->{label}."_supply_air",
    value => $self->{dclFanModuleSupplyAir},
  ) if $self->{dclFanModuleSupplyAir} != -30;
  $self->add_perfdata(
    label => $self->{label}."_fan1_speed",
    value => $self->{dclFanModuleSpeed1},
    uom => '%',
  );
  $self->add_perfdata(
    label => $self->{label}."_fan2_speed",
    value => $self->{dclFanModuleSpeed2},
    uom => '%',
  );
}

sub dump {
  my ($self) = @_;
  $self->SUPER::dump();
  printf "%s\n", Data::Dumper::Dumper($self->{state});
}


package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::FanModuleA101;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::FanModule);
use strict;

package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::FanModuleA102;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::FanModule);
use strict;

package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::FanModuleA103;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::FanModule);
use strict;

package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::FanModuleA105;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::FanModule);
use strict;

package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::FanModuleA106;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::FanModule);
use strict;

package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::FanModuleA107;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::FanModule);
use strict;

package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::FanModuleA110;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::FanModule);
use strict;

package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::FanModuleA405;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::FanModule);
use strict;

package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::FanModuleA406;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::FanModule);
use strict;



package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::Temperatures;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  my $class = ref($self);
  $class =~ /::TemperatureModule(AR.*)/;
  my $number = $1;
  foreach my $attr (qw(Name Health State Value1 Value2 Value3 Value4 Value5 Value6)) {
    if (exists $self->{'dclTemperatures'.$number.$attr}) {
      $self->{'dclTemperatures'.$attr} = $self->{'dclTemperatures'.$number.$attr};
    }
  }
  foreach my $attr (qw(Name Health State Value1 Value2 Value3 Value4 Value5 Value6)) {
    delete $self->{'dclTemperatures'.$number.$attr};
  }
  $self->{label} = lc $self->{dclTemperaturesName};
  $self->{label} =~ s/[- ]/_/g;
}

sub check {
  my ($self) = @_;
  # dclTemperatureModuleHealth "If an error is occured."
  # dclTemperatureModuleState "State of values.
  # ACHTUNG: mit sowas verknuepfen: dclGlobalSettingsLimitsIndex...
  my $state = {
      sensor1Fault => 0,
      sensor2Fault => 0,
      sensor3Fault => 0,
      sensor4Fault => 0,
      sensor5Fault => 0,
      sensor6Fault => 0,
      busOk => 0,
  };
  foreach my $statekey (split /,/, $self->{dclTemperaturesState}) {
    $state->{$statekey} = 1;
  }
  %{$self->{state}} = %{$state};
  $self->add_info(sprintf "%s is %s", $self->{dclTemperaturesName},
      $self->{dclTemperaturesHealth});
  if ($self->{dclTemperaturesHealth} ne "online") {
    $self->add_warning();
  }
  $self->add_perfdata(
    label => $self->{label}."_temp_1",
    value => $self->{dclTemperaturesValue1},
  );
  $self->add_perfdata(
    label => $self->{label}."_temp_2",
    value => $self->{dclTemperaturesValue1},
  );
  $self->add_perfdata(
    label => $self->{label}."_temp_3",
    value => $self->{dclTemperaturesValue1},
  );
  $self->add_perfdata(
    label => $self->{label}."_temp_4",
    value => $self->{dclTemperaturesValue1},
  );
  $self->add_perfdata(
    label => $self->{label}."_temp_5",
    value => $self->{dclTemperaturesValue1},
  );
  $self->add_perfdata(
    label => $self->{label}."_temp_6",
    value => $self->{dclTemperaturesValue1},
  );
}

sub dump {
  my ($self) = @_;
  $self->SUPER::dump();
  printf "%s\n", Data::Dumper::Dumper($self->{state});
}


package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::TemperaturesAR1A203;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::Temperatures);
use strict;

package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::TemperaturesAR3A203;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::Temperatures);
use strict;

package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::TemperaturesAR2A203;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::Temperatures);
use strict;

package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::TemperaturesAR4A203;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::Temperatures);
use strict;



package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::ValveModule;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  my $class = ref($self);
  $class =~ /::ValveModule(A.*)/;
  my $number = $1;
  foreach my $attr (qw(Name Health State Position1 Position2 Temperature1 Temperature2 Temperature3)) {
    if (exists $self->{'dclValveModule'.$number.$attr}) {
      $self->{'dclValveModule'.$attr} = $self->{'dclValveModule'.$number.$attr};
    }
  }
  foreach my $attr (qw(Name Health State Position1 Position2 Temperature1 Temperature2 Temperature3)) {
    delete $self->{'dclValveModule'.$number.$attr};
  }
  $self->{dclValveModuleTemperature1} /= 10;
  $self->{dclValveModuleTemperature2} /= 10;
  $self->{dclValveModuleTemperature3} /= 10;
  $self->{dclValveModulePosition1} /= 10;
  $self->{dclValveModulePosition2} /= 10;
  $self->{label} = lc $self->{dclValveModuleName};
  $self->{label} =~ s/[- ]/_/g;
}

sub check {
  my ($self) = @_;
  my $state = {
      emergencyRun => 0,
      standAloneRun => 0,
      sensorFault1 => 0,
      sensorFault2 => 0,
      sensorFault3 => 0,
      busOk => 0,
  };
  foreach my $statekey (split /,/, $self->{dclValveModuleState}) {
    $state->{$statekey} = 1;
  }
  %{$self->{state}} = %{$state};
  $self->add_info(sprintf "%s is %s", $self->{dclValveModuleName},
      $self->{dclValveModuleHealth});
  if ($self->{dclValveModuleHealth} ne "online") {
    $self->add_warning();
  }
  $self->add_perfdata(
    label => $self->{label}."_temp_1",
    value => $self->{dclValveModuleTemperature1},
  ) if $self->{dclValveModuleTemperature1} != -30;
  $self->add_perfdata(
    label => $self->{label}."_temp_2",
    value => $self->{dclValveModuleTemperature2},
  ) if $self->{dclValveModuleTemperature2} != -30;
  $self->add_perfdata(
    label => $self->{label}."_temp_3",
    value => $self->{dclValveModuleTemperature3},
  ) if $self->{dclValveModuleTemperature3} != -30;
}

package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::ValveModuleA104;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::ValveModule);
use strict;

package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::ValveModuleA108;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::ValveModule);
use strict;

package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::ValveModuleA111;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::ValveModule);
use strict;

package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::ValveModuleA407;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::ValveModule);
use strict;

package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::ValveModuleA408;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::ValveModule);
use strict;


package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::AnalogueModule;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  my $class = ref($self);
  $class =~ /::AnalogueModule(A.*)/;
  my $number = $1;
  $self->{Table} = $number;
  $self->{dclAnalogueIndex} = $self->{flat_indices};
  foreach my $attr (qw(Name Health State Value1 Value2 Value3 Value4 Value5 Value6)) {
    if (exists $self->{'dclAnalogue'.$number.$attr}) {
      $self->{'dclAnalogueModule'.$attr} = $self->{'dclAnalogue'.$number.$attr};
    }
  }
  foreach my $attr (qw(Name Health State Value1 Value2 Value3 Value4 Value5 Value6)) {
    delete $self->{'dclAnalogue'.$number.$attr};
  }
  $self->{label} = lc $self->{dclAnalogueModuleName};
  $self->{label} =~ s/[- ]/_/g;
  $self->{dclAnalogueModuleValue1} /= 10;
  $self->{dclAnalogueModuleValue2} /= 10;
  $self->{dclAnalogueModuleValue3} /= 10;
  $self->{dclAnalogueModuleValue4} /= 10;
  $self->{dclAnalogueModuleValue5} /= 10;
  $self->{dclAnalogueModuleValue6} /= 10;
}

package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::AnalogueModuleA109;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::AnalogueModule);
use strict;

package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::AnalogueModuleAR3A208;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::AnalogueModule);
use strict;

package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::AnalogueModuleAR4A208;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::AnalogueModule);
use strict;

package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::AnalogueModuleA409;
our @ISA = qw(CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::AnalogueModule);
use strict;


package CheckWutHealth::Emerson::KnuerrDCL::Component::SensorSubsystem::Gateway;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  foreach (qw(dclGatewayCtrlManualValueFan dclGatewayCtrlManualValueValve
      dclGatewayCtrlReturnAirTempSetPointOffset
      dclGatewayCtrlReturnAirTemperature
      dclGatewayCtrlSupplyAirTempSetPoint
      dclGatewayCtrlSupplyAirTemperature)) {
    $self->{$_} /= 10 if $self->{$_};
  }
  $self->{label} = "gateway_ctrl_".$self->{flat_indices};
}



sub check {
  my ($self) = @_;
  $self->add_perfdata(
    label => $self->{label}."_return_air_temp",
    value => $self->{dclGatewayCtrlReturnAirTemperature},
  ) if $self->{dclGatewayCtrlReturnAirTemperature} != -30;
  $self->add_perfdata(
    label => $self->{label}."_supply_air_temp",
    value => $self->{dclGatewayCtrlSupplyAirTemperature},
  ) if $self->{dclGatewayCtrlSupplyAirTemperature} != -30;
  $self->add_perfdata(
    label => $self->{label}."_supply_air_setpoint",
    value => $self->{dclGatewayCtrlSupplyAirTempSetPoint},
  ) if $self->{dclGatewayCtrlSupplyAirTempSetPoint} != -30;
}


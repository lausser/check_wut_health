package CheckWutHealth::Geist::V4::Components::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("GEIST-V4-MIB", qw(
      temperatureUnits
  ));
  $self->get_snmp_tables("GEIST-V4-MIB", [
    ["tempsensors", "tempSensorTable", "CheckWutHealth::Geist::V4::Components::SensorSubsystem::TempSensor", sub { my $o = shift; $o->{temperatureUnits} = $self->{temperatureUnits}; 1; } ],
    ["airflowsensors", "airFlowSensorTable", "CheckWutHealth::Geist::V4::Components::SensorSubsystem::AirflowSensor", sub { my $o = shift; $o->{temperatureUnits} = $self->{temperatureUnits}; 1; } ],
    ["dewpointsensors", "dewPointSensorTable", "CheckWutHealth::Geist::V4::Components::SensorSubsystem::DewpointSensor", sub { my $o = shift; $o->{temperatureUnits} = $self->{temperatureUnits}; 1; } ],
    ["ccatsensors", "ccatSensorTable", "CheckWutHealth::Geist::V4::Components::SensorSubsystem::CcatSensor", sub { my $o = shift; $o->{temperatureUnits} = $self->{temperatureUnits}; 1; } ],
    ["t3hdsensors", "t3hdSensorTable", "CheckWutHealth::Geist::V4::Components::SensorSubsystem::T3hdSensor", sub { my $o = shift; $o->{temperatureUnits} = $self->{temperatureUnits}; 1; } ],
    ["thdsensors", "thdSensorTable", "CheckWutHealth::Geist::V4::Components::SensorSubsystem::ThdSensor", sub { my $o = shift; $o->{temperatureUnits} = $self->{temperatureUnits}; 1; } ],
    ["rpmsensors", "rpmSensorTable", "CheckWutHealth::Geist::V4::Components::SensorSubsystem::RpmSensor", sub { my $o = shift; $o->{temperatureUnits} = $self->{temperatureUnits}; 1; } ],
    ["a2dsensors", "a2dSensorTable", "CheckWutHealth::Geist::V4::Components::SensorSubsystem::A2dSensor", sub { my $o = shift; $o->{temperatureUnits} = $self->{temperatureUnits}; 1; } ],
  ]);
}


package CheckWutHealth::Geist::V4::Components::SensorSubsystem::Sensor;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub sensortype {
  my ($self) = @_;
  my $type = lc ref($self);
  $type =~ s/^.*:://;
  $type =~ s/^(.*)sensor.*/$1/;
  return $type;
}

sub normalize {
  my ($self, $str) = @_;
  $str =~ s/[^a-zA-Z0-9]/_/g;
  return $str;
}

sub finish {
  my ($self) = @_;
  foreach (keys %{$self}) {
    $self->{avail} = $self->{$_} if /.*SensorAvail$/;
    $self->{name} = $self->{$_} if /.*SensorName$/;
  }
  $self->{name} = $self->normalize($self->{name});
  $self->{name} = $self->sensortype()."_".$self->{name};
  #$self->{label} = lc $self->{name}."_".$self->{flat_indices};
  #koennte ueberfluessig sein, jedenfalls in den beispielen ist es so.
  #da wurden labels vergeben, die eindeutig sind.
  # z.b.
  # t3hdSensorExtAName: Top
  # t3hdSensorExtBName: Bot
  # t3hdSensorIntName: Mid
  # t3hdSensorName: GT3HD
  # thdSensorName: GTHD
  #
  # dann wurden Labels vergeben (in der gui steht dann unter "GT3HD" ein "Temp_Hum_Mid"
  # t3hdSensorExtAName: Top
  # t3hdSensorExtBName: Bot
  # t3hdSensorIntName: Mid
  # t3hdSensorName: Temp_Hum_Mid
  # thdSensorName: Temp_Hum_Bottom
  # 
  # wobei Temp_Hum_Mid und Temp_Hum_Bottom Sektionsueberschriften in der Gui sind
  # Top Mid Bot werden unter der Spalte "Label" gefuehrt (in einer t3hd-Sektion)
  # und GTHD unter der Spalte "Name" (in einer thd-Sektion)

  $self->{label} = lc $self->{name}
}

sub avail {
  my ($self) = @_;
  $self->add_info(sprintf "%s state is %s",
      $self->{name}, $self->{avail});
  if ($self->{avail} eq "Available") {
    $self->add_ok();
  } elsif ($self->{avail} eq "Unavailable") {
    $self->add_critical();
  } elsif ($self->{avail} eq "Partially Unavailable") {
    $self->add_warning();
  }
}

package CheckWutHealth::Geist::V4::Components::SensorSubsystem::TempSensor;
our @ISA = qw(CheckWutHealth::Geist::V4::Components::SensorSubsystem::Sensor);
use strict;

sub finish {
  my ($self) = @_;
  $self->SUPER::finish();
  $self->{tempSensorTemp} /= 10;
}

sub check {
  my ($self) = @_;
  $self->SUPER::avail();
  my $temp = $self->{label}."_temp";
  $self->set_thresholds(metric => $temp,
      warning => '0:50',
      critical => '0:70',
  );
  $self->add_message($self->check_thresholds(metric => $temp,
      value => $self->{tempSensorTemp}),
      sprintf("temperature %.1f%s", $self->{tempSensorTemp}, $self->{temperatureUnits}));
  $self->add_perfdata(label => $temp,
      value => $self->{tempSensorTemp});
}

package CheckWutHealth::Geist::V4::Components::SensorSubsystem::AirflowSensor;
our @ISA = qw(CheckWutHealth::Geist::V4::Components::SensorSubsystem::Sensor);
use strict;

sub finish {
  my ($self) = @_;
  $self->SUPER::finish();
  $self->{airFlowSensorTemp} /= 10;
}

sub check {
  my ($self) = @_;
  $self->SUPER::avail();
  my $temp = $self->{label}."_temp";
  my $hum = $self->{label}."_hum";
  $self->set_thresholds(metric => $temp,
      warning => '0:50',
      critical => '0:70',
  );
  $self->set_thresholds(metric => $hum,
      warning => '70',
      critical => '80',
  );
  $self->add_message($self->check_thresholds(metric => $temp,
      value => $self->{airFlowSensorTemp}),
      sprintf("temperature %.1f%s", $self->{airFlowSensorTemp}, $self->{temperatureUnits}));
  $self->add_message($self->check_thresholds(metric => $hum,
      value => $self->{airFlowSensorHumidity}),
      sprintf("humdidity %.1f%%", $self->{airFlowSensorHumidity}));
  $self->add_perfdata(label => $temp,
      value => $self->{airFlowSensorTemp});
  $self->add_perfdata(label => $hum,
      value => $self->{airFlowSensorHumidity});
}

package CheckWutHealth::Geist::V4::Components::SensorSubsystem::DewpointSensor;
our @ISA = qw(CheckWutHealth::Geist::V4::Components::SensorSubsystem::Sensor);
use strict;

sub finish {
  my ($self) = @_;
  $self->SUPER::finish();
  $self->{dewPointSensorTemp} /= 10;
}

sub check {
  my ($self) = @_;
  $self->SUPER::avail();
  my $temp = $self->{label}."_temp";
  my $hum = $self->{label}."_hum";
  $self->set_thresholds(metric => $temp,
      warning => '0:50',
      critical => '0:70',
  );
  $self->set_thresholds(metric => $hum,
      warning => '70',
      critical => '80',
  );
  $self->add_message($self->check_thresholds(metric => $temp,
      value => $self->{dewPointSensorTemp}),
      sprintf("temperature %.1f%s", $self->{dewPointSensorTemp}, $self->{temperatureUnits}));
  $self->add_message($self->check_thresholds(metric => $hum,
      value => $self->{dewPointSensorHumidity}),
      sprintf("humdidity %.1f%%", $self->{dewPointSensorHumidity}));
  $self->add_perfdata(label => $temp,
      value => $self->{dewPointSensorTemp});
  $self->add_perfdata(label => $hum,
      value => $self->{dewPointSensorHumidity});
}

package CheckWutHealth::Geist::V4::Components::SensorSubsystem::CcatSensor;
our @ISA = qw(CheckWutHealth::Geist::V4::Components::SensorSubsystem::Sensor);
use strict;

# ohne Beispiel mache ich nichts

package CheckWutHealth::Geist::V4::Components::SensorSubsystem::T3hdSensor;
our @ISA = qw(CheckWutHealth::Geist::V4::Components::SensorSubsystem::Sensor);
use strict;

sub finish {
  my ($self) = @_;
  $self->SUPER::finish();
  $self->{t3hdSensorIntTemp} /= 10;
  $self->{t3hdSensorExtATemp} /= 10;
  $self->{t3hdSensorExtBTemp} /= 10;
}

sub check {
  my ($self) = @_;
  my $sensor_name = $self->sensortype()."_".$self->normalize($self->{t3hdSensorName});
  my $int_name = $sensor_name ."_".$self->normalize($self->{t3hdSensorIntName});
  my $int_label = lc $int_name;
  my $int_temp = $int_label."_temp";
  my $int_hum = $int_label."_hum";

  my $exta_name = $sensor_name ."_".$self->normalize($self->{t3hdSensorExtAName});
  my $exta_label = lc $exta_name;
  my $exta_temp = $exta_label."_temp";

  my $extb_name = $sensor_name ."_".$self->normalize($self->{t3hdSensorExtBName});
  my $extb_label = lc $extb_name;
  my $extb_temp = $extb_label."_temp";

  if ($self->{t3hdSensorAvail} eq "Available") {
    $self->add_info(sprintf "%s is available, temperature %.2f%s, humidity %.2f%%",
        $int_name, $self->{t3hdSensorIntTemp}, $self->{temperatureUnits},
        $self->{t3hdSensorIntHumidity});
    $self->set_thresholds(metric => $int_temp,
        warning => '0:50',
        critical => '0:70',
    );
    $self->set_thresholds(metric => $int_hum,
        warning => '70',
        critical => '80',
    );
    $self->add_message($self->worst_level(
        $self->check_thresholds(metric => $int_temp,
            value => $self->{t3hdSensorIntTemp}),
        $self->check_thresholds(metric => $int_hum,
            value => $self->{t3hdSensorIntHumidity})
    ));
    $self->add_perfdata(label => $int_temp,
        value => $self->{t3hdSensorIntTemp});
    $self->add_perfdata(label => $int_hum,
        uom => "%",
        value => $self->{t3hdSensorIntHumidity});
  } else {
    $self->add_warning_mitigation(sprintf "%s is not available", $int_name);
  }

  if ($self->{t3hdSensorExtAAvail} eq "Available") {
    $self->add_info(sprintf "%s is available, temperature %.2f%s",
        $exta_name, $self->{t3hdSensorExtATemp}, $self->{temperatureUnits});
    $self->set_thresholds(metric => $exta_temp,
        warning => '0:50',
        critical => '0:70',
    );
    $self->add_message($self->check_thresholds(metric => $exta_temp,
        value => $self->{t3hdSensorExtATemp}));
    $self->add_perfdata(label => $exta_temp,
        value => $self->{t3hdSensorExtATemp});
  } else {
    $self->add_warning_mitigation(sprintf "%s is not available", $exta_name);
  }

  if ($self->{t3hdSensorExtBAvail} eq "Available") {
    $self->add_info(sprintf "%s is available, temperature %.2f%s",
        $extb_name, $self->{t3hdSensorExtBTemp}, $self->{temperatureUnits});
    $self->set_thresholds(metric => $extb_temp,
        warning => '0:50',
        critical => '0:70',
    );
    $self->add_message($self->check_thresholds(metric => $extb_temp,
        value => $self->{t3hdSensorExtBTemp}));
    $self->add_perfdata(label => $extb_temp,
        value => $self->{t3hdSensorExtBTemp});
  } else {
    $self->add_warning_mitigation(sprintf "%s is not available", $extb_name);
  }
}

package CheckWutHealth::Geist::V4::Components::SensorSubsystem::ThdSensor;
our @ISA = qw(CheckWutHealth::Geist::V4::Components::SensorSubsystem::Sensor);
use strict;

sub finish {
  my ($self) = @_;
  $self->SUPER::finish();
  $self->{thdSensorTemp} /= 10;
}

sub check {
  my ($self) = @_;
  $self->SUPER::avail();
  my $temp = $self->{label}."_temp";
  my $hum = $self->{label}."_hum";
  $self->add_message($self->check_thresholds(metric => $temp,
      value => $self->{thdSensorTemp}),
      sprintf("temperature %.1f%s", $self->{thdSensorTemp}, $self->{temperatureUnits}));
  $self->add_message($self->check_thresholds(metric => $hum,
      value => $self->{thdSensorHumidity}),
      sprintf("humdidity %.1f%%", $self->{thdSensorHumidity}));
  $self->set_thresholds(metric => $temp,
      warning => '0:50',
      critical => '0:70',
  );
  $self->set_thresholds(metric => $hum,
      warning => '70',
      critical => '80',
  );
  $self->add_perfdata(label => $temp,
      value => $self->{thdSensorTemp});
  $self->add_perfdata(label => $hum,
      uom => "%",
      value => $self->{thdSensorHumidity});
}

package CheckWutHealth::Geist::V4::Components::SensorSubsystem::RpmSensor;
our @ISA = qw(CheckWutHealth::Geist::V4::Components::SensorSubsystem::Sensor);
use strict;

# wenns einer zahlt

package CheckWutHealth::Geist::V4::Components::SensorSubsystem::A2dSensor;
our @ISA = qw(CheckWutHealth::Geist::V4::Components::SensorSubsystem::Sensor);
use strict;

# analoger Sensor. Das kann alles moegliche sein.
# Beispiele her, Geld her, dann schaue ich mal

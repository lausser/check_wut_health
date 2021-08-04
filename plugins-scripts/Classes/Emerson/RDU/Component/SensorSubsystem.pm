package Classes::Emerson::RDU::Component::SensorSubsystem;
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
  @{$self->{states}} = qw(
      coolingstate
      heatingstate
      humidifyingstate
      dehumidifyingstate
  );
  @{$self->{alarms}} = qw(
      remoteshutdownalarm
      waterunderflooralarm
      smokealarm
      firealarm
      surgeprotectiondevicealarm
      condensatehighwaterlevelala
      filtercloggedalarm
      lossofairflowalarm
      customalarm1
      customalarm2
      customalarm3
      customalarm4
      customalarm5
      customalarm6
      lossofteamworkmasteralarm
      lossofteamworkslavealarm
      repeatedteamworkaddressalarm
      lossofpoweralarm
      powerovervoltagealarm
      powerundervoltagealarm
      powerfrequencyoffsetalarm
      powerlossofphasealarm
      poweroppositephasealarm
      lossofacpoweralarm
      lossofdcpoweralarm
      fanmaintenancealarm
      filtermaintenancealarm
      heatermaintenancealarm
      humidifiermaintenancealarm
      watervalvemaintenancealarm
      fanfailure1
      fanfailure2
      fanfailure3
      fanfailure4
      fanfailure5
      fanfailure6
      fanfailure7
      fanfailure8
      fanfailure9
      fanfailure10
      watervalvefailure
      electricalheaterfailure
      humidifierfailure
      airdamperfailure
      condensatepumpfailure1
      condensatepumpfailure2
      highreturnairtemperatureala
      lowreturnairtemperaturealar
      highsupplyairtemperatureala
      lowsupplyairtemperaturealar
      highremoteairtemperatureala
      lowremoteairtemperaturealar
      highreturnairhumidityalarm
      lowreturnairhumidityalarm
      highsupplyairhumidityalarm
      lowsupplyairhumidityalarm
      highremoteairhumidityalarm
      lowremoteairhumidityalarm
      highinletwatertemperatureal
      lowinletwatertemperatureala
      highoutletwatertemperaturea
      lowoutletwatertemperatureal
      highinletwaterpressurealarm
      lowinletwaterpressurealarm
      lossofwaterflowalarm
      lowwaterflowalarm
      highpressurealarm
      highpressurelockoutalarm
      lowpressurealarm
      lowpressurelockoutalarm
      highdischargetemperaturealar
      highdischargetemperaturelock
      lowdischargetemperaturealarm
      lowdischargetemperaturelocko
      lowdischargesuperheatalarm
      lowdischargesuperheatlockout
      highpressureabnormalalarm
      lowpressureabnormalalarm
      compressorpressuredifference-1
      compressorpressuredifference-2
      eevdrivecommunicationfailure
      eevdrivefailure
      compressordrivecommunication-1
      compressordrivecommunication-2
      compressordrivefailure
      compressordrivefailurelockou
      highpressuresensorfailure
      lowpressuresensorfailure
      lowpressuresensorfailureloc
      dischargetemperaturesensorfa
      suctiontemperaturesensorfail
      inletwatertemperaturesensor
      outletwatertemperaturesensor
      returnairtemperaturesensorf-1
      returnairtemperaturesensorf-2
      returnairtemperaturesensorf-3
      returnairhumiditysensorfail-1
      returnairhumiditysensorfail-2
      returnairhumiditysensorfail-3
      supplyairtemperaturesensorf-1
      supplyairtemperaturesensorf-2
      supplyairtemperaturesensorf-3
      supplyairhumiditysensorfail-1
      supplyairhumiditysensorfail-2
      supplyairhumiditysensorfail-3
      remoteairtemperaturesensorf-1
      remoteairtemperaturesensorf-2
      remoteairtemperaturesensorf-3
      remoteairtemperaturesensorf-4
      remoteairtemperaturesensorf-5
      remoteairtemperaturesensorf-6
      remoteairtemperaturesensorf-7
      remoteairtemperaturesensorf-8
      remoteairtemperaturesensorf-9
      remoteairtemperaturesensorf-10
      remoteairhumiditysensorfail-1
      remoteairhumiditysensorfail-2
      remoteairhumiditysensorfail-3
      remoteairhumiditysensorfail-4
      remoteairhumiditysensorfail-5
      remoteairhumiditysensorfail-6
      remoteairhumiditysensorfail-7
      remoteairhumiditysensorfail-8
      remoteairhumiditysensorfail-9
      remoteairhumiditysensorfail-10
      staticpressuresensorfailure-1
      staticpressuresensorfailure-2
      waterpressuresensorfailure1
      waterpressuresensorfailure2
      waterflowsensorfailure
      lossofairflowsensorfailure
      filterpressuredifferencesens
      compressordrivefailureu00
      compressordrivefailureu01
      compressordrivefailureu02
      compressordrivefailureu03
      compressordrivefailureu04
      compressordrivefailureu05
      compressordrivefailureu06
      compressordrivefailureu07
      compressordrivefailureu08
      compressordrivefailureu09
      compressordrivefailureu10
      compressordrivefailureu11
      compressordrivefailureu12
      compressordrivefailureu13
      compressordrivefailureu14
      compressordrivefailureu15
      eevdriverunselectrefrigerant
      systemlackofrefrigerant
      compressordriveheatsinkhigh
      compressordriveovercurrent
      compressordrivephaseloss
      compressordrivedcpowerabnor
      communicatestatus
  );
      # reserved # faengt beim Pep an zu kreischen, wenn das Geraet die master-Rolle uebernimmt. Daher, weg mit dem Dreck und ich hab meine Ruhe. Falls euch die Bude abbrennt, weil ihr keinen reserved Alarm bekommen habt, dann koennt ihr bei mir ein custom-reserved-Release kaeuflich erwerben, das ist aber teuerer als ein weiterer Brand. Oder anders: das hier ist das sogenannte Kleingedruckte, es ist oeffentlich und jeder kann es lesen. Ich moechte nicht, dass ihr dieses Plugin verwendet! Ich verbiete es euch sogar! Wer es dennoch einsetzt, der braucht wegen eines verpassten Alarms nicht rummaulen.
  $self->get_snmp_objects("ENP-AC-PACC-MIB", (@{$self->{states}}, @{$self->{alarms}}));
  @{$self->{powers}} = qw(
    unitinstantaneouspower unittotalpower
  );
  @{$self->{currents}} = qw(
    phaseacurrent phasebcurrent phaseccurrent
  );
  @{$self->{frequencies}} = qw(
    powerfrequency
  );
  @{$self->{voltages}} = qw(
    phaseavoltage phasebvoltage phasecvoltage
  );
  @{$self->{temperatures}} = qw(
    returnairtemperature1 returnairtemperature2 returnairtemperature3 supplyairtemperature1 supplyairtemperature2 supplyairtemperature3 remoteairtemperature1 remoteairtemperature2 remoteairtemperature3 remoteairtemperature4 remoteairtemperature5 remoteairtemperature6 remoteairtemperature7 remoteairtemperature8 remoteairtemperature9 remoteairtemperature10 inletwatertemperature outletwatertemperature dischargetemperature suctiontemperature dischargesuperheat suctionsuperheat
  );
  @{$self->{humidities}} = qw(
    returnairhumidity1 returnairhumidity2 returnairhumidity3 supplyairhumidity1 supplyairhumidity2 supplyairhumidity3 remoteairhumidity1 remoteairhumidity2 remoteairhumidity3 remoteairhumidity4 remoteairhumidity5 remoteairhumidity6 remoteairhumidity7 remoteairhumidity8 remoteairhumidity9 remoteairhumidity10
  );
  @{$self->{fans}} = qw(
    fanspeed condenserfanspeed
  );
  $self->get_snmp_objects("ENP-AC-PACC-MIB", (@{$self->{powers}}, @{$self->{currents}}, @{$self->{frequencies}}, @{$self->{voltages}}, @{$self->{temperatures}}, @{$self->{humidities}}, @{$self->{fans}}));
}

sub check {
  my ($self) = @_;
  foreach (@{$self->{states}}) {
    $self->add_info(sprintf '%s is %s', $_, $self->{$_});
    $self->add_ok();
  }
  delete $self->{states};
  foreach (@{$self->{alarms}}) {
    next if ! defined $self->{$_};
    $self->add_info(sprintf '%s status is %s', $_, $self->{$_});
    if ($self->{$_} eq "alarm") {
      $self->add_critical();
    }
  }
  delete $self->{alarms};
  foreach (@{$self->{powers}}) {
    $self->add_info(sprintf "%s is %s", $_, $self->{$_});
    next if $self->{$_} == -1;
    next if $self->{$_} == -10;
    next if $self->{$_} == 32767;
    next if $self->{$_} == 65535;
    $self->{$_} /= 10;
    $self->add_perfdata(label => $_,
        value => $self->{$_},
    );
  }
  delete $self->{powers};
  foreach (@{$self->{currents}}) {
    next if $self->{$_} == -1;
    next if $self->{$_} == -10;
    next if $self->{$_} == 32767;
    next if $self->{$_} == 65535;
    $self->{$_} /= 10;
    $self->add_perfdata(label => $_,
        value => $self->{$_},
    );
  }
  delete $self->{currents};
  foreach (@{$self->{frequencies}}) {
    $self->add_info(sprintf "%s is %s", $_, $self->{$_});
    next if $self->{$_} == -1;
    next if $self->{$_} == -10;
    next if $self->{$_} == 32767;
    next if $self->{$_} == 65535;
    $self->{$_} /= 10;
    $self->add_perfdata(label => $_,
        value => $self->{$_},
    );
  }
  delete $self->{frequencies};
  foreach (@{$self->{voltages}}) {
    $self->add_info(sprintf "%s is %s", $_, $self->{$_});
    next if $self->{$_} == -1;
    next if $self->{$_} == -10;
    next if $self->{$_} == 32767;
    next if $self->{$_} == 65535;
    $self->{$_} /= 10;
    $self->add_perfdata(label => $_,
        value => $self->{$_},
    );
  }
  delete $self->{voltages};
  foreach (@{$self->{temperatures}}) {
    $self->add_info(sprintf "%s is %s", $_, $self->{$_});
    next if $self->{$_} == -1;
    next if $self->{$_} == -10;
    next if $self->{$_} == 32767;
    next if $self->{$_} == 65535;
    $self->{$_} /= 10;
    $self->add_perfdata(label => $_,
        value => $self->{$_},
    );
  }
  delete $self->{temperatures};
  foreach (@{$self->{humidities}}) {
    $self->add_info(sprintf "%s is %s", $_, $self->{$_});
    next if $self->{$_} == -1;
    next if $self->{$_} == -10;
    next if $self->{$_} == 32767;
    next if $self->{$_} == 65535;
    $self->{$_} /= 10;
    $self->add_perfdata(label => $_,
        value => $self->{$_},
        uom => '%',
    );
  }
  delete $self->{humidities};
  foreach (@{$self->{fans}}) {
    $self->add_info(sprintf "%s is %s", $_, $self->{$_});
    next if $self->{$_} == 0;
    next if $self->{$_} == -1;
    next if $self->{$_} == -10;
    next if $self->{$_} == 32767;
    next if $self->{$_} == 65535;
    $self->{$_} /= 10;
    $self->add_perfdata(label => $_.'_rpm',
        value => $self->{$_},
    );
  }
  delete $self->{fans};
}

package Classes::Emerson::RDU::Component::SensorSubsystem::DrecksSensor;
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


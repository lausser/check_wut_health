package CheckWutHealth::Stulz::WIB8000;
our @ISA = qw(CheckWutHealth::Stulz);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor::status/) {
    $Monitoring::GLPlugin::SNMP::session->timeout(60) if $Monitoring::GLPlugin::SNMP::session;
    $self->analyze_and_check_sensor_subsystem("CheckWutHealth::Stulz::WIB8000::Component::SensorSubsystem");
  } else {
    $self->no_such_mode();
  }
}

package CheckWutHealth::Stulz::WIB8000::Component::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->bulk_is_baeh(1); # mit dem default von 20 zerlegts das ding
  # aber nachher eine verschnaufpause von > 60s lassen
  $self->get_snmp_objects("STULZ-WIB8000-MIB", qw(wibUnitname wibTempUnit
      wibFirmware wibsettingAuxInLow wibsettingAuxInHigh wibsettingAuxInState
  ));
  my $timeout = $Monitoring::GLPlugin::SNMP::session ?
      $Monitoring::GLPlugin::SNMP::session->timeout() : 0;
  $Monitoring::GLPlugin::SNMP::session->timeout(5) if $timeout;
  $self->get_snmp_tables("STULZ-WIB8000-MIB", [
    # wibIndexTable ist eine nicht-existierende Tabelle, die mit
    # wibBusNumber, wibDeviceAddress, wibModuleNumber indiziert ist.
    # Uns interessiert zunaechst die unitstateTable, aber deren Abfrage
    # dauert ewig bzw. laeuft in den getnext-Fallback. Das gilt fuer alle
    # Tabellen. Daher holen wir im ersten Schritt die drei Indices und fragen
    # die interessanten Werte per GET ab, was wesentlich schneller geht.
    # (Abgesehen davon, dass es unzaehlige Tabellen gibt, die in vernuenftiger
    # Zeit nicht gewalkt werden koennen)
    # infoSystemTable antwortet am schnellsten, daher kommen die Indices von ihr
    #
      #["units", "unitTable", "CheckWutHealth::Stulz::GenericUnit", undef, ["numberOfModules"]],
      ["units", "unitTable", "CheckWutHealth::Stulz::GenericUnit"],
      ["unitstates", "infoSystemTable", "CheckWutHealth::Stulz::GenericUnitState", undef, ["unitType"]],
  ]);
  $Monitoring::GLPlugin::SNMP::session->timeout($timeout) if $timeout;
  # wir muessen wibBusNumber, wibDeviceAddress, wibModuleNumber kennen
  # aber auch nur wibBusNumber, wibDeviceAddress fuer unitsettingHasFailure,
  # einer OID die zur unitTable (Table for unit-settings) gehoert
  # "modules" mit 3 indices initialisiert ein State-Objekt, dessen Werte aus
  # unterschiedlichen 3-Index-Tables stammen. (Temp/Hum/OnOff...)
  @{$self->{bus_device_module}} = ();
  @{$self->{bus_device}} = ();
  my %seen;
  foreach my $unitstate (@{$self->{unitstates}}) {
    # unitstateTable Table for values in submenu unitstate
    # unitstateEntry INDEX { wibBusNumber, wibDeviceAddress, wibModuleNumber }
    push(@{$self->{bus_device_module}}, {
        bus => $unitstate->{bus},
        device => $unitstate->{device},
        module => $unitstate->{module},
    });
    # bus,device identifizieren eine unit
    # unitTable Table for values in submenu unitSettings
    # unitEntry INDEX { wibBusNumber, wibDeviceAddress }
    unless (grep { $_->{bus} eq $unitstate->{bus} && $_->{device} eq $unitstate->{device} } @{$self->{bus_device}}) {
      push(@{$self->{bus_device}}, {
          bus => $unitstate->{bus},
          device => $unitstate->{device},
      });
    }
  }
  $self->protect_value("bus_device_module", "bus_device_module", sub {
      my $bus_device_module_list = shift;
      # damit sich das Drecksteil vom Schock des letzten Walks erholen kann.
      if (! @{$bus_device_module_list}) {
        sleep 15;
      }
      return @{$bus_device_module_list} ? 1 : 0;
  });

  $timeout = $Monitoring::GLPlugin::SNMP::session ?
      $Monitoring::GLPlugin::SNMP::session->timeout() : 0;
  $Monitoring::GLPlugin::SNMP::session->timeout(15) if $timeout;
}

sub check {
  my $self = shift;
  $self->add_ok("WIB8000 ".$self->{wibUnitname});
  foreach (@{$self->{unitstates}}) {
    $_->check();
  }
  foreach (@{$self->{units}}) {
    $_->check();
  }
  $self->{num_units} = scalar(@{$self->{unitstates}});
  $self->{num_on_units} = scalar(grep { $_->{unitOnOff} eq "on" } @{$self->{unitstates}});
  if ($self->opts->warningx || $self->opts->criticalx) {
    my $warningx = $self->opts->warningx;
    my $criticalx = $self->opts->criticalx;
    if (exists $warningx->{num_on_units} || exists $criticalx->{num_on_units}) {
      $self->set_thresholds(
          metric => 'num_on_units',
          warning => $warningx->{num_on_units},
          critical => $criticalx->{num_on_units},
      );
      $self->add_message(
          $self->check_thresholds(metric => 'num_on_units', value => $self->{num_on_units}),
          sprintf "%d of %d units are on", $self->{num_on_units}, $self->{num_units}
      );
      $self->add_perfdata(
          label => 'num_on_units',
          value => $self->{num_on_units},
          warning => $warningx->{num_on_units},
          critical => $criticalx->{num_on_units},
      );
    }
  }
}

package CheckWutHealth::Stulz::GenericUnit;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  if ($self->{unitsettingHasFailure}) {
    $self->add_critical("unit %s has a settings failure",
        $self->{unitsettingName});
  }
}


package CheckWutHealth::Stulz::GenericUnitState;
# unitstateEntry A row in the table of values in submenu unitstate
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my $self = shift;
  $self->{bus} = $self->{indices}->[0];
  $self->{device} = $self->{indices}->[1];
  $self->{module} = $self->{indices}->[2];
  my $index = join(".", ($self->{bus}, $self->{device}, $self->{module}));
  my $value = $self->get_snmp_object("STULZ-WIB8000-MIB", "hardwareTypeControllerType", $index);
  $self->{hardwareTypeControllerType} = {
    0 => "unknown",
    1 => "C4000",
    2 => "C1001",
    3 => "C1002",
    4 => "C5000",
    5 => "C6000",
    6 => "C1010",
    7 => "C7000IOC",
    8 => "C7000AT",
    9 => "C7000PT",
    10 => "C5MSC",
    11 => "C7000PT2",
    12 => "C2020",
    13 => "C100",
    14 => "C102",
    15 => "C103",
  }->{$value};
  $index = join(".", ($self->{bus}, $self->{device}));
  foreach my $oid (qw(unitsettingName unitsettingHwType unitsettingReachability
      unitsettingHasFailure unitsettingFamily)) {
    $self->{$oid} = $self->get_snmp_object("STULZ-WIB8000-MIB", $oid, $index);
    delete $self->{$oid} if ! defined $self->{$oid};
  }
  if ($self->{hardwareTypeControllerType} eq "C1002") {
    $self->rebless("CheckWutHealth::Stulz::C1002");
#  } elsif ($self->{hardwareTypeControllerType} eq "C7000IOC") {
#    $self->rebless("CheckWutHealth::Stulz::C7000IOC");
#    diese monstrositaet kommt spaeter
  } else {
    $self->rebless("CheckWutHealth::Stulz::Unit");
  }
  $self->finish();
}



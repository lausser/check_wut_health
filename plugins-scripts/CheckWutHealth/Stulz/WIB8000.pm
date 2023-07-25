package CheckWutHealth::Stulz::WIB8000;
our @ISA = qw(CheckWutHealth::Stulz);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_objects("STULZ-WIB8000-MIB", qw(wibUnitname wibTempUnit
      wibFirmware wibsettingAuxInLow wibsettingAuxInHigh wibsettingAuxInState
  ));
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
      ["units", "unitstateTable", "CheckWutHealth::Stulz::GenericUnit", undef, ["hardwareTypeControllerType"]],
  ]);
  $Monitoring::GLPlugin::SNMP::session->timeout($timeout) if $timeout;
  @{$self->{bus_device_module}} = ();
  foreach (@{$self->{units}}) {
    push(@{$self->{bus_device_module}}, {
        bus => $_->{indices}->[0],
        device => $_->{indices}->[1],
        module => $_->{indices}->[2],
    });
  }
  # bus,device identifizieren eine unit
  # unitTable INDEX { wibBusNumber, wibDeviceAddress }
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
  foreach (@{$self->{units}}) {
    $_->check();
  }
  $self->{num_units} = scalar(@{$self->{units}});
  $self->{num_on_units} = scalar(grep { $_->{unitOnOff} eq "on" } @{$self->{units}});
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



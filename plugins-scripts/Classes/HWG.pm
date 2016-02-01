package Classes::HWG;
our @ISA = (Classes::Device);

package Classes::HWG::WLD;
our @ISA = (Classes::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_sensor_subsystem("Classes::HWG::WLD::Component::SensorSubsystem");
  } else {
    $self->no_such_mode();
  }
}

package Classes::HWG::WLD::Component::SensorSubsystem;
our @ISA = (Monitoring::GLPlugin::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables("Hwg-WLD-MIB", [
      ["sensors", "sensTable", "Classes::HWG::WLD::Component::SensorSubsystem::Sensor"],
  ]);
}

package Classes::HWG::WLD::Component::SensorSubsystem::Sensor;
our @ISA = (Monitoring::GLPlugin::TableItem);
use strict;

sub check {
  my $self = shift;
  printf "%s\n", Data::Dumper::Dumper($self);
}




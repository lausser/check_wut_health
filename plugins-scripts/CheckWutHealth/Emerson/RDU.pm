package CheckWutHealth::Emerson::RDU;
our @ISA = qw(CheckWutHealth::Device);
use strict;

# Dreckszeug
# ENP_AC_PACC-MIB
# ENP_ENV_SIC-MIB
# ENP_RDU-MIB
# Alle drei bezeichnen sich als
# EMERSON NETWORK POWER (ENPC) For RDU-SIC G2 MIB
# Null Erklaerung, Objektnamen doppelt vergeben.
# Stattdessen sowas:
#------------------------------------------------------------
#-- 3 Alarm trap table
#-- If you want to know the equipment trap list detail,
#-- Please find a Excel file named "RDU-SIC G2 trap table";
#------------------------------------------------------------
# Danke, das hilft mir weiter!
# Schlampig zusammengedengelt von einem Hanswurscht
# Oder Hanswursx wie man heutzutage sagt.

sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_sensor_subsystem("CheckWutHealth::Emerson::RDU::Component::SensorSubsystem");
  } elsif ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_diag_subsystem("CheckWutHealth::Emerson::RDU::Component::EnvironmentalSubsystem");
  } else {
    $self->no_such_mode();
  }
}



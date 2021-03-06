package Classes::Device;
our @ISA = qw(Monitoring::GLPlugin::SNMP);
use strict;

sub classify {
  my $self = shift;
  if (! ($self->opts->hostname || $self->opts->snmpwalk)) {
    $self->add_unknown('either specify a hostname or a snmpwalk file');
  } else {
    $self->check_snmp_and_model();
    if (! $self->check_messages()) {
      if ($self->opts->verbose && $self->opts->verbose) {
        printf "I am a %s\n", $self->{productname};
      }
      if ($self->opts->mode =~ /^my-/) {
        $self->load_my_extension();
      } elsif ($self->implements_mib('WebGraph-8xThermometer-MIB')) {
        bless $self, 'Classes::WebioAn8Graph';
        $self->debug('using Classes::WebioAn8Graph');
      } elsif ($self->implements_mib('WebGraph-Thermo-Hygro-Barometer-MIB')) {
        bless $self, 'Classes::WebGraphThermoBaro';
        $self->debug('using Classes::WebGraphThermoBaro');
      } elsif ($self->implements_mib('WebGraph-Thermo-Hygro-Barometer-US-MIB')) {
        bless $self, 'Classes::WebGraphThermoBaroUS';
        $self->debug('using Classes::WebGraphThermoBaroUS');
      } elsif ($self->implements_mib('HWg-WLD-MIB')) {
        bless $self, 'Classes::HWG::WLD';
        $self->debug('using Classes::HWG::WLD');
      } elsif ($self->implements_mib('STULZ-WIB8000-MIB')) {
        bless $self, 'Classes::Stulz::WIB8000';
        $self->debug('using Classes::Stulz::WIB8000-MIB');
      } elsif ($self->implements_mib('EMD-MIB')) {
        bless $self, 'Classes::Raritan::EMD';
        $self->debug('using Classes::Raritan::EMD');
      } elsif ($self->implements_mib('LIEBERT-GP-ENVIRONMENTAL-MIB')) {
        bless $self, 'Classes::Liebert';
        $self->debug('using Classes::Liebert');
      } elsif ($self->implements_mib('THE_V01-MIB')) {
        bless $self, 'Classes::Papouch';
        $self->debug('using Classes::Papouch');
      } elsif ($self->implements_mib('ENVIROMUX5D')) {
        $self->rebless('Classes::NTI');
      } elsif ($self->implements_mib('RITTAL-LCP-DX-MIB') || $self->get_snmp_object('RITTAL-LCP-DX-MIB', 'setpoint-lcp')) {
        $self->rebless('Classes::Rittal::LCPDX');
        # Rumtrickserei, Mib alleine reicht nicht. Wegen:
        # OMD[mon-p1]:~$ snmpwalk -ObentU -v2c -c public 10.211.124.65 1.3.6.1.4.1.9839.2.1
        # .1.3.6.1.4.1.9839.2.1.1.1.0 = INTEGER: 0
        # .1.3.6.1.4.1.9839.2.1.1.2.0 = INTEGER: 0
        # ...
        # OMD[mon-p1]:~$ snmpwalk -ObentU -v2c -c public 10.211.124.65 1.3.6.1.4.1.9839.2
        # .1.3.6.1.4.1.9839.2 = No Such Object available on this agent at this OID
        # Euch sollte man stundenlang in den Sack dreschen!

      } elsif ($self->implements_mib('ENP-RDU-MIB')) {
        $self->rebless('Classes::Emerson::RDU');
      } else {
        if (my $class = $self->discover_suitable_class()) {
          bless $self, $class;
          $self->debug('using '.$class);
        } else {
          bless $self, 'Classes::Generic';
          $self->debug('using Classes::Generic');
        }
      }
    }
  }
  return $self;
}


package Classes::Generic;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /something specific/) {
  } else {
    bless $self, 'Monitoring::GLPlugin::SNMP';
    $self->no_such_mode();
  }
}

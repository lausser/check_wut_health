package CheckWutHealth::Device;
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
      my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
      if ($self->opts->mode =~ /^my-/) {
        $self->load_my_extension();
      } elsif ($self->implements_mib('WebGraph-8xThermometer-MIB')) {
        $self->rebless('CheckWutHealth::WebioAn8Graph');
      } elsif ($self->implements_mib('WEBGRAPH-THERMO-HYGROMETER-MIB')) {
        $self->rebless('CheckWutHealth::WebGraphThermoHygro');
      } elsif ($self->implements_mib('WEBGRAPH-THERMO-HYGROMETER-US-MIB')) {
        $self->rebless('CheckWutHealth::WebGraphThermoHygroUS');
      } elsif ($self->implements_mib('WebGraph-Thermo-Hygro-Barometer-MIB')) {
        $self->rebless('CheckWutHealth::WebGraphThermoHygroBaro');
      } elsif ($self->implements_mib('WebGraph-Thermo-Hygro-Barometer-US-MIB')) {
        $self->rebless('CheckWutHealth::WebGraphThermoHygroBaroUS');
      } elsif ($self->implements_mib('HWg-WLD-MIB')) {
        $self->rebless('CheckWutHealth::HWG::WLD');
      } elsif ($self->implements_mib('STULZ-WIB8000-MIB')) {
        $self->rebless('CheckWutHealth::Stulz::WIB8000');
      } elsif ($self->implements_mib('EMD-MIB')) {
        $self->rebless('CheckWutHealth::Raritan::EMD');
      } elsif ($self->implements_mib('PDU2-MIB')) {
        $self->rebless('CheckWutHealth::Raritan::PDU2');
      } elsif ($self->implements_mib('GEIST-V4-MIB')) {
        $self->rebless('CheckWutHealth::Geist::V4');
      } elsif ($self->implements_mib('LIEBERT-GP-ENVIRONMENTAL-MIB')) {
        $self->rebless('CheckWutHealth::Liebert');
      } elsif ($self->implements_mib('LIEBERT-GP-FLEXIBLE-MIB')) {
        $self->rebless('CheckWutHealth::Liebert');
      } elsif ($self->implements_mib('THE_V01-MIB')) {
        $self->rebless('CheckWutHealth::Papouch');
      } elsif ($self->implements_mib('ENVIROMUX5D')) {
        $self->rebless('CheckWutHealth::NTI');
      } elsif ($self->implements_mib("KELVIN-PCOWEB-LCP-DX-MIB") and 1) {
        #$self->get_snmp_object("KELVIN-PCOWEB-LCP-DX-MIB", "current-year") and
        #$self->get_snmp_object("KELVIN-PCOWEB-LCP-DX-MIB", "current-year") == $year - 100) {
        $self->rebless('CheckWutHealth::Carel::pCOWeb');
      } elsif ($self->implements_mib('RITTAL-LCP-DX-MIB') || $self->get_snmp_object('RITTAL-LCP-DX-MIB', 'setpoint-lcp')) {
        $self->rebless('CheckWutHealth::Rittal::LCPDX');
        # Rumtrickserei, Mib alleine reicht nicht. Wegen:
        # OMD[mon-p1]:~$ snmpwalk -ObentU -v2c -c public 10.211.124.65 1.3.6.1.4.1.9839.2.1
        # .1.3.6.1.4.1.9839.2.1.1.1.0 = INTEGER: 0
        # .1.3.6.1.4.1.9839.2.1.1.2.0 = INTEGER: 0
        # ...
        # OMD[mon-p1]:~$ snmpwalk -ObentU -v2c -c public 10.211.124.65 1.3.6.1.4.1.9839.2
        # .1.3.6.1.4.1.9839.2 = No Such Object available on this agent at this OID
        # Euch sollte man stundenlang in den Sack dreschen!
      } elsif ($self->implements_mib('ENP-RDU-MIB')) {
        $self->rebless('CheckWutHealth::Emerson::RDU');
      } else {
        if (my $class = $self->discover_suitable_class()) {
          $self->rebless($class);
        } else {
          $self->rebless('CheckWutHealth::Generic');
        }
      }
    }
  }
  $self->{generic_class} = "CheckWutHealth::Generic";
  return $self;
}


package CheckWutHealth::Generic;
our @ISA = qw(CheckWutHealth::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /something specific/) {
  } else {
    bless $self, 'Monitoring::GLPlugin::SNMP';
    $self->no_such_mode();
  }
}

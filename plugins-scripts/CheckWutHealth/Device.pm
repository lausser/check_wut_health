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
      $year += 1900;
      $year = $year % 100;
      $mon += 1;

      $Monitoring::GLPlugin::SNMP::MibsAndOids::origin->{'CAREL-WHATSBEHIND-MIB'} = {
        url => '',
        name => 'PcoWeb with something behind it',
      };
      $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'CAREL-WHATSBEHIND-MIB'} = {
        # pd pcoweb-dumb, nix angepasst, einfach nur Klima drangehaengt
        # pst pcoweb-with-sysoid-trick, sysoid hingefaked (s.u. Librenms)
        # lcp clearly-rittal-lcp-agentCode, echte oids von Rittal
        'pd-agentCode' => '1.3.6.1.4.1.9839.1.2',
        'pst-agentCode' => '1.3.6.1.4.1.9839.2606.1.2',
        'lcp-agentCode' => '1.3.6.1.4.1.2606.21.1.2',
        'pd-current-year' => '1.3.6.1.4.1.9839.2.1.3.12',
        'pst-current-year' => '1.3.6.1.4.1.9839.2606.2.1.3.12',
        'lcp-current-year' => '1.3.6.1.4.1.2606.21.2.1.3.12',
        'pd-current-month' => '1.3.6.1.4.1.9839.2.1.3.10',
        'pst-current-month' => '1.3.6.1.4.1.9839.2606.2.1.3.10',
        'lcp-current-month' => '1.3.6.1.4.1.2606.21.2.1.3.10',
      };
      if ($self->opts->mode =~ /^my-/) {
        $self->load_my_extension();
      } elsif (defined $self->get_snmp_object("CAREL-WHATSBEHIND-MIB", "pd-agentCode") and $self->get_snmp_object("CAREL-WHATSBEHIND-MIB", "pd-agentCode") == 2 and defined $self->get_snmp_object("CAREL-WHATSBEHIND-MIB", "pd-current-year") and $self->get_snmp_object("CAREL-WHATSBEHIND-MIB", "pd-current-year") == $year and defined $self->get_snmp_object("CAREL-WHATSBEHIND-MIB", "pd-current-month") and $self->get_snmp_object("CAREL-WHATSBEHIND-MIB", "pd-current-month") == $mon) {
        foreach my $oid (keys %{$Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'RITTAL-LCP-DX-MIB'}}) {
          $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'RITTAL-LCP-DX-MIB'}->{$oid} =~ s/1\.3\.6\.1\.4\.1\.2606\.21/1.3.6.1.4.1.9839/g;
        }
        $self->rebless('CheckWutHealth::Rittal::LCPDX');
      } elsif (defined $self->get_snmp_object("CAREL-WHATSBEHIND-MIB", "pst-agentCode") and $self->get_snmp_object("CAREL-WHATSBEHIND-MIB", "pst-agentCode") == 2 and defined $self->get_snmp_object("CAREL-WHATSBEHIND-MIB", "pst-current-year") and $self->get_snmp_object("CAREL-WHATSBEHIND-MIB", "pst-current-year") == $year and defined $self->get_snmp_object("CAREL-WHATSBEHIND-MIB", "pst-current-month") and $self->get_snmp_object("CAREL-WHATSBEHIND-MIB", "pst-current-month") == $mon) {
        foreach my $oid (keys %{$Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'RITTAL-LCP-DX-MIB'}}) {
          $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'RITTAL-LCP-DX-MIB'}->{$oid} =~ s/1\.3\.6\.1\.4\.1\.2606\.21/1.3.6.1.4.1.9839.2606/g;
        }
        $self->rebless('CheckWutHealth::Rittal::LCPDX');
      } elsif (defined $self->get_snmp_object("CAREL-WHATSBEHIND-MIB", "lcp-agentCode") and $self->get_snmp_object("CAREL-WHATSBEHIND-MIB", "lcp-agentCode") == 2 and defined $self->get_snmp_object("CAREL-WHATSBEHIND-MIB", "lcp-current-year") and $self->get_snmp_object("CAREL-WHATSBEHIND-MIB", "lcp-current-year") == $year and defined $self->get_snmp_object("CAREL-WHATSBEHIND-MIB", "lcp-current-month") and $self->get_snmp_object("CAREL-WHATSBEHIND-MIB", "lcp-current-month") == $mon) {
        $self->rebless('CheckWutHealth::Rittal::LCPDX');
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
      } elsif ($self->implements_mib('DIDACTUM-SYSTEM-MIB')) {
        $self->rebless('CheckWutHealth::Didactum');
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

__END__
      #
      # Carel PCOWeb ist so ein Mini-Webserverdings, an welches alle
      # moeglichen Hersteller sich dranhaengen. Oder besser andersrum:
      # In den riesigsten Klimaanlagen (https://www.rittal.com/lt-en/products/PG0168KLIMA1/PGR1951KLIMA1/PG1023KLIMA1/PRO33639?variantId=3313480 z.b.)
      # wird so ein Pco als Netzwerk-Frontend eingebaut.
      # Hintenraus spricht das Dings ein sog. HVAC-Protokoll, welches Modbus,
      # Ethernet, Serial und weiss der Geier was sein kann.
      # Pco faengt mit .1.3.6.1.4.1.9839 an
      # Wie es aussieht nehmen die die Rittal-OIDs und ersetzen einfach
      # das 2606 in 1.3.6.1.4.1.2606.* durch 9839. Das ist natuerlich
      # konfigurierbar, so dass 1.3.6.1.4.1.9839.2606.* genauso moeglich ist.
      # sysObjID ist auch konfigurierbar, d.h. hierauf ist auch kein Verlass,
      # das ist allenfalls ein Hinweis.
      # Weil Librenms vorschlaegt, Enterprise OID anzupassen...ich lese gerade
      # in https://www.carel.com/documents/10191/0/+030220966/12c36f92-bfa6-4418-97bf-ecc21acc4f37?version=1.1
      # "Enterprise OID (required for sending the TRAP message):
      #
      # Das Dings hat OIDs für
      # digital group 2.1.1.[1..207]
      # integer group 2.1.2.[1..207]
      # analog group 2.1.3.[1..207]
      # Die Bedeutung haengt dann davon ab, welcher Hersteller hintendran
      # verbaut wurde. Je nachdem sind auch nur 1..n in Verwendung.
      # 2.1.1.23 ist bei einem Rittal LCP z.b. ein General Alarm, bei
      # CAREL-ug40cdz.MIB, UG40 Close Control Uniflair device
      # digitalObjects.23 = Alarm: Room High Humidity
      # UNCDZ.MIB, UNIFLAIR UNCDZ device
      # digitalObjects 23 = Alarm: High Pressure 2
      # rittal-LCP-DX.mib, Rittal's LCP DX units
      # digitalObjects 23 = General Alarm Contact
      # kelvin-pCOWeb-Chiller.MIB, New MIB Chiller
      # digitalObjects 23 = Overload fan 4 circuit 1 alarm
      # DataAire-dap4-al-MIB.mib
      # digitalObjects 23 = No water flow alarm
      #
      #
# MIBS/CAREL-RITTAL-LCP-3311-MIB   # selbstgebaut , achtung 2 versionen
# MIBS/Rittal-LCP-DX.MIB

# KELVIN-pCOWeb-Chiller-MIB -> KELVIN-pCOWeb-Chiller-MIB
#  201309131602Z
#  This is the MIB module for the kelvin-pCOWeb-Chiller device
#  New MIB Chiller
#  digitalObjects 1.3.6.1.4.1.9839.2.1.1

# pCOWeb_LCP-DX_RimatriX_2014_rev01.mib -> KELVIN-pCOWeb-LCP-DX-MIB
#  201309131602Z
#  This is the MIB module for the kelvin-pCOWeb-LCP-DX device
#  DESCRIPTION "New MIB-LCP"
#  digitalObjects 1.3.6.1.4.1.9839.2.1.1
#  current-year 1.3.6.1.4.1.9839.2.1.3.12

# Rittal-LCP-DX.MIB -> Rittal-LCP-DX-MIB
#  201312011000Z
#  This is the official MIB module for the Rittal's LCP DX units
#  201309221200Z
#  A new Rittal OID 1.3.6.1.4.1.2606.21 has been associated to LCP DX family
#  First release, made by Kelvin: New MIB-LCP
#  digitalObjects 1.3.6.1.4.1.2606.21.2.1.1
#  current-year 1.3.6.1.4.1.2606.21.2.1.3.12

.1.3.6.1.2.1.1.2.0 = OID: .1.3.6.1.4.1.9839.2606
.1.3.6.1.4.1.9839.1.1.0 = INTEGER: 4
.1.3.6.1.4.1.9839.1.2.0 = INTEGER: 2
.1.3.6.1.4.1.9839.1.3.1.1.0 = STRING: "alarm fired"
.1.3.6.1.4.1.9839.1.3.1.2.0 = STRING: "alarm reentered"
.1.3.6.1.4.1.9839.2.0.10.1.0 = INTEGER: 2
.1.3.6.1.4.1.9839.2.0.11.1.0 = INTEGER: 0

.1.3.6.1.2.1.1.2.0 = OID: .1.3.6.1.4.1.9839.2606.1
.1.3.6.1.4.1.9839.2606.1.1.0 = INTEGER: 4
.1.3.6.1.4.1.9839.2606.1.2.0 = INTEGER: 2
.1.3.6.1.4.1.9839.2606.1.3.1.1.0 = STRING: "alarm fired"
.1.3.6.1.4.1.9839.2606.1.3.1.2.0 = STRING: "alarm reentered"
.1.3.6.1.4.1.9839.2606.2.0.10.1.0 = INTEGER: 2
.1.3.6.1.4.1.9839.2606.2.0.11.1.0 = INTEGER: 0

.1.3.6.1.2.1.1.2.0 = OID: .1.3.6.1.4.1.8072.3.2.10
.1.3.6.1.4.1.2606.21.1.1.0 = INTEGER: 4
.1.3.6.1.4.1.2606.21.1.2.0 = INTEGER: 2
.1.3.6.1.4.1.2606.21.1.3.1.1.0 = STRING: "alarm fired"
.1.3.6.1.4.1.2606.21.1.3.1.2.0 = STRING: "alarm reentered"
.1.3.6.1.4.1.2606.21.2.0.10.1.0 = INTEGER: 2
.1.3.6.1.4.1.2606.21.2.0.11.1.0 = INTEGER: 0
ziemlich klar, das ist Rittal-LCP-DX-MIB

.1.3.6.1.2.1.1.2.0 = OID: .1.3.6.1.4.1.8072.3.2.10
.1.3.6.1.4.1.9839.1.1.0 = INTEGER: 4
.1.3.6.1.4.1.9839.1.2.0 = INTEGER: 2
.1.3.6.1.4.1.9839.1.3.1.1.0 = STRING: "alarm fired"
.1.3.6.1.4.1.9839.1.3.1.2.0 = STRING: "alarm reentered"
.1.3.6.1.4.1.9839.2.0.10.1.0 = INTEGER: 2
.1.3.6.1.4.1.9839.2.0.11.1.0 = INTEGER: 0

Basis rausfinden, also alle
1.3.6.1.4.1.9839
1.3.6.1.4.1.9839.2606
1.3.6.1.4.1.2606.21
Dazu Pseudo-MIBS mit
.1.3.6.1.4.1.9839.1.2.0
.1.3.6.1.4.1.9839.2606.1.2.0
.1.3.6.1.4.1.2606.21.1.2.0
Der Wert muss 2 sein, Code of the Agent. 2=pCOWeb
Dann <basis>.2.1.3.12, muss das Jahr sein. Wenns passt, dann LCP
Und <basis>.2.1.3.10 ist der Monat
(Wenns ein Rittal Chiller ist, der hat bei 2.1.3.12 irgendein Gateway und
bei .10 eine Netzmaske 8-16-24-32. Kombi aus beiden sollte eindeutig sein)

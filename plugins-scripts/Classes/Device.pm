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
      } elsif ($self->implements_mib('HWg-WLD-MIB')) {
        bless $self, 'Classes::HWG::WLD';
        $self->debug('using Classes::HWG::WLD');
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

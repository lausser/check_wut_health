package CheckWutHealth::Carel::Boss::Component::SensorSubsystem;
use strict;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my $self = shift;
  $self->get_snmp_objects('BOSS-SNMP-AGENT-MIB', qw(
      l9d1RetAirHumValuer l9d1RetAirTempValuer l9d1SupAirTempValuer
      l9d1CfgretLowTThrsr l9d1CfgretHiTThrsr
      l9d1CfgretHiHumThrsRelr l9d1CfgretLowHumThrsRelr
      l9d1CfgsupHiTThrsr l9d1CfgsupLowTThrsr
  ));
  # Das Zeug ist Datentype Opaque, also willkuerlich binaer verschlonzt
  foreach (qw(
      l9d1RetAirHumValuer l9d1RetAirTempValuer l9d1SupAirTempValuer
      l9d1CfgretLowTThrsr l9d1CfgretHiTThrsr
      l9d1CfgretHiHumThrsRelr l9d1CfgretLowHumThrsRelr
      l9d1CfgsupHiTThrsr l9d1CfgsupLowTThrsr
  )) {
    if (defined $self->{$_}) {
      if ($self->{$_} =~ /^[0-9\.]*$/) {
        # stammt wohl vom snmpwalk, passt
      } elsif (length($self->{$_}) == 7) {
        # raw to hex zum validieren
        my $hex = unpack("H*", $self->{$_});
        # einzelne bytes
        my @bytes = $hex =~ /(..)/g;
        if (@bytes != 7 || $bytes[0] ne '9f' || $bytes[1] ne '78' || $bytes[2] ne '04') {
          # ja mei
        } else {
          my $binary_float = substr($self->{$_}, -4);
          # big-endian single-precision float
          $self->{$_} = unpack('f>', $binary_float);
        }
      } else {
        # tut mir leid
      }
    }
  }
}

sub check {
  my $self = shift;
  $self->add_info(sprintf "Supply Air Temperature is %.2f, Return Air Temperature is %.2f, Humidity is %.2f%%",
      $self->{l9d1SupAirTempValuer},
      $self->{l9d1RetAirTempValuer},
      $self->{l9d1RetAirHumValuer}
  );
  $self->set_thresholds(
      metric => "temp_ret_air",
      warning => $self->{l9d1CfgretLowTThrsr}.":".$self->{l9d1CfgretHiTThrsr},
      critical => $self->{l9d1CfgretLowTThrsr}.":".$self->{l9d1CfgretHiTThrsr},
  );
  $self->add_message($self->check_thresholds(
      metric => "temp_ret_air",
      value => $self->{l9d1RetAirTempValuer}
  ), sprintf("Return Air Temperature is %.2f", $self->{l9d1RetAirTempValuer}));
  $self->add_perfdata(label => "temp_ret_air",
      value => $self->{l9d1RetAirTempValuer}
  );
  $self->set_thresholds(
      metric => "hum_ret_air",
      warning => $self->{l9d1CfgretLowHumThrsRelr}.":".$self->{l9d1CfgretHiHumThrsRelr},
      critical => $self->{l9d1CfgretLowHumThrsRelr}.":".$self->{l9d1CfgretHiHumThrsRelr},
  );
  $self->add_message($self->check_thresholds(
      metric => "hum_ret_air",
      value => $self->{l9d1RetAirHumValuer}
  ), sprintf("Return Air Humidity is %.2f%%", $self->{l9d1RetAirHumValuer}));
  $self->add_perfdata(label => "hum_ret_air",
      value => $self->{l9d1RetAirHumValuer},
      uom => "%",
  );
  $self->set_thresholds(
      metric => "temp_sup_air",
      warning => $self->{l9d1CfgsupLowTThrsr}.":".$self->{l9d1CfgsupHiTThrsr},
      critical => $self->{l9d1CfgsupLowTThrsr}.":".$self->{l9d1CfgsupHiTThrsr},
  );
  $self->add_message($self->check_thresholds(
      metric => "temp_sup_air",
      value => $self->{l9d1SupAirTempValuer}
  ), sprintf("Supply Air Temperature is %.2f", $self->{l9d1SupAirTempValuer}));
  $self->add_perfdata(label => "temp_sup_air",
      value => $self->{l9d1SupAirTempValuer}
  );
}



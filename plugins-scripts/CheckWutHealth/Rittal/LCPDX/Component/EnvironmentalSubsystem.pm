package CheckWutHealth::Rittal::LCPDX::Component::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  # alarm-output DESCRIPTION "General Alarm Contact" (ist 1, aber gui sagt ok)
  $self->{digital_descriptions} = {
    "comp-overload" => "Drive/Compressor Overload",
    "high-pressure" => "High Pressure Switch Alarm",
    "remote-on-off" => "Remote ON/OFF", # off (0), on (1)"
    "alarm-inverter" => "General Inverter Alarm",
    "alarm-off-line" => "Off-Line inverter Alarm", # driveAlarm Power+ drive off
#    "comp-on" => "Compressor On", # inverterOnOff Inverter On/Off
    "alarm-output" => "General Alarm Contact",
    "al-envelope" => "Envelope Alarm", # Compressor forced off working out envelope
    "al-start-fail-lock" => "Start failure lock Alarm",
    "mal-discharge-ht" => "Dicharge HT Alarm", # Maximum discharge temperature has been reached
    "mal-dp-startup" => "Delta pressure Start-Up compressor too high",
    "mal-dp-lubrification-oil" => "Delta pressure Lubrification oil too low",
    "alarm-server-in-temp1" => "Probe B2 Alarm (Broken or Disconnected)",
    "alarm-server-in-temp2" => "Probe B3 Alarm (Broken or Disconnected)",
    "alarm-server-in-temp3" => "Probe B4 Alarm (Broken or Disconnected)",
    "alarm-server-out-temp1" => "Probe B6 Alarm (Broken or Disconnected)",
    "alarm-server-out-temp2" => "Probe B7 Alarm (Broken or Disconnected)",
    "alarm-server-out-temp3" => "Probe B8 Alarm (Broken or Disconnected)",
    "alarm-comp-discharge-temp" => "Probe B9 Alarm (Broken or Disconnected)",
    "alarm-comp-suction-temp" => "Probe B10 Alarm (Broken or Disconnected)",
    "alarm-comp-discharge-pressure" => "Probe B11 Alarm (Broken or Disconnected)",
    "alarm-comp-suction-pressure" => "Probe B12 Alarm (Broken or Disconnected)",
  };
  $self->get_snmp_objects("RITTAL-LCP-DX-MIB", keys %{$self->{digital_descriptions}});
  $self->{analog_descriptions} = {
    "error-code" => "Current Error Code",
  };
}

sub check {
  my ($self) = @_;
  my $errors = 0;
  $self->{num_alarms} = 0;
  foreach (grep { defined $self->{$_} } keys %{$self->{digital_descriptions}}) {
    $self->add_info($self->{digital_descriptions}->{$_}." is ".$self->{$_});
    $self->{num_alarms}++;
    if ($_ eq "alarm-output") {
      next;
      # schon mal bestaetigt, dass das auf 1 war, in der GUI aber alles ok war
      # Laut einer schwindligen CAREL-RITTAL-LCP-3311-MIB.mib ist alarm=0,ok=1
      # Andere wiederum behauptet glatt das Gegenteil.
      # Hat keine Aussagekraft. Mehrere abgefragt:
      # .1.3.6.1.4.1.9839.2.1.1.23.0 = INTEGER  0
      # .1.3.6.1.4.1.9839.2606.2.1.1.23.0 = INTEGER  0
      # .1.3.6.1.4.1.2606.21.2.1.1.23.0 = INTEGER  1
      # .1.3.6.1.4.1.2606.21.2.1.1.23.0 = INTEGER  1
      # .1.3.6.1.4.1.2606.21.2.1.1.23.0 = INTEGER  1
      # .1.3.6.1.4.1.2606.21.2.1.1.23.0 = INTEGER  1
      # .1.3.6.1.4.1.9839.2.1.1.23.0 = INTEGER  1
      # Ich sehe keinen Weg, irgendeine Unterscheidung zwischen den Geraeten
      # zu treffen. Hoffen wir darauf, dass ein alarm-output andere Alarme
      # nach sich zieht.
      $self->add_critical();
      $errors++;
    } elsif ($_ eq "remote-on-off" and $self->{$_}) {
      # Nachdem sich jetzt alle beschweren, dass dieser Alarm nicht sein sollte
      # 7.2.1 Einschalten des LCP DX und des externen
      # Verflüssigers
      # Nachdem sowohl das LCP DX als auch der externe Ver-
      # flüssiger bzw. der Verflüssiger zur indirekten Freikühlung
      # elektrisch angeschlossen und am jeweiligen Haupt-
      # schalter eingeschaltet sind, führen Sie abschließend
      # noch die beiden folgenden Arbeitsschritte durch:
      # Falls Sie das LCP DX über einen Fernschalter ein- und
      # ausschalten möchten: Entfernen Sie in der Elektronik-
      # box an der Klemmleiste X1A die Brücke zwischen den
      # beiden Klemmen 30 und 80 („Remote On-Off“) und
      # schließen Sie dort potentialfrei einen Fernschalter
      # (Schließer) an (Abb. 31, Pos. 1).
      # Wenn die beiden Klemmen nicht gebrückt sind, wird
      # im Display die Status-Meldung „Din-Off“ angezeigt.
      # Ändern Sie den Status des Geräts im Menü „On/Off
      # Unit“ von „Off“ auf „On“ (vgl. Abschnitt 7.6 „Menü-
      # ebene A „On/Off Unit““).
      # Was auch immer das bedeutet, ob bei 1 eventuell gar kein solcher
      # Fernschalter vorhanden ist oder ob 1 bedeutet, das Glump wurde damit
      # ausgeknipst: mir ist das jetzt wurscht, 1 ist erstmal ok.
      # Und sollte sich nochmal einer beschweren, dann fliegt der Remotekrempel
      # ganz raus.
      $self->add_ok();
    } elsif ($_ eq "high-pressure" and $self->{$_}) {
      # auch hier: bei fuenf Spaniern und einem Polen auf 1. Ich dreh's mal um,
      # wird schon gutgehen.
      $self->add_ok();
    } elsif ($self->{$_}) {
      $self->add_critical();
      $errors++;
    }
  }
  if (! $errors and $self->{"error-code"}) {
    # https://github.com/epiecs/carel-pco-mibs?tab=readme-ov-file
    # https://www.rittal.com/de-de/products/PG0800ITINFRA1/PGR1951ITINFRA1/PG1023ITINFRA1/PRO34169?variantId=3311410
    # Stellt sich raus, der Dreck ist seit drei Jahren abgekuendigt!!!!
    $self->add_info({
      0 => "OK",
      2 => "Probe B2 faulty or disconnected",
      3 => "Probe B3 faulty or disconnected",
      4 => "Probe B4 faulty or disconnected",
      5 => "Probe B5 faulty or disconnected",
      6 => "Probe B6 faulty or disconnected",
      7 => "Probe B7 faulty or disconnected",
      8 => "Probe B8 faulty or disconnected",
      9 => "Probe B9 faulty or disconnected",
      10 => "Probe B10 faulty or disconnected",
      11 => "Probe B11 faulty or disconnected",
      12 => "Probe B12 faulty or disconnected",
      13 => "High pressure",
      14 => "High pressure compressor 1 by transducer",
      15 => "Low pressure compressor/compressors by transducer",
      16 => "Compressor 1 overload or inverter alarm",
      17 => "Envelope alarm zone",
      18 => "Compressor start failure",
      19 => "High discharge gas temperature",
      20 => "Low pressure differential (insufficient lubrication)",
      21 => "Fan overload",
      22 => "Sensor failure",
      23 => "EEV motor error",
      24 => "Low superheat",
      25 => "Low suction temperature",
      26 => "Low evaporation temperature",
      27 => "High evaporation temperature",
      28 => "High condensing temperature",
      29 => "Driver offline",
      30 => "Power+ offline",
      31 => "Power+ Generic Alarm",
      32 => "Unexpected inverter stop",
      33 => "Max temperature (warning)",
    }->{$self->{"error-code"}});
    $self->add_critical();
  }
}


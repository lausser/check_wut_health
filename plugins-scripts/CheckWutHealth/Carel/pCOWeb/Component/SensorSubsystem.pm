package CheckWutHealth::Carel::pCOWeb::Component::SensorSubsystem;
use strict;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my $self = shift;
  $self->get_snmp_objects('KELVIN-PCOWEB-LCP-DX-MIB', qw(
      gentRelease  agentCode  pCOId1-Status  pCOId1-ErrorsNumber  din1  din2  din3  din4  din5  din6  din7  din8  din9  din10  dobj11  dobj12  dobj13  dobj14  dobj15  dobj16  dout1  dout2  dout3  dout4  dout5  dout6  dout7  dout8  dout9  dout10  dout11  dout12  bms-res-alarm  al-envelope  al-start-fail-lock  mal-start-failure-msk  mal-discharge-ht  dobj34  mal-dp-startup  mal-dp-lubrification-oil  mal-b1  mal-b2  mal-b3  mal-b4  mal-b5  mal-b6  mal-b7  mal-b8  mal-b9  mal-b10  mal-b11  mal-b12  b1-value  b2-value  b3-value  b4-value  b5-value  b6-value  b7-value  b8-value  b9-value  b10-value  b11-value  b12-value  evap-temp  cond-temp  aobj15  aobj16  aobj17  aobj18  aobj19  aobj20  medium-temp-out  medium-temp-in  rotor-speed-rps  motor-current  aobj47  setpoint-lcp  rotor-speed-hz  drive-status  error-code  drive-temp  bus-voltage  motor-voltage  power-req-0-1000-after-envelope  current-hour  current-minute  current-month  current-weekday  current-year  on-off-BMS  envelope-zone  ht-zone  cooling-capacity-after-envelope  valve-steps  y3-AOut3  current-day  fans-speed-percent  fans-speed-rpm  evd-valve-opening-percent
  ));
}

sub check {
  my $self = shift;
  $self->add_info("pCOId1 status is ".$self->{"pCOId1-Status"});
  if ($self->{"pCOId1-Status"} ne "online") {
    $self->add_warning();
  }
  if ($self->{"pCOId1-ErrorsNumber"} > 0) {
    $self->add_warning(sprintf "%d communication errors from pCOId1",
        $self->{"pCOId1-ErrorsNumber"});
  }
  if (defined $self->{din1}) {
    if ($self->{din1}) {
    }
  }
  if (defined $self->{din2}) {
    if ($self->{din2}) {
      $self->add_critical("Drive/Compressor Overload");
    }
  }
  if (defined $self->{din3}) {
    if ($self->{din3}) {
      # 19.4.23 Pep
      # the vendor confirmed that there is a bug that could trigger the alarm and we are waiting for new firmware that will fix it.
      # In the meanwhile, is it posible to ignore this OID in the monitoring?
      #$self->add_critical("High Pressure Switch Alarm");
      $self->add_critical_mitigation("High Pressure Switch Alarm");
    }
  }
  if (defined $self->{din4}) {
    if ($self->{din4}) {
    }
  }
  if (defined $self->{din5}) {
    if ($self->{din5}) {
    }
  }
  if (defined $self->{din6}) {
    if ($self->{din6}) {
    }
  }
  if (defined $self->{din7}) {
    if ($self->{din7}) {
    }
  }
  if (defined $self->{din8}) {
    if ($self->{din8}) {
      # like High Pressure Switch Alarm
      # Pep: the vendor told us that because of our type of installation Remote ON/OFF can be ignored as well
      $self->add_critical_mitigation("Remote ON/OFF");
    }
  }
  if (defined $self->{din9}) {
    if ($self->{din9}) {
    }
  }
  if (defined $self->{din10}) {
    if ($self->{din10}) {
    }
  }
  if (defined $self->{dobj11}) {
    if ($self->{dobj11}) {
      $self->add_critical("General Inverter Alarm");
    }
  }
  if (defined $self->{dobj12}) {
    if ($self->{dobj12}) {
      $self->add_critical("Off-Line inverter Alarm");
    }
  }
  if (defined $self->{dobj13}) {
    if ($self->{dobj13}) {
    }
  }
  if (defined $self->{dobj14}) {
    if ($self->{dobj14}) {
    }
  }
  if (defined $self->{dobj15}) {
    if ($self->{dobj15}) {
    }
  }
  if (defined $self->{dobj16}) {
    if ($self->{dobj16}) {
    }
  }
  if (defined $self->{dout1}) {
    if ($self->{dout1}) {
      $self->add_ok("Compressor On");
    } else {
      $self->add_ok("Compressor Off");
    }
  }
  if (defined $self->{dout2}) {
    if ($self->{dout2}) {
    }
  }
  if (defined $self->{dout3}) {
    if ($self->{dout3}) {
    }
  }
  if (defined $self->{dout4}) {
    if ($self->{dout4}) {
    }
  }
  if (defined $self->{dout5}) {
    if ($self->{dout5}) {
    }
  }
  if (defined $self->{dout6}) {
    if ($self->{dout6}) {
    }
  }
  if (defined $self->{dout7}) {
    #     from the source of the lpc.html file:
    # function parseResults() {
    #
    # // DIGITALS variables
    #
    # if (digitals[23] == 1)
    #         { document.getElementById("alarm").innerHTML="<img src=noalarm.gif>"; } else{ document.getElementById("alarm").innerHTML="<img src=alarm.gif>";}
    #
    #     So if dout7 = 1 then the device is "ok", and when the value is 0, then we have an alarm
    # 
    if (! $self->{dout7}) {
      $self->add_critical("General Alarm Contact");
    }
  }
  if (defined $self->{dout8}) {
    if ($self->{dout8}) {
    }
  }
  if (defined $self->{dout9}) {
    if ($self->{dout9}) {
    }
  }
  if (defined $self->{dout10}) {
    if ($self->{dout10}) {
    }
  }
  if (defined $self->{dout11}) {
    if ($self->{dout11}) {
    }
  }
  if (defined $self->{dout12}) {
    if ($self->{dout12}) {
    }
  }
  if (defined $self->{"bm-res-alarm"}) {
    if ($self->{"bm-res-alarm"}) {
      $self->add_ok("Reset Alarm by Supervisor");
    }
  }
  if (defined $self->{"al-envelope"}) {
    if ($self->{"al-envelope"}) {
      $self->add_critical("Envelope Alarm");
    }
  }
  if (defined $self->{"al-start-fail"}) {
    if ($self->{"al-start-fail"}) {
      $self->add_critical("Start failure lock Alarm");
    }
  }
  if (defined $self->{"mal-start-failure-msk"}) {
    if ($self->{"mal-start-failure-msk"}) {
      $self->add_critical("Start failure mask Alarm");
    }
  }
  if (defined $self->{"mal-discharge-ht"}) {
    if ($self->{"mal-discharge-ht"}) {
      $self->add_critical("Discharge HT Alarm");
    }
  }
  if (defined $self->{dobj34}) {
    if ($self->{dobj34}) {
    }
  }
  if (defined $self->{"mal-dp-startup"}) {
    if ($self->{"mal-dp-startup"}) {
      $self->add_critical("Delta pressure Start-Up compressor too high");
    }
  }
  if (defined $self->{"mal-dp-lubrification-oil"}) {
    if ($self->{"mal-dp-lubrification-oil"}) {
      $self->add_critical("Delta pressure Lubrification oil too low");
    }
  }
  foreach my $b (1..12) {
    if (defined $self->{"mal-b".$b}) {
      if ($self->{"mal-b".$b}) {
        $self->add_critical("Probe B".$b." Alarm (Broken or Disconnected)");
      }
    }
  }
  if (defined $self->{"b1-value"}) {
    $self->set_thresholds(metric => "b1-value", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "b1-value", value => $self->{"b1-value"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "B1 Probe Value", $self->{"b1-value"});
      $self->add_message($level);
    }
  }
  if (defined $self->{"b2-value"}) {
    $self->set_thresholds(metric => "b2-value", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "b2-value", value => $self->{"b2-value"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "B2 Probe Value - LCP Server IN", $self->{"b2-value"});
      $self->add_message($level);
    }
  }
  if (defined $self->{"b3-value"}) {
    $self->set_thresholds(metric => "b3-value", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "b3-value", value => $self->{"b3-value"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "B3 Probe Value - LCP Server IN", $self->{"b3-value"});
      $self->add_message($level);
    }
  }
  if (defined $self->{"b4-value"}) {
    $self->set_thresholds(metric => "b4-value", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "b4-value", value => $self->{"b4-value"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "B4 Probe Value - LCP Server IN", $self->{"b4-value"});
      $self->add_message($level);
    }
  }
  if (defined $self->{"b5-value"}) {
    $self->set_thresholds(metric => "b5-value", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "b5-value", value => $self->{"b5-value"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "B5 Probe Value", $self->{"b5-value"});
      $self->add_message($level);
    }
  }
  if (defined $self->{"b6-value"}) {
    $self->set_thresholds(metric => "b6-value", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "b6-value", value => $self->{"b6-value"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "B6 Probe Value - ROOM Server OUT", $self->{"b6-value"});
      $self->add_message($level);
    }
  }
  if (defined $self->{"b7-value"}) {
    $self->set_thresholds(metric => "b7-value", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "b7-value", value => $self->{"b7-value"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "B7 Probe Value - ROOM Server OUT", $self->{"b7-value"});
      $self->add_message($level);
    }
  }
  if (defined $self->{"b8-value"}) {
    $self->set_thresholds(metric => "b8-value", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "b8-value", value => $self->{"b8-value"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "B9 Probe Value - ROOM Server OUT", $self->{"b8-value"});
      $self->add_message($level);
    }
  }
  if (defined $self->{"b9-value"}) {
    $self->set_thresholds(metric => "b9-value", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "b9-value", value => $self->{"b9-value"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "B9 Probe Value - Compressor Discharge Temperature", $self->{"b9-value"});
      $self->add_message($level);
    }
  }
  if (defined $self->{"b10-value"}) {
    $self->set_thresholds(metric => "b10-value", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "b10-value", value => $self->{"b10-value"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "B10 Probe Value - Compressor Suction Temperature", $self->{"b10-value"});
      $self->add_message($level);
    }
  }
  if (defined $self->{"b11-value"}) {
    $self->{"b11-value"} /= 10;
    $self->set_thresholds(metric => "b11-value", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "b11-value", value => $self->{"b11-value"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "B11 Probe Value - Compressor Discharge Pressure", $self->{"b11-value"});
      $self->add_message($level);
    }
    $self->add_perfdata(
        label => "cond-pressure",
        value => $self->{"b11-value"},
    );
  }
  if (defined $self->{"b12-value"}) {
    $self->{"b12-value"} /= 10;
    $self->set_thresholds(metric => "b12-value", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "b12-value", value => $self->{"b12-value"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "B12 Probe Value - Compressor Suction Pressure", $self->{"b12-value"});
      $self->add_message($level);
    }
    $self->add_perfdata(
        label => "evap-pressure",
        value => $self->{"b12-value"},
    );
  }
  if (defined $self->{"evap-temp"}) {
    $self->{"evap-temp"} /= 10;
    $self->set_thresholds(metric => "evap-temp", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "evap-temp", value => $self->{"evap-temp"});
    if ($level) {
      $self->add_info(sprintf "%s is %dDegC", "Evaporation Temperature", $self->{"evap-temp"});
      $self->add_message($level);
    }
    $self->add_perfdata(
        label => "evap-temp",
        value => $self->{"evap-temp"},
        min => -40,
        max => 60,
    );
  }
  if (defined $self->{"cond-temp"}) {
    $self->{"cond-temp"} /= 10;
    $self->set_thresholds(metric => "cond-temp", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "cond-temp", value => $self->{"cond-temp"});
    if ($level) {
      $self->add_info(sprintf "%s is %dDegC", "Condensation Temperature", $self->{"cond-temp"});
      $self->add_message($level);
    }
    $self->add_perfdata(
        label => "cond-temp",
        value => $self->{"cond-temp"},
        min => -40,
        max => 60,
    );
  }
  # aobj15
  # aobj16
  # ...
  # aobj20
  if (defined $self->{"medium-temp-out"}) {
    $self->{"medium-temp-out"} /= 10;
    $self->set_thresholds(metric => "medium-temp-out", warning => "18:28", critical => "10:35");
    my $level = $self->check_thresholds(metric => "medium-temp-out", value => $self->{"medium-temp-out"});
    if (1 or $level) {
      $self->add_info(sprintf "%s is %dDegC", "Server Medium Temp Out - (Room)", $self->{"medium-temp-out"});
      $self->add_message($level);
    }
    $self->add_perfdata(
        label => "medium-temp-out",
        value => $self->{"medium-temp-out"},
        min => 0,
        max => 50,
    );
  }
  if (defined $self->{"medium-temp-in"}) {
    $self->{"medium-temp-in"} /= 10;
    $self->set_thresholds(metric => "medium-temp-in", warning => "18:28", critical => "10:35");
    my $level = $self->check_thresholds(metric => "medium-temp-in", value => $self->{"medium-temp-in"});
    if ($level) {
      $self->add_info(sprintf "%s is %dDegC", "Server Medium Temp In - (LCP)", $self->{"medium-temp-in"});
      $self->add_message($level);
    }
    $self->add_perfdata(
        label => "medium-temp-in",
        value => $self->{"medium-temp-in"},
        min => 0,
        max => 50,
    );
  }
  if (defined $self->{"rotor-speed-rps"}) {
    $self->{"rotor-speed-rps"} /= 10;
    $self->set_thresholds(metric => "rotor-speed-rps", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "rotor-speed-rps", value => $self->{"rotor-speed-rps"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "Compressor Rotor Speed (RPS)", $self->{"rotor-speed-rps"});
      $self->add_message($level);
    }
    $self->add_perfdata(
        label => "rotor-speed-rps",
        value => $self->{"rotor-speed-rps"},
    );
  }
  if (defined $self->{"motor-current"}) {
    $self->{"motor-current"} /= 10;
    $self->set_thresholds(metric => "motor-current", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "motor-current", value => $self->{"motor-current"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "Compressor Motor Current (Amp)", $self->{"motor-current"});
      $self->add_message($level);
    }
    $self->add_perfdata(
        label => "motor-current",
        value => $self->{"motor-current"},
    );
  }
  # aobj47
  if (defined $self->{"setpoint-lcp"}) {
    $self->{"setpoint-lcp"} /= 10;
    $self->set_thresholds(metric => "setpoint-lcp", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "setpoint-lcp", value => $self->{"setpoint-lcp"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "Setpoint LCP", $self->{"setpoint-lcp"});
      $self->add_message($level);
    }
    $self->add_perfdata(
        label => "setpoint-lcp",
        value => $self->{"setpoint-lcp"},
    );
  }
  # integer variables
  if (defined $self->{"rotor-speed-hz"}) {
    $self->set_thresholds(metric => "rotor-speed-hz", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "rotor-speed-hz", value => $self->{"rotor-speed-hz"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "Compressor Rotor Speed (Hz)", $self->{"rotor-speed-hz"});
      $self->add_message($level);
    }
  }
  if (defined $self->{"drive-status"}) {
    # 0..2, normalerweise 1
    # Anwender meint, er bekommt unnoetigerweise einen Alarm, wenn das
    # Geraet im Standby ist. Service History zeigt, dass sich das so aeussert:
    # CRITICAL - Driver Status is 0, Compressor Off, Server Medium Temp Out - (Room) is 24DegC, Fans Speed (percent) is 30%
    # 11.1.21 (NSR2615857), dann gibt's dafuer jetzt einen Hinweis
    $self->add_info(sprintf "%s is %d", "Driver Status", $self->{"drive-status"});
    if (defined $self->{dout1} and not $self->{dout1} and $self->{"drive-status"} == 0) {
      # Compressor Off
      $self->annotate_info("In Standby");
    }
    if ($self->{"drive-status"} == 0) {
      if (defined $self->{dout1} and not $self->{dout1} and $self->{"drive-status"} == 0) {
        $self->add_ok();
      } else {
        $self->add_unknown();
      }
    } elsif ($self->{"drive-status"} == 2) {
      $self->add_critical();
    } 
  }
  if (defined $self->{"error-code"}) {
    if ($self->{"error-code"}) {
      $self->add_info(sprintf "%s is %d", "Current Error Code", $self->{"error-code"});
      $self->add_warning();
    }
  }
  if (defined $self->{"drive-temp"}) {
    $self->set_thresholds(metric => "drive-temp", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "drive-temp", value => $self->{"drive-temp"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "Driver Temperature", $self->{"drive-temp"});
      $self->add_message($level);
    }
  }
  if (defined $self->{"bus-voltage"}) {
    $self->set_thresholds(metric => "bus-voltage", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "bus-voltage", value => $self->{"bus-voltage"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "DC Bus Voltage", $self->{"bus-voltage"});
      $self->add_message($level);
    }
  }
  if (defined $self->{"motor-voltage"}) {
    $self->set_thresholds(metric => "motor-voltage", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "motor-voltage", value => $self->{"motor-voltage"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "Motor Voltage", $self->{"motor-voltage"});
      $self->add_message($level);
    }
  }
  if (defined $self->{"power-req-0-1000-after-envelope"}) {
    $self->set_thresholds(metric => "power-req-0-1000-after-envelope", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "power-req-0-1000-after-envelope", value => $self->{"power-req-0-1000-after-envelope"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "Power Request after Envelope", $self->{"power-req-0-1000-after-envelope"});
      $self->add_message($level);
    }
  }
  # year month day...
  if (defined $self->{"on-off-BMS"}) {
    $self->set_thresholds(metric => "on-off-BMS", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "on-off-BMS", value => $self->{"on-off-BMS"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "ON/OFF Status BMS", $self->{"on-off-BMS"});
      $self->add_message($level);
    }
  }
  if (defined $self->{"envelope-zone"}) {
    $self->set_thresholds(metric => "envelope-zone", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "envelope-zone", value => $self->{"envelope-zone"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "Envelope Zone", $self->{"envelope-zone"});
      $self->add_message($level);
    }
  }
  if (defined $self->{"ht-zone"}) {
    $self->set_thresholds(metric => "ht-zone", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "ht-zone", value => $self->{"ht-zone"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "HT Zone", $self->{"ht-zone"});
      $self->add_message($level);
    }
  }
  if (defined $self->{"cooling-capacity-after-envelope"}) {
    $self->set_thresholds(metric => "cooling-capacity-after-envelope", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "cooling-capacity-after-envelope", value => $self->{"cooling-capacity-after-envelope"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "Cooling Capacity after Envelope", $self->{"cooling-capacity-after-envelope"});
      $self->add_message($level);
    }
  }
  if (defined $self->{"valve-steps"}) {
    $self->set_thresholds(metric => "valve-steps", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "valve-steps", value => $self->{"valve-steps"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "Valve Steps Position", $self->{"valve-steps"});
      $self->add_message($level);
    }
  }
  if (defined $self->{"y3-AOut3"}) {
    $self->{"y3-AOut3"} /= 10; # hat 461 bei fans-speed-percent = 46
    $self->set_thresholds(metric => "y3-AOut3", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "y3-AOut3", value => $self->{"y3-AOut3"});
    if ($level) {
      $self->add_info(sprintf "%s is %d", "Fans speed %", $self->{"y3-AOut3"});
      $self->add_message($level);
    }
  }

  if (defined $self->{"fans-speed-percent"}) {
    $self->set_thresholds(metric => "fans-speed-percent",
        warning => 80,
        critical => 95
    );
    my $level = $self->check_thresholds(metric => "fans-speed-percent", value => $self->{"fans-speed-percent"});
    if (1 or $level) {
      $self->add_info(sprintf "Fans Speed (percent) is %d%%", $self->{"fans-speed-percent"});

      $self->add_message($level);
    }
    $self->add_perfdata(label => "fans-speed-percent",
        value => $self->{"fans-speed-percent"},
        uom => "%",
    );
  }
  if (0 and defined $self->{"fans-speed-rpm"}) {
    $self->set_thresholds(metric => "fans-speed-rpm",
        warning => 1000,
        critical => 2000
    );
    my $level = $self->check_thresholds(metric => "fans-speed-rpm", value => $self->{"fans-speed-rpm"});
    if ($level) {
      $self->add_info(sprintf "Fans Speed (rpm) %drpm", $self->{"fans-speed-rpm"});
      $self->add_message($level);
    }
    $self->add_perfdata(label => "fans-speed-rpm",
        value => $self->{"fans-speed-rpm"},
    );
  }
  if (defined $self->{"evd-valve-opening-percent"}) {
    $self->set_thresholds(metric => "evd-valve-opening-percent", warning => "", critical => "");
    my $level = $self->check_thresholds(metric => "evd-valve-opening-percent", value => $self->{"evd-valve-opening-percent"});
    if (0 and $level) {
      $self->add_info(sprintf "%s is %d", "EVD Valve opening percent", $self->{"evd-valve-opening-percent"});
      $self->add_message($level);
    }
    $self->add_perfdata(label => "evd-valve-opening-percent",
        value => $self->{"evd-valve-opening-percent"},
        uom => "%",
    );
  }
}



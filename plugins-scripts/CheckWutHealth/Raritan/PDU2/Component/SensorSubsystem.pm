package CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  # logConfigurationTable
  my @tables = (qw(nameplateTable unitConfigurationTable activeDNSServerTable activeNTPServerTable controllerConfigurationTable trapInformationTable unitSensorConfigurationTable inletConfigurationTable inletPoleConfigurationTable inletSensorConfigurationTable inletPoleSensorConfigurationTable inletLinePairConfigurationTable inletLinePairSensorConfigurationTable overCurrentProtectorConfigurationTable overCurrentProtectorPoleConfigurationTable overCurrentProtectorSensorConfigurationTable outletConfigurationTable outletPoleConfigurationTable outletSensorConfigurationTable outletPoleSensorConfigurationTable externalSensorConfigurationTable externalSensorTypeDefaultThresholdsTable serverReachabilityTable wireConfigurationTable wireSensorConfigurationTable transferSwitchConfigurationTable transferSwitchPoleConfigurationTable transferSwitchSensorConfigurationTable powerMeterConfigurationTable circuitConfigurationTable circuitPoleConfigurationTable circuitSensorConfigurationTable circuitPoleSensorConfigurationTable outletGroupConfigurationTable outletGroupSensorConfigurationTable peripheralDevicePackageTable unitSensorMeasurementsTable inletSensorMeasurementsTable inletPoleSensorMeasurementsTable inletLinePairSensorMeasurementsTable outletSensorMeasurementsTable outletPoleSensorMeasurementsTable overCurrentProtectorSensorMeasurementsTable externalSensorMeasurementsTable wireSensorMeasurementsTable transferSwitchSensorMeasurementsTable circuitSensorMeasurementsTable circuitPoleSensorMeasurementsTable outletGroupSensorMeasurementsTable outletSwitchControlTable transferSwitchControlTable actuatorControlTable rcmSelfTestTable overCurrentProtectorRcmSelfTestTable inletSensorControlTable inletPoleSensorControlTable inletLinePairSensorControlTable outletSensorControlTable outletPoleSensorControlTable unitSensorControlTable overCurrentProtectorSensorControlTable externalSensorControlTable transferSwitchSensorControlTable circuitSensorControlTable circuitPoleSensorControlTable outletGroupSwitchControlTable outletGroupSensorControlTable serverPowerControlTable reliabilityDataTableSequenceNumber reliabilityDataTable hwFailureTable));
  foreach (@tables) {
    my $package_name = "CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::".$_;
    {
      no strict "refs";
      @{ "${package_name}::ISA" } = ("Monitoring::GLPlugin::SNMP::TableItem");
      
    }
    $self->get_snmp_tables('PDU2-MIB', [
      [$_, $_, 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::'.$_],
    ]);
  }
  $self->get_snmp_tables('PDU2-MIB-nono', [
#    ['controllerconfigs', 'controllerConfigurationTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
#    ['unitsensorconfigs', 'unitSensorConfigurationTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
#    ['dnsservers', 'activeDNSServerTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
#    ['ntpservers', 'activeNTPServerTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
#    ['externalsensorconfigs', 'externalSensorConfigurationTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
#    ['externalsensordefaultthresholds', 'externalSensorTypeDefaultThresholdsTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
#    ['peripheraldevices', 'peripheralDevicePackageTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
#    ['externalsensorcontrolss', 'externalSensorControlTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
#    ['sensormeasurements', 'unitSensorMeasurementsTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
#    ['sensorcontrols', 'unitSensorControlTable', 'Monitoring::GLPlugin::SNMP::TableItem'],
#    ['externalsensormeasurements', 'externalSensorMeasurementsTable', 'Monitoring::GLPlugin::SNMP::TableItem'],


    ['nameplateTable', 'nameplateTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::nameplateTable'],
    ['unitConfigurationTable', 'unitConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::unitConfigurationTable'],
    ['activeDNSServerTable', 'activeDNSServerTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::activeDNSServerTable'],
    ['activeNTPServerTable', 'activeNTPServerTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::activeNTPServerTable'],
    ['controllerConfigurationTable', 'controllerConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::controllerConfigurationTable'],
    #['logConfigurationTable', 'logConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::logConfigurationTable'],
    ['trapInformationTable', 'trapInformationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::trapInformationTable'],
    ['unitSensorConfigurationTable', 'unitSensorConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::unitSensorConfigurationTable'],
    ['inletConfigurationTable', 'inletConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::inletConfigurationTable'],
    ['inletPoleConfigurationTable', 'inletPoleConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::inletPoleConfigurationTable'],
    ['inletSensorConfigurationTable', 'inletSensorConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::inletSensorConfigurationTable'],
    ['inletPoleSensorConfigurationTable', 'inletPoleSensorConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::inletPoleSensorConfigurationTable'],
    ['inletLinePairConfigurationTable', 'inletLinePairConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::inletLinePairConfigurationTable'],
    ['inletLinePairSensorConfigurationTable', 'inletLinePairSensorConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::inletLinePairSensorConfigurationTable'],
    ['overCurrentProtectorConfigurationTable', 'overCurrentProtectorConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::overCurrentProtectorConfigurationTable'],
    ['overCurrentProtectorPoleConfigurationTable', 'overCurrentProtectorPoleConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::overCurrentProtectorPoleConfigurationTable'],
    ['overCurrentProtectorSensorConfigurationTable', 'overCurrentProtectorSensorConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::overCurrentProtectorSensorConfigurationTable'],
    ['outletConfigurationTable', 'outletConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::outletConfigurationTable'],
    ['outletPoleConfigurationTable', 'outletPoleConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::outletPoleConfigurationTable'],
    ['outletSensorConfigurationTable', 'outletSensorConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::outletSensorConfigurationTable'],
    ['outletPoleSensorConfigurationTable', 'outletPoleSensorConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::outletPoleSensorConfigurationTable'],
    ['externalSensorConfigurationTable', 'externalSensorConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::externalSensorConfigurationTable'],
    ['externalSensorTypeDefaultThresholdsTable', 'externalSensorTypeDefaultThresholdsTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::externalSensorTypeDefaultThresholdsTable'],
    ['serverReachabilityTable', 'serverReachabilityTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::serverReachabilityTable'],
    ['wireConfigurationTable', 'wireConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::wireConfigurationTable'],
    ['wireSensorConfigurationTable', 'wireSensorConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::wireSensorConfigurationTable'],
    ['transferSwitchConfigurationTable', 'transferSwitchConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::transferSwitchConfigurationTable'],
    ['transferSwitchPoleConfigurationTable', 'transferSwitchPoleConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::transferSwitchPoleConfigurationTable'],
    ['transferSwitchSensorConfigurationTable', 'transferSwitchSensorConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::transferSwitchSensorConfigurationTable'],
    ['powerMeterConfigurationTable', 'powerMeterConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::powerMeterConfigurationTable'],
    ['circuitConfigurationTable', 'circuitConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::circuitConfigurationTable'],
    ['circuitPoleConfigurationTable', 'circuitPoleConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::circuitPoleConfigurationTable'],
    ['circuitSensorConfigurationTable', 'circuitSensorConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::circuitSensorConfigurationTable'],
    ['circuitPoleSensorConfigurationTable', 'circuitPoleSensorConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::circuitPoleSensorConfigurationTable'],
    ['outletGroupConfigurationTable', 'outletGroupConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::outletGroupConfigurationTable'],
    ['outletGroupSensorConfigurationTable', 'outletGroupSensorConfigurationTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::outletGroupSensorConfigurationTable'],
    ['peripheralDevicePackageTable', 'peripheralDevicePackageTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::peripheralDevicePackageTable'],
    ['logIndexTable', 'logIndexTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::logIndexTable'],
    ['logTimeStampTable', 'logTimeStampTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::logTimeStampTable'],
    ['unitSensorLogTable', 'unitSensorLogTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::unitSensorLogTable'],
    ['inletSensorLogTable', 'inletSensorLogTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::inletSensorLogTable'],
    ['inletPoleSensorLogTable', 'inletPoleSensorLogTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::inletPoleSensorLogTable'],
    ['inletLinePairSensorLogTable', 'inletLinePairSensorLogTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::inletLinePairSensorLogTable'],
    ['outletSensorLogTable', 'outletSensorLogTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::outletSensorLogTable'],
    ['outletPoleSensorLogTable', 'outletPoleSensorLogTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::outletPoleSensorLogTable'],
    ['overCurrentProtectorSensorLogTable', 'overCurrentProtectorSensorLogTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::overCurrentProtectorSensorLogTable'],
    ['externalSensorLogTable', 'externalSensorLogTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::externalSensorLogTable'],
    ['wireSensorLogTable', 'wireSensorLogTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::wireSensorLogTable'],
    ['transferSwitchSensorLogTable', 'transferSwitchSensorLogTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::transferSwitchSensorLogTable'],
    ['circuitSensorLogTable', 'circuitSensorLogTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::circuitSensorLogTable'],
    ['circuitPoleSensorLogTable', 'circuitPoleSensorLogTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::circuitPoleSensorLogTable'],
    ['outletGroupSensorLogTable', 'outletGroupSensorLogTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::outletGroupSensorLogTable'],
    ['unitSensorMeasurementsTable', 'unitSensorMeasurementsTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::unitSensorMeasurementsTable'],
    ['inletSensorMeasurementsTable', 'inletSensorMeasurementsTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::inletSensorMeasurementsTable'],
    ['inletPoleSensorMeasurementsTable', 'inletPoleSensorMeasurementsTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::inletPoleSensorMeasurementsTable'],
    ['inletLinePairSensorMeasurementsTable', 'inletLinePairSensorMeasurementsTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::inletLinePairSensorMeasurementsTable'],
    ['outletSensorMeasurementsTable', 'outletSensorMeasurementsTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::outletSensorMeasurementsTable'],
    ['outletPoleSensorMeasurementsTable', 'outletPoleSensorMeasurementsTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::outletPoleSensorMeasurementsTable'],
    ['overCurrentProtectorSensorMeasurementsTable', 'overCurrentProtectorSensorMeasurementsTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::overCurrentProtectorSensorMeasurementsTable'],
    ['externalSensorMeasurementsTable', 'externalSensorMeasurementsTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::externalSensorMeasurementsTable'],
    ['wireSensorMeasurementsTable', 'wireSensorMeasurementsTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::wireSensorMeasurementsTable'],
    ['transferSwitchSensorMeasurementsTable', 'transferSwitchSensorMeasurementsTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::transferSwitchSensorMeasurementsTable'],
    ['circuitSensorMeasurementsTable', 'circuitSensorMeasurementsTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::circuitSensorMeasurementsTable'],
    ['circuitPoleSensorMeasurementsTable', 'circuitPoleSensorMeasurementsTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::circuitPoleSensorMeasurementsTable'],
    ['outletGroupSensorMeasurementsTable', 'outletGroupSensorMeasurementsTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::outletGroupSensorMeasurementsTable'],
    ['outletSwitchControlTable', 'outletSwitchControlTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::outletSwitchControlTable'],
    ['transferSwitchControlTable', 'transferSwitchControlTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::transferSwitchControlTable'],
    ['actuatorControlTable', 'actuatorControlTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::actuatorControlTable'],
    ['rcmSelfTestTable', 'rcmSelfTestTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::rcmSelfTestTable'],
    ['overCurrentProtectorRcmSelfTestTable', 'overCurrentProtectorRcmSelfTestTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::overCurrentProtectorRcmSelfTestTable'],
    ['inletSensorControlTable', 'inletSensorControlTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::inletSensorControlTable'],
    ['inletPoleSensorControlTable', 'inletPoleSensorControlTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::inletPoleSensorControlTable'],
    ['inletLinePairSensorControlTable', 'inletLinePairSensorControlTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::inletLinePairSensorControlTable'],
    ['outletSensorControlTable', 'outletSensorControlTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::outletSensorControlTable'],
    ['outletPoleSensorControlTable', 'outletPoleSensorControlTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::outletPoleSensorControlTable'],
    ['unitSensorControlTable', 'unitSensorControlTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::unitSensorControlTable'],
    ['overCurrentProtectorSensorControlTable', 'overCurrentProtectorSensorControlTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::overCurrentProtectorSensorControlTable'],
    ['externalSensorControlTable', 'externalSensorControlTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::externalSensorControlTable'],
    ['transferSwitchSensorControlTable', 'transferSwitchSensorControlTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::transferSwitchSensorControlTable'],
    ['circuitSensorControlTable', 'circuitSensorControlTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::circuitSensorControlTable'],
    ['circuitPoleSensorControlTable', 'circuitPoleSensorControlTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::circuitPoleSensorControlTable'],
    ['outletGroupSwitchControlTable', 'outletGroupSwitchControlTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::outletGroupSwitchControlTable'],
    ['outletGroupSensorControlTable', 'outletGroupSensorControlTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::outletGroupSensorControlTable'],
    ['serverPowerControlTable', 'serverPowerControlTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::serverPowerControlTable'],
    ['reliabilityDataTableSequenceNumber', 'reliabilityDataTableSequenceNumber', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::reliabilityDataTableSequenceNumber'],
    ['reliabilityDataTable', 'reliabilityDataTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::reliabilityDataTable'],
    ['reliabilityErrorLogTable', 'reliabilityErrorLogTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::reliabilityErrorLogTable'],
    ['hwFailureTable', 'hwFailureTable', 'CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::hwFailureTable'],
  ]);
  #foreach (@tables) {
  #  printf "%-50s %04d\n", $_, exists $self->{$_} ? scalar(@{$self->{$_}}) : 0;
  #}
  $self->merge_tables('externalSensorConfigurationTable', 'externalSensorMeasurementsTable');
  foreach (@{$self->{externalSensorConfigurationTable}}) {
    $_->finish_after_merge();
  }
  # PDU2-MIB::unitSensorMeasurementsTable ist zwar leer, also mit 1 element
  # aber dieses hat PDU2-MIB::measurementsUnitSensorState.1.46
  # alle PDU2-MIB::measurementsUnitSensorValue.1.46 minnmax etc sind 0
  
  # unitSensorConfigurationEntry externalSensorTypeDefaultThresholdsEntry unitSensorMeasurementsEntry unitSensorControlEntry 
}

sub check {
  my $self = shift;
  foreach (@{$self->{externalSensorConfigurationTable}}) {
    $_->check();
  }
}

package CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::externalSensorConfigurationTable;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish_after_merge {
  my $self = shift;
  $self->{label} = $self->{externalSensorName} =~ s/[^a-zA-Z0-9]/_/gr;
  if ($self->{externalSensorUnits}) {
    my $divisor = $self->{externalSensorDecimalDigits} ? 10**$self->{externalSensorDecimalDigits} : 1;
    foreach (qw(externalSensorLowerCriticalThreshold externalSensorLowerWarningThreshold
        externalSensorUpperCriticalThreshold externalSensorUpperWarningThreshold
        measurementsExternalSensorMaxValue
        measurementsExternalSensorMinValue
        measurementsExternalSensorValue)) {
      $self->{$_} /= $divisor if $self->{$_};
    }
  }
  if ($self->{externalSensorUnits}) {
    $self->{externalSensorUnits} = "C" if $self->{externalSensorUnits} eq "degreeC";
    $self->{externalSensorUnits} = "F" if $self->{externalSensorUnits} eq "degreeF";
    $self->{externalSensorUnits} = "%" if $self->{externalSensorUnits} eq "percent";
  }
  bless $self, "CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::externalSensorConfigurationTable::".$self->{externalSensorType} if $self->{externalSensorType} eq "onOff";
  bless $self, "CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::externalSensorConfigurationTable::".$self->{externalSensorType} if $self->{externalSensorType} eq "distance";
return;
  bless $self, "CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::externalSensorConfigurationTable::".$self->{externalSensorType} if $self->{externalSensorType} eq "temperature";
  bless $self, "CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::externalSensorConfigurationTable::".$self->{externalSensorType} if $self->{externalSensorType} eq "humidity";
}

sub check {
  my $self = shift;
  $self->finish();
  $self->add_info(sprintf "%s sensor %s shows %.2f%s and is %s",
      $self->{externalSensorType},
      $self->{externalSensorName},
      $self->{measurementsExternalSensorValue},
      $self->{externalSensorUnits},
      $self->{measurementsExternalSensorState});
  $self->add_message($self->state_to_level());
  $self->add_sensor_perfdata();
}

sub state_to_level {
  my $self = shift;
  my $nueric_with_upper_lower_warning_critical_thresholds = {
      unavailable => 3,
      belowLowerCritical => 2,
      belowLowerWarning => 1,
      normal => 0,
      aboveUpperWarning => 1,
      aboveUpperCritical => 2,
  };
  my $normal_alarmed = {
      unavailable => 3,
      normal => 0,
      alarmed => 2,
  };
  my $level = {
    'rmsCurrent' => $nueric_with_upper_lower_warning_critical_thresholds,
    'peakCurrent' => $nueric_with_upper_lower_warning_critical_thresholds,
    'unbalancedCurrent' => $nueric_with_upper_lower_warning_critical_thresholds,
    'rmsVoltage' => $nueric_with_upper_lower_warning_critical_thresholds,
    'activePower' => $nueric_with_upper_lower_warning_critical_thresholds,
    'apparentPower' => $nueric_with_upper_lower_warning_critical_thresholds,
    'powerFactor' => $nueric_with_upper_lower_warning_critical_thresholds,
    'activeEnergy' => $nueric_with_upper_lower_warning_critical_thresholds,
    'apparentEnergy' => $nueric_with_upper_lower_warning_critical_thresholds,
    'temperature' => $nueric_with_upper_lower_warning_critical_thresholds,
    'humidity' => $nueric_with_upper_lower_warning_critical_thresholds,
    'airFlow' => $nueric_with_upper_lower_warning_critical_thresholds,
    'airPressure' => $nueric_with_upper_lower_warning_critical_thresholds,
    'onOff' => {
        'unavailable' => 3,
        'on' => 0,
        'off' => 2,
    },
    'trip' => {
        'unavailable' => 3,
        'open' => 2,
        'closed' => 0,
    },
    'vibration' => $nueric_with_upper_lower_warning_critical_thresholds,
    'waterDetection' => $normal_alarmed,
    'smokeDetection' => $normal_alarmed,
    'binary' => $normal_alarmed,
    'contact' => $normal_alarmed,
    'fanSpeed' => $nueric_with_upper_lower_warning_critical_thresholds,
    'surgeProtectorStatus' => {
        'unavailable' => 3,
        'ok' => 0,
        'fault' => 2,
    },
    'frequency' => $nueric_with_upper_lower_warning_critical_thresholds,
    'phaseAngle' => $nueric_with_upper_lower_warning_critical_thresholds,
    'rmsVoltageLN' => $nueric_with_upper_lower_warning_critical_thresholds,
    'residualCurrent' => $nueric_with_upper_lower_warning_critical_thresholds,
    'rcmState' => {
        'unavailable' => 3,
        'normal' => 0,
        'warning' => 1,
        'critical' => 2,
        'selfTest' => 0,
        'fail' => 2,
    },
    'absoluteHumidity' => $nueric_with_upper_lower_warning_critical_thresholds,
    'reactivePower' => $nueric_with_upper_lower_warning_critical_thresholds,
    'other' => {
        'unavailable' => 3,
    },
    'none' => {
        'unavailable' => 3,
    },
    'powerQuality' => {
        'unavailable' => 3,
        'normal' => 0,
        'warning' => 1,
        'critical' => 2,
    },
    'overloadStatus' => {
        'unavailable' => 3,
        'ok' => 0,
        'fault' => 2,
    },
    'overheatStatus' => {
        'unavailable' => 3,
        'ok' => 0,
        'fault' => 2,
    },
    'displacementPowerFactor' => $nueric_with_upper_lower_warning_critical_thresholds,
    'residualDcCurrent' => $nueric_with_upper_lower_warning_critical_thresholds,
    'fanStatus' => {
        'unavailable' => 3,
        'ok' => 0,
        'fault' => 2,
    },
    'inletPhaseSyncAngle' => $nueric_with_upper_lower_warning_critical_thresholds,
    'inletPhaseSync' => {
        'unavailable' => 3,
        'inSync' => 0,
        'outOfSync' => 2,
    },
    'operatingState' => {
        'unavailable' => 3,
        'normal' => 0,
        'standby' => 0,
        'nonRedundant' => 1,
        'off' => 2,
    },
    'activeInlet' => {
        'unavailable' => 3,
        'one' => 1,
        'two' => 0,
        'off' => 2,
    },
    'illuminance' => $nueric_with_upper_lower_warning_critical_thresholds,
    'doorContact' => $normal_alarmed,
    'tamperDetection' => $normal_alarmed,
    'motionDetection' => $normal_alarmed,
    'i1smpsStatus' => {
        'unavailable' => 3,
        'ok' => 0,
        'fault' => 2,
    },
    'i2smpsStatus' => {
        'unavailable' => 3,
        'ok' => 0,
        'fault' => 2,
    },
    'switchStatus' => {
        'unavailable' => 3,
        'ok' => 0,
        'i1OpenFault' => 2,
        'i1ShortFault' => 2,
        'i2OpenFault' => 2,
        'i2ShortFault' => 2,
    },
    'doorLockState' => {
        'unavailable' => 3,
        'open' => 2,
        'closed' => 0,
    },
    'doorHandleLock' => {
        'unavailable' => 3,
        'open' => 2,
        'closed' => 0,
    },
    'crestFactor' => $nueric_with_upper_lower_warning_critical_thresholds,
    'length' => $nueric_with_upper_lower_warning_critical_thresholds,
    'distance' => $nueric_with_upper_lower_warning_critical_thresholds,
    'activePowerDemand' => $nueric_with_upper_lower_warning_critical_thresholds,
    'residualAcCurrent' => $nueric_with_upper_lower_warning_critical_thresholds,
    'particleDensity' => $nueric_with_upper_lower_warning_critical_thresholds,
    'voltageThd' => $nueric_with_upper_lower_warning_critical_thresholds,
    'currentThd' => $nueric_with_upper_lower_warning_critical_thresholds,
    'inrushCurrent' => $nueric_with_upper_lower_warning_critical_thresholds,
    'unbalancedVoltage' => $nueric_with_upper_lower_warning_critical_thresholds,
    'unbalancedLineLineCurrent' => $nueric_with_upper_lower_warning_critical_thresholds,
    'unbalancedLineLineVoltage' => $nueric_with_upper_lower_warning_critical_thresholds,
  };
  my $my_levels = {};
  if (exists $level->{$self->{externalSensorType}}) {
    $my_levels = $level->{$self->{externalSensorType}};
    if ($self->{externalSensorType} eq "onOff" && exists $level->{$self->{externalOnOffSensorSubtype}}) {
      $my_levels = $level->{$self->{externalOnOffSensorSubtype}};
    }
  }
  if (exists $my_levels->{$self->{measurementsExternalSensorState}}) {
    return $my_levels->{$self->{measurementsExternalSensorState}};
  } else {
    return 3;
  }
}

sub bin_and {
  my ($self, $bin1, $bin2) = @_;
  return (($bin1 & $bin2) ne "00000000") ? 1 : 0;
}

sub add_sensor_perfdata {
  my $self = shift;
  return if $self->{externalSensorUnits} eq "none";
  my $externalSensorEnabledThresholds = unpack("B*", $self->{externalSensorEnabledThresholds});
  my $warning = "";
  my $critical = "";
  $critical .= $self->{externalSensorLowerCriticalThreshold}.":"
      if $self->bin_and($externalSensorEnabledThresholds, "10000000");
  $warning .= $self->{externalSensorLowerWarningThreshold}.":"
      if $self->bin_and($externalSensorEnabledThresholds, "01000000");
  $warning .= $self->{externalSensorUpperWarningThreshold}
      if $self->bin_and($externalSensorEnabledThresholds, "00100000");
  $critical .= $self->{externalSensorUpperCriticalThreshold}
      if $self->bin_and($externalSensorEnabledThresholds, "00010000");
  # externalSensorEnabledThresholds OBJECT-TYPE
  #    SYNTAX     BITS { lowerCritical(0),
  #                      lowerWarning(1),
  #                      upperWarning(2),
  #                      upperCritical(3) }
  # 0=links....3=rechts. lc und uc = 0x09
  $self->{externalSensorEnabledThresholdsHuman} = $externalSensorEnabledThresholds;
  if ($self->{externalSensorUnits} eq "percent" || $self->{externalSensorUnits} eq "%") {
    $self->add_perfdata(label => $self->{label},
        value => $self->{measurementsExternalSensorValue},
        warning => $warning,
        critical => $critical,
        uom => "%",
    );
  } else {
    $self->add_perfdata(label => $self->{label},
        value => $self->{measurementsExternalSensorValue},
        warning => $warning,
        critical => $critical,
    );
  }
}


package CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::externalSensorConfigurationTable::onOff;
our @ISA = qw(CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::externalSensorConfigurationTable);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf "%s %s %s is %s",
      $self->{externalSensorType},
      $self->{externalOnOffSensorSubtype},
      $self->{externalSensorName},
      $self->{measurementsExternalSensorState});
  $self->add_message($self->state_to_level());
}

package CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::externalSensorConfigurationTable::temperature;
our @ISA = qw(CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::externalSensorConfigurationTable);
use strict;

sub finish {
  my $self = shift;
}


sub check {
  my $self = shift;
  $self->finish();
  $self->add_info(sprintf "%s sensor %s shows %.2f%s and is %s",
      $self->{externalSensorType},
      $self->{externalSensorName},
      $self->{measurementsExternalSensorValue},
      $self->{externalSensorUnits},
      $self->{measurementsExternalSensorState});
  $self->add_message($self->state_to_level());
  $self->add_sensor_perfdata();
}

package CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::externalSensorConfigurationTable::distance;
our @ISA = qw(CheckWutHealth::Raritan::PDU2::Component::SensorSubsystem::externalSensorConfigurationTable);
use strict;

sub check {
  my $self = shift;
  if ($self->{measurementsExternalSensorState} eq "unavailable") {
    # externalSensorName: WSB-Test_Rack2-Leckage_Detector_Distance 1
    # externalSensorType: distance
    # externalSensorUnits: meters
    # measurementsExternalSensorState: unavailable
    # measurementsExternalSensorValue: 0
    # ist zu sehen in Zusammenarbeit mit
    # externalSensorName: WSB-Test_Rack2-Leckage-Detector_Length 1
    # externalSensorType: length
    # externalSensorUnits: meters
    # measurementsExternalSensorState: normal
    # measurementsExternalSensorValue: 6.9
    # und
    # externalOnOffSensorSubtype: waterDetection
    # externalSensorName: WSB-Test_Rack2-Leckage-Detector_1_hinten
    # externalSensorType: onOff
    # externalSensorUnits: none
    # measurementsExternalSensorState: normal
    # measurementsExternalSensorValue: 0
    #
    # Da liegt ein Kabel aus, welches an etlichen Stellen Sensoren hat, die Wasser melden. Das Kabel hat
    # eine Laenge (WSB-Test_Rack2-Leckage-Detector_Length 1) und wenn ein Leck entdeckt wird,
    # dann geht der onOff WSB-Test_Rack2-Leckage-Detector_1_hinten in einen Alarmstatus.
    # Zusaetzlich beinhaltet Sensor WSB-Test_Rack2-Leckage_Detector_Distance 1 die Entfernung des meldenden
    # Sensorpunktes zum Anschlusspunkt des Kabels.
    #
    # distance unavailable = es gibt kein Leck und somit keine Distanz
    $self->add_ok();
  } else {
    $self->add_info(sprintf "%s %s %s is %s",
        $self->{externalSensorType},
        $self->{externalOnOffSensorSubtype},
        $self->{externalSensorName},
        $self->{measurementsExternalSensorState});
    $self->add_message($self->state_to_level());
  }
}



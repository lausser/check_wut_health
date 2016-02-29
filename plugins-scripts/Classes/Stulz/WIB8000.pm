package Classes::Stulz::WIB8000;
our @ISA = qw(Classes::Stulz);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_sensor_subsystem("Classes::Stulz::WIB8000::Component::SensorSubsystem");
  } else {
    $self->no_such_mode();
  }
}

package Classes::Stulz::WIB8000::Component::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_objects("STULZ-WIB8000", qw(wibUnitname wibTempUnit
      wibFirmware wibsettingAuxInLow wibsettingAuxInHigh
  ));
  foreach (qw(wibIndexTable alarmMailTable unitTable logUnitTable infoValTemperatureTable infoValHumidityTable infoValPressureTable infoValWaterTable infoValRefrigerantTable infoValAEcontrolTable infoValMiscellaneousTable infoModulefunctionsComponenTable infoCoolingTable infoCompressorTable infoValvesTable infoSuctionvalvesTable infoGECWValvesTable infoHGBPsTable infoEEV1Table infoEEV2Table infoDrycoolerTable infoPumpsTable infoLouverTable infoCondesorfanTable infoIccTable infoMovableCoilTable infoHeatingTable infoEHeatingTable infoHumidityTable infoAirTable infoAirAETable infoSensorIORawdataTable infoZoneSequencingTable infoStatRuntimesTable infoStatFunctionsTable infoStatComponentsTable infoStatCompressorsTable infoStatPumpsTable infoStatEHeatingsTable infoStatDrycoolersTable infoStatMaintenanceTable infoSystemTable opValuesControlTable opCtrlAirTable opCtrlTemperatureTable opCtrlHumidityTable opCtrlPressureTable opCtrlWaterTable opCtrlRefrigerantTable opCtrlAEoperationTable opCtrlEcocoolTable opCompressorTable opCompressor1Table opCompressor2Table opCompressor3Table opCompressor4Table opCompressor5Table opCompressor6Table opSuctionValveTable opGECWValveTable opEEV1Table opEEV2Table opChillerFreecoolingValveTable opDrycooler1Table opDrycooler2Table opDrycooler3Table opDrycooler4Table opPump1Table opPump2Table opPump3Table opPump4Table opEcoLouverTable opCondensorfanTable opEHeat1Table opEHeat2Table opEHeat3Table opHotgasHeatTable opHwrValveTable opHumidifierTable opDehumidificationTable opFanTable opAirLouverTable opAEfilterTable opSensor1Table opSensor2Table opSensor3Table opSensor4Table opSensor5Table opSensor6Table opSensor7Table opSensor8Table opSensor9Table opSensor10Table opSensor11Table opSensor12Table opSensor13Table opSensor14Table opSensor15Table opSensor16Table opSensor17Table opSensor18Table opSensor19Table opSensor20Table opSensor21Table opExtAlarms1Table opExtAlarms2Table opExtAlarms3Table opExtAlarms4Table opExtAlarms5Table opExtAlarms6Table opExtAlarms7Table opExtAlarms8Table opExtAlarms9Table opExtAlarms10Table opUnitalarmsTable confCtrlAirTable confCtrlTemperatureTable confCtrlHumidityTable confCtrlWaterTable confCtrlRefrigLPmanagementTable confCtrlRefrigHPmanagementTable confCtrlMiscParametersTable confCtrlGEOperationTable confCtrlChillerFreecoolingTable confCtrlAEoperationTable confCtrlecocoolTable confCompressor1Table confCompressor2Table confCompressor3Table confCompressor4Table confCompressor5Table confCompressor6Table confSuctionValvesTable confGECWValveTable confGECWValve1Table confGECWValve2Table confGValveTable confHGBP1Table confHGBP2Table confEEV1Table confEEV2Table confDrycooler1Table confDrycooler2Table confDrycooler3Table confDrycooler4Table confPump1Table confPump2Table confPump3Table confPump4Table confEcoLouverTable confFreshairLouverTable confAntifreezeLouverTable confCirculationLouverTable confExitLouverTable confCondensorfanTable confIccTable confMovableCoilTable confEHeat1Table confEHeat2Table confEHeat3Table confHotgasHeatTable confHwrValveTable confHumidifierTable confDehumidificationTable confFanGeneralTable confFanAlarmTable confFanSpecialModesTable confAirLouverTable confAEfilterTable confSensor1Table confSensor2Table confSensor3Table confSensor4Table confSensor5Table confSensor6Table confSensor7Table confSensor8Table confSensor9Table confSensor10Table confSensor11Table confSensor12Table confSensor13Table confSensor14Table confSensor15Table confSensor16Table confSensor17Table confSensor18Table confSensor19Table confSensor20Table confSensor21Table confExtAlarms1Table confExtAlarms2Table confExtAlarms3Table confExtAlarms4Table confExtAlarms5Table confExtAlarms6Table confExtAlarms7Table confExtAlarms8Table confExtAlarms9Table confExtAlarms10Table confUnitalarmsTable confDigitalPortsTable confValueOutput1Table confValueOutput2Table confValueOutput3Table confValueOutput4Table confUPSOperationTable confManCompressorsTable confManSuctionValveTable confManSuctionValve2Table confManGECWValveTable confManGValveTable confManHGBP1Table confManHGBP2Table confManEEV1Table confManEEV2Table confManDrycooler1Table confManDrycooler2Table confManDrycooler3Table confManDrycooler4Table confManPump1Table confManPump2Table confManPump3Table confManPump4Table confManLouverEcoTable confManLouverFreshAirTable confManLouverAntiFreezeTable confManLouvercirculationTable confManLouverExitTable confManConFanTable confManEHeat1Table confManEHeat2Table confManEHeat3Table confManHotgasHeatTable confManHwrValveTable confManHumidifierTable confManDehumidificationTable confManFanTable confManAirLouverTable confManSensor1Table confManSensor2Table confManSensor3Table confManSensor4Table confManSensor5Table confManSensor6Table confManSensor7Table confManSensor8Table confManSensor9Table confManSensor10Table confManSensor11Table confManSensor12Table confManSensor13Table confManSensor14Table confManSensor15Table confManSensor16Table confManSensor17Table confManSensor18Table confManSensor19Table confManSensor20Table confManSensor21Table confManExtAlarms1Table confManExtAlarms2Table confManExtAlarms3Table confManExtAlarms4Table confManExtAlarms5Table confManExtAlarms6Table confManExtAlarms7Table confManExtAlarms8Table confManExtAlarms9Table confManExtAlarms10Table confZoneSequencingTable confCondFanTable confMaintenanceTable confInterfacesTable stateTable overviewTable unitstateTable unitviewTable unitAlarmsTable)) {
  $self->get_snmp_tables("STULZ-WIB8000", [
      [$_, $_, "Monitoring::GLPlugin::TableItem"]
  ]);
  }
  $self->xxget_snmp_tables("Stulz-WIB8000", [
      ["alarmmails", "alarmMailTable", "Monitoring::GLPlugin::TableItem"],
      ["units", "unitTable", "Monitoring::GLPlugin::TableItem"],
      ["logunits", "logUnitTable", "Monitoring::GLPlugin::TableItem"],
      ["temps", "infoValTemperatureTable", "Monitoring::GLPlugin::TableItem"],
      ["humidities", "infoValHumidityTable", "Monitoring::GLPlugin::TableItem"],
      ["pressures", "infoValPressureTable", "Monitoring::GLPlugin::TableItem"],
      ["waters", "infoValWaterTable", "Monitoring::GLPlugin::TableItem"],
      ["refrigerants", "infoValRefrigerantTable", "Monitoring::GLPlugin::TableItem"],
      ["aecontrols", "infoValAEcontrolTable", "Monitoring::GLPlugin::TableItem"],
      ["miscs", "infoValMiscellaneousTable", "Monitoring::GLPlugin::TableItem"],
      ["modulefuncs", "infoModulefunctionsComponenTable", "Monitoring::GLPlugin::TableItem"],
      ["coolings", "infoCoolingTable", "Monitoring::GLPlugin::TableItem"],
      ["compressors", "infoCompressorTable", "Monitoring::GLPlugin::TableItem"],
      ["valves", "infoValvesTable", "Monitoring::GLPlugin::TableItem"],
      ["suctionvalves", "infoSuctionvalvesTable", "Monitoring::GLPlugin::TableItem"],
      ["waters", "infoValWaterTable", "Monitoring::GLPlugin::TableItem"],
  ]);
}



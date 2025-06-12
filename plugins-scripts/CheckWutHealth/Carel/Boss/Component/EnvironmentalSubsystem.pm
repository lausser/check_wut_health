package CheckWutHealth::Carel::Boss::Component::EnvironmentalSubsystem;
use strict;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my $self = shift;
  # aus liebert-pdx-and-liebert-pcw-v1a-application-monitoring-user-guide-installer-user-guide-for-liebe.txt (pdf2txt)
  # und MIBS/SNMP-AGENT-MIB-20250225135517.mib zusammengefuehrt
  # (merge mit SNMP-AGENT-MIB-liebert-pdx-and-liebert-pcw-v1a.py)
  # Kein Oendant in der MIB gefunden fuer:
  # ['117', 'Al_MasterNotAvail', 'Master Unit Not Available', 'Warning']
  $self->{alarmoids} = {
      'l9d1AlretainActive' => {
          'num' => '1',
          'name' => 'Al_retain.Active',
          'desc' => 'Retain Memory Error',
          'level' => 'Alarm',
       },
      'l9d1AlErrretainwriteActive' => {
          'num' => '2',
          'name' => 'Al_Err_retain_write.Active',
          'desc' => 'Too Much Retain Writing',
          'level' => 'Alarm',
       },
      'l9d1AlHeaterHiTActive' => {
          'num' => '3',
          'name' => 'Al_HeaterHiT.Active',
          'desc' => 'Heater High Temperature Lockout',
          'level' => 'Warning',
       },
      'l9d1AlHiRetAirTempActive' => {
          'num' => '4',
          'name' => 'Al_HiRetAirTemp.Active',
          'desc' => 'High Return Temperature',
          'level' => 'Warning',
       },
      'l9d1AlHiSupAirTempActive' => {
          'num' => '5',
          'name' => 'Al_HiSupAirTemp.Active',
          'desc' => 'High Supply Temperature',
          'level' => 'Warning',
       },
      'l9d1AlHiRemAirTempActive' => {
          'num' => '6',
          'name' => 'Al_HiRemAirTemp.Active',
          'desc' => 'High Remote Temperature',
          'level' => 'Warning',
       },
      'l9d1AlLowRetAirTempActive' => {
          'num' => '7',
          'name' => 'Al_LowRetAirTemp.Active',
          'desc' => 'Low Return Temperature',
          'level' => 'Warning',
       },
      'l9d1AlLowSupAirTempActive' => {
          'num' => '8',
          'name' => 'Al_LowSupAirTemp.Active',
          'desc' => 'Low Supply Temperature',
          'level' => 'Warning',
       },
      'l9d1AlLowRemAirTempActive' => {
          'num' => '9',
          'name' => 'Al_LowRemAirTemp.Active',
          'desc' => 'Low Remote Temperature',
          'level' => 'Warning',
       },
      'l9d1AlEvpFanActive' => {
          'num' => '10',
          'name' => 'Al_EvpFan.Active',
          'desc' => 'One (or more) Evaporator Fan in',
          'level' => 'Alarm',
       },
      'l9d1AlEvpFanOfflineActive' => {
          'num' => '11',
          'name' => 'Al_EvpFanOffline.Active',
          'desc' => 'One (or more) Evaporator Fan Offline',
          'level' => 'Alarm',
       },
      'l9d1AlAllEvpFansOfflineActive' => {
          'num' => '12',
          'name' => 'Al_AllEvpFansOffline.Active',
          'desc' => 'All Evaporator Fans Offline',
          'level' => 'Alarm',
       },
      'l9d1AlGenFanActive' => {
          'num' => '13',
          'name' => 'Al_GenFan.Active',
          'desc' => 'Loss of Air Flow',
          'level' => 'Alarm',
       },
      'l9d1AlBmsOfflineActive' => {
          'num' => '15',
          'name' => 'Al_BmsOffline.Active',
          'desc' => 'BMS Offline',
          'level' => 'Warning',
       },
      'l9d1AlLPCirc1Active' => {
          'num' => '16',
          'name' => 'Al_LPCirc1.Active',
          'desc' => 'Low Pressure Circuit 1',
          'level' => 'Alarm',
       },
      'l9d1AlLPCirc2Active' => {
          'num' => '17',
          'name' => 'Al_LPCirc2.Active',
          'desc' => 'Low Pressure Circuit 2',
          'level' => 'Alarm',
       },
      'l9d1AlHPCirc1Active' => {
          'num' => '18',
          'name' => 'Al_HPCirc1.Active',
          'desc' => 'High Pressure Circuit 1',
          'level' => 'Alarm',
       },
      'l9d1AlHPCirc2Active' => {
          'num' => '19',
          'name' => 'Al_HPCirc2.Active',
          'desc' => 'High Pressure Circuit 2',
          'level' => 'Alarm',
       },
      'l9d1AlSoftHPCirc1Active' => {
          'num' => '20',
          'name' => 'Al_SoftHPCirc1.Active',
          'desc' => 'Soft High Pressure Circuit 1',
          'level' => 'Warning',
       },
      'l9d1AlSoftHPCirc2Active' => {
          'num' => '21',
          'name' => 'Al_SoftHPCirc2.Active',
          'desc' => 'Soft High Pressure Circuit 2',
          'level' => 'Warning',
       },
      'l9d1AlThComp1Circ1Active' => {
          'num' => '22',
          'name' => 'Al_ThComp1Circ1.Active',
          'desc' => 'Thermal Protection Compressor 1 Circuit 1',
          'level' => 'Alarm',
       },
      'l9d1AlThComp2Circ1Active' => {
          'num' => '23',
          'name' => 'Al_ThComp2Circ1.Active',
          'desc' => 'Thermal Protection Compressor 2 Circuit 1',
          'level' => 'Alarm',
       },
      'l9d1AlThComp1Circ2Active' => {
          'num' => '24',
          'name' => 'Al_ThComp1Circ2.Active',
          'desc' => 'Thermal Protection Compressor 1 Circuit 2',
          'level' => 'Alarm',
       },
      'l9d1AlThComp2Circ2Active' => {
          'num' => '25',
          'name' => 'Al_ThComp2Circ2.Active',
          'desc' => 'Thermal Protection Compressor 2 Circuit 2',
          'level' => 'Alarm',
       },
      'l9d1AlLowSHC1Active' => {
          'num' => '26',
          'name' => 'Al_LowSH_C1.Active',
          'desc' => 'Low Suction SuperHeat Circuit 1',
          'level' => 'Alarm',
       },
      'l9d1AlLowSHC2Active' => {
          'num' => '27',
          'name' => 'Al_LowSH_C2.Active',
          'desc' => 'Low Suction SuperHeat Circuit 2',
          'level' => 'Alarm',
       },
      'l9d1AlHiSHCirc1Active' => {
          'num' => '28',
          'name' => 'Al_HiSHCirc1',
          'desc' => 'High Suction SuperHeat Circuit 1',
          'level' => 'Alarm',
       },
      'l9d1AlHiSHCirc2Active' => {
          'num' => '29',
          'name' => 'Al_HiSHCirc2',
          'desc' => 'High Suction SuperHeat Circuit 2',
          'level' => 'Alarm',
       },
      'l9d1AlRetPrbActive' => {
          'num' => '30',
          'name' => 'Al_RetPrb.Active',
          'desc' => 'Return Sensor Failure (Cumulative)',
          'level' => 'Alarm',
       },
      'l9d1AlSupPrbActive' => {
          'num' => '31',
          'name' => 'Al_SupPrb.Active',
          'desc' => 'Supply Sensor Failure (Cumulative)',
          'level' => 'Alarm',
       },
      'l9d1AlRemPrbActive' => {
          'num' => '32',
          'name' => 'Al_RemPrb.Active',
          'desc' => 'Remote Sensor Failure (Cumulative)',
          'level' => 'Alarm',
       },
      'l9d1AlAmbPrbActive' => {
          'num' => '33',
          'name' => 'Al_AmbPrb.Active',
          'desc' => 'Outdoor Sensor Failure',
          'level' => 'Alarm',
       },
      'l9d1AlLPPrb1Active' => {
          'num' => '34',
          'name' => 'Al_LPPrb1.Active',
          'desc' => 'Suction Pressure Sensor Circuit 1 Failure',
          'level' => 'Alarm',
       },
      'l9d1AlLPPrb2Active' => {
          'num' => '35',
          'name' => 'Al_LPPrb2.Active',
          'desc' => 'Suction Pressure Sensor Circuit 2 Failure',
          'level' => 'Alarm',
       },
      'l9d1AlHPPrb1Active' => {
          'num' => '36',
          'name' => 'Al_HPPrb1.Active',
          'desc' => 'Discharge Pressure Sensor Circuit 1 Failure',
          'level' => 'Alarm',
       },
      'l9d1AlHPPrb2Active' => {
          'num' => '37',
          'name' => 'Al_HPPrb2.Active',
          'desc' => 'Discharge Pressure Sensor Circuit 2 Failure',
          'level' => 'Alarm',
       },
      'l9d1AlSuctTPrb1Active' => {
          'num' => '38',
          'name' => 'Al_SuctTPrb1.Active',
          'desc' => 'Suction Temperature Sensor Circuit 1 Failure',
          'level' => 'Alarm',
       },
      'l9d1AlSuctTPrb2Active' => {
          'num' => '39',
          'name' => 'Al_SuctTPrb2.Active',
          'desc' => 'Suction Temperature Sensor Circuit 2 Failure',
          'level' => 'Alarm',
       },
      'l9d1AlDscgPrb1Active' => {
          'num' => '40',
          'name' => 'Al_DscgPrb1.Active',
          'desc' => 'Discharge Temperature Sensor Circuit 1 Failure',
          'level' => 'Alarm',
       },
      'l9d1AlDscgPrb2Active' => {
          'num' => '41',
          'name' => 'Al_DscgPrb2.Active',
          'desc' => 'Discharge Temperature Sensor Circuit 2 Failure',
          'level' => 'Alarm',
       },
      'l9d1AlAlarmEvtActive' => {
          'num' => '42',
          'name' => 'Al_AlarmEvt.Active',
          'desc' => 'Configurable',
          'level' => 'Alarm',
       },
      'l9d1AlCustIn1Active' => {
          'num' => '43',
          'name' => 'Al_CustIn1.Active',
          'desc' => 'C-Input 1',
          'level' => 'Alarm',
       },
      'l9d1AlCustIn2Active' => {
          'num' => '44',
          'name' => 'Al_CustIn2.Active',
          'desc' => 'C-Input 2',
          'level' => 'Alarm',
       },
      'l9d1AlCustIn3Active' => {
          'num' => '45',
          'name' => 'Al_CustIn3.Active',
          'desc' => 'C-Input 3',
          'level' => 'Alarm',
       },
      'l9d1AlCustIn4Active' => {
          'num' => '46',
          'name' => 'Al_CustIn4.Active',
          'desc' => 'C-Input 4',
          'level' => 'Alarm',
       },
      'l9d1AlCmpLockOutPDActive' => {
          'num' => '47',
          'name' => 'Al_CmpLockOutPD.Active',
          'desc' => 'Compressor Lockout (with PumpDown)',
          'level' => 'Message',
       },
      'l9d1AlCmpLockOutActive' => {
          'num' => '48',
          'name' => 'Al_CmpLockOut.Active',
          'desc' => 'Compressor Lockout',
          'level' => 'Message',
       },
      'l9d1AlCnd1FailEvtActive' => {
          'num' => '49',
          'name' => 'Al_Cnd1FailEvt.Active',
          'desc' => 'Condenser 1 Failure',
          'level' => 'Warning',
       },
      'l9d1AlCnd2FailEvtActive' => {
          'num' => '50',
          'name' => 'Al_Cnd2FailEvt.Active',
          'desc' => 'Condenser 2 Failure',
          'level' => 'Warning',
       },
      'l9d1AlCndPmpEvtActive' => {
          'num' => '51',
          'name' => 'Al_CndPmpEvt.Active',
          'desc' => 'Condensing Pump',
          'level' => 'Alarm',
       },
      'l9d1AlCndPmpEvtActive' => {
          'num' => '52',
          'name' => 'Al_CndPmpLCEvt.Active',
          'desc' => 'Condensing Pump',
          'level' => 'Alarm',
       },
      'l9d1AlCndPmpEvtActive' => {
          'num' => '53',
          'name' => 'Al_CndPmpSDEvt.Active',
          'desc' => 'Condensing Pump',
          'level' => 'Alarm',
       },
      'l9d1AlFireActive' => {
          'num' => '54',
          'name' => 'Al_Fire.Active',
          'desc' => 'Fire',
          'level' => 'Alarm',
       },
      'l9d1ALFlowALSDEvtActive' => {
          'num' => '55',
          'name' => 'Al_FlowAlrmEvt.Active',
          'desc' => 'Loss of Flow',
          'level' => 'Warning',
       },
      'l9d1ALFlowALSDEvtActive' => {
          'num' => '56',
          'name' => 'Al_FlowALLCEvt.Active',
          'desc' => 'Loss of Flow',
          'level' => 'Warning',
       },
      'l9d1ALFlowALSDEvtActive' => {
          'num' => '57',
          'name' => 'AL_FlowALSDEvt.Active',
          'desc' => 'Loss of Flow',
          'level' => 'Alarm',
       },
      'l9d1AlHeaterAlrmEvtActive' => {
          'num' => '58',
          'name' => 'Al_HeaterAlrmEvt.Active',
          'desc' => 'Heater',
          'level' => 'Alarm',
       },
      'l9d1AlHighCWT1EvtActive' => {
          'num' => '59',
          'name' => 'Al_HighCWT1Evt.Active',
          'desc' => 'High CW1 Temperature',
          'level' => 'Warning',
       },
      'l9d1AlHighCWT2EvtActive' => {
          'num' => '60',
          'name' => 'Al_HighCWT2Evt.Active',
          'desc' => 'High CW2 Temperature',
          'level' => 'Warning',
       },
      'l9d1AlHumProblemEvtActive' => {
          'num' => '61',
          'name' => 'Al_HumProblemEvt.Active',
          'desc' => 'Humidifier Problem',
          'level' => 'Warning',
       },
      'l9d1AlAlarmEvtActive' => {
          'num' => '62',
          'name' => 'Al_WarningEvt.Active',
          'desc' => 'Configurable',
          'level' => 'Warning',
       },
      'l9d1AlWaterAlrmEvtActive' => {
          'num' => '63',
          'name' => 'Al_WaterAlrmEvt.Active',
          'desc' => 'Water',
          'level' => 'Alarm',
       },
      'l9d1AlNoPowerEvtActive' => {
          'num' => '64',
          'name' => 'Al_NoPowerEvt.Active',
          'desc' => 'No Power',
          'level' => 'Warning',
       },
      'l9d1AlSmokeActive' => {
          'num' => '65',
          'name' => 'Al_Smoke.Active',
          'desc' => 'Smoke',
          'level' => 'Alarm',
       },
      'l9d1CF' => {
          'num' => '66',
          'name' => 'Al_CloggedFilt.Active',
          'desc' => 'Clogged Filter',
          'level' => 'Warning',
       },
      'l9d1AlOutOfWorkingRangeAlActive' => {
          'num' => '67',
          'name' => 'Al_OutOfWorkingRangeAl.Active',
          'desc' => 'Stop Due to High Temp',
          'level' => 'Alarm',
       },
      'l9d1AlOutOfWorkingRangeWaActive' => {
          'num' => '68',
          'name' => 'Al_OutOfWorkingRangeWa.Active',
          'desc' => 'Out Of Working Range',
          'level' => 'Warning',
       },
      'l9d1AlHiRemAirHumActive' => {
          'num' => '69',
          'name' => 'Al_HiRemAirHum.Active',
          'desc' => 'High Remote Humidity',
          'level' => 'Warning',
       },
      'l9d1AlLowRetAirHumActive' => {
          'num' => '70',
          'name' => 'Al_LowRetAirHum.Active',
          'desc' => 'Low Return Humidity',
          'level' => 'Warning',
       },
      'l9d1AlLowRemAirHumActive' => {
          'num' => '71',
          'name' => 'Al_LowRemAirHum.Active',
          'desc' => 'Low Remote Humidity',
          'level' => 'Warning',
       },
      'l9d1AlHiRetAirHumActive' => {
          'num' => '72',
          'name' => 'Al_HiRetAirHum.Active',
          'desc' => 'High Return Humidity',
          'level' => 'Warning',
       },
      'l9d1AlLPCirc1WaActive' => {
          'num' => '73',
          'name' => 'Al_LPCirc1_Wa.Active',
          'desc' => 'Soft Low Pressure Circuit 1 (MTM Only)',
          'level' => 'Warning',
       },
      'l9d1AlForceFCActive' => {
          'num' => '75',
          'name' => 'Al_ForceFC.Active',
          'desc' => 'Force FC',
          'level' => 'Message',
       },
      'l9d1AlRetHumPrbActive' => {
          'num' => '76',
          'name' => 'Al_RetHumPrb.Active',
          'desc' => 'Humidity Return Sensor Failure (MTM Only)',
          'level' => 'Alarm',
       },
      'l9d1AlUCMissingActive' => {
          'num' => '81',
          'name' => 'Al_UCMissing.Active',
          'desc' => 'UC Missing',
          'level' => 'Alarm',
       },
      'l9d1AlFanWHLimitActive' => {
          'num' => '82',
          'name' => 'Al_Fan_WHLimit.Active',
          'desc' => 'Conditioner/Fans Working Hours Exceeded',
          'level' => 'Warning',
       },
      'l9d1AlCWWHLimitActive' => {
          'num' => '83',
          'name' => 'Al_CW_WHLimit.Active',
          'desc' => 'CW1 Valve Working Hours Exceeded',
          'level' => 'Warning',
       },
      'l9d1AlCW2WHLimitActive' => {
          'num' => '84',
          'name' => 'Al_CW2_WHLimit.Active',
          'desc' => 'CW2 Valve Working Hours Exceeded',
          'level' => 'Warning',
       },
      'l9d1AlCmp1C1WHLimitActive' => {
          'num' => '85',
          'name' => 'Al_Cmp1C1_WHLimit.Active',
          'desc' => 'Comp1 Circ1 Working Hours Exceeded',
          'level' => 'Warning',
       },
      'l9d1AlCmp2C1WHLimitActive' => {
          'num' => '86',
          'name' => 'Al_Cmp2C1_WHLimit.Active',
          'desc' => 'Comp2 Circ1 Working Hours Exceeded',
          'level' => 'Warning',
       },
      'l9d1AlCmp1C2WHLimitActive' => {
          'num' => '87',
          'name' => 'Al_Cmp1C2_WHLimit.Active',
          'desc' => 'Comp1 Circ2 Working Hours Exceeded',
          'level' => 'Warning',
       },
      'l9d1AlCmp2C2WHLimitActive' => {
          'num' => '88',
          'name' => 'Al_Cmp2C2_WHLimit.Active',
          'desc' => 'Comp2 Circ2 Working Hours Exceeded',
          'level' => 'Warning',
       },
      'l9d1AlFCWHLimitActive' => {
          'num' => '89',
          'name' => 'Al_FC_WHLimit.Active',
          'desc' => 'FC Working Hours Exceeded',
          'level' => 'Warning',
       },
      'l9d1AlAirEcoWHLimitActive' => {
          'num' => '90',
          'name' => 'Al_AirEco_WHLimit.Active',
          'desc' => 'AirEco Working Hours Exceeded',
          'level' => 'Warning',
       },
      'l9d1AlPREWHLimitActive' => {
          'num' => '91',
          'name' => 'Al_PRE_WHLimit.Active',
          'desc' => 'PRE1 Working Hours Exceeded',
          'level' => 'Warning',
       },
      'l9d1AlPRE2WHLimitActive' => {
          'num' => '92',
          'name' => 'Al_PRE2_WHLimit.Active',
          'desc' => 'PRE2 Working Hours Exceeded',
          'level' => 'Warning',
       },
      'l9d1AlHeaterWHLimitActive' => {
          'num' => '93',
          'name' => 'Al_Heater_WHLimit.Active',
          'desc' => 'El. Heater1 Working Hours Exceeded',
          'level' => 'Warning',
       },
      'l9d1AlHeater2WHLimitActive' => {
          'num' => '94',
          'name' => 'Al_Heater2_WHLimit.Active',
          'desc' => 'El. Heater2 Working Hours Exceeded',
          'level' => 'Warning',
       },
      'l9d1AlHotGWWHLimitActive' => {
          'num' => '95',
          'name' => 'Al_HotGW_WHLimit.Active',
          'desc' => 'Hot Water/Gas Working Hours Exceeded',
          'level' => 'Warning',
       },
      'l9d1AlCondWHLimitActive' => {
          'num' => '96',
          'name' => 'Al_Cond_WHLimit.Active',
          'desc' => 'Condenser Fans1 Working Hours Exceeded',
          'level' => 'Warning',
       },
      'l9d1AlCond2WHLimitActive' => {
          'num' => '97',
          'name' => 'Al_Cond2_WHLimit.Active',
          'desc' => 'Condenser Fans2 Working Hours Exceeded',
          'level' => 'Warning',
       },
      'l9d1AlHumWHLimitActive' => {
          'num' => '98',
          'name' => 'Al_Hum_WHLimit.Active',
          'desc' => 'Humidifier Working Hours Exceeded',
          'level' => 'Warning',
       },
      'l9d1AlDehumWHLimitActive' => {
          'num' => '99',
          'name' => 'Al_Dehum_WHLimit.Active',
          'desc' => 'Dehumidification Working Hours Exceeded',
          'level' => 'Warning',
       },
      'l9d1AlVSDOOECirc1Active' => {
          'num' => '100',
          'name' => 'Al_VSD_OOE_Circ1.Active',
          'desc' => 'VSD Circuit 1 Out of Envelope',
          'level' => 'Alarm',
       },
      'l9d1AlVSDCirc1Active' => {
          'num' => '101',
          'name' => 'Al_VSD_Circ1.Active',
          'desc' => 'VSD Circuit 1 Generic Event',
          'level' => 'Alarm',
       },
      'l9d1AlVSDOfflineCirc1Active' => {
          'num' => '102',
          'name' => 'Al_VSDOffline_Circ1.Active',
          'desc' => 'VSD Circuit 1 Offline',
          'level' => 'Alarm',
       },
      'l9d1AlVSDCirc1Active' => {
          'num' => '103',
          'name' => 'Al_WarnVSD_Circ1.Active',
          'desc' => 'VSD Circuit 1 Generic Event',
          'level' => 'Warning',
       },
      'l9d1AlVSDOOECirc2Active' => {
          'num' => '104',
          'name' => 'Al_VSD_OOE_Circ2.Active',
          'desc' => 'VSD Circuit 2 Out of Envelope',
          'level' => 'Alarm',
       },
      'l9d1AlVSDCirc2Active' => {
          'num' => '105',
          'name' => 'Al_VSD_Circ2.Active',
          'desc' => 'VSD Circuit 2 Generic Event',
          'level' => 'Alarm',
       },
      'l9d1AlVSDOfflineCirc2Active' => {
          'num' => '106',
          'name' => 'Al_VSDOffline_Circ2.Active',
          'desc' => 'VSD Circuit 2 Offline',
          'level' => 'Alarm',
       },
      'l9d1AlVSDCirc2Active' => {
          'num' => '107',
          'name' => 'Al_WarnVSD_Circ2.Active',
          'desc' => 'VSD Circuit 2 Generic Event',
          'level' => 'Warning',
       },
      'l9d1AlNetFailActive' => {
          'num' => '108',
          'name' => 'Al_NetFail.Active',
          'desc' => 'Network Failure',
          'level' => 'Warning',
       },
      'l9d1AlNoConnUnit1Active' => {
          'num' => '109',
          'name' => 'Al_NoConnUnit1.Active',
          'desc' => 'No Connection to Unit 1',
          'level' => 'Warning',
       },
      'l9d1AlCnd1FanActive' => {
          'num' => '111',
          'name' => 'Al_Cnd1Fan.Active',
          'desc' => 'One (or more) Condenser C1 Fan in',
          'level' => 'Alarm',
       },
      'l9d1AlCnd1FanOfflineActive' => {
          'num' => '112',
          'name' => 'Al_Cnd1FanOffline.Active',
          'desc' => 'One (or more) Condenser C1 Fan Offline',
          'level' => 'Warning',
       },
      'l9d1AlAllCnd1FansOfflineActive' => {
          'num' => '113',
          'name' => 'Al_AllCnd1FansOffline.Active',
          'desc' => 'All Condenser C1 Fans Offline',
          'level' => 'Warning',
       },
      'l9d1AlCnd2FanActive' => {
          'num' => '114',
          'name' => 'Al_Cnd2Fan.Active',
          'desc' => 'One (or more) Condenser C2 Fan in',
          'level' => 'Alarm',
       },
      'l9d1AlCnd2FanOfflineActive' => {
          'num' => '115',
          'name' => 'Al_Cnd2FanOffline.Active',
          'desc' => 'One (or more) Condenser C2 Fan Offline',
          'level' => 'Warning',
       },
      'l9d1AlAllCnd2FansOfflineActive' => {
          'num' => '116',
          'name' => 'Al_AllCnd2FansOffline.Active',
          'desc' => 'All Condenser C2 Fans Offline',
          'level' => 'Warning',
       },
      'l9d1AlCPYOfflineActive' => {
          'num' => '118',
          'name' => 'Al_CPY_Offline.Active',
          'desc' => 'HCB Offline',
          'level' => 'Warning',
       },
      'l9d1AlCPYShutDownActive' => {
          'num' => '119',
          'name' => 'Al_CPY_ShutDown.Active',
          'desc' => 'HCB Shut Down',
          'level' => 'Warning',
       },
      'l9d1AlEMeterOfflineActive' => {
          'num' => '120',
          'name' => 'Al_EMeter_Offline.Active',
          'desc' => 'Energy Meter Offline',
          'level' => 'Warning',
       },
      'l9d1AlLOPC1Active' => {
          'num' => '121',
          'name' => 'Al_LOP_C1.Active',
          'desc' => 'Low Operating Pressure Circuit 1',
          'level' => 'Alarm',
       },
      'l9d1AlLOPC2Active' => {
          'num' => '122',
          'name' => 'Al_LOP_C2.Active',
          'desc' => 'Low Operating Pressure Circuit 2',
          'level' => 'Alarm',
       },
      'l9d1AlMOPC2Active' => {
          'num' => '123',
          'name' => 'Al_MOP_C2.Active',
          'desc' => 'Maximum Operating Pressure Circuit 2',
          'level' => 'Alarm',
       },
      'l9d1AlMOPC1Active' => {
          'num' => '124',
          'name' => 'Al_MOP_C1.Active',
          'desc' => 'Maximum Operating Pressure Circuit 1',
          'level' => 'Alarm',
       },
      'l9d1AlEEVGenC1Active' => {
          'num' => '125',
          'name' => 'Al_EEV_Gen_C1.Active',
          'desc' => 'Generic EEV Circuit 1',
          'level' => 'Alarm',
       },
      'l9d1AlEEVGenC2Active' => {
          'num' => '126',
          'name' => 'Al_EEV_Gen_C2.Active',
          'desc' => 'Generic EEV Circuit 2',
          'level' => 'Alarm',
       },
      'l9d1AlEVDOfflineC1Active' => {
          'num' => '127',
          'name' => 'Al_EVD_Offline_C1.Active',
          'desc' => 'EEV Driver Offline Circuit 1',
          'level' => 'Alarm',
       },
      'l9d1AlEVDOfflineC2Active' => {
          'num' => '128',
          'name' => 'Al_EVD_Offline_C2.Active',
          'desc' => 'EEV Driver Offline Circuit 2',
          'level' => 'Alarm',
       },
      'l9d1AlCnd1AllFanActive' => {
          'num' => '129',
          'name' => 'Al_Cnd1AllFan.Active',
          'desc' => 'All Condenser C1 Fans in',
          'level' => 'Alarm',
       },
      'l9d1AlCnd2AllFanActive' => {
          'num' => '130',
          'name' => 'Al_Cnd2AllFan.Active',
          'desc' => 'All Condenser C2 Fans in',
          'level' => 'Alarm',
       },
      'l9d1AlVSDHiDscgTCirc1Active' => {
          'num' => '131',
          'name' => 'Al_VSD_HiDscgT_Circ1.Active',
          'desc' => 'High Discharge Temperature Circuit 1',
          'level' => 'Alarm',
       },
      'l9d1AlVSDHiDscgTCirc2Active' => {
          'num' => '132',
          'name' => 'Al_VSD_HiDscgT_Circ2.Active',
          'desc' => 'High Discharge Temperature Circuit 2',
          'level' => 'Alarm',
       },
      'l9d1AlDampWrongPosActive' => {
          'num' => '133',
          'name' => 'Al_DampWrongPos.Active',
          'desc' => 'Wrong Damper Position',
          'level' => 'Alarm',
       },
      'l9d1AlReducedEcoAirFlwActive' => {
          'num' => '134',
          'name' => 'Al_ReducedEcoAirFlw.Active',
          'desc' => 'Reduced Eco Air Flow',
          'level' => 'Warning',
       },
      'l9d1AlVSDStartUpFailCirc1Active' => {
          'num' => '135',
          'name' => 'Al_VSD_StartUpFail_Circ1.Active',
          'desc' => 'VSD Circuit 1 Startup Failure',
          'level' => 'Alarm',
       },
      'l9d1AlVSDStartUpFailCirc2Active' => {
          'num' => '136',
          'name' => 'Al_VSD_StartUpFail_Circ2.Active',
          'desc' => 'VSD Circuit 2 Startup Failure',
          'level' => 'Alarm',
       },
      'l9d1AlLossCW1FlwActive' => {
          'num' => '137',
          'name' => 'Al_LossCW1Flw.Active',
          'desc' => 'Loss of CW1 Flow',
          'level' => 'Warning',
       },
      'l9d1AlLossCW2FlwActive' => {
          'num' => '138',
          'name' => 'Al_LossCW2Flw.Active',
          'desc' => 'Loss of CW2 Flow',
          'level' => 'Warning',
       },
      'l9d1AlDehReqOffFCActive' => {
          'num' => '139',
          'name' => 'Al_DehReqOff_FC.Active',
          'desc' => 'FC Off by Dehum',
          'level' => 'Message',
       },
      'l9d1AlHumStopFC1HActive' => {
          'num' => '140',
          'name' => 'Al_HumStopFC_1H.Active',
          'desc' => 'FC Stopped for 1 Hour by Hum',
          'level' => 'Message',
       },
      'l9d1AlDehumStopFC1HActive' => {
          'num' => '141',
          'name' => 'Al_DehumStopFC_1H.Active',
          'desc' => 'FC Stopped for 1 Hour by Dehum',
          'level' => 'Message',
       },
      'l9d1AlDT3StopFCActive' => {
          'num' => '142',
          'name' => 'Al_DT3StopFC.Active',
          'desc' => 'FC Stopped for 1 Hour by DT3',
          'level' => 'Message',
       },
      'l9d1AlDehLowLim1LockActive' => {
          'num' => '143',
          'name' => 'Al_DehLowLim1Lock.Active',
          'desc' => 'Dehum Stop by Low Limit 1',
          'level' => 'Message',
       },
      'l9d1AlDehLowLim2LockActive' => {
          'num' => '144',
          'name' => 'Al_DehLowLim2Lock.Active',
          'desc' => 'Dehum Stop by Low Limit 2',
          'level' => 'Message',
       },
      'l9d1AlFCLockoutActive' => {
          'num' => '145',
          'name' => 'Al_FCLockout.Active',
          'desc' => 'FC Lockout',
          'level' => 'Message',
       },
      'l9d1AlSecondSetPActive' => {
          'num' => '146',
          'name' => 'Al_SecondSetP.Active',
          'desc' => 'Second Set Point Active',
          'level' => 'Message',
       },
      'l9d1AlHeatLockoutActive' => {
          'num' => '147',
          'name' => 'Al_HeatLockout.Active',
          'desc' => 'Heaters Lockout',
          'level' => 'Message',
       },
      'l9d1AlHumHeatLockoutActive' => {
          'num' => '148',
          'name' => 'Al_HumHeatLockout.Active',
          'desc' => 'Humidifier and Heaters Lockout',
          'level' => 'Message',
       },
      'l9d1AlHumLockoutActive' => {
          'num' => '149',
          'name' => 'Al_HumLockout.Active',
          'desc' => 'Humidifier Lockout',
          'level' => 'Message',
       },
      'l9d1AlStandbyOnActive' => {
          'num' => '150',
          'name' => 'Al_StandbyOn.Active',
          'desc' => 'Standby On',
          'level' => 'Message',
       },
      'l9d1AlCoolFan100Active' => {
          'num' => '151',
          'name' => 'Al_CoolFan100.Active',
          'desc' => 'Cool and Fan 100%',
          'level' => 'Message',
       },
      'l9d1AlUltracapSupplyActive' => {
          'num' => '152',
          'name' => 'Al_UltracapSupply.Active',
          'desc' => 'Ultracap Active',
          'level' => 'Message',
       },
      'l9d1AlPwrOnActive' => {
          'num' => '153',
          'name' => 'Al_PwrOn.Active',
          'desc' => 'Power On',
          'level' => 'Message',
       },
      'l9d1AlPwrOffActive' => {
          'num' => '154',
          'name' => 'Al_PwrOff.Active',
          'desc' => 'Power Off',
          'level' => 'Message',
       },
      'l9d1AlUnitOnActive' => {
          'num' => '155',
          'name' => 'Al_UnitOn.Active',
          'desc' => 'Unit On',
          'level' => 'Message',
       },
      'l9d1AlExpansionOfflineActive' => {
          'num' => '157',
          'name' => 'Al_ExpansionOffline.Active',
          'desc' => 'Expansion Board 1 Offline',
          'level' => 'Alarm',
       },
      'l9d1AlExpansion2OfflineActive' => {
          'num' => '158',
          'name' => 'Al_Expansion2Offline.Active',
          'desc' => 'Expansion Board 2 Offline',
          'level' => 'Alarm',
       },
      'l9d1AlSafeNTCSensActive' => {
          'num' => '159',
          'name' => 'Al_SafeNTCSens.Active',
          'desc' => 'Heater High Temperature Probe Fail',
          'level' => 'Alarm',
       },
      'l9d1AlOptTempPrbActive' => {
          'num' => '160',
          'name' => 'Al_OptTempPrb.Active',
          'desc' => 'Optional Probe 1 Fail',
          'level' => 'Warning',
       },
      'l9d1AlAETempPrbActive' => {
          'num' => '161',
          'name' => 'Al_AETempPrb.Active',
          'desc' => 'Air Economizer Probe Fail',
          'level' => 'Alarm',
       },
      'l9d1AlGlyTempPrbActive' => {
          'num' => '162',
          'name' => 'Al_GlyTempPrb.Active',
          'desc' => 'Glycol Temperature Probe Fail',
          'level' => 'Alarm',
       },
      'l9d1AlOptTempPrb2Active' => {
          'num' => '163',
          'name' => 'Al_OptTempPrb_2.Active',
          'desc' => 'Optional Probe 2 Fail',
          'level' => 'Warning',
       },
      'l9d1AlOptTempPrb3Active' => {
          'num' => '164',
          'name' => 'Al_OptTempPrb_3.Active',
          'desc' => 'Optional Probe 3 Fail',
          'level' => 'Warning',
       },
      'l9d1AlCWInletPrbFailActive' => {
          'num' => '165',
          'name' => 'Al_CW_InletPrbFail.Active',
          'desc' => 'CW1 Inlet Probe Fail',
          'level' => 'Warning',
       },
      'l9d1AlCWOutletPrbFailActive' => {
          'num' => '166',
          'name' => 'Al_CW_OutletPrbFail.Active',
          'desc' => 'CW1 Outlet Probe Fail',
          'level' => 'Warning',
       },
      'l9d1AlCW2InletPrbFailActive' => {
          'num' => '167',
          'name' => 'Al_CW2_InletPrbFail.Active',
          'desc' => 'CW2 Inlet Probe Fail',
          'level' => 'Warning',
       },
      'l9d1AlCW2OutletPrbFailActive' => {
          'num' => '168',
          'name' => 'Al_CW2_OutletPrbFail.Active',
          'desc' => 'CW2 Outlet Probe Fail',
          'level' => 'Warning',
       },
      'l9d1AlLocStaticPPrbFailActive' => {
          'num' => '169',
          'name' => 'Al_LocStaticP_PrbFail.Active',
          'desc' => 'Local Static Pressure Sensor Fail',
          'level' => 'Warning',
       },
      'l9d1AlSysStaticPPrbFailActive' => {
          'num' => '170',
          'name' => 'Al_SysStaticP_PrbFail.Active',
          'desc' => 'System Static Pressure Sensor Fail',
          'level' => 'Warning',
       },
      'l9d1AlWFlowPrbFailActive' => {
          'num' => '171',
          'name' => 'Al_WFlowPrbFail.Active',
          'desc' => 'CW1 Water Flow Sensor Fail',
          'level' => 'Warning',
       },
      'l9d1AlWFlow2PrbFailActive' => {
          'num' => '172',
          'name' => 'Al_WFlow2PrbFail.Active',
          'desc' => 'CW2 Water Flow Sensor Fail',
          'level' => 'Warning',
       },
      'l9d1AlSysRetPrbFailActive' => {
          'num' => '173',
          'name' => 'Al_SysRetPrbFail.Active',
          'desc' => 'Return System Sensor Failure',
          'level' => 'Warning',
       },
      'l9d1AlSysRemPrbFailActive' => {
          'num' => '174',
          'name' => 'Al_SysRemPrbFail.Active',
          'desc' => 'Remote System Sensor Failure',
          'level' => 'Warning',
       },
      'l9d1AlCPYActive' => {
          'num' => '175',
          'name' => 'Al_CPY.Active',
          'desc' => 'HCB Disable',
          'level' => 'Warning',
       },
      'l9d1AlCWMBValve1OfflineActive' => {
          'num' => '176',
          'name' => 'Al_CW_MBValve1Offline.Active',
          'desc' => 'Mb CW Valve 1 Offline',
          'level' => 'Alarm',
       },
      'l9d1AlCWMBValve2OfflineActive' => {
          'num' => '177',
          'name' => 'Al_CW_MBValve2Offline.Active',
          'desc' => 'Mb CW Valve 2 Offline',
          'level' => 'Alarm',
       },
      'l9d1AlCWMBValve3OfflineActive' => {
          'num' => '178',
          'name' => 'Al_CW_MBValve3Offline.Active',
          'desc' => 'Mb CW Valve 3 Offline',
          'level' => 'Alarm',
       },
      'l9d1AlCWMBValve4OfflineActive' => {
          'num' => '179',
          'name' => 'Al_CW_MBValve4Offline.Active',
          'desc' => 'Mb CW Valve 4 Offline',
          'level' => 'Alarm',
       },
      'l9d1AlCPYHiConductActive' => {
          'num' => '180',
          'name' => 'Al_CPY_HiConduct.Active',
          'desc' => 'Supply Water High Conductivity',
          'level' => 'Warning',
       },
      'l9d1AlEcoEmrgncyOvrrdActive' => {
          'num' => '181',
          'name' => 'Al_EcoEmrgncyOvrrd.Active',
          'desc' => 'Air Eco Emergency Override',
          'level' => 'Message',
       },
      'l9d1AlRem1PrbFailActive' => {
          'num' => '182',
          'name' => 'Al_Rem1PrbFail.Active',
          'desc' => 'Remote 1 Sensor Failure',
          'level' => 'Warning',
       },
      'l9d1AlRem2PrbFailActive' => {
          'num' => '183',
          'name' => 'Al_Rem2PrbFail.Active',
          'desc' => 'Remote 2 Sensor Failure',
          'level' => 'Warning',
       },
      'l9d1AlRem3PrbFailActive' => {
          'num' => '184',
          'name' => 'Al_Rem3PrbFail.Active',
          'desc' => 'Remote 3 Sensor Failure',
          'level' => 'Warning',
       },
      'l9d1AlRem4PrbFailActive' => {
          'num' => '185',
          'name' => 'Al_Rem4PrbFail.Active',
          'desc' => 'Remote 4 Sensor Failure',
          'level' => 'Warning',
       },
      'l9d1AlRem5PrbFailActive' => {
          'num' => '186',
          'name' => 'Al_Rem5PrbFail.Active',
          'desc' => 'Remote 5 Sensor Failure',
          'level' => 'Warning',
       },
      'l9d1AlRem6PrbFailActive' => {
          'num' => '187',
          'name' => 'Al_Rem6PrbFail.Active',
          'desc' => 'Remote 6 Sensor Failure',
          'level' => 'Warning',
       },
      'l9d1AlRem7PrbFailActive' => {
          'num' => '188',
          'name' => 'Al_Rem7PrbFail.Active',
          'desc' => 'Remote 7 Sensor Failure',
          'level' => 'Warning',
       },
      'l9d1AlRem8PrbFailActive' => {
          'num' => '189',
          'name' => 'Al_Rem8PrbFail.Active',
          'desc' => 'Remote 8 Sensor Failure',
          'level' => 'Warning',
       },
      'l9d1AlRem9PrbFailActive' => {
          'num' => '190',
          'name' => 'Al_Rem9PrbFail.Active',
          'desc' => 'Remote 9 Sensor Failure',
          'level' => 'Warning',
       },
      'l9d1AlRem10PrbFailActive' => {
          'num' => '191',
          'name' => 'Al_Rem10PrbFail.Active',
          'desc' => 'Remote 10 Sensor Failure',
          'level' => 'Warning',
       },
      'l9d1AlCndRefrT1Active' => {
          'num' => '192',
          'name' => 'Al_CndRefrT1',
          'desc' => 'Condenser Refrigerant Sensor T1 Failure',
          'level' => 'Alarm',
       },
      'l9d1AlEPPump1OutTActive' => {
          'num' => '193',
          'name' => 'Al_EP_Pump1OutT.Active',
          'desc' => 'Pump1 Outlet Temp Sensor Failure',
          'level' => 'Alarm',
       },
      'l9d1AlEPPump1InPActive' => {
          'num' => '194',
          'name' => 'Al_EP_Pump1InP.Active',
          'desc' => 'Pump1 Inlet Press Sensor Failure',
          'level' => 'Alarm',
       },
      'l9d1AlEPPump1OutPActive' => {
          'num' => '195',
          'name' => 'Al_EP_Pump1OutP.Active',
          'desc' => 'Pump1 Outlet Press Sensor Failure',
          'level' => 'Alarm',
       },
      'l9d1AlCndRefrT2Active' => {
          'num' => '196',
          'name' => 'Al_CndRefrT2',
          'desc' => 'Condenser Refrigerant Sensor T2 Failure',
          'level' => 'Alarm',
       },
      'l9d1AlEPPump2OutTActive' => {
          'num' => '197',
          'name' => 'Al_EP_Pump2OutT.Active',
          'desc' => 'Pump2 Outlet Temp Sensor Failure',
          'level' => 'Alarm',
       },
      'l9d1AlEPPump2InPActive' => {
          'num' => '198',
          'name' => 'Al_EP_Pump2InP.Active',
          'desc' => 'Pump2 Inlet Press Sensor Failure',
          'level' => 'Alarm',
       },
      'l9d1AlEPPump2OutPActive' => {
          'num' => '199',
          'name' => 'Al_EP_Pump2OutP.Active',
          'desc' => 'Pump2 Outlet Press Sensor Failure',
          'level' => 'Alarm',
       },
      'l9d1AlEPPump1FailActive' => {
          'num' => '200',
          'name' => 'Al_EP_Pump1Fail.Active',
          'desc' => 'Pump1 Failure',
          'level' => 'Alarm',
       },
      'l9d1AlEPPump2FailActive' => {
          'num' => '201',
          'name' => 'Al_EP_Pump2Fail.Active',
          'desc' => 'Pump2 Failure',
          'level' => 'Alarm',
       },
      'l9d1AlCond1OutdoorTempActive' => {
          'num' => '202',
          'name' => 'Al_Cond1OutdoorTemp.Active',
          'desc' => 'Condenser 1 Outdoor Temp Sensor Failure',
          'level' => 'Alarm',
       },
      'l9d1AlCond2OutdoorTempActive' => {
          'num' => '203',
          'name' => 'Al_Cond2OutdoorTemp.Active',
          'desc' => 'Condenser 2 Outdoor Temp Sensor Failure',
          'level' => 'Alarm',
       },
      'l9d1AlExpansion3OfflineActive' => {
          'num' => '204',
          'name' => 'Al_Expansion3Offline.Active',
          'desc' => 'Expansion Board 3 Offline',
          'level' => 'Alarm',
       },
      'l9d1AlExpansion4OfflineActive' => {
          'num' => '205',
          'name' => 'Al_Expansion4Offline.Active',
          'desc' => 'Expansion Board 4 Offline',
          'level' => 'Alarm',
       },
      'l9d1AlDisplayOffActive' => {
          'num' => '206',
          'name' => 'Al_DisplayOff.Active',
          'desc' => 'Unit Off by Display',
          'level' => 'Message',
       },
      'l9d1AlRemoteOffActive' => {
          'num' => '207',
          'name' => 'Al_RemoteOff.Active',
          'desc' => 'Unit Off by Remote Input',
          'level' => 'Message',
       },
      'l9d1AlThreePosOffActive' => {
          'num' => '208',
          'name' => 'Al_ThreePosOff.Active',
          'desc' => 'Unit Off by 3 Pos Switch',
          'level' => 'Message',
       },
      'l9d1AlBmsOffActive' => {
          'num' => '209',
          'name' => 'Al_BmsOff.Active',
          'desc' => 'Unit Off by Monitoring',
          'level' => 'Message',
       },
      'l9d1AlSleepOffActive' => {
          'num' => '210',
          'name' => 'Al_SleepOff.Active',
          'desc' => 'Unit Off by Timer',
          'level' => 'Message',
       },
      'l9d1AlAlarmOffActive' => {
          'num' => '211',
          'name' => 'Al_AlarmOff.Active',
          'desc' => 'Unit Off by',
          'level' => 'Alarm',
       },
      'l9d1AlStandbyActive' => {
          'num' => '212',
          'name' => 'Al_Standby.Active',
          'desc' => 'Unit Standby Mode',
          'level' => 'Message',
       },
      'l9d1AlManualModeActive' => {
          'num' => '213',
          'name' => 'Al_ManualMode.Active',
          'desc' => 'Unit Manual Mode',
          'level' => 'Message',
       },
      'l9d1AlCndLowAmbThrs2Active' => {
          'num' => '214',
          'name' => 'Al_CndLowAmbThrs2.Active',
          'desc' => 'Very Low Outdoor Temperature',
          'level' => 'Warning',
       },
      'l9d1AlCndLowAmbThrs2Active' => {
          'num' => '215',
          'name' => 'Al_CndLowAmbThrs3.Active',
          'desc' => 'Very Low Outdoor Temperature',
          'level' => 'Alarm',
       },
      'l9d1AlEPLoSHPump1Active' => {
          'num' => '216',
          'name' => 'Al_EP_LoSHPump1',
          'desc' => 'Low SuperHeat Pump 1',
          'level' => 'Alarm',
       },
      'l9d1AlEPHiSHPump1Active' => {
          'num' => '217',
          'name' => 'Al_EP_HiSHPump1',
          'desc' => 'High SuperHeat Pump 1',
          'level' => 'Alarm',
       },
      'l9d1AlEPLoSCPump1Active' => {
          'num' => '218',
          'name' => 'Al_EP_LoSCPump1',
          'desc' => 'Low SubCool Pump 1',
          'level' => 'Alarm',
       },
      'l9d1AlEPLoDPPump1Active' => {
          'num' => '219',
          'name' => 'Al_EP_LoDPPump1',
          'desc' => 'Low Diff Press Pump 1',
          'level' => 'Alarm',
       },
      'l9d1AlEPHiDPPump1Active' => {
          'num' => '220',
          'name' => 'Al_EP_HiDPPump1',
          'desc' => 'High Diff Press Pump 1',
          'level' => 'Alarm',
       },
      'l9d1AlEPLoSHPump2Active' => {
          'num' => '221',
          'name' => 'Al_EP_LoSHPump2',
          'desc' => 'Low SuperHeat Pump 2',
          'level' => 'Alarm',
       },
      'l9d1AlEPHiSHPump2Active' => {
          'num' => '222',
          'name' => 'Al_EP_HiSHPump2',
          'desc' => 'High SuperHeat Pump 2',
          'level' => 'Alarm',
       },
      'l9d1AlEPLoSCPump2Active' => {
          'num' => '223',
          'name' => 'Al_EP_LoSCPump2',
          'desc' => 'Low SubCool Pump 2',
          'level' => 'Alarm',
       },
      'l9d1AlEPLoDPPump2Active' => {
          'num' => '224',
          'name' => 'Al_EP_LoDPPump2',
          'desc' => 'Low Diff Press Pump 2',
          'level' => 'Alarm',
       },
      'l9d1AlEPHiDPPump2Active' => {
          'num' => '225',
          'name' => 'Al_EP_HiDPPump2',
          'desc' => 'High Diff Press Pump 2',
          'level' => 'Alarm',
       },
      'l9d1AlEPPump1Active' => {
          'num' => '226',
          'name' => 'Al_EP_Pump1',
          'desc' => 'Pump 1',
          'level' => 'Alarm',
       },
      'l9d1AlEPPump2Active' => {
          'num' => '227',
          'name' => 'Al_EP_Pump2',
          'desc' => 'Pump 2',
          'level' => 'Alarm',
       },
      'l9d1AlEPStartFailPump1Active' => {
          'num' => '228',
          'name' => 'Al_EP_StartFailPump1',
          'desc' => 'Startup Failure Pump 1',
          'level' => 'Alarm',
       },
      'l9d1AlEPStartFailPump2Active' => {
          'num' => '229',
          'name' => 'Al_EP_StartFailPump2',
          'desc' => 'Startup Failure Pump 2',
          'level' => 'Alarm',
       },
      'l9d1AlEPStartLockPump1Active' => {
          'num' => '230',
          'name' => 'Al_EP_StartLockPump1',
          'desc' => 'Startup Lock Pump 1',
          'level' => 'Warning',
       },
      'l9d1AlEPStartLockPump2Active' => {
          'num' => '231',
          'name' => 'Al_EP_StartLockPump2',
          'desc' => 'Startup Lock Pump 2',
          'level' => 'Warning',
       },
      'l9d1AlLowStartPCirc1Active' => {
          'num' => '232',
          'name' => 'Al_LowStartPCirc1',
          'desc' => 'Low Start Pressure Circuit 1',
          'level' => 'Alarm',
       },
      'l9d1AlLowStartPCirc2Active' => {
          'num' => '233',
          'name' => 'Al_LowStartPCirc2',
          'desc' => 'Low Start Pressure Circuit 2',
          'level' => 'Alarm',
       },
      'l9d1AlStopOnLPCirc1Active' => {
          'num' => '234',
          'name' => 'Al_StopOnLPCirc1',
          'desc' => 'Stop On Low Pressure Circuit 1',
          'level' => 'Alarm',
       },
      'l9d1AlStopOnLPCirc2Active' => {
          'num' => '235',
          'name' => 'Al_StopOnLPCirc2',
          'desc' => 'Stop On Low Pressure Circuit 2',
          'level' => 'Alarm',
       },
      'l9d1AlFreezeProtCirc1Active' => {
          'num' => '236',
          'name' => 'Al_FreezeProtCirc1',
          'desc' => 'Freeze Protection Circuit 1',
          'level' => 'Message',
       },
      'l9d1AlFreezeProtCirc2Active' => {
          'num' => '237',
          'name' => 'Al_FreezeProtCirc2',
          'desc' => 'Freeze Protection Circuit 2',
          'level' => 'Message',
       },
      'l9d1AlLowStartPCirc1Active' => {
          'num' => '238',
          'name' => 'Al_LowStartPMsgCirc1',
          'desc' => 'Low Start Pressure Circuit 1',
          'level' => 'Message',
       },
      'l9d1AlLowStartPCirc2Active' => {
          'num' => '239',
          'name' => 'Al_LowStartPMsgCirc2',
          'desc' => 'Low Start Pressure Circuit 2',
          'level' => 'Message',
       },
      'l9d1AlCapDeratingCirc1Active' => {
          'num' => '240',
          'name' => 'Al_CapDeratingCirc1',
          'desc' => 'Capacity Derating Circuit 1',
          'level' => 'Message',
       },
      'l9d1AlCapDeratingCirc2Active' => {
          'num' => '241',
          'name' => 'Al_CapDeratingCirc2',
          'desc' => 'Capacity Derating Circuit 2',
          'level' => 'Message',
       },
      'l9d1AlStaticPOutOfRangeActive' => {
          'num' => '242',
          'name' => 'Al_StaticP_OutOfRange',
          'desc' => 'Static Pressure Out Of Range',
          'level' => 'Warning',
       },
      'l9d1AlEEV1WHLimitActive' => {
          'num' => '243',
          'name' => 'Al_EEV1_WHLimit',
          'desc' => 'EEV Circuit 1 Working Hours Exceeded',
          'level' => 'Warning',
       },
      'l9d1AlEEV2WHLimitActive' => {
          'num' => '244',
          'name' => 'Al_EEV2_WHLimit',
          'desc' => 'EEV Circuit 2 Working Hours Exceeded',
          'level' => 'Warning',
       },
      'l9d1AlEPPropLockoutActive' => {
          'num' => '245',
          'name' => 'Al_EP_PropLockout',
          'desc' => 'EconoPhase Prop Lockout',
          'level' => 'Warning',
       },
      'l9d1AlSurgeArresterActive' => {
          'num' => '246',
          'name' => 'Al_SurgeArrester',
          'desc' => 'Surge Arrester Failure',
          'level' => 'Alarm',
       },
      'l9d1AlClogFiltMbTh1Active' => {
          'num' => '247',
          'name' => 'Al_ClogFiltMbTh1',
          'desc' => 'Clogged Filter Th1',
          'level' => 'Warning',
       },
      'l9d1AlClogFiltMbTh2Active' => {
          'num' => '248',
          'name' => 'Al_ClogFiltMbTh2',
          'desc' => 'Clogged Filter Th2',
          'level' => 'Warning',
       },
      'l9d1AlClogFiltMbGenericActive' => {
          'num' => '249',
          'name' => 'Al_ClogFiltMbGeneric',
          'desc' => 'Clogged Filter Error',
          'level' => 'Warning',
       },
      'l9d1AlAtsActive' => {
          'num' => '250',
          'name' => 'Al_Ats',
          'desc' => 'ATS Error',
          'level' => 'Warning',
       },
      'l9d1AlAirFlowSensFailActive' => {
          'num' => '251',
          'name' => 'Al_AirFlowSensFail',
          'desc' => 'Airflow Sensor Failure',
          'level' => 'Warning',
       },
      'l9d1AlCndMbValve1OfflineActive' => {
          'num' => '252',
          'name' => 'Al_CndMbValve1Offline',
          'desc' => 'Mb Condenser Valve 1 Offline',
          'level' => 'Alarm',
       },
      'l9d1AlCndMbValve2OfflineActive' => {
          'num' => '253',
          'name' => 'Al_CndMbValve2Offline',
          'desc' => 'Mb Condenser Valve 2 Offline',
          'level' => 'Alarm',
       },
      'l9d1AlFcMbValve1OfflineActive' => {
          'num' => '254',
          'name' => 'Al_FcMbValve1Offline',
          'desc' => 'Mb FC Valve 1 Offline',
          'level' => 'Alarm',
       },
      'l9d1AlAuxSenDisconnectActive' => {
          'num' => '255',
          'name' => 'Al_AuxSenDisconnect',
          'desc' => 'Aux Sensor Disconnected',
          'level' => 'Warning',
       },
  };
  my @names = keys %{$self->{alarmoids}};
  # das sind jetzt natuerlich 900 snmpget. Mal schauen, wie schnell das ist
  ####$self->get_snmp_objects('BOSS-SNMP-AGENT-MIB', @names);
  $self->{alarms} = [];
  foreach my $name (@names) {
    if (!defined $self->{$name}) {
      next;
    }
    $self->{alarmoids}->{$name}->{status} = $self->{$name};
    my $alarm = CheckWutHealth::Carel::Boss::Component::EnvironmentalSubsystem::Alarm->new(%{$self->{alarmoids}->{$name}});
    push(@{$self->{alarms}}, CheckWutHealth::Carel::Boss::Component::EnvironmentalSubsystem::Alarm->new(%{$self->{alarmoids}->{$name}}));
    delete $self->{$name};
  }
  delete $self->{alarmoids};
  $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'BOSS-SNMP-AGENT-MIB'}->{l9d1AlTable} = '1.3.6.1.4.1.476.1.42.4.3';
  $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'BOSS-SNMP-AGENT-MIB'}->{l9d1AlEntry} = '1.3.6.1.4.1.476.1.42.4.3.32';
  #$self->get_snmp_tables("BOSS-SNMP-AGENT-MIB", [
  #  ["alarms", "l9d1AlTable", "CheckWutHealth::Carel::Boss::Component::EnvironmentalSubsystem::Alarm"],
  #]);
  $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'BOSS-SNMP-AGENT-MIB'}->{l9d1UnitStatusDefinition} = "BOSS-SNMP-AGENT-MIB::l9d1UnitStatus";
  $Monitoring::GLPlugin::SNMP::MibsAndOids::definitions->{'BOSS-SNMP-AGENT-MIB'}->{l9d1UnitStatus} = {
      0 => "display off",
      1 => "remote off",
      2 => "3pos off",
      3 => "monit off",
      4 => "timer off",
      5 => "alarm off",
      6 => "shutdown del",
      7 => "standby",
      8 => "tr stby",
      9 => "alarm stby",
      10 => "fanback",
      11 => "unit on",
      12 => "warning on",
      13 => "alarm on",
      14 => "damper open",
      15 => "power fail",
      16 => "manual",
      17 => "restart delay",
  };
  $self->get_snmp_objects('BOSS-SNMP-AGENT-MIB', (qw(l9d1UnitStatus)));
}

sub check {
  my $self = shift;
  $self->SUPER::check();
  $self->add_info(sprintf "unit status is: %s",
      $self->{l9d1UnitStatus});
  if (! $self->check_messages()) {
    $self->reduce_messages("no alarms");
  }
  if ($self->{l9d1UnitStatus} =~ /warning/) {
    $self->add_warning();
  } elsif ($self->{l9d1UnitStatus} =~ /(alarm on)|(power fail)/) {
    $self->add_critical();
  } else {
    $self->add_ok();
  }
}


package CheckWutHealth::Carel::Boss::Component::EnvironmentalSubsystem::Alarm;
use strict;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my $self = shift;
  if ($self->{name} eq "Al_SafeNTCSens.Active") {
    $self->{status} = "true";
    
  }
}

sub check {
  my $self = shift;
  $self->add_info(sprintf "%s is %s", $self->{name}, $self->{status});
  if ($self->{status} ne "false") {
    if ($self->{level} eq "Message") {
      $self->add_ok();
    } elsif ($self->{level} eq "Warning") {
      $self->add_warning();
    } elsif ($self->{level} eq "Alarm") {
      $self->add_critical();
    }
  }
}


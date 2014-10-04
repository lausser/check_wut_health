#! /usr/bin/perl

use strict;
my $plugin = Classes::Device->new(
    shortname => '',
    usage => 'Usage: %s [ -v|--verbose ] [ -t <timeout> ] '.
        '--mode <what-to-do> '.
        '--hostname <network-component> --community <snmp-community>'.
        '  ...]',
    version => '$Revision: #PACKAGE_VERSION# $',
    blurb => 'This plugin checks various parameters of network components ',
    url => 'http://labs.consol.de/nagios/check_nwc_health',
    timeout => 60,
    plugin => $GLPlugin::pluginname,
);
$plugin->add_mode(
    internal => 'device::uptime',
    spec => 'uptime',
    alias => undef,
    help => 'Check the uptime of the device',
);
$plugin->add_mode(
    internal => 'device::hardware::health',
    spec => 'hardware-health',
    alias => undef,
    help => 'Check the status of environmental equipment (fans, temperatures, power)',
);
$plugin->add_mode(
    internal => 'device::sensor::status',
    spec => 'sensor-status',
    alias => undef,
    help => 'Check the status of the sensors',
);

$plugin->add_arg(
    spec => 'blacklist|b=s',
    help => '--blacklist
   Blacklist some (missing/failed) components',
    required => 0,
    default => '',
);
$plugin->add_arg(
    spec => 'hostname|H=s',
    help => '--hostname
   Hostname or IP-address of the device',
    required => 0,
    env => 'HOSTNAME',
);
$plugin->add_snmp_args();
$plugin->add_arg(
    spec => 'mode=s',
    help => "--mode
   A keyword which tells the plugin what to do",
    required => 1,
);
$plugin->add_arg(
    spec => 'name=s',
    help => "--name
   The name of a sensor",
    required => 0,
);
$plugin->add_arg(
    spec => 'drecksptkdb=s',
    help => "--drecksptkdb
   This parameter must be used instead of --name, because Devel::ptkdb is stealing the latter from the command line",
    aliasfor => "name",
    required => 0,
);
$plugin->add_arg(
    spec => 'regexp',
    help => "--regexp
   A flag indicating that --name is a regular expression",
    required => 0,
);
$plugin->add_arg(
    spec => 'critical=s',
    help => '--critical
   The critical threshold',
    required => 0,
);
$plugin->add_arg(
    spec => 'warning=s',
    help => '--warning
   The warning threshold',
    required => 0,
);
$plugin->add_arg(
    spec => 'warningx=s%',
    help => '--warningx
   The extended warning thresholds',
    required => 0,
);
$plugin->add_arg(
    spec => 'criticalx=s%',
    help => '--criticalx
   The extended critical thresholds',
    required => 0,
);
$plugin->add_arg(
    spec => 'negate=s%',
    help => "--negate
   The parameter allows you to map exit levels, such as warning=critical",
    required => 0,
);
$plugin->add_arg(
    spec => 'with-mymodules-dyn-dir=s',
    help => '--with-mymodules-dyn-dir
   A directory where own extensions can be found',
    required => 0,
);
$plugin->add_arg(
    spec => 'statefilesdir=s',
    help => '--statefilesdir
   An alternate directory where the plugin can save files',
    required => 0,
    env => 'STATEFILESDIR',
);
$plugin->add_arg(
    spec => 'snmpwalk=s',
    help => '--snmpwalk
   A file with the output of a snmpwalk (used for simulation)
   Use it instead of --hostname',
    required => 0,
    env => 'SNMPWALK',
);
$plugin->add_arg(
    spec => 'oids=s',
    help => '--oids
   A list of oids which are downloaded and written to a cache file.
   Use it together with --mode oidcache',
    required => 0,
);
$plugin->add_arg(
    spec => 'offline:i',
    help => '--offline
   The maximum number of seconds since the last update of cache file before
   it is considered too old',
    required => 0,
    env => 'OFFLINE',
);
$plugin->add_arg(
    spec => 'multiline',
    help => '--multiline
   Multiline output',
    required => 0,
);

$plugin->getopts();
$plugin->classify();
$plugin->validate_args();

if (! $plugin->check_messages()) {
  $plugin->init();
  if (! $plugin->check_messages()) {
    $plugin->add_ok($plugin->get_summary())
        if $plugin->get_summary();
    $plugin->add_ok($plugin->get_extendedinfo(" "))
        if $plugin->get_extendedinfo();
  }
} elsif ($plugin->opts->snmpwalk && $plugin->opts->offline) {
  ;
} else {
  $plugin->add_critical('wrong device');
}
my ($code, $message) = $plugin->opts->multiline ?
    $plugin->check_messages(join => "\n", join_all => ', ') :
    $plugin->check_messages(join => ', ', join_all => ', ');
$message .= sprintf "\n%s\n", $plugin->get_info("\n")
    if $plugin->opts->verbose >= 1;
#printf "%s\n", Data::Dumper::Dumper($plugin);

$plugin->nagios_exit($code, $message);



package Classes::Rittal::LCPDX::Component::SensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  @{$self->{fanspeeds}} = qw(
      y3-AOut3 y4-AOut4
  );
  @{$self->{pressures}} = qw(
      comp-discharge-pressure comp-suction-pressure
  );
  @{$self->{rpms}} = qw(
      rotor-speed-rps
  );
  @{$self->{temperatures}} = qw(
      server-in-temp1 server-in-temp2 server-in-temp3
      server-out-temp1 server-out-temp2 server-out-temp3
      comp-discharge-temp comp-suction-temp
      evap-temp cond-temp
  );
  $self->get_snmp_objects("RITTAL-LCP-DX-MIB", (@{$self->{pressures}}, @{$self->{temperatures}}, @{$self->{fanspeeds}}, @{$self->{rpms}}));
}

sub check {
  my ($self) = @_;
  foreach (grep { defined $self->{$_} } @{$self->{temperatures}}) {
    my $name = $_ =~ s/-/_/gr;
    my $value = $self->{$_} / 10.0;
    $self->add_info(sprintf '%s is %.1fC', $name, $value);
    $self->add_ok();
    $self->add_perfdata(label => $name,
        value => $value,
    );
  }
  delete $self->{temperatures};
  foreach (grep { defined $self->{$_} } @{$self->{pressures}}) {
    my $name = $_ =~ s/-/_/gr;
    my $value = $self->{$_} / 10.0;
    $self->add_info(sprintf '%s is %.1fbar', $name, $value);
    $self->add_ok();
    $self->add_perfdata(label => $name,
        value => $value,
    );
  }
  delete $self->{pressures};
  foreach (grep { defined $self->{$_} } @{$self->{fanspeeds}}) {
    my $name = $_ =~ s/-/_/gr;
    my $value = $self->{$_} / 10.0;
    $self->add_info(sprintf 'fan speed %s is %.1f%%', $name, $value);
    $self->set_thresholds(
        metric => "fan_speed_".$name,
        warning => 80,
        critical => 90,
    );
    $self->add_message($self->check_thresholds(
        metric => "fan_speed_".$name,
        value => $value,
    ));
    $self->add_perfdata(label => "fan_speed_".$name,
        value => $value,
        uom => '%',
    );
  }
  delete $self->{fanspeeds};
  foreach (grep { defined $self->{$_} } @{$self->{rpms}}) {
    my $name = $_ =~ s/-/_/gr;
    my $value = $self->{$_} / 10.0;
    $self->add_info(sprintf '%s is %.1frps', $name, $value);
    $self->add_ok();
    $self->add_perfdata(label => $name,
        value => $value,
    );
  }
  delete $self->{rpms};
}

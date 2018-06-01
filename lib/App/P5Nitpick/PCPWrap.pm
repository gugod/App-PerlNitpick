package App::P5Nitpick::PCPWrap;
use strict;
use warnings;

sub new {
    my ($class, $pcp_class, $on_violate_cb) = @_;

    my $o = $pcp_class->new;

    $o->{__p5nitpick_pcpwrap_pcp_class} = $pcp_class;
    $o->{__p5nitpick_pcpwrap_on_violate_cb} = $on_violate_cb,

    my $new_class = "App::P5Nitpick::PCPWrap::${pcp_class}";
    eval <<"NEW_PKG";
package $new_class;
our \@ISA = qw(App::P5Nitpick::PCPWrap $pcp_class);
NEW_PKG

    bless $o, $new_class;
    return $o;
}

sub violation {
    my ($self, $msg, $expl, $elem) = @_;
    print STDERR "==> $msg\n";
    $self->{__p5nitpick_pcpwrap_on_violate_cb}->($msg, $expl, $elem);
}


1;

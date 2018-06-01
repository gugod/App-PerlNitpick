package App::P5Nitpick::Rule::RemoveUnusedVariables;
# ABSTRACT: Remove unused variables

=encoding UTF-8

This nitpicking rules removes variabse that is declared but not used.

=cut

use Moose;
use PPI::Document;
use Perl::Critic::Document;
use Perl::Critic::Policy::Variables::ProhibitUnusedVariables;

use App::P5Nitpick::PCPWrap;

has document => (
    is => 'ro',
    required => 1,
    isa => 'PPI::Document',
);

no Moose;

sub rewrite {
    my ($self) = @_;

    my $o = App::P5Nitpick::PCPWrap->new('Perl::Critic::Policy::Variables::ProhibitUnusedVariables');

    my @vio = $o->violates(
        undef,
        Perl::Critic::Document->new(-source => $self->document)
    );

    for (@vio) {
        my ($msg, $explain, $el) = @$_;
        if ($el->variables == 1) {
            $el->remove;
        } else {
            # TODO
        }

    }

    return $self->document;
}

1;

package App::P5Nitpick::Rule::RemoveUnusedVariables;
# ABSTRACT: Remove unused variables

=encoding UTF-8

This nitpicking rules removes variabse that is declared but not used.

=cut

use Moose;
use PPI::Document;

has document => (
    is => 'ro',
    required => 1,
    isa => 'PPI::Document',
);

use App::P5Nitpick::PCPWrap;
use Perl::Critic::Policy::Variables::ProhibitUnusedVariables;

no Moose;

sub rewrite {
    my ($self) = @_;

    my @violates;
    my $o = App::P5Nitpick::PCPWrap->new(
        'Perl::Critic::Policy::Variables::ProhibitUnusedVariables',
        sub {
            my ($msg, $explain, $el) = @_;

            if ($el->variables == 1) {
                $el->remove;
            } else {
                # TODO
            }
        }
    );


    $o->violates(undef, $self->document);

    require Data::Dumper;

    print Data::Dumper::Dumper([$o, \@violates]);
}

1;

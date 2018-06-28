package App::P5Nitpick::Rule::RemoveUnusedInclude;
# ABSTRACT: Remove unused include statements.

=encoding UTF-8

This nitpicking rules removes include statements that are actually un-used.

=cut

use Moose;
use PPI::Document;
use Perl::Critic::Document;
use Perl::Critic::Policy::Variables::ProhibitUnusedVariables;

use App::P5Nitpick::PCPWrap;

no Moose;

sub rewrite {
    my ($self, $doc) = @_;

    my $o = App::P5Nitpick::PCPWrap->new('Perl::Critic::Policy::TooMuchCode::ProhibitUnusedInclude');

    my @vio = $o->violates(
        $doc,
        Perl::Critic::Document->new(-source => $doc)
    );

    for (@vio) {
        my ($msg, $explain, $el) = @$_;
        my $next_space = $el->next_sibling;
        $next_space = undef unless $next_space && $next_space->isa('PPI::Token::Whitespace');

        if ($next_space && $next_space->content eq "\n") {
            $next_space->remove;
        }
        $el->remove;
    }

    return $doc;
}

1;

package App::P5Nitpick::Rule::UseMouseWithNoMouse;
# ABSTRACT: Ensure a 'no Mouse;' statement is there if 'use Mouse;' is.

=encoding UTF-8

=head1 DESCRIPTION

This nitpicking rule ensure a 'no Mouse' statement
is present in the file if a 'use Mouse' is there.

=cut

use Moose;
use PPI::Document;

sub rewrite {
    my ($self, $doc) = @_;

    if ($self->has_use_mouse_but_has_no_no_mouse($doc)) {
        $self->append_no_mouse($doc);
    }
    return $doc;
}

sub has_use_mouse_but_has_no_no_mouse {
    my ($self, $doc) = @_;
    my $include_statements = $doc->find(sub { $_[1]->isa('PPI::Statement::Include') }) || [];

    my ($has_use, $has_no);
    for my $st (@$include_statements) {
        if ($st->module eq 'Mouse') {
            if ($st->type eq 'use') {
                $has_use = 1;
            } elsif ($st->type eq 'no') {
                $has_no = 1;
            }
        }
    }
    return $has_use && !$has_no;
}

sub append_no_mouse {
    my ($self, $doc) = @_;

    my $el = PPI::Document->new(\"no Mouse;")->find_first('PPI::Statement::Include');
    $el->remove;

    my @child = $doc->schildren();
    $child[-1]->insert_before($el);
    $child[-1]->insert_before(PPI::Token::Whitespace->new("\n"));
    return $doc;
}

1;

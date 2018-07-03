package App::P5Nitpick::Rule::RewriteWithAssignmentOperators;

use Moose;
use PPI::Document;
use PPI::Token::Whitespace;

no Moose;

sub rewrite {
    my ($self, $document) = @_;

    my @op_assign = grep {
        my $op = $_;
        $op->content eq '=' && $op->parent->isa('PPI::Statement') && $op->parent->schildren == 6 && do {
            my $tok = $op->sprevious_sibling;
            $tok->isa('PPI::Token::Symbol') && $tok->raw_type eq '$'
        }  && do {
            my $op2 = $op->parent->schild(3);
            $op2->isa('PPI::Token::Operator') && $op2->content ne '->'
        }
    } @{$document->find('PPI::Token::Operator') // []};
    return $document unless @op_assign;

    my @found;
    for my $op (@op_assign) {
        my $prev = $op->sprevious_sibling;
        my $next = $op->snext_sibling;
        if ($next->isa('PPI::Token::Symbol') && $prev->content eq $next->content) {
            push @found, $op->parent;
        }
    }

    for my $statement (@found) {
        my @child = $statement->schildren;

        # assigment operator :)
        my $assop = PPI::Token::Operator->new($child[3]->content . $child[1]->content);

        $child[3]->remove;
        $child[2]->remove;
        $child[1]->insert_after($assop);
        $child[1]->remove;
    }

    return $document;
}

1;

__END__

=head1 DESCRIPTION

This rule rewrites those assignments that alter a single varible with itself.
For example, this one:

    $x = $x + 2;

Is rewritten with the C<+=> assignment operator, as:

    $x += 2;

=cut

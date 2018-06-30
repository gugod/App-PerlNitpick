package App::P5Nitpick::Rule::DedupeIncludeStatements;
use Moose;

sub rewrite {
    my ($self, $document) = @_;

    my %used;
    my @to_delete;
    for my $el (@{ $document->find('PPI::Statement::Include') ||[]}) {
        next unless $el->type && $el->type eq 'use';
        my $module = $el->module;
        if ($used{"$el"}) {
            push @to_delete, $el;
        } else {
            $used{"$el"} = 1;
        }
    }

    for my $el (@to_delete) {
        $el->remove;
    }

    return $document;
}

no Moose;
1;

__END__

=head1 DedupeIncludeStatements

In this rule, multiple identical "use" staments of the same module are merged.

For example, this code:

    use File::Temp;
    use Foobar;
    use File::Temp;

... is transformed to:

    use File::Temp;
    use Foobar;

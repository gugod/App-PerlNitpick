package App::P5Nitpick::Rule::DedupeIncludeStatements;
use Moose;
use PPI::Document;

has document => (
    is => 'ro',
    required => 1,
    isa => 'PPI::Document',
);

sub rewrite {
    my ($self) = @_;

    my %used;
    my @to_delete;
    for my $el (@{ $self->document->find('PPI::Statement::Include') ||[]}) {
        next unless $el->type && $el->type eq 'use';
        if ($used{$module}) {
            push @to_delete, $el;
            push @{ $used{$module}{args_to_append} }, $el->arguments;
        } else {
            $used{$module} = { element => $el, args_to_append => [] };
        }
    }
    
}

1;

__END__

=head1 DedupeIncludeStatements

In this rule, multiple "use" staments of the same module are merged.

For example, this code:

    use File::Temp 'tempfile';
    use Foobar;
    use File::Temp 'tempdir';

... is transformed to:

    use File::Temp ('tempfile', 'tempdir');
    use Foobar;


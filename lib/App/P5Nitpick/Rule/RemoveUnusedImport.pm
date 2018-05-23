package App::P5Nitpick::Rule::RemoveUnusedImport;
# ABSTRACT: Remove unused import

=encoding UTF-8

=head1 DESCRIPTION

This nitpicking rule removes imports that are explicitly put there, but
not used in the same file.

For example, C<Dumper> is not used this simple program:

    use Data::Dumper 'Dumper';
    print 42;

And it will be removed by this program.

=cut

use Moose;
use PPI::Document;

has document => (
    is => 'ro',
    required => 1,
    isa => 'PPI::Document',
);

sub rewrite {
    my ($self) = @_;
    my $doc = $self->document;

    ## To be implemented

    my $new_code = "$doc";
    return PPI::Document->new( \$new_code );
}

1;

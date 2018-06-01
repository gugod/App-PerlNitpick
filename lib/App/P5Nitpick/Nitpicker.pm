package App::P5Nitpick::Nitpicker;
use Moose;

has file => (
    is => 'ro',
    required => 1,
    isa => 'Str',
);

has rules => (
    is => 'ro',
    required => 1,
    isa => 'ArrayRef[Str]',
);

use App::P5Nitpick::Rule::QuoteSimpleStringWithSingleQuote;
use App::P5Nitpick::Rule::RemoveUnusedImport;
use App::P5Nitpick::Rule::RemoveEffectlessUTF8Pragma;
use App::P5Nitpick::Rule::UseMouseWithNoMouse;

use PPI::Document;
use File::Slurp qw(read_file);

sub rewrite {
    my ($self) = @_;

    my $code = read_file( $self->file );
    my $ppi = PPI::Document->new( \$code );
    for my $rule (@{$self->rules}) {
        my $rule_class = 'App::P5Nitpick::Rule::' . $rule;
        $rule_class->new( document => $ppi )->rewrite;
    }
    $ppi->save( $self->file );
    return;
}

1;

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

has inplace => (
    is => 'ro',
    required => 1,
    default  => 0,
    isa => 'Bool',
);

use App::P5Nitpick::Rule::QuoteSimpleStringWithSingleQuote;
use App::P5Nitpick::Rule::RemoveUnusedImport;
use App::P5Nitpick::Rule::RemoveEffectlessUTF8Pragma;
use App::P5Nitpick::Rule::UseMouseWithNoMouse;
use App::P5Nitpick::Rule::RemoveUnusedVariables;

use PPI::Document;
use File::Slurp qw(read_file);

sub rewrite {
    my ($self) = @_;

    my $ppi = PPI::Document->new( $self->file ) or return;
    for my $rule (@{$self->rules}) {
        my $rule_class = 'App::P5Nitpick::Rule::' . $rule;
        $rule_class->new( document => $ppi )->rewrite;
    }
    if ($self->inplace) {
        $ppi->save( $self->file );
    } else {
        $ppi->save( $self->file . ".new" );
    }
    return;
}

1;

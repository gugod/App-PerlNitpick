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

use PPI::Document;
use Module::Find qw(useall);
use File::Slurp qw(read_file);

my @rules = useall App::P5Nitpick::Rule;

sub list_rules {
    my ($class) = @_;
    for my $rule (@rules) {
        $rule =~ s/\A .+ :://x;
        print "$rule\n";
    }
    return;
}

sub rewrite {
    my ($self) = @_;

    my $ppi = PPI::Document->new( $self->file ) or return;
    for my $rule (@{$self->rules}) {
        my $rule_class = 'App::P5Nitpick::Rule::' . $rule;
        $ppi = $rule_class->new->rewrite($ppi);
    }
    if ($self->inplace) {
        $ppi->save( $self->file );
    } else {
        $ppi->save( $self->file . ".new" );
    }
    return;
}

1;

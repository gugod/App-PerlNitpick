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

# use Module::Find qw(useall);
# my @rules = sort { $a cmp $b } useall App::P5Nitpick::Rule;

# perl -Mlib=local -Ilib -MModule::Find=findallmod -E 'say "use $_;" for findallmod("App::P5Nitpick::Rule")'
use App::P5Nitpick::Rule::AppendUnimportStatement;
use App::P5Nitpick::Rule::DedupeIncludeStatements;
use App::P5Nitpick::Rule::MoreOrLessSpaces;
use App::P5Nitpick::Rule::QuoteSimpleStringWithSingleQuote;
use App::P5Nitpick::Rule::RemoveEffectlessUTF8Pragma;
use App::P5Nitpick::Rule::RemoveUnusedImport;
use App::P5Nitpick::Rule::RemoveUnusedInclude;
use App::P5Nitpick::Rule::RemoveUnusedVariables;
use App::P5Nitpick::Rule::RewriteHeredocAsQuotedString;
use App::P5Nitpick::Rule::RewriteRefWithRefUtil;
use App::P5Nitpick::Rule::RewriteWithAssignmentOperators;

my @rules = qw(AppendUnimportStatement DedupeIncludeStatements MoreOrLessSpaces QuoteSimpleStringWithSingleQuote RemoveEffectlessUTF8Pragma RemoveUnusedImport RemoveUnusedInclude RemoveUnusedVariables RewriteHeredocAsQuotedString RewriteRefWithRefUtil RewriteWithAssignmentOperators);

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

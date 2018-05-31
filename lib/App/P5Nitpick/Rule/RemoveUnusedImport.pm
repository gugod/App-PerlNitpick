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

    my @violations = $self->find_violations;
    for my $tuple (@violations) {
        my ($word, $import) = @$tuple;
        my @args_literal = $import->{expr_qw}->literal;
        my @new_args_literal = grep { $_ ne $word } @args_literal;

        if (@new_args_literal == 0) {
            # $import->{statement}->delete;
            $import->{expr_qw}{content} = 'qw()';
            $import->{expr_qw}{sections}[0]{size} = length($import->{expr_qw}{content});
        } else {
            # These 3 lines should probably be moved to the internal of PPI::Token::QuoteLike::Word
            $import->{expr_qw}{content} =~ s/\s ${word} \s/ /gsx;
            $import->{expr_qw}{content} =~ s/\b ${word} \b//gsx;
            $import->{expr_qw}{sections}[0]{size} = length($import->{expr_qw}{content});

            # my @new_args_literal = $import->{expr_qw}->literal;
            # if (@new_args_literal == 0) {
            #     $import->{statement}->delete;
            # }
        }
    }

    return $doc;
}

sub index_words {
    my ($self) = @_;
    my $include_statements = $elem->find(sub { $_[1]->isa('PPI::Statement::Include') }) || [];

    my $idx = {
        imported => {},
        modules  => {},
    };

    for my $st (@$include_statements) {
        my $included_module = $st->module;
        next if $is_special{"$included_module"};

        my $expr_qw = $st->find( sub { $_[1]->isa('PPI::Token::QuoteLike::Words'); }) or next;

        if (@$expr_qw == 1) {
            my $expr = $expr_qw->[0];

            my $expr_str = "$expr";

            # Remove the quoting characters.
            substr($expr_str, 0, 3) = '';
            substr($expr_str, -1, 1) = '';

            my @words = split ' ', $expr_str;
            for my $w (@words) {
                next if $w =~ /\A [:\-\+]/x;

                push @{ $idx->{imported}{$w} }, {
                    statement => $st,
                    expr_qw   => $expr,
                };
            }
            push @{ $idx->{imported}{$included_module} }, { statement => $st };
        }
    }

    for my $el_word (@{ $elem->find( sub { $_[1]->isa('PPI::Token::Word') }) ||[]}) {
        push @{ $idx->{used}{"$el_word"} }, $el_word;
    }

    return $idx;
}

sub find_violations {
    my ($self) = @_;

    my $elem = $self->document;

    my %imported;
    my %is_special = map { $_ => 1 } qw(use parent base constant MouseX::Foreign);

    my $include_statements = $elem->find(sub { $_[1]->isa('PPI::Statement::Include') }) || [];
    for my $st (@$include_statements) {
        next unless $st->type eq 'use';
        my $included_module = $st->module;
        next if $is_special{"$included_module"};

        my $expr_qw = $st->find( sub { $_[1]->isa('PPI::Token::QuoteLike::Words'); }) or next;

        if (@$expr_qw == 1) {
            my $expr = $expr_qw->[0];

            my $expr_str = "$expr";

            # Remove the quoting characters.
            substr($expr_str, 0, 3) = '';
            substr($expr_str, -1, 1) = '';

            my @words = split ' ', $expr_str;
            for my $w (@words) {
                next if $w =~ /\A [:\-\+]/x;
                push @{ $imported{$w} //=[] }, {
                    statement => $st,
                    expr_qw   => $expr,
                };
            }
        }
    }

    my %used;
    for my $el_word (@{ $elem->find( sub { $_[1]->isa('PPI::Token::Word') }) ||[]}) {
        $used{"$el_word"}++;
    }

    my @violations;
    my @to_report = grep { !$used{$_} } (sort keys %imported);

    for my $tok (@to_report) {
        for my $import (@{ $imported{$tok} }) {
            push @violations, [ $tok, $import ];
        }
    }

    return @violations;
}

1;

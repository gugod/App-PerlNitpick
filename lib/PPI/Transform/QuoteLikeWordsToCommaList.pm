package PPI::Transform::QuoteLikeWordsToCommaList;
use strict;
use Params::Util   qw{_INSTANCE _STRING};

use parent 'PPI::Transform';

sub document {
    my $self = shift;
    my $document = _INSTANCE(shift, 'PPI::Document') or return undef;

    my $qwtokens = $document->find('PPI::Token::QuoteLike::Words') or return undef;

    for my $tok (@$qwtokens) {
        my @words = $tok->literal;
        my $expr = '(' . join(', ', map { "'$_'" } @words) . ')';
        my $el = PPI::Structure::List->new( $expr );

        # XXX: Does not work. Because $tok and $el is different class.
        $tok->replace($el);
    }

    return 0+@$qwtokens;
}


1;

__END__


=head1 What

This transformations converts a qw() token into a list of simple
strings separated by commans, grouped with parens:

For mexample, this:

    PPI::Token::QuoteLike::Words  	'qw(foo bar baz)'

is turned into:

    PPI::Structure::List  	( ... )
      PPI::Statement::Expression
        PPI::Token::Quote::Single  	''foo''
        PPI::Token::Operator  	','
        PPI::Token::Whitespace  	' '
        PPI::Token::Quote::Single  	''bar''
        PPI::Token::Operator  	','
        PPI::Token::Whitespace  	' '
        PPI::Token::Quote::Single  	''baz''

=cut


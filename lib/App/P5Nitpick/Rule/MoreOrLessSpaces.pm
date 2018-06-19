package App::P5Nitpick::Rule::MoreOrLessSpaces;
use Moose;
use PPI::Document;
use PPI::Token::Whitespace;

has document => (
    is => 'ro',
    required => 1,
    isa => 'PPI::Document',
);

no Moose;

sub rewrite {
    my ($self) = @_;
    my $doc = $self->document;

    for my $el (@{ $doc->find('PPI::Token::Whitespace') ||[]}) {
        next unless $el->content eq "\n";

        my $prev1 = $el->previous_sibling or next;
        my $prev2 = $prev1->previous_sibling or next;
        $el->delete if $prev1->isa('PPI::Token::Whitespace') && $prev1->content eq "\n" && $prev2->isa('PPI::Token::Whitespace') && $prev2->content eq "\n";
    }

    for my $el0 (@{ $doc->find('PPI::Structure::List') ||[]}) {
        for my $el (@{ $el0->find('PPI::Token::Operator') ||[]}) {
            next unless $el->content eq ',';
            my $next_el = $el->next_sibling or next;
            if ($next_el->isa('PPI::Token::Whitespace')) {
                # Make sure there is only one whitespace
                if ($next_el->content =~ /  +/) {
                    $next_el->set_content(' ');
                }
            } else {
                # Insert a new one.
                my $wht = PPI::Token::Whitespace->new(' ');
                $el->insert_after($wht);
            }
        }
    }

    return $self->document;
}

1;

__END__

=head1 MoreOrLessSpaces

In this rule, space characters is inserted or removed within one line
between punctuation boundaries.


package App::P5Nitpick::Rule::MoreOrLessHorizontalSpaces ;
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

=head1 MoreOrLessHorizontalSpaces

In this rule, space characters is inserted or removed within one line
between punctuation boundaries.


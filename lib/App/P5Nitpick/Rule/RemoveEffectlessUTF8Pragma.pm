package App::P5Nitpick::Rule::RemoveEffectlessUTF8Pragma;
# ABSTRACT: Re-quote strings with single quotes ('') if they look "simple"

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

    my $use_utf8_statements = $doc->find(
        sub {
            my $st = $_[1];
            $st->isa('PPI::Statement::Include') && $st->schild(0) eq 'use' && $st->schild(1) eq 'utf8';
        }
    );
    return $doc unless $use_utf8_statements;
    
    my $chars_outside_ascii_range = 0;
    for (my $tok = $doc->first_token; $tok; $tok = $tok->next_token) {
        next unless $tok->significant;
        my $src = $tok->content;
        utf8::decode($src);

        my @c = split '', $src;
        for (my $i = 0; $i < @c; $i++) {
            if (ord($c[$i]) > 127) {
                $chars_outside_ascii_range++;
            }
        }
        last if $chars_outside_ascii_range;
    }

    unless ($chars_outside_ascii_range) {
        $_->remove for @$use_utf8_statements;
    }

    my $new_code = "$doc";
    return PPI::Document->new( \$new_code );
}

1;

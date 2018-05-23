package App::P5Nitpick::Rule::QuoteSimpleStrWithSingleQuote;
# ABSTRACT: Re-quote strings with single quotes ('') if they look "simple"

=head1 DESCRIPTION

This nitpicking rule re-quote simple strings with single-quote.
For example, C<"coffee"> becomes C<'coffee'>.

Simple strings are the ones that:

    - is a string literal (not variable)
    - is currently quoted with: q, qq, double-quote ("), or single-quote (')
    - has no interpolations inside
    - has no quote characters inside
    - has no sigil characters inside
    - has no metachar

For example, here's a short list of simple strings:

    - q<肆拾貳>
    - qq{Latte Art}
    - "Spring"
    - "Error: insufficient vaspin gas"

While here are some counter examples:

    - "john.smith@example.com"
    - "'s-Gravenhage"
    - 'Look at this @{[ longmess() ]}'
    - q<The symbol $ is also known as dollor sign.>

Roughly speaking, given a string, if you can re-quote it with single-quote (')
without changing its value -- then it is a simple string.

=cut

1;

#!perl
use strict;
use Test2::V0;

use App::P5Nitpick::Rule::QuoteSimpleStringWithSingleQuote;

my @tests = (
    [q{print "riho";}, q{print 'riho';}],
);

for my $t (@tests) {
    my ($code_before, $code_after) = @$t;

    my $doc = PPI::Document->new(\$code_before);
    my $o = App::P5Nitpick::Rule::QuoteSimpleStringWithSingleQuote->new();
    my $doc2 = $o->rewrite($doc);
    my $code2 = "$doc2";
    is $code2, $code_after, $code_before;
}

done_testing;


#!perl
use strict;
use Test2::V0;

use PPI::Document;
use App::P5Nitpick::Rule::DedupeIncludeStatements;

my @tests = (
    [q{use Abc; print "riho";use Abc;}, q{use Abc; print "riho";}],
);

for my $t (@tests) {
    my ($code_before, $code_after) = @$t;

    my $doc = PPI::Document->new(\$code_before);
    my $o = App::P5Nitpick::Rule::DedupeIncludeStatements->new();
    my $doc2 = $o->rewrite($doc);
    my $code2 = "$doc2";
    is $code2, $code_after, $code_before;
}

done_testing;


#!perl
use strict;
use Test2::V0;

use App::P5Nitpick::Rule::AppendUnimportStatement;

subtest 'append "no Mouse";' => sub {
    my $code = <<CODE;
package Bar;
use Mouse;
print 42;
1;
CODE

    my $doc = PPI::Document->new(\$code);
    my $o = App::P5Nitpick::Rule::AppendUnimportStatement->new();
    my $code2 = "". $o->rewrite($doc);
    ok $code2 =~ m{no Mouse;\n1;\n};
};

subtest 'append "no Moose";' => sub {
    my $code = <<CODE;
package Bar;
use Moose;
print 42;
1;
CODE

    my $doc = PPI::Document->new(\$code);
    my $o = App::P5Nitpick::Rule::AppendUnimportStatement->new();
    my $code2 = "". $o->rewrite($doc);
    ok $code2 =~ m{no Moose;\n1;\n};
};

subtest 'append "no Moo";' => sub {
    my $code = <<CODE;
package Bar;
use Moo;
print 42;
1;
CODE

    my $doc = PPI::Document->new(\$code);
    my $o = App::P5Nitpick::Rule::AppendUnimportStatement->new();
    my $code2 = "". $o->rewrite($doc);
    ok $code2 =~ m{no Moo;\n1;\n};
};

done_testing;

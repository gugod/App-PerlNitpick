#!perl
use strict;
use Test2::V0;

use App::P5Nitpick::Rule::RemoveUnusedImport;

subtest 'Remove only the imported subroutine' => sub {

    my $code = <<CODE;
use Foobar qw(Foo Baz);
print Foo(42);
CODE

    my $doc = PPI::Document->new(\$code);
    my $o = App::P5Nitpick::Rule::RemoveUnusedImport->new( document => $doc );
    my $doc2 = $o->rewrite();
    my $code2 = "$doc2";

    ok $code2 !~ m/Baz/s;
};

subtest 'Remove only the entire `use` statement' => sub {

    my $code = <<CODE;
use Foobar qw(Baz);
print 42;
CODE

    my $doc = PPI::Document->new(\$code);
    my $o = App::P5Nitpick::Rule::RemoveUnusedImport->new( document => $doc );
    my $doc2 = $o->rewrite();
    my $code2 = "$doc2";

    ok $code2 !~ m/Baz/s;
    ok $code2 !~ m/use Foobar/s;
};

done_testing;

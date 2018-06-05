package App::P5Nitpick::Rule::DedupeIncludeStatements;

1;

__END__

=head1 DedupeIncludeStatements

In this rule, multiple "use" staments of the same module are merged.

For example, this code:

    use File::Temp 'tempfile';
    use Foobar;
    use File::Temp 'tempdir';

... is transformed to:

    use File::Temp ('tempfile', 'tempdir');
    use Foobar;


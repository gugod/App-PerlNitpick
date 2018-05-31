requires 'Getopt::Long';
requires 'File::Slurp';
requires 'Moose';
requires 'PPI';
requires 'PPIx::Utils';

on test => sub {
    requires 'Test2::V0';
};

use ExtUtils::MakeMaker;

WriteMakefile(
    'AUTHOR'        => 'John McNamara (jmcnamara@cpan.org)',
    'ABSTRACT'      => 'A class for creating Pod to Wiki filters',
    'NAME'          => 'Pod::Simple::Wiki',
    'VERSION_FROM'  => 'Wiki.pm',
    'NEEDS_LINKING' => 0,
    'PREREQ_PM'     => {Pod::Simple => 0},
    'dist'          => {COMPRESS => 'gzip -best', SUFFIX => 'gz'},
);

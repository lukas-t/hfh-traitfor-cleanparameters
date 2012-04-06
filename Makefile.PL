use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'HTML::FormHandlerX::TraitFor::CleanParameters',
    AUTHOR              => q{Lukas Thiemeier <lukast@cpan.org>},
    VERSION_FROM        => 'lib/HTML/FormHandlerX/TraitFor/CleanParameters.pm',
    ABSTRACT_FROM       => 'lib/HTML/FormHandlerX/TraitFor/CleanParameters.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
	'HTML::FormHandler' => "0.40",
	'Moose' => 0,
	'Moose::Role' => 0,
	'Data:.Clone' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'HTML-FormHandlerX-TraitFor-CleanParameters-*' },
);

use ExtUtils::MakeMaker;

WriteMakefile
(
	'NAME'		=>	'BM::API',
	'VERSION_FROM'	=>	'lib/BM/API.pm',
	'PREREQ_PM'	=>	{
		'LWP::UserAgent'	=>	0,
		'JSON'			=>	0,
		'MIME::Base64'		=>	0
	}

);


use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "An API for communicating with ElasticSearch",
  "AUTHOR" => "Clinton Gormley <drtech\@cpan.org>",
  "BUILD_REQUIRES" => {
    "ElasticSearch::SearchBuilder" => 0,
    "File::Temp" => "0.20",
    "Test::Differences" => 0,
    "Test::Exception" => 0,
    "Test::More" => "0.96"
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "ElasticSearch",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "ElasticSearch",
  "PREREQ_PM" => {
    "Any::URI::Escape" => 0,
    "Carp" => 0,
    "Data::Dumper" => 0,
    "ElasticSearch::SearchBuilder" => "0.14",
    "Encode" => 0,
    "Exporter" => 0,
    "File::Path" => 0,
    "File::Spec::Functions" => 0,
    "File::Temp" => "0.22",
    "HTTP::Lite" => 0,
    "HTTP::Request" => 0,
    "HTTP::Tiny" => 0,
    "IO::Handle" => 0,
    "IO::Socket" => 0,
    "IO::Uncompress::Inflate" => 0,
    "JSON" => 0,
    "LWP::ConnCache" => 0,
    "LWP::UserAgent" => 0,
    "List::Util" => 0,
    "POSIX" => 0,
    "Scalar::Util" => "1.07",
    "Task::Weaken" => 0,
    "URI" => 0,
    "YAML" => 0,
    "constant" => 0,
    "overload" => 0,
    "parent" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.54",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);





use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "The official client for Elasticsearch",
  "AUTHOR" => "Clinton Gormley <drtech\@cpan.org>",
  "BUILD_REQUIRES" => {
    "Test::More" => "0.98"
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Elasticsearch",
  "EXE_FILES" => [],
  "LICENSE" => "apache",
  "NAME" => "Elasticsearch",
  "PREREQ_PM" => {
    "Any::URI::Escape" => 0,
    "Data::Dumper" => 0,
    "Encode" => 0,
    "HTTP::Tiny" => "v0.33.0",
    "IO::Select" => 0,
    "IO::Socket::SSL" => 0,
    "IO::Uncompress::Inflate" => 0,
    "JSON" => 0,
    "List::Util" => 0,
    "Log::Any" => 0,
    "Log::Any::Adapter" => 0,
    "MIME::Base64" => 0,
    "Module::Runtime" => 0,
    "Moo" => 0,
    "Moo::Role" => 0,
    "Scalar::Util" => 0,
    "Sub::Exporter" => 0,
    "Time::HiRes" => 0,
    "Try::Tiny" => 0,
    "URI" => 0,
    "namespace::autoclean" => 0,
    "overload" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "TEST_REQUIRES" => {
    "Exporter" => 0,
    "File::Basename" => 0,
    "Log::Any::Adapter::Callback" => 0,
    "Test::Deep" => 0,
    "Test::Exception" => 0,
    "Test::More" => 0,
    "YAML" => 0,
    "lib" => 0
  },
  "VERSION" => "0.71",
  "test" => {
    "TESTS" => "t/*.t t/10_Basic/*.t t/20_Serializer/*.t t/30_Logger/*.t t/40_Transport/*.t t/50_Cxn_Pool/*.t t/60_Cxn/*.t t/70_Helper/*.t t/90_Client_Spec/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  my $tr = delete $WriteMakefileArgs{TEST_REQUIRES};
  my $br = $WriteMakefileArgs{BUILD_REQUIRES};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

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




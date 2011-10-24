
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "File::Temp" => "0.20",
    "Module::Build" => "0.3601",
    "Test::Differences" => 0,
    "Test::Exception" => 0,
    "Test::More" => "0.96"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "An API for communicating with ElasticSearch",
  "dist_author" => [
    "Clinton Gormley <drtech\@cpan.org>"
  ],
  "dist_name" => "ElasticSearch",
  "dist_version" => "0.47",
  "license" => "perl",
  "module_name" => "ElasticSearch",
  "recommends" => {
    "JSON::XS" => 0,
    "URI::Escape::XS" => 0
  },
  "recursive_test_files" => 1,
  "requires" => {
    "Any::URI::Escape" => 0,
    "Data::Dumper" => 0,
    "ElasticSearch::SearchBuilder" => "0.07",
    "Encode" => 0,
    "Exporter" => 0,
    "File::Path" => 0,
    "File::Spec::Functions" => 0,
    "File::Temp" => "0.20",
    "HTTP::Lite" => 0,
    "HTTP::Request" => 0,
    "HTTP::Tiny" => 0,
    "IO::Socket" => 0,
    "IO::Uncompress::Inflate" => 0,
    "JSON" => 0,
    "LWP::ConnCache" => 0,
    "LWP::UserAgent" => 0,
    "List::Util" => 0,
    "POSIX" => 0,
    "Scalar::Util" => "1.07",
    "URI" => 0,
    "YAML" => 0,
    "base" => 0,
    "constant" => 0,
    "overload" => 0,
    "parent" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => []
);


use ExtUtils::CBuilder;

if ( !( grep { $_ eq '--pp' } @ARGV )
    && ExtUtils::CBuilder->new()->have_compiler )
{
    my $recommends = $module_build_args{recommends} || {};
    my $requires   = $module_build_args{requires}   || {};
    my @modules    = qw();
    @modules       = grep {/\bXS\b/} keys %$recommends
        unless @modules;
    $requires->{$_} = delete $recommends->{$_} || 0
        for @modules;
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;

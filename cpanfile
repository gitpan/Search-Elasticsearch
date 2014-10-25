requires "Any::URI::Escape" => "0";
requires "Data::Dumper" => "0";
requires "Encode" => "0";
requires "HTTP::Tiny" => "v0.33.0";
requires "IO::Select" => "0";
requires "IO::Socket::SSL" => "0";
requires "IO::Uncompress::Inflate" => "0";
requires "JSON" => "0";
requires "List::Util" => "0";
requires "Log::Any" => "0";
requires "Log::Any::Adapter" => "0";
requires "MIME::Base64" => "0";
requires "Module::Runtime" => "0";
requires "Moo" => "0";
requires "Moo::Role" => "0";
requires "Scalar::Util" => "0";
requires "Sub::Exporter" => "0";
requires "Time::HiRes" => "0";
requires "Try::Tiny" => "0";
requires "URI" => "0";
requires "namespace::autoclean" => "0";
requires "overload" => "0";
requires "strict" => "0";
requires "warnings" => "0";
recommends "JSON::XS" => "0";
recommends "URI::Escape::XS" => "0";

on 'build' => sub {
  requires "Test::More" => "0.98";
};

on 'test' => sub {
  requires "Exporter" => "0";
  requires "File::Basename" => "0";
  requires "Log::Any::Adapter::Callback" => "0";
  requires "Test::Deep" => "0";
  requires "Test::Exception" => "0";
  requires "Test::More" => "0";
  requires "YAML" => "0";
  requires "lib" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "6.30";
};

on 'develop' => sub {
  requires "Test::More" => "0";
  requires "Test::NoTabs" => "0";
  requires "Test::Pod" => "1.41";
};

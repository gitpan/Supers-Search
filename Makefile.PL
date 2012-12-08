
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Search model for soysuper",
  "AUTHOR" => "Diego Kuperman <diego\@freekeylabs.com>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Supers-Search",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Supers::Search",
  "PREREQ_PM" => {
    "Elastic::Doc" => 0,
    "Elastic::Model" => 0,
    "MooseX::Types::Moose" => 0,
    "MooseX::Types::Structured" => 0,
    "Supers::Image::Identity" => 0
  },
  "VERSION" => "1.123430",
  "test" => {
    "TESTS" => ""
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




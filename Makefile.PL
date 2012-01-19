#!/usr/bin/perl
use strict;
use ExtUtils::MakeMaker;

my $prereqs = {
  'Cwd'  => 0,
  'Set::Crontab'  => 0,
  'Schedule::Cron::Events' => 0,
  'Storable'  => 0,
  'Time::HiRes'  => 0,
  'Time::Local'  => 0,
  'Yandex::Tools' => 0,
  };

WriteMakefile(
  NAME          => 'snaked',
  VERSION_FROM  => 'lib/snaked.pm',
  ABSTRACT_FROM => 'lib/snaked.pm',
  EXE_FILES     => [ 'snaked' ],
  PREREQ_PM     => $prereqs,
  AUTHOR     => 'Petya Kohts <petya@kohts.ru>',
  );

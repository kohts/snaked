package snaked;

use vars qw($VERSION);
$VERSION = '0.07';

use strict;
use warnings;


1;

__END__

=head1 NAME

snaked - cron as it should be.

=head1 SYNOPSIS

  # import old cron jobs (TO BE IMPLEMENTED)
  snaked --import-crontabs

  # check which jobs are configured
  snaked --show-jobs

  # rock with snake
  snaked --daemon

  # (and do not forget to stop old cron
  # so your jobs are not run twice)

=head1 DESCRIPTION

B<snaked> is a job scheduler, just like cron,
which has several unique features making it
much more flexible and useful than any other
cron implementation.

It is heavily tested on Linux and FreeBSD
but might (and hopefully with your help will)
be run on any Perl + POSIX compliant system.

=head2 limit job execution time

You can choose to configure the maximum limit of time
for each job to finish. If job doesn't finish in time
it is killed. The limit is independently configurable
for each job. Forget about lockf, ps -ef | grep -v grep
and cron jobs being run twice and more times concurrently.

You can also configure the upper limit of execution time
of any job of the given snaked instance. This global limit
is checked independently of the individual
job execution time limits.

=head2 unique job id and job dependencies

Each snaked job has its unique job identifier
which is used to configure job dependencies:
for any job you can specify other jobs
(addressed by their identifiers) which
shouldn't be run with this job concurrently.

So if job A is being executed and time comes
to start job B which is configured as conflicting
with job A, then the start of job B is postponed
until job A is finished.

=head2 more often than once a minute

snaked allows jobs to be run more often than once a minute.

Actually snaked supports two execution schedule formats:
old cron format with not less than a minute time resolution
and snaked job schedule format which specifies how often
the jobs is run in seconds, making it possible to run job
even once a second!

=head1 CONFIGURATION EXAMPLE

snaked configuration is a directory which contains
global instance options (each option in separate file)
and associated job definitions where job definition
is also a directory with each job option
stored in a separate file:

  .
  |-- admin_email
  |-- jobs
  |   |-- every_hour
  |   |   |-- cmd
  |   |   `-- execution_schedule
  |   |-- every_ten_seconds
  |   |   |-- cmd
  |   |   `-- execution_interval
  |   `-- fast_job
  |       |-- cmd
  |       |-- conflicts
  |       `-- execution_interval
  `-- log

Above shown configuration defines admin_email
for the snaked instance (optional, defaults to root)
and log file path (optional, defaults to /tmp/snaked.log):

  testing18:/etc/snaked# cat admin_email
  root
  testing18:/etc/snaked# cat log
  /var/log/snaked/snaked.log

There are three jobs named every_hour, every_ten_seconds
and fast_job. All of them contain cmd file -- an executable
which is run by snaked (this can be any executable
allowed by underlying operating system):

  testing18:/etc/snaked/jobs/every_hour# ls -l cmd
  -rwxr-xr-x 1 root root 0 2010-07-07 00:24 cmd
  testing18:/etc/snaked/jobs/every_hour# file cmd
  cmd: POSIX shell script text executable

First job, every_hour, has a parameter execution_schedule
which is an old cron schedule example (parsed by L<Schedule::Cron::Events>):

  testing18:/etc/snaked/jobs/every_hour# cat execution_schedule
  0 * * * *

Two other jobs use snaked execution_interval schedule,
specifying that every_ten_seconds job should be run
once in ten seconds, and fast_job should be run
once in every second.

  testing18:/etc/snaked/jobs/every_ten_seconds# cat execution_interval
  10
  testing18:/etc/snaked/jobs/fast_job# cat execution_interval
  1

To make it a bit more explanatory we've defined conflicts option
for fast_job which specifies that fast_job should not be run
if every_ten_seconds is running:

  testing18:/etc/snaked/jobs/fast_job# cat conflicts
  every_ten_seconds

Which translates to "try to run 'fast_job' as often as once a second,
but wait if 'every_ten_seconds' job is running".

=head1 DAEMON OPTIONS

=over 4

=item admin_email

Optional. Where to send emails about failing jobs. Defaults to root.

=item log

Optional. Name of the log filename which holds all the log messages
including informational and error messages. Defaults to /tmp/snaked.log.

=item log_errors

Optional. Name of the log filename used only for error messages.
Defaults to nothing, turning off separate error logging.

=item log_rotate_size

Optional. Size of the log file after which it is rotated.
Defaults to 10 MB.

=item log_rotate_keep_copies

Optional. Number of rotated log files to preserve.
Defaults to 2.

=item max_job_time

Optional. Specifies maximum exeuction time limit for all the jobs.
Defaults to 2 hours.

=item pidfile

Optional. Filename of the pidfile where snaked stores
the pid of its main process. Defaults to nothing,
which does not generate any pidfile.

=back

=head1 JOB OPTIONS

=over 4

=item admin_email

Optional. Where toe send emails about failures of this job.
Defaults to global admin_email option (and overrides it). 

=item cmd

Mandatory. Executable with correct file permissions (executable bit on)
which is allowed by underlying operating system. Can be shell script or binary.

=item execution_interval, execution_schedule

Only one parameter, execution_interval or execution_schedule, is allowed
and is mandatory for one job. execution_interval specifies number of seconds
(positive integer) between invocations of cmd. execution_schedule specifies
standard cron format schedule (first five fields) for the job.

=item execution_timeout

Optional. Specifies time limit for the job, in seconds.
Defaults to nothing, turning time limit off.

=item kill_timeout

Optional. Specifies time in seconds between TERM and KILL signals
sent to the job when snaked needs to stop the job (when snaked
stop or restarts, when job runs too long). Defaults to 60 seconds.

=item notification_interval

Optional. Time period in seconds. Job failure emails are not sent
more often than this time period. First email is sent after
first time period of constant failures. This option is used
to suppress emails about accidental job failures. Defaults to 0,
which turns the feature off (delivers email on every job failure).

=item start_random_sleep

Optional. Time period in seconds which specifoes random
first run shift in time for the job. Defaults to 0,
which turns the feature off.

=item conflicts

Optional. Space/line separated list of job identifiers
which should not be run while this job is run. If any
job from this list is currently being executed
then the job owning the option will not be executed.
Defaults to nothing, allowing the job to be run
independently of the status of any other job.

snaked organizes conflicting jobs into job groups,
running every job from the job group one by one
(if the time for the job has come). This guarantees
that every conflicting job is run from time to time
though its start time might be shifted because of
waiting for the conflicting jobs.

=back

=head1 CREDITS

Thank you to Yandex team (in alphabetic order):

  Denis Barov
  Maxim Dementyev
  Eugene Fedotov
  Andrey Grunau
  Andrey Ignatov
  Dmitry Parfenov
  Alexey Simakov
  Julie S Ukhlicheva
  Anton Ustyugov
  Andrey Zonov

for their bug reports, suggestions and contributions.

=head1 AUTHORS

Petya Kohts E<lt>petya@kohts.ruE<gt>

=head1 COPYRIGHT

Copyright 2009 - 2010 Petya Kohts.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

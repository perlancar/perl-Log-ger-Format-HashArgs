package Log::ger::Plugin::HashArgs;

# AUTHORITY
# DATE
# DIST
# VERSION

use strict;
use warnings;

use Log::ger::Util;

sub get_hooks {
    my %conf = @_;

    my $sub_name    = $conf{sub_name}    || "log";
    my $method_name = $conf{method_name} || "log";

    return {
        create_filter => [
            __PACKAGE__, # key
            50,          # priority
            sub {        # hook
                my %hook_args = @_; # see Log::ger::Manual::Internals/"Arguments passed to hook"

                my $filter = sub {
                    my %log_args = @_;
                    # die "$logger_name(): Please specify 'level'" unless exists $log_args{level};
                    my $level = Log::ger::Util::numeric_level($log_args{level});
                    return 0 unless $level <= $Log::ger::Current_Level;
                    {level=>$level};
                };

                [$filter, 0, 'ml_hashargs'];
            },
        ],

        create_formatter => [
            __PACKAGE__, # key
            50,          # priority
            sub {        # hook
                my %hook_args = @_; # see Log::ger::Manual::Internals/"Arguments passed to hook"

                my $formatter = sub {
                    my %log_args = @_;
                    $log_args{message};
                };

                [$formatter, 0, 'ml_hashargs'];
            },
        ],

        create_routine_names => [
            __PACKAGE__, # key
            50,          # priority
            sub {        # hook
                my %hook_args = @_; # see Log::ger::Manual::Internals/"Arguments passed to hook"

                return [{
                    log_subs    => [[$sub_name   , undef, 'ml_hashargs', undef, 'ml_hashargs']],
                    log_methods => [[$method_name, undef, 'ml_hashargs', undef, 'ml_hashargs']],
                }, $conf{exclusive}];
            },
        ],

    };
}

1;
# ABSTRACT: Log using hash arguments

=for Pod::Coverage ^(.+)$

=head1 SYNOPSIS

 use Log::ger::Plugin 'HashArgs', (
     # sub_name    => 'log_it', # the default name is 'log'
     # method_name => 'log_it', # the default name is 'log'
     # exclusive => 1,          # optional, defaults to 0
 );
 use Log::ger::Output 'Screen';
 use Log::ger;

 log(level => 'info', message => 'an info message ...'); # won't be output to screen
 log(level => 'warn', message => 'a warning!');          # will be output


=head1 DESCRIPTION

This is a plugin to log using a single log subroutine that is passed the message
as well as the level, using hash arguments.

Note: the multilevel log is slightly slower because of the extra argument and
additional string level -> numeric level conversion. See benchmarks in
L<Bencher::Scenarios::LogGer>.

Note: the individual separate C<log_LEVEL> subroutines (or C<LEVEL> methods) are
still installed, unless you specify configuration L</exclusive> to true.


=head1 CONFIGURATION

=head2 sub_name

Str. Logger subroutine name. Defaults to C<log> if not specified.

=head2 method_name

Str. Logger method name. Defaults to C<log> if not specified.

=head2 exclusive

Boolean. If set to true, will block the generation of the default C<log_LEVEL>
subroutines or C<LEVEL> methods (e.g. C<log_warn>, C<trace>, ...).


=head1 SEE ALSO

L<Log::ger::Like::LogDispatch> which uses this plugin. The interface provided by
this HashArgs plugin is similar to L<Log::Dispatch> interface.

L<Log::ger::Plugin::MultilevelLog>

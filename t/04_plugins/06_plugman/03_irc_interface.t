use strict;
use warnings FATAL => 'all';
use lib 't/inc';
use POE;
use POE::Component::IRC::State;
use POE::Component::IRC::Plugin::PlugMan;
use POE::Component::Server::IRC;
use Test::More tests => 12;

my $bot1 = POE::Component::IRC::State->spawn(
    Flood        => 1,
    plugin_debug => 1,
);
my $bot2 = POE::Component::IRC::State->spawn(
    Flood        => 1,
    plugin_debug => 1,
);
my $ircd = POE::Component::Server::IRC->spawn(
    Auth      => 0,
    AntiFlood => 0,
);

$bot1->plugin_add(PlugMan => POE::Component::IRC::Plugin::PlugMan->new(
    botowner => 'TestBot2!*@*',
));

POE::Session->create(
    package_states => [
        main => [qw(
            _start
            ircd_listener_add
            ircd_listener_failure
            _shutdown
            irc_001
            irc_chan_sync
            irc_public
            irc_disconnected
        )],
    ],
);

$poe_kernel->run();

sub _start {
    my ($kernel) = $_[KERNEL];

    $ircd->yield('register', 'all');
    $ircd->yield('add_listener');
    $kernel->delay(_shutdown => 60, 'Timed out');
}

sub ircd_listener_failure {
    my ($kernel, $op, $reason) = @_[KERNEL, ARG1, ARG3];
    $kernel->yield('_shutdown', "$op: $reason");
}

sub ircd_listener_add {
    my ($kernel, $port) = @_[KERNEL, ARG0];

    $bot1->yield(register => 'all');
    $bot1->yield(connect => {
        nick    => 'TestBot1',
        server  => '127.0.0.1',
        port    => $port,
    });

    $bot2->yield(register => 'all');
    $bot2->yield(connect => {
        nick    => 'TestBot2',
        server  => '127.0.0.1',
        port    => $port,
    });
}

sub irc_001 {
    my $irc = $_[SENDER]->get_heap();
    pass('Logged in');
    $irc->yield(join => '#testchannel');
}

sub irc_chan_sync {
    my ($heap, $where) = @_[HEAP, ARG0];
    is($where, '#testchannel', 'Joined Channel Test');

    $heap->{joined}++;
    if ($heap->{joined} == 2) {
        $bot2->yield(privmsg => $where, $bot1->nick_name() . ': plugin_add CTCP POE::Component::IRC::Plugin::CTCP');
        $bot2->yield(privmsg => $where, $bot1->nick_name() . ': plugin_reload CTCP');
        $bot2->yield(privmsg => $where, $bot1->nick_name() . ': plugin_del CTCP');
    }
}

sub irc_public {
    my $irc = $_[SENDER]->get_heap();
    if ($irc == $bot1) {
        pass('Got command');
    }
    else {
        pass('Got response');
        $_[HEAP]->{response}++;
        if ($_[HEAP]->{response} == 3) {
            $bot1->yield('quit');
            $bot2->yield('quit');
        }
    }
}

sub irc_disconnected {
    my ($kernel, $heap) = @_[KERNEL, HEAP];
    pass('irc_disconnected');
    $heap->{count}++;
    $kernel->yield('_shutdown') if $heap->{count} == 2;
}

sub _shutdown {
    my ($kernel, $error) = @_[KERNEL, ARG0];
    fail($error) if defined $error;

    $kernel->alarm_remove_all();
    $ircd->yield('shutdown');
    $bot1->yield('shutdown');
    $bot2->yield('shutdown');
}


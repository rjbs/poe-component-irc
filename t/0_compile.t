use strict;
use warnings;
use Test::More;

my @modules = qw(
    POE::Filter::IRC
    POE::Filter::IRC::Compat
    POE::Filter::CTCP
    POE::Component::IRC
    POE::Component::IRC::State
    POE::Component::IRC::Qnet
    POE::Component::IRC::Qnet::State
    POE::Component::IRC::Constants
    POE::Component::IRC::Common
    POE::Component::IRC::Test::Plugin
    POE::Component::IRC::Test::Harness
    POE::Component::IRC::Projects
    POE::Component::IRC::Plugin
    POE::Component::IRC::Plugin::Whois
    POE::Component::IRC::Plugin::Proxy
    POE::Component::IRC::Plugin::PlugMan
    POE::Component::IRC::Plugin::NickServID
    POE::Component::IRC::Plugin::NickReclaim
    POE::Component::IRC::Plugin::Logger
    POE::Component::IRC::Plugin::ISupport
    POE::Component::IRC::Plugin::FollowTail
    POE::Component::IRC::Plugin::Console
    POE::Component::IRC::Plugin::Connector
    POE::Component::IRC::Plugin::CTCP
    POE::Component::IRC::Plugin::CycleEmpty
    POE::Component::IRC::Plugin::BotTraffic
    POE::Component::IRC::Plugin::BotAddressed
    POE::Component::IRC::Plugin::AutoJoin
    POE::Component::IRC::Plugin::BotCommand
    POE::Component::IRC::Plugin::DCC
);

plan tests => scalar @modules;
use_ok($_) for @modules;

no warnings;
diag("Testing POE-Component-IRC $POE::Component::IRC::VERSION (svn r$POE::Component::IRC::REVISION) with POE $POE::VERSION and Perl $^V ($^X)");

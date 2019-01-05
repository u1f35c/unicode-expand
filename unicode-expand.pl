use strict;
use warnings;

use utf8;
use Encode qw(decode_utf8);
use charnames ();

use Irssi;
our $VERSION = '1.50';
our %IRSSI = (
    authors     => 'Jonathan McDowell',
    contact     => 'noodles@earth.li',
    name        => 'unicode-expand',
    description => 'Expands Unicode characters to include their names',
    license     => 'Public Domain',
    changed     => "Fri Dec  8 13:39:00 UTC 2017",
    url         => 'https://the.earth.li/~noodles/unicode-expand.pl',
);

sub expand_message_public {
    my ($server, $data, $nick, $mask, $target) = @_;
    Irssi::signal_continue($server, expand($server, $target, $data),
                           $nick, $mask, $target);
}

sub expand_message_private {
    my ($server, $data, $nick, $mask) = @_;
    Irssi::signal_continue($server, expand($server, $nick, $data),
                           $nick, $mask);
}

sub expand_part {
    my ($server, $channel, $nick, $mask, $reason) = @_;
    Irssi::signal_continue($server, $channel, $nick, $mask,
                           expand($server, $channel, $reason));
}

sub expand_quit {
    my ($server, $nick, $mask, $reason) = @_;
    Irssi::signal_continue($server, $nick, $mask,
                           expand($server, $nick, $reason));
}

sub expand_kick {
    my ($server, $channel, $nick, $kicker, $mask, $reason) = @_;
    Irssi::signal_continue($server, $channel, $nick, $kicker, $mask,
                           expand($server, $channel, $reason));
}

sub expand_topic {
    my ($server, $channel, $topic, $nick, $mask) = @_;
    Irssi::signal_continue($server, $channel,
                           expand($server, $channel, $topic), $nick, $mask);
}

sub expand_char {
    my ($char) = @_;

    my $name = charnames::viacode(ord $1);
    $name = sprintf("{%X}", ord $1) unless defined($name);

    return $name;
}

sub expand {
    my ($server, $target, $data) = @_;

    $data = decode_utf8($data);
    $data =~ s{([^\p{Letter}\p{Punctuation}\p{Control}\p{Space}\p{Sc}[:ascii:]])}{
        "${1} [".expand_char($1)."]"
    }ge;

    return $data;
}

Irssi::signal_add('message public', \&expand_message_public);
Irssi::signal_add('message private', \&expand_message_private);
Irssi::signal_add('message part', \&expand_part);
Irssi::signal_add('message quit', \&expand_quit);
Irssi::signal_add('message kick', \&expand_kick);
Irssi::signal_add('message topic', \&expand_topic);
Irssi::signal_add('message irc action', \&expand_message_public);
Irssi::signal_add('message irc notice', \&expand_message_public);

#!/usr/bin/env raku

use YAMLish;
use Twitter;

sub MAIN (
    Bool :$yes,            #= Tweet for real. dry-run otherwise.
    IO::Path(Str) :$config #= Path to an existing twitter.yml config file.
) {

    my $tweet = $*IN.slurp;

    if $config && $yes {
        send-tweet($config, $tweet);
    }

    return 0;
}

sub send-tweet (IO::Path $config, Str $tweet) {
    my %config = load-yaml(slurp($config));
    my $twitter = Twitter.new:
               consumer-key => %config<consumer_key>,
               consumer-secret => %config<consumer_secret>,
               access-token => %config<access_token>,
               access-token-secret => %config<access_token_secret>;

    my %res = $twitter.tweet: $tweet;

    if (%res<id_str>) {
        say "https://twitter.com/{ %res<user><screen_name> }/status/{ %res<id_str> }";
        return True;
    } else {
        $*ERR.say: "Failed: { %res.gist }";
        return False;
    }
}

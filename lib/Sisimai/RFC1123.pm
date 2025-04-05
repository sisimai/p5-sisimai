package Sisimai::RFC1123;
use v5.26;
use strict;
use warnings;
use Sisimai::String;

state $Sandwiched = [
    # (Postfix) postfix/src/smtp/smtp_proto.c: "host %s said: %s (in reply to %s)",
    # - <kijitora@example.com>: host re2.example.com[198.51.100.2] said: 550 ...
    # - <kijitora@example.org>: host r2.example.org[198.51.100.18] refused to talk to me:
    ["host ", " said: "],
    ["host ", " talk to me: "],
    ["while talking to ", ":"], # (Sendmail) ... while talking to mx.bouncehammer.jp.:
    ["host ", " ["],            # (Exim) host mx.example.jp [192.0.2.20]: 550 5.7.0 
    [" by ", ". ["],            # (Gmail) ...for the recipient domain example.jp by mx.example.jp. [192.0.2.1].

    # (MailFoundry)
    # - Delivery failed for the following reason: Server mx22.example.org[192.0.2.222] failed with: 550...
    # - Delivery failed for the following reason: mail.example.org[192.0.2.222] responded with failure: 552..
    ["delivery failed for the following reason: ", " with"],
    ["remote system: ", "("],   # (MessagingServer) Remote system: dns;mx.example.net (mx. -- 
    ["smtp server <", ">"],     # (X6) SMTP Server <smtpd.libsisimai.org> rejected recipient ...
    ["-mta: ", ">"],            # (MailMarshal) Reporting-MTA:      <rr1.example.com>
    [" : ", "["],               # (SendGrid) cat:000000:<cat@example.jp> : 192.0.2.1 : mx.example.jp:[192.0.2.2]...
];
state $StartAfter = [
    "generating server: ",      # (Exchange2007) en-US/Generating server: mta4.example.org
    "serveur de g",             # (Exchange2007) fr-FR/Serveur de gè¾¿îè¾¿òation
    "server di generazione",    # (Exchange2007) it-CH
    "genererande server",       # (Exchange2007) sv-SE
];
state $ExistUntil = [
    " did not like our ",       # (Dragonfly) mail-inbound.libsisimai.net [192.0.2.25] did not like our DATA: ...
];

sub is_internethost {
    # Check that the argument is a valid Internet hostname or not
    # @param    [String] argv0  String to be checked
    # @return   [Boolean]       0: is not a valid hostname
    #                           1: is a valid hostname
    # @since v5.2.0
    my $class = shift;
    my $argv0 = shift || return 0;

    return 0 if length $argv0 > 255 || length $argv0 < 4;
    return 0 if index($argv0, ".") == -1;
    return 0 if index($argv0, "..") > -1;
    return 0 if index($argv0, "--") > -1;
    return 0 if index($argv0, ".") ==  0;
    return 0 if index($argv0, "-") ==  0;
    return 0 if substr($argv0, -1, 1) eq "-";

    my $hostnameok = 1;
    my @characters = split("", uc $argv0);
    for my $e ( @characters ) {
        # Check each characater is a number or an alphabet
        my $f = ord $e;
        if( $f  < 45            ) { $hostnameok = 0; last } # 45 = '-'
        if( $f == 47            ) { $hostnameok = 0; last } # 47 = '/'
        if( $f  > 57 && $f < 65 ) { $hostnameok = 0; last } # 57 = '9', 65 = 'A'
        if( $f  > 90            ) { $hostnameok = 0; last } # 90 = 'Z'
    }
    return 0 if $hostnameok == 0;

    my $p1 = rindex($argv0, ".");
    my $cv = substr($argv0, $p1 + 1,); return 0 if length $cv > 63;
    for my $e ( split("", $cv) ) {
        # The top level domain should not include a number
        my $f = ord $e;
        if( $f > 47 && $f < 58 ) { $hostnameok = 0; last }
    }
    return $hostnameok;
}

sub find {
    # find() returns a valid internet hostname found from the argument
    # @param    string argv1  String including hostnames
    # @return   string        A valid internet hostname found in the argument
    # @since v5.2.0
    my $class = shift;
    my $argv1 = shift || return "";

    my $sourcetext = lc $argv1;
    my $sourcelist = [];
    my $foundtoken = [];
    my $thelongest = 0;
    my $hostnameis = "";

    # Replace some string for splitting by " "
    # - mx.example.net[192.0.2.1] => mx.example.net [192.0.2.1]
    # - mx.example.jp:[192.0.2.1] => mx.example.jp :[192.0.2.1]
    s/\[/ [/g, s/\(/ (/g, s/</ </g for $sourcetext; # Prefix a space character before each bracket
    s/\]/] /g, s/\)/) /g, s/</> /g for $sourcetext; # Suffix a space character behind each bracket
    s/:/: /g, s/;/; /g             for $sourcetext; # Suffix a space character behind : and ;
    $sourcetext =  Sisimai::String->sweep($sourcetext);

    MAKELIST: while(1) {
        for my $e ( @$Sandwiched ) {
            # Check a hostname exists between the $e->[0] and $e->[1] at array "Sandwiched"
            # Each array in Sandwiched have 2 elements
            next unless Sisimai::String->aligned(\$sourcetext, $e);

            my $p1 = index($sourcetext, $e->[0]);
            my $p2 = index($sourcetext, $e->[1]);
            my $cw = length $e->[0];
            next if $p1 + $cw >= $p2;

            $sourcelist = [split(" ", substr($sourcetext, $p1 + $cw, $p2 - $cw - $p1))];
            last MAKELIST;
        }

        # Check other patterns which are not sandwiched
        for my $e ( @$StartAfter ) {
            # $StartAfter have some strings, not an array.
            my $p1 = index($sourcetext, $e); next if $p1 < 0;
            my $cw = length $e;
            $sourcelist = [split(" ", substr($sourcetext, $p1 + $cw,))];
            last MAKELIST;
        }

        for my $e ( @$ExistUntil ) {
            # ExistUntil have some strings, not an array.
            my $p1 = index($sourcetext, $e); next if $p1 < 0;
            $sourcelist = [split(" ", substr($sourcetext, 0, $p1))];
            last MAKELIST;
        }

        $sourcelist = [split(" ", $sourcetext)] if scalar @$sourcelist == 0;
        last MAKELIST;
    }

    for my $e ( @$sourcelist ) {
        # Pick some strings which is 4 or more length, is including "." character
        substr($e, -1, 1, "") if substr($e, -1, 1) eq ".";  # Remove "." at the end of the string
        $e =~ y/[]()<>:;//d;                                # Remove brackets, colon, and semi-colon

        next if length $e < 4 || index($e, ".") < 0 || __PACKAGE__->is_internethost($e) == 0;
        push @$foundtoken, $e;
    }
    return ""               if scalar @$foundtoken == 0;
    return $foundtoken->[0] if scalar @$foundtoken == 1;

    for my $e ( @$foundtoken ) {
        # Returns the longest hostname
        my $cw = length $e; next if $thelongest >= $cw;
        $hostnameis = $e;
        $thelongest = $cw;
    }
    return $hostnameis;
}

1;
__END__
=encoding utf-8

=head1 NAME

Sisimai::RFC1123 - Internet hostname related class

=head1 SYNOPSIS

    use Sisimai::RFC1123;

    print Sisimai::RFC1123->is_internethost("mx2.example.jp"); # 1
    print Sisimai::RFC1123->is_internethost("localhost");      # 0


=head1 DESCRIPTION

C<Sisimai::RFC1123> is a class related to the Internet hosts

=head1 CLASS METHODS

=head2 C<B<is_internethost(I<String>)>>

C<is_internethost()> method returns true when the argument is a valid hostname

    print Sisimai::RFC1123->is_internethost("mx2.example.jp"); # 1
    print Sisimai::RFC1123->is_internethost("localhost");      # 0

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2024,2025 azumakuniyuki, All rights reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut


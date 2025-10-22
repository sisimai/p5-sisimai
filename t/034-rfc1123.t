use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::RFC1123;

my $Package = 'Sisimai::RFC1123';
my $Methods = { 'class'  => ['is_internethost', 'find'], 'object' => [] };

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
    my $hostnames0 = [
        '',
        '127.0.0.1',
        'cat',
        'neko',
        'nyaan.22',
        'mx0.example.22',
        'mx0.example.jp-',
        'mx--0.example.jp',
        'mx..0.example.jp',
        'mx0.example.jp/neko',
    ];
    my $hostnames1 = [
        'localhost',
        'localhost6',
        'mx1.example.jp',
        'mx1.example.jp.',
        'a.jp',
    ];
    my $serversaid = [
        '<neko@example.jp>: host neko.example.jp[192.0.2.2] said: 550 5.7.1 This message was not accepted due to domain (libsisimai.org) owner DMARC policy',
        'neko.example.jp[192.0.2.232]: server refused to talk to me: 421 Service not available, closing transmission channel',
        '... while talking to neko.example.jp.: <<< 554 neko.example.jp ESMTP not accepting connections',
        'host neko.example.jp [192.0.2.222]: 500 Line limit exceeded',
        'Google tried to deliver your message, but it was rejected by the server for the recipient domain nyaan.jp by neko.example.jp. [192.0.2.2].',
        'Delivery failed for the following reason: Server neko.example.jp[192.0.2.222] failed with: 550 <kijitora@example.jp> No such user here',
        'Remote system: dns;neko.example.jp (TCP|17.111.174.65|48044|192.0.2.225|25) (neko.example.jp ESMTP SENDMAIL-VM)',
        'SMTP Server <neko.example.jp> rejected recipient <cat@libsisimai.org> (Error following RCPT command). It responded as follows: [550 5.1.1 User unknown]',
        'Reporting-MTA:      <neko.example.jp>',
        'cat@example.jp:000000:<cat@example.jp> : 192.0.2.250 : neko.example.jp:[192.0.2.153] : 550 5.1.1 <cat@example.jp>... User Unknown  in RCPT TO',
        'Generating server: neko.example.jp',
        'Server di generazione: neko.example.jp',
        'Serveur de génération : neko.example.jp',
        'Genererande server: neko.example.jp',
        'neko.example.jp [192.0.2.25] did not like our RCPT TO: 550 5.1.1 <cat@example.jp>: Recipient address rejected: User unknown',
        'neko.example.jp [192.0.2.79] did not like our final DATA: 554 5.7.9 Message not accepted for policy reasons',
    ];
    my $ip46domain = [
        ['', 0],
        ['<neko@example.jp>', 0],
        ['<neko@[IPv4:192.0.2.25]>', 1],
        ['neko@[IPv4:192.0.2.25]', 1],
        ['neko@[Neko:192.0.2.25]', 0],
        ['neko@[IPv6:192.0.2.25]', 0],
        ['neko@[IPv6:2001:DB8::1]', 1],
        ['neko@[IPv5:2001:DB8::1]', 0],
        ['<neko@[IPv6:2001:DB8::1]>', 1],
        ['neko@[IPv6:2001:0DB8:0000:0000:0000:0000:0000:0001]', 1],
        ['<neko@[IPv6:2001:0DB8:0000:0000:0000:0000:0000:0001]>', 1],
    ];

    for my $e ( @$hostnames0 ) {
        # Invalid hostnames
        is $Package->is_internethost($e), 0, '->is_internethost('.$e.') = 0';
    }

    for my $e ( @$hostnames1 ) {
        # Valid hostnames
        is $Package->is_internethost($e), 1, '->is_internethost('.$e.') = 1';
    }

    for my $e ( @$serversaid ) {
        # find() returns "neko.example.jp"
        my $v = $Package->find($e);
        is $v, "neko.example.jp", '->find('.$e.') = '.$v;
    }

    for my $e ( @$ip46domain ) {
        is $Package->is_domainliteral($e->[0]), $e->[1], '->is_domainliteral('.$e->[0].') = '.$e->[1];
    }
}

done_testing;


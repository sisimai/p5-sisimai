use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::SMTP::Command;

my $Package = 'Sisimai::SMTP::Command';
my $Methods = { 'class' => ['test', 'find'], 'object' => [] };

use_ok $Package;
can_ok $Package, @{ $Methods->{'class'} };

MAKETEST: {
    my $smtperrors = {
        'HELO' => [
            'lost connection with mx.example.jp[192.0.2.2] while performing the HELO handshake',
            'SMTP error from remote mail server after HELO mx.example.co.jp:',
        ],
        'EHLO' => [
            'SMTP error from remote mail server after EHLO neko.example.com:',
        ],
        'MAIL' => [
            '452 4.3.2 Connection rate limit exceeded. (in reply to MAIL FROM command)',
            '5.1.8 (Server rejected MAIL FROM address)',
            '5.7.1 Access denied (in reply to MAIL FROM command)',
            'SMTP error from remote mail server after MAIL FROM:<shironeko@example.jp> SIZE=1543:',
        ],
        'RCPT' => [
            '550 5.1.1 <DATA@MAIL.EXAMPLE.JP>... User Unknown  in RCPT TO',
            '550 user unknown (in reply to RCPT TO command)',
            '>>> RCPT To:<mikeneko@example.co.jp>',
            'most progress was RCPT TO response; remote host 192.0.2.32 said: 550 Unknown user MAIL@example.ne.jp',
            'SMTP error from remote mail server after RCPT TO:<kijitora@example.jp>:',
        ],
        'DATA' => [
            'Email rejected per DMARC policy for libsisimai.org (in reply to end of DATA command)',
            'SMTP Server <192.0.2.223> refused to accept your message (DATA), with the following error message',
        ],
    };

    my $v = '';
    is $Package->test(),   undef, '->test() returns undef';
    is $Package->test(''), undef, '->test("") returns undef';
    is $Package->test('NEKO'), 0, '->test("NEKO") returns 0';
    is $Package->test('CONN'), 1, '->test("CONN") returns 1';

    is $Package->find(),       undef, '->find("") returns undef';
    is $Package->find(''),     undef, '->find() returns undef';
    is $Package->find('NEKO'), undef, '->find("NEKO") returns undef';

    for my $e ( keys %$smtperrors ) {
        ok $Package->test($e);
        for my $f ( $smtperrors->{ $e }->@* ) {
            $v = $Package->find($f);
            ok $f, 'Error message text = '.$f;
            is $v, $e, 'SMTP command = '.$v;
        }
    }
}

done_testing;


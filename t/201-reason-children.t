use strict;
use feature ':5.10';
use lib qw(./lib ./blib/lib);
use Test::More;
use Module::Load;
use Sisimai;

my $reasonchildren = {
    'AuthFailure'     => ["550 5.1.0 192.0.2.222 is not allowed to send from <example.net> per it's SPF Record"],
    'BadReputation'   => ['451 4.7.650 The mail server [192.0.2.2] has been temporarily rate limited due to IP reputation.'],
    'Blocked'         => ['550 Access from ip address 192.0.2.1 blocked.'],
    'ContentError'    => ['550 5.6.0 the headers in this message contain improperly-formatted binary content'],
    'ExceedLimit'     => ['5.2.3 Message too large'],
    'Expired'         => ['421 4.4.7 Delivery time expired'],
    'Filtered'        => ['550 5.1.2 User reject'],
    'HasMoved'        => ['550 5.1.6 address neko@cat.cat has been replaced by neko@example.jp'],
    'HostUnknown'     => ['550 5.2.1 Host Unknown'],
    'MailboxFull'     => ['450 4.2.2 Mailbox full'],
    'MailerError'     => ['X-Unix; 255'],
    'MesgTooBig'      => ['400 4.2.3 Message too big'],
    'NetworkError'    => ['554 5.4.6 Too many hops'],
    'NoRelaying'      => ['550 5.0.0 Relaying Denied'],
    'NotAccept'       => ['556 SMTP protocol returned a permanent error'],
    'NotCompliantRFC' => ['550 5.7.1 This message is not RFC 5322 compliant. There are multiple Subject headers.'],
    'OnHold'          => ['5.0.901 error'],
    'Rejected'        => ['550 5.1.8 Domain of sender address example.org does not exist'],
    'RequirePTR'      => ['550 5.7.25 [192.0.2.25] The IP address sending this message does not have a PTR record setup'],
    'PolicyViolation' => ['570 5.7.7 Email not accepted for policy reasons'],
    'SecurityError'   => ['570 5.7.0 Authentication failure'],
    'SpamDetected'    => ['570 5.7.7 Spam Detected'],
    'Speeding'        => ['451 4.7.1 <smtp.example.jp[192.0.2.3]>: Client host rejected: Please try again slower'],
    'Suspend'         => ['550 5.0.0 Recipient suspend the service'],
    'SystemError'     => ['500 5.3.5 System config error'],
    'SystemFull'      => ['550 5.0.0 Mail system full'],
    'TooManyConn'     => ['421 Too many connections'],
    'UserUnknown'     => ['550 5.1.1 Unknown User'],
    'VirusDetected'   => ['550 5.7.9 The message was rejected because it contains prohibited virus or spam content'],
};

my $ss = shift @{ Sisimai->rise('./set-of-emails/maildir/bsd/lhost-sendmail-01.eml') };
isa_ok $ss, 'Sisimai::Fact';

for my $e ( keys %$reasonchildren ) {
    my $r = 'Sisimai::Reason::'.$e;
    Module::Load::load $r;
    is $r->text, lc $e, $r.'->text = '.lc($e);
    is $r->true, undef, $r.'->true = undef';
    ok length $r->description, $r.'->description = '.$r->description;

    my $q = $r->true($ss) // 0;
    like $q, qr/\A[01]\z/, $r.'->true($ss) = 0 or 1';

    next if $e eq 'OnHold';
    for my $v ( @{ $reasonchildren->{ $e } } ) {
        is $r->match(lc $v), 1, $r.'->match('.$v.') = 1';
    }
    is $r->match(), undef;
} 

for my $e ( 'Delivered', 'Feedback', 'Undefined', 'Vacation', 'SyntaxError' ) {
    my $r = 'Sisimai::Reason::'.$e;
    Module::Load::load $r;
    is $r->text, lc $e, $r.'->text = '.lc($e);
    is $r->true, undef, $r.'->true = undef';
    is $r->match,undef, $r.'->match = undef';
    ok length $r->description, $r.'->description = '.$r->description;
}

done_testing;


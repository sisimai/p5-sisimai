use strict;
use Test::More;
use lib qw(./lib ./blib/lib);

use_ok 'Sisimai';
use_ok 'Sisimai::'.$_ for qw(
    Address
    ARF
    Data
    Group
        Group::Phone
        Group::Web
    ISO3166
    Mail
        Mail::Mbox
        Mail::Maildir
    MDA
    Message
    MIME
    MSP
        MSP::JP::Biglobe
        MSP::JP::KDDI
        MSP::US::Facebook
        MSP::US::Google
        MSP::US::Verizon
    MTA
        MTA::Courier
        MTA::Exchange
        MTA::Exim
        MTA::Fallback
        MTA::OpenSMTPD
        MTA::Postfix
        MTA::qmail
        MTA::Sendmail
    Reason
        Reason::Blocked
        Reason::ContentError
        Reason::ExceedLimit
        Reason::Expired
        Reason::Filtered
        Reason::HostUnknown
        Reason::MailboxFull
        Reason::MailerError
        Reason::MesgTooBig
        Reason::NotAccept
        Reason::OnHold
        Reason::Rejected
        Reason::RelayingDenied
        Reason::SecurityError
        Reason::Suspend
        Reason::SystemFull
        Reason::UserUnknown
    Rhost
        Rhost::GoogleApps
    RFC2606
    RFC3463
    RFC5322
    String
    Time
);

my $c = [ qw|
    AE AL AR AT AU AW BE BG BM BR BS CA CH CL CN CO CR CZ DE DK DO EC EG ES FR
    GR GT HK HN HR HU ID IE IL IN IR IS IT JM JP KE KR LB LK LU LV MA MD ME MK
    MO MU MX MY NG NI NL NO NP NZ OM PA PE PH PK PL PR PT PY RO RS RU SA SE SG
    SK SR SV TH TR TW UA UG UK US UY VE VN ZA|
];

for my $e ( @$c ) {
    use_ok 'Sisimai::Group::'.$e.'::Web';
    use_ok 'Sisimai::Group::'.$e.'::Phone';
}

done_testing;



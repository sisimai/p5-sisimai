use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-bite-email-code';

my $enginename = 'RFC3464';
my $enginetest = Sisimai::Bite::Email::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A5[.]1[.]1\z/,      'r' => qr/mailboxfull/,   'a' => qr/dovecot/, 'b' => qr/\A1\z/ },
    { 'n' => '03', 's' => qr/\A5[.]0[.]0\z/,      'r' => qr/policyviolation/, 'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '04', 's' => qr/\A5[.]5[.]0\z/,      'r' => qr/mailererror/,   'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '05', 's' => qr/\A5[.]2[.]1\z/,      'r' => qr/filtered/,      'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '06', 's' => qr/\A5[.]5[.]0\z/,      'r' => qr/userunknown/,   'a' => qr/mail.local/, 'b' => qr/\A0\z/ },
    { 'n' => '07', 's' => qr/\A4[.]4[.]0\z/,      'r' => qr/expired/,       'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '08', 's' => qr/\A5[.]7[.]1\z/,      'r' => qr/spamdetected/,  'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '09', 's' => qr/\A[45][.]\d[.]\d+\z/,'r' => qr/(?:mailboxfull|undefined)/, 'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '10', 's' => qr/\A5[.]1[.]6\z/,      'r' => qr/hasmoved/,      'a' => qr/RFC3464/, 'b' => qr/\A0\z/ },
    { 'n' => '26', 's' => qr/\A5[.]1[.]1\z/,      'r' => qr/userunknown/,   'a' => qr/RFC3464/, 'b' => qr/\A0\z/ },
    { 'n' => '28', 's' => qr/\A2[.]1[.]5\z/,      'r' => qr/delivered/,     'a' => qr/RFC3464/, 'b' => qr/\A-1\z/ },
    { 'n' => '29', 's' => qr/\A5[.]5[.]0\z/,      'r' => qr/syntaxerror/,   'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '34', 's' => qr/\A5[.]0[.]\d+\z/,    'r' => qr/networkerror/,  'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '35', 's' => qr/\A[45][.]0[.]0\z/,   'r' => qr/(?:filtered|expired|rejected)/,'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '36', 's' => qr/\A4[.]0[.]0\z/,      'r' => qr/expired/,       'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '37', 's' => qr/\A5[.]0[.]\d+\z/,    'r' => qr/hostunknown/,   'a' => qr/RFC3464/, 'b' => qr/\A0\z/ },
    { 'n' => '38', 's' => qr/\A5[.]0[.]\d+\z/,    'r' => qr/mailboxfull/,   'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '39', 's' => qr/\A5[.]0[.]\d+\z/,    'r' => qr/onhold/,        'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '40', 's' => qr/\A4[.]4[.]6\z/,      'r' => qr/networkerror/,  'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '41', 's' => qr/\A\z/,               'r' => qr/vacation/,      'a' => qr/RFC3464/, 'b' => qr/\A-1\z/ },
];
 
 $enginetest->($enginename, $isexpected);
done_testing;


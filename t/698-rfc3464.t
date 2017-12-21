use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-bite-email-code';

my $enginename = 'RFC3464';
my $enginetest = Sisimai::Bite::Email::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A5[.]1[.]1\z/,      'r' => qr/mailboxfull/,   'a' => qr/dovecot/, 'b' => qr/\A1\z/ },
    { 'n' => '02', 's' => qr/\A[45][.]0[.]\d+\z/, 'r' => qr/(?:undefined|filtered|expired)/, 'a' => qr/RFC3464/, 'b' => qr/\d\z/ },
    { 'n' => '03', 's' => qr/\A[45][.]0[.]\d+\z/, 'r' => qr/(?:undefined|expired)/,          'a' => qr/RFC3464/, 'b' => qr/\d\z/ },
    { 'n' => '04', 's' => qr/\A5[.]5[.]0\z/,      'r' => qr/mailererror/,   'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '05', 's' => qr/\A5[.]2[.]1\z/,      'r' => qr/filtered/,      'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '06', 's' => qr/\A5[.]5[.]0\z/,      'r' => qr/userunknown/,   'a' => qr/mail.local/, 'b' => qr/\A0\z/ },
    { 'n' => '07', 's' => qr/\A4[.]4[.]0\z/,      'r' => qr/expired/,       'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '08', 's' => qr/\A5[.]7[.]1\z/,      'r' => qr/spamdetected/,  'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '09', 's' => qr/\A4[.]3[.]0\z/,      'r' => qr/mailboxfull/,   'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '10', 's' => qr/\A5[.]1[.]1\z/,      'r' => qr/userunknown/,   'a' => qr/RFC3464/, 'b' => qr/\A0\z/ },
    { 'n' => '11', 's' => qr/\A5[.]\d[.]\d+\z/,   'r' => qr/spamdetected/,  'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '12', 's' => qr/\A4[.]3[.]0\z/,      'r' => qr/mailboxfull/,   'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '13', 's' => qr/\A4[.]0[.]0\z/,      'r' => qr/mailererror/,   'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '14', 's' => qr/\A4[.]4[.]1\z/,      'r' => qr/expired/,       'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '15', 's' => qr/\A5[.]0[.]\d+\z/,    'r' => qr/mesgtoobig/,    'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '16', 's' => qr/\A5[.]0[.]\d+\z/,    'r' => qr/filtered/,      'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '17', 's' => qr/\A5[.]0[.]\d+\z/,    'r' => qr/expired/,       'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '18', 's' => qr/\A5[.]1[.]1\z/,      'r' => qr/userunknown/,   'a' => qr/RFC3464/, 'b' => qr/\A0\z/ },
    { 'n' => '19', 's' => qr/\A5[.]0[.]\d+\z/,    'r' => qr/onhold/,        'a' => qr/RFC3464/, 'b' => qr/\A0\z/ },
    { 'n' => '20', 's' => qr/\A5[.]0[.]\d+\z/,    'r' => qr/mailererror/,   'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '21', 's' => qr/\A5[.]0[.]\d+\z/,    'r' => qr/networkerror/,  'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '22', 's' => qr/\A5[.]0[.]\d+\z/,    'r' => qr/hostunknown/,   'a' => qr/RFC3464/, 'b' => qr/\A0\z/ },
    { 'n' => '23', 's' => qr/\A5[.]0[.]\d+\z/,    'r' => qr/mailboxfull/,   'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '24', 's' => qr/\A5[.]0[.]\d+\z/,    'r' => qr/onhold/,        'a' => qr/RFC3464/, 'b' => qr/\d\z/ },
    { 'n' => '25', 's' => qr/\A5[.]0[.]\d+\z/,    'r' => qr/onhold/,        'a' => qr/RFC3464/, 'b' => qr/\d\z/ },
    { 'n' => '26', 's' => qr/\A5[.]1[.]1\z/,      'r' => qr/userunknown/,   'a' => qr/RFC3464/, 'b' => qr/\A0\z/ },
    { 'n' => '27', 's' => qr/\A4[.]4[.]6\z/,      'r' => qr/networkerror/,  'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '28', 's' => qr/\A2[.]1[.]5\z/,      'r' => qr/delivered/,     'a' => qr/RFC3464/, 'b' => qr/\A-1\z/ },
    { 'n' => '29', 's' => qr/\A5[.]5[.]0\z/,      'r' => qr/syntaxerror/,   'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '30', 's' => qr/\A4[.]2[.]2\z/,      'r' => qr/mailboxfull/,   'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '31', 's' => qr/\A5[.]0[.]\d+\z/,    'r' => qr/virusdetected/, 'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '32', 's' => qr/\A5[.]0[.]\d+\z/,    'r' => qr/filtered/,      'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '33', 's' => qr/\A5[.]2[.]0\z/,      'r' => qr/spamdetected/,  'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
    { 'n' => '34', 's' => qr/\A5[.]0[.]\d+\z/,    'r' => qr/networkerror/,  'a' => qr/RFC3464/, 'b' => qr/\A1\z/ },
];
 
 $enginetest->($enginename, $isexpected);
done_testing;


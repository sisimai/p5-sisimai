use strict;
use warnings;
use Test::More;
use lib qw(./lib ./blib/lib);
require './t/600-bite-email-code';

my $enginename = 'Sendmail';
my $enginetest = Sisimai::Bite::Email::Code->maketest;
my $isexpected = [
    { 'n' => '01', 's' => qr/\A5[.]1[.]1\z/,    'r' => qr/userunknown/,     'b' => qr/\A0\z/ },
    { 'n' => '02', 's' => qr/\A5[.][12][.]1\z/, 'r' => qr/(?:userunknown|filtered)/, 'b' => qr/\d\z/ },
    { 'n' => '03', 's' => qr/\A5[.]1[.]1\z/,    'r' => qr/userunknown/,     'b' => qr/\A0\z/ },
    { 'n' => '04', 's' => qr/\A5[.]1[.]8\z/,    'r' => qr/rejected/,        'b' => qr/\A1\z/ },
    { 'n' => '05', 's' => qr/\A5[.]2[.]3\z/,    'r' => qr/exceedlimit/,     'b' => qr/\A1\z/ },
    { 'n' => '06', 's' => qr/\A5[.]6[.]9\z/,    'r' => qr/contenterror/,    'b' => qr/\A1\z/ },
    { 'n' => '07', 's' => qr/\A5[.]7[.]1\z/,    'r' => qr/norelaying/,      'b' => qr/\A1\z/ },
    { 'n' => '08', 's' => qr/\A4[.]7[.]1\z/,    'r' => qr/blocked/,         'b' => qr/\A1\z/ },
    { 'n' => '09', 's' => qr/\A5[.]7[.]9\z/,    'r' => qr/policyviolation/, 'b' => qr/\A1\z/ },
    { 'n' => '10', 's' => qr/\A4[.]7[.]1\z/,    'r' => qr/blocked/,         'b' => qr/\A1\z/ },
    { 'n' => '11', 's' => qr/\A4[.]4[.]7\z/,    'r' => qr/expired/,         'b' => qr/\A1\z/ },
    { 'n' => '12', 's' => qr/\A4[.]4[.]7\z/,    'r' => qr/expired/,         'b' => qr/\A1\z/ },
    { 'n' => '13', 's' => qr/\A5[.]3[.]0\z/,    'r' => qr/systemerror/,     'b' => qr/\A1\z/ },
    { 'n' => '14', 's' => qr/\A5[.]1[.]1\z/,    'r' => qr/userunknown/,     'b' => qr/\A0\z/ },
    { 'n' => '15', 's' => qr/\A5[.]1[.]2\z/,    'r' => qr/hostunknown/,     'b' => qr/\A0\z/ },
    { 'n' => '16', 's' => qr/\A5[.]5[.]0\z/,    'r' => qr/blocked/,         'b' => qr/\A1\z/ },
    { 'n' => '17', 's' => qr/\A5[.]1[.]6\z/,    'r' => qr/hasmoved/,        'b' => qr/\A0\z/ },
    { 'n' => '18', 's' => qr/\A5[.]0[.]0\z/,    'r' => qr/mailererror/,     'b' => qr/\A1\z/ },
    { 'n' => '19', 's' => qr/\A5[.]2[.]0\z/,    'r' => qr/filtered/,        'b' => qr/\A1\z/ },
    { 'n' => '20', 's' => qr/\A5[.]4[.]6\z/,    'r' => qr/networkerror/,    'b' => qr/\A1\z/ },
    { 'n' => '21', 's' => qr/\A4[.]4[.]7\z/,    'r' => qr/blocked/,         'b' => qr/\A1\z/ },
    { 'n' => '22', 's' => qr/\A5[.]1[.]6\z/,    'r' => qr/hasmoved/,        'b' => qr/\A0\z/ },
    { 'n' => '24', 's' => qr/\A5[.]1[.]2\z/,    'r' => qr/hostunknown/,     'b' => qr/\A0\z/ },
    { 'n' => '25', 's' => qr/\A5[.]1[.]1\z/,    'r' => qr/userunknown/,     'b' => qr/\A0\z/ },
    { 'n' => '26', 's' => qr/\A5[.]1[.]1\z/,    'r' => qr/userunknown/,     'b' => qr/\A0\z/ },
    { 'n' => '27', 's' => qr/\A5[.]0[.]0\z/,    'r' => qr/filtered/,        'b' => qr/\A1\z/ },
    { 'n' => '28', 's' => qr/\A5[.]1[.]1\z/,    'r' => qr/userunknown/,     'b' => qr/\A0\z/ },
    { 'n' => '29', 's' => qr/\A4[.]5[.]0\z/,    'r' => qr/expired/,         'b' => qr/\A1\z/ },
    { 'n' => '30', 's' => qr/\A4[.]4[.]7\z/,    'r' => qr/expired/,         'b' => qr/\A1\z/ },
    { 'n' => '31', 's' => qr/\A5[.]7[.]0\z/,    'r' => qr/securityerror/,   'b' => qr/\A1\z/ },
    { 'n' => '32', 's' => qr/\A5[.]1[.]1\z/,    'r' => qr/userunknown/,     'b' => qr/\A0\z/ },
    { 'n' => '33', 's' => qr/\A5[.]7[.]1\z/,    'r' => qr/blocked/,         'b' => qr/\A1\z/ },
    { 'n' => '34', 's' => qr/\A5[.]7[.]0\z/,    'r' => qr/securityerror/,   'b' => qr/\A1\z/ },
    { 'n' => '35', 's' => qr/\A5[.]7[.]13\z/,   'r' => qr/suspend/,         'b' => qr/\A1\z/ },
    { 'n' => '36', 's' => qr/\A5[.]7[.]1\z/,    'r' => qr/blocked/,         'b' => qr/\A1\z/ },
    { 'n' => '37', 's' => qr/\A5[.]1[.]1\z/,    'r' => qr/userunknown/,     'b' => qr/\A0\z/ },
    { 'n' => '38', 's' => qr/\A5[.]7[.]1\z/,    'r' => qr/spamdetected/,    'b' => qr/\A1\z/ },
    { 'n' => '39', 's' => qr/\A4[.]4[.]5\z/,    'r' => qr/systemfull/,      'b' => qr/\A1\z/ },
    { 'n' => '40', 's' => qr/\A5[.]2[.]0\z/,    'r' => qr/filtered/,        'b' => qr/\A1\z/ },
    { 'n' => '41', 's' => qr/\A5[.]0[.]0\z/,    'r' => qr/filtered/,        'b' => qr/\A1\z/ },
    { 'n' => '42', 's' => qr/\A5[.]1[.]2\z/,    'r' => qr/hostunknown/,     'b' => qr/\A0\z/ },
    { 'n' => '43', 's' => qr/\A5[.]7[.]1\z/,    'r' => qr/policyviolation/, 'b' => qr/\A1\z/ },
    { 'n' => '44', 's' => qr/\A5[.]6[.]0\z/,    'r' => qr/contenterror/,    'b' => qr/\A1\z/ },
    { 'n' => '45', 's' => qr/\A5[.]1[.]1\z/,    'r' => qr/userunknown/,     'b' => qr/\A0\z/ },
    { 'n' => '46', 's' => qr/\A5[.]5[.]0\z/,    'r' => qr/userunknown/,     'b' => qr/\A0\z/ },
    { 'n' => '47', 's' => qr/\A5[.]1[.]1\z/,    'r' => qr/userunknown/,     'b' => qr/\A0\z/ },
    { 'n' => '48', 's' => qr/\A5[.]7[.]1\z/,    'r' => qr/filtered/,        'b' => qr/\A1\z/ },
];

$enginetest->($enginename, $isexpected);
done_testing;


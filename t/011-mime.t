use strict;
use Test::More;
use lib qw(./lib ./blib/lib);
use Sisimai::MIME;
use Encode;

my $PackageName = 'Sisimai::MIME';
my $MethodNames = {
    'class' => [ 'is_mimeencoded', 'mimedecode', 'boundary' ],
    'object' => [],
};

use_ok $PackageName;
can_ok $PackageName, @{ $MethodNames->{'class'} };

MAKE_TEST: {
    my $v = '';
    my $x = 'ASCII TEXT';
    my $y = '白猫にゃんこ';
    my $z = '=?utf-8?B?55m954yr44Gr44KD44KT44GT?=';

    is $PackageName->is_mimeencoded( \$x ), 0, '->mimeencoded = 0';
    is $PackageName->is_mimeencoded( \$y ), 0, '->mimeencoded = 0';
    is $PackageName->is_mimeencoded( \$z ), 1, '->mimeencoded = 1';

    for my $e ( $x, $y ) {
        $v = $PackageName->mimedecode( [ $e ] );
        $v = Encode::encode_utf8 $v if utf8::is_utf8 $v;
        is $v, $e, '->mimedecode = '.$e;
    }

    $v = $PackageName->mimedecode( [ $z ] );
    $v = Encode::encode_utf8 $v if utf8::is_utf8 $v;
    is $v, $y, '->mimedecode = '.$y;

    # MIME-Encoded text in multiple lines
    $y = '何でも薄暗いじめじめした所でニャーニャー泣いていた事だけは記憶している。';
    $z = [
        '=?utf-8?B?5L2V44Gn44KC6JaE5pqX44GE44GY44KB44GY44KB44GX44Gf5omA?=',
        '=?utf-8?B?44Gn44OL44Oj44O844OL44Oj44O85rOj44GE44Gm44GE44Gf5LqL?=',
        '=?utf-8?B?44Gg44GR44Gv6KiY5oa244GX44Gm44GE44KL44CC?=',
    ];
    $v = $PackageName->mimedecode( $z );
    $v = Encode::encode_utf8 $v if utf8::is_utf8 $v;
    is $v, $y, '->mimedecode = '.$y;

    my $r = 'Content-Type: multipart/mixed; boundary=Apple-Mail-1-526612466';
    my $b = 'Apple-Mail-1-526612466';
    is $PackageName->boundary( $r ), $b, '->boundary() = '.$b;
    is $PackageName->boundary( $r, 0 ), '--'.$b, '->boundary(0) = --'.$b;
    is $PackageName->boundary( $r, 1 ), '--'.$b.'--', '->boundary(1) = --'.$b.'--';
    is $PackageName->boundary( $r, 2 ), '--'.$b.'--', '->boundary(2) = --'.$b.'--';
}

done_testing;

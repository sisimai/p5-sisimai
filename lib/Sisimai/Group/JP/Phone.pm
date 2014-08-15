package Sisimai::Group::JP::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major cellular phone company's domains in Japan
        'nttdocomo' => [ 
            qr/\Adocomo[.]ne[.]jp\z/,
            qr/\Amopera[.](?:ne[.]jp|net)\z/,   # mopera, http://www.mopera.net/
            qr/\Adocomo[.]blackberry[.]com\z/,  # BlackBerry by NTT DoCoMo
            qr/\Adocomo-camera[.]ne[.]jp\z/,    # photo-server@docomo-camera.ne.jp
            qr/\A(?:nttpnet|phone|mozio)[.]ne[.]jp/,
        ],
        'aubykddi'  => [
            qr/\Aezweb[.]ne[.]jp\z/,
            qr/\A[0-9a-z]{2}[.]ezweb[.]ne[.]jp\z/,
            qr/\A[0-9a-z][-0-9a-z]{0,8}[0-9a-z][.]biz[.]ezweb[.]ne[.]jp\z/,
            qr/\Aido[.]ne[.]jp\z/,
            qr/\Aez[a-j][.]ido[.]ne[.]jp\z/,
        ],
        'softbank'  => [
            qr/\Asoftbank[.]ne[.]jp\z/,
            qr/\A[dhtcrksnq][.]vodafone[.]ne[.]jp\z/,
            qr/\Ajp-[dhtcrksnq][.]ne[.]jp\z/,
            qr/\Ai[.]softbank[.]jp\z/,      # SoftBank|Apple iPhone
        ],
        'disney' => [
            # MVNO, Disney Mobile; http://disneymobile.jp/
            qr/\Adisney[.]ne[.]jp\z/,
        ],
        'vertu' => [
            # MVNO, VERTU; http://www.vertu.com/jp-jp/home
            qr/\Avertuclub[.]ne[.]jp\z/,
        ],
        'tu-ka' => [
            qr/\Asky[.](?:tkk|tkc|tu-ka)[.]ne[.]jp\z/,
        ],
        'willcom' => [
            # Willcom AIR-EDGE
            # http://www.willcom-inc.com/ja/service/contents_service/create/center_info/index.html
            qr/\Apdx[.]ne[.]jp\z/,
            qr/\A(?:di|dj|dk|wm)[.]pdx[.]ne[.]jp\z/,
            qr/willcom[.]com\z/,    # Created at 2009/01/15
        ],
        'emobile' => [ 
            # EMOBILE EMNET
            qr/\Aemnet[.]ne[.]jp\z/,
            qr/\Abb[.]emobile[.]jp\z/,  # https://store.emobile.jp/help/help_mail.html
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::JP::Phone - Major phone provider's domains in Japan

=head1 SYNOPSIS

    use Sisimai::Group::JP::Phone;
    print Sisimai::Group::JP::Phone->find('docomo.ne.jp');    # nttdocomo

=head1 DESCRIPTION

Sisimai::Group::JP::Phone has a domain list of major cellular phone providers
and major smart phone providers in Japan.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

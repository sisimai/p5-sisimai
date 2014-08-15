package Sisimai::Group::TW::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in Republic Of China, Taiwan
        'kingnet' => [
            # KingNet(Gmail); http://mail.kingnet.com.tw/
            qr/kingnet[.]com[.]tw\z/,
        ],
        'seednet' => [
            # http://www.seed.net.tw/
            qr/\Aseed[.]net[.]tw\z/,
            qr/\Atpts[1-8][.]seed[.]net[.]tw\z/,
            qr/\A(?:venus|mars|saturn|titan|iris|libra|pavo)[.]seed[.]net[.]tw\z/,
            qr/\A(?:ara|tcts|tcts1|shts|ksts|ksmail)[.]seed[.]net[.]tw\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::TW::Web - Major web mail service provider's domains in Taiwan

=head1 SYNOPSIS

    use Sisimai::Group::TW::Web;
    print Sisimai::Group::TW::Web->find('seed.net.tw');    # seednet

=head1 DESCRIPTION

Sisimai::Group::TW::Web has a domain list of major web mail service providers
in Taiwan.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

package Sisimai::Group::JP::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in Japan
        'aubykddi' => [
            # KDDI auone(Gmail); http://auone.jp/
            qr/\Aauone[.]jp\z/,
        ],
        'goo' => [
            # goo mail, http://mail.goo.ne.jp/index.html
            qr/\Amail[.]goo[.]ne[.]jp\z/,
            qr/\Agoo[.]jp\z/,
        ],
        'infoseek' => [
            # http://infoseek.jp/ < 50MB...
            qr/\Ainfoseek[.]jp\z/,
            qr/\Arakuten[.]com\z/,
        ],
        'livedoor' => [
            # livedoor mail(Gmail) http://mail.livedoor.com/
            qr/\Alivedoor[.]com\z/, # Until Oct 31, 2013
        ],
        'nifty' => [
            # http://www.nifty.com/
            qr/\Anifty[.]com\z/,
            qr/\Anifmail[.]jp\z/,               # Until Sep 30, 2010
            qr/\A(?:mb|sp).+[.]nifty[.]com\z/,  # http://www.nifty.com/mail/mailaccount/service.htm
            qr/\A[0-9a-z]+[.]nifty[.]jp\z/,     # http://www.nifty.com/mail/plus/index.htm

            # http://www.nifty.com/mail/sanrio/domainlist.htm
            qr/\A(?:kitty|x[-]o|mymelody|usahana|mimmy|kikilala|charmmy|cinnamonroll)[.]jp\z/,
            qr/\A(?:chibimaru|ayankey|mr[-]bear|pannapitta|zashikibuta|tuxedosam)[.]jp\z/,
            qr/\A(?:goropikadon|marroncream|littletwinstars|pompompurin|pekkle)[.]jp\z/,
            qr/\A(?:pochacco|deardaniel|badbadtz[-]maru|corocorokuririn|pattyandjimmy)[.]jp\z/,
            qr/\A(?:pokopon|han[-]gyodon|shirousa|kurousa|sugar[-]bunnies)[.]jp\z/,
        ],
        'nttdocomo' => [
            # DoCoMo web mail powered by goo; http://dwmail.jp/
            qr/\Adwmail[.]jp\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::JP::Web - Major web mail service provider's domains in Japan

=head1 SYNOPSIS

    use Sisimai::Group::JP::Web;
    print Sisimai::Group::JP::Web->find('goo.jp');    # goo

=head1 DESCRIPTION

Sisimai::Group::JP::Web has a domain list of major web mail service providers
in Japan.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

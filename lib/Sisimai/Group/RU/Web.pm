package Sisimai::Group::RU::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in Russia
        'qip' => [
            # http://qip.ru/
            qr/\A(?:qip|pochta|front|hotbox|hotmail|land|newmail)[.]ru\z/,
            qr/\A(?:nightmail|nm|pochtamt|pop3|rbcmail|smtp)[.]ru\z/,
            qr/\A(?:5ballov|aeterna|ziza|memori|photofile|fotoplenka)[.]ru\z/,
            qr/\A(?:fromru|mail15|mail333|pochta)[.]com\z/,
            qr/\Akrovatka[.]su\z/,
            qr/\Apisem[.]net\z/,
        ],
        'runet' => [
            # http://mail.ru/
            qr/\A(?:mail|bk|inbox|list)[.]ru\z/,
        ],
        'yandex' => [
            # http://yandex.ru/
            qr/\Ayandex[.]ru\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::RU::Web - Major web mail service provider's domains in Russia

=head1 SYNOPSIS

    use Sisimai::Group::RU::Web;
    print Sisimai::Group::RU::Web->find('mail.ru');    # runet

=head1 DESCRIPTION

Sisimai::Group::RU::Web has a domain list of major web mail service providers
in Russia.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

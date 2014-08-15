package Sisimai::Group::IE::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Cellular phone domains in Ireland
        # See http://en.wikipedia.org/wiki/List_of_SMS_gateways
        'meteor' => [
            # Meteor Mobile; http://www.meteor.ie/
            qr/\A(?:sms|mms)[.]mymeteor[.]ie\z/,
        ],
        #'vodafone' => [
        #   # Vodafone; http://www.vodafone.ie/
        #   # http://forum.vodafone.ie/index.php?/topic/5367-email-to-sms-gateway/
        #   qr/\Asms[.]vodafone[.]ie\z/,
        #],
        'o2' => [
            # O2 Ireland; http://www.o2online.ie/
            qr/\Ao2mail[.]ie\z/,
        ],
        'three' => [
            # 3 Ireland; http://three.ie/
            qr/\A3ireland[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::IE::Phone - Major phone provider's domains in Ireland

=head1 SYNOPSIS

    use Sisimai::Group::IE::Phone;
    print Sisimai::Group::IE::Phone->find('o2mail.ie');    # o2

=head1 DESCRIPTION

Sisimai::Group::IE::Phone has a domain list of major cellular phone providers
and major smart phone providers in Ireland.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

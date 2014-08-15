package Sisimai::Group::IN::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in India
        'ibibo' => [
            # http://www.ibibo.com/
            qr/\Aibibo[.]com\z/,
        ],
        'in.com' => [
            # in.com; http://mail.in.com/
            qr/\Ain[.]com\z/,
        ],
        'india.com' => [
            # http://www.india.com/
            qr/\A(?:zmail|timepass|imail|india|tadka|indiawrites|dvaar|takdhinadhin)[.]com\z/,
        ],
        'rediff.com' => [
            # rediff.com; http://www.rediff.com/
            qr/\Arediffmail[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::IN::Web - Major web mail service provider's domains in India

=head1 SYNOPSIS

    use Sisimai::Group::IN::Web;
    print Sisimai::Group::IN::Web->find('ibibo.com');    # ibibo

=head1 DESCRIPTION

Sisimai::Group::IN::Web has a domain list of major web mail service providers
in India.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

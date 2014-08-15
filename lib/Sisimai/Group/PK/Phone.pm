package Sisimai::Group::PK::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Islamic Republic of Pakistan
        'mobilink' => [
            # Mobilink; http://www.mobilinkgsm.com/
            qr/\Amobilink[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::PK::Phone - Major phone provider's domains in Pakistan

=head1 SYNOPSIS

    use Sisimai::Group::PK::Phone;
    print Sisimai::Group::PK::Phone->find('mobilink.blackberry.com');  # mobilink

=head1 DESCRIPTION

Sisimai::Group::PK::Phone has a domain list of major cellular phone providers
and major smart phone providers in Pakistan.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

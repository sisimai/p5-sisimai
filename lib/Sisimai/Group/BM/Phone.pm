package Sisimai::Group::BM::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Bermuda Islands
        'm3wireless' => [
            # M3Wireless; http://www.m3wireless.bm/
            qr{\Am3wireless[.]blackberry[.]com\z},
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::BM::Phone - Major phone provider's domains in Bermuda Islands

=head1 SYNOPSIS

    use Sisimai::Group::BM::Phone;
    print Sisimai::Group::BM::Phone->find('m3wireless.blackberry.com');    # m3wireless

=head1 DESCRIPTION

Sisimai::Group::BM::Phone has a domain list of major cellular phone providers
and major smart phone providers in Bermuda Islands.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

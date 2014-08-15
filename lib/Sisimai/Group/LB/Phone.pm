package Sisimai::Group::LB::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Lebanon/Lebanese Republic
        'alfa' => [
            # alfa; http://www.alfa.com.lb/
            qr/\Aalfa[.]blackberry[.]com\z/,
        ],
        'mtctouch' => [
            # mtc touch; http://www.mtctouch.com.lb/
            qr/\Amtctouch[.]blackberry[.]com\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::LB::Phone - Major phone provider's domains in Lebanon

=head1 SYNOPSIS

    use Sisimai::Group::LB::Phone;
    print Sisimai::Group::LB::Phone->find('alfa.blackberry.com');  # alfa

=head1 DESCRIPTION

Sisimai::Group::LB::Phone has a domain list of major cellular phone providers
and major smart phone providers in Lebanon.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

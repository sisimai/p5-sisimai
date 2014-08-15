package Sisimai::Group::ME::Phone;
use parent 'Sisimai::Group::Phone';
use strict;
use warnings;

sub table {
    return {
        # Major company's smaprtphone domains in Montenegro
        't-mobile' => [
            # T-Mobile; http://www.t-mobile.me/
            qr/\Ainstantemail[.]t-mobile[.]me\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::ME::Phone - Major phone provider's domains in Montenegro

=head1 SYNOPSIS

    use Sisimai::Group::ME::Phone;
    print Sisimai::Group::ME::Phone->find('instantemail.t-mobile.me'); # t-mobile

=head1 DESCRIPTION

Sisimai::Group::ME::Phone has a domain list of major cellular phone providers
and major smart phone providers in Montenegro.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

package Sisimai::Group::Phone;
use strict;
use warnings;

sub table {
    return {
        # Major cellular phone provider's domains in The World
        # https://github.com/cubiclesoft/email_sms_mms_gateways
        'bulksms' => [
            # BulkSMS International; http://bulksms.net
            qr/\Abulksms[.]net\z/,
        ],
        'bulletin' => [
            # BULLETIN; bulletinmessenger.net
            qr/\Abulletinmessenger[.]net\z/,
        ],
        'globalstar' => [
            # Globalstar; http://globalstar.com/
            qr/\Amsg[.]globalstarusa[.]com/,
        ],
        'iridium' => [
            # Iridium Communications Inc.; http://iridium.com/
            qr/\Amsg[.]iridium[.]com\z/,
        ],
        'panaceamobile' => [
            # Panacea Mobile; http://www.panaceamobile.com
            qr/\Aapi[.]panaceamobile[.]com\z/,
        ],
        'routomessaging' => [
            # RoutoMessaging; http://www.routomessaging.com
            qr/\Aemail2sms[.]routomessaging[.]com\z/,
        ],
        # Major smartphone provider's domains in The World
        'orange' => [
            # Orange; http://www.orange.com/
            qr/\Ablackberry[.]orange[.](?:ch|es|fr|md|pl|ro|sk)\z/,
            qr/\Ablackberry[.]orange[.]co[.]uk\z/,
            qr/\Aorange[.]?(?:at|bw|ci|cm|do|il|jo|ke|lu|re|sn|tn|uk)[.]blackberry[.]com\z/,
            qr/\Aorange(?:armenia|madagascar|mali|niger)[.]blackberry[.]com\z/,
        ],
        'nokia' => [
            # Ovi by Nokia, http://www.ovi.com/
            # Nokia Mail, https://www.nokiamail.com/home
            qr/\A(?:ovi|nokiamail)[.]com\z/,
        ],
        'vertu' => [
            # Vertu.Me; http://www.vertu.me/
            qr/\Avertu[.]me\z/,
        ],
        'vodafone' => [
            # Vodafone; http://www.vodafone.com/
            qr/\A360[.]com\z/,  # Vodafone 360, http://vodafone360.com/
            qr/\Amobileemail[.]vodafone[.]com[.](?:au|eg|fj|gh|hr|mk|mt|my|qa|tr)\z/,
            qr/\Amobileemail[.]vodafone[.](?:al|at|bg|cd|cz|de|dk|es|fr|gg|gr|hu)\z/,
            qr/\Amobileemail[.]vodafone[.](?:ie|in|is|it|je|lk|lt|lv|nl|pt|ro|se|si)\z/,
            qr/\Amobileemail[.]vodafone[.]net\z/,
            qr/\Amobileemail[.]vodafonesa[.]co[.]za\z/,
        ],
    };
}

sub category { 'phone' }
sub find {
    # @Description  Find the provider name of the domain
    # @Param <str>  (String) Domain part of the email address
    # @Return       (String) Provider name
    my $class = shift;
    my $argvs = shift || return '';
    my $table = $class->table;
    my $value = '';

    for my $e ( keys %$table ) {
        # Match with patterns in regular expressions of each provider
        next unless grep { $argvs =~ $_ } @{ $table->{ $e } };
        $value = $e;
        last;
    }
    return $value;
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::Phone - Major phone provider's domains in the world

=head1 SYNOPSIS

    use Sisimai::Group::Phone;
    print Sisimai::Group::Phone->find('nokiamail.com');    # nokia

=head1 DESCRIPTION

Sisimai::Group::Phone has a domain list of major cellular phone providers and
major smart phone providers of the world.

=head1 CLASS METHODS

=head2 C<B<find( I<domain> )>>

C<domain()> returns a category name found by the domain name from domain list.

    print Sisimai::Group::Phone->find('nokiamail.com');    # nokia

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

package Sisimai::Group::Web;
use strict;
use warnings;

sub table {
    return {
        # Major webmail provider's domains in The World
        #  * http://en.wikipedia.org/wiki/Webmail
        #  * http://en.wikipedia.org/wiki/Comparison_of_webmail_providers
        'aol' => [
            # AOL; America OnLine
            qr/\Aaol[.](?:com|net|org|asia)\z/,
            qr/\Aaim[.](?:com|net)\z/,
            qr/\Aaol[.]co[.](?:ck|gg|im|je|jp|kr|mu|nz|tt|uk|vi)\z/,
            qr/\Aaol[.]com[.](?:ag|ai|ar|au|az|br|bs|co|dm|do|gi|gy|kz|mx|nf|sc|tr|uy|ve)\z/,
            qr/\Aaol[.](?:ac|ag|am|at|be|bs|cg|ch|cl|cz|de|dk|es|fi|fm|fr|hk|hn|ie|in|io|it)\z/,
            qr/\Aaol[.](?:jp|kg|kr|lv|md|nl|pl|ru|rw|sc|se|sh|sn|to|tt|tw)\z/,
            qr/\Anetscape[.]net\z/,
            qr/\A(?:games|love|wow|ygm)[.]com\z/,   # AOL's Project Phoenix
        ],
        'apple' => [
            # mobileme, http://me.com/
            qr/\A(?:icloud|mac|me)[.]com\z/,
            qr/\Amac[.]me\z/,
        ],
        'excite' => [
            # http://excite.com/
            qr/\Aexcite[.](?:at|ch|com|cz|de|dk|es|eu|fr|ie|it)\z/,
            qr/\Aexcite[.](?:jp|li|lt|lv|nl|pl|se)\z/,
            qr/\Aexcite[.]co[.](jp|uk)\z/,
        ],
        'facebook' => [
            # Facebook has half a billion users.
            # http://www.facebook.com/
            qr/\Afacebook[.]com\z/,
            qr/\A(?:m|groups)[.]facebook[.]com\z/,
        ],
        'google' => [
            # GMail http://mail.google.com/mail/
            qr/\Agmail[.]com\z/,

            # GMail in U.K. and Germany
            qr/\Agooglemail[.]com\z/,
        ],
        'lycos' => [
            # http://www.lycos.com/
            qr/\Alycos[.](?:at|com|de|es|fr|in|nl)\z/,
            qr/\Alycosmail[.]com\z/,
        ],
        'microsoft' => [
            # Windows Live Hotmail http://www.hotmail.com/
            qr/\A(?:live|msn|windowslive|outlook)[.]com\z/,
            qr/\Ahotmail[.](?:com|info)\z/,
            qr/\Ahotmail[.](?:ac|as|at|bb|be|bs|ca|ch|cl|cz|de|dk|ee|es|fi|fr|gr|hk|hu)\z/,
            qr/\Ahotmail[.](?:ie|it|jp|la|lt|lu|lv|ly|mn|mw|my|nl|no|ph|pl|pn|pt)\z/,
            qr/\Ahotmail[.](?:rs|se|sg|sh|sk|ua|vu)\z/,
            qr/\Ahotmail[.]co[.](?:at|hu|id|il|in|it|jp|kr|nz|pn|th|ug|uk|ve|za)\z/,
            qr/\Ahotmail[.]com[.](?:ar|au|bo|br|do|hk|ly|my|ph|pl|ru|sg|tr|tt|tw|uz|ve|vn)\z/,
            qr/\Alive[.](?:at|be|ca|ch|cl|cn|de|dk|fi|fr|hk|ie|in|it|jp|lu|nl|no|ph|ru|se)\z/,
            qr/\Alive[.]co[.](?:hu|in|it|kr|uk|za)\z/,
            qr/\Alive[.]com[.](?:ar|au|co|mx|my|pe|ph|pk|pt|sg|ve)\z/,
            qr/\Amsn[.](?:cn|fi|fr|hu|it|nl)\z/,
            qr/\Amsnhotmail[.]nl\z/,
            qr/\Awindowslive[.](?:es|fi|fr|hu|it|mp|nl)\z/,
            qr/\Aoutlook[.](?:at|be|bg|bz|cl|cm|co|de|dk|ec|fr|hn|ht|hu|ie|it|jp)\z/,
            qr/\Aoutlook[.](?:kr|la|lv|mx|my|pa|ph|pk|pt|ro|sa|sg|si|sk|uy)\z/,
            qr/\Aoutlook[.]com[.](?:ar|au|br|es|fr|gr|hr|pe|py|tr|ua|vn)\z/,
        ],
        'myspace' => [
            # MySpace Mail has over 15 million users.
            # http://www.myspace.com/
            qr/\Amyspace[.]com\z/,
        ],
        'opera' => [
            # My Opera Mail; https://mail.opera.com/
            qr/\Amyopera[.]com\z/,
        ],
        'orange' => [
            # Orange; 
            # LatinMail; http://www.latinmail.com/
            qr/\A(?:latinmail|starmedia)[.]com\z/,
        ],
        'yahoo' => [
            # Yahoo! Mail; http://world.yahoo.com/
            qr/\Ayahoo[.]com\z/,
            qr/\Ayahoo[.](?:at|be|bg|ca|cl|cn|cz|de|dk|ee|es|fi|fr|gr|hu)\z/,
            qr/\Ayahoo[.](?:ie|in|it|jp||lt|lv|nl|no|pl|pt|ro|se|sk)\z/,
            qr/\Ayahoo[.]co[.](?:ee|id|il|in|jp|kr|nz|th|uk|za)\z/,
            qr/\Ayahoo[.]com[.](?:ar|au|br|co|hk|hr|mx|my|pe|ph|sg|tr|tw|ua|ve|vn)\z/,
            qr/\A(?:ymail|rocketmail)[.]com\z/, # From 2008/06/19
            qr/\Ayahoo[.]ne[.]jp\z/,            # From 2013/08/20

            # http://promo.mail.yahoo.co.jp/collabo/
            # From 2009/12/01
            qr/\Ailove-(?:mickey|minnie|pooh|stitch|tinkerbell)[.]jp\z/,
            qr/\Agamba[-]fan[.]jp\z/,
            qr/\Ahawks[-]fan[.]jp\z/,
            qr/\Ay[-]fmarinos[.]com\z/,     # From 2010/02/17
        ],
    };
}

sub category { 'web' }
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

Sisimai::Group::Web - Major web mail service provider's domains in the world

=head1 SYNOPSIS

    use Sisimai::Group::Web;
    print Sisimai::Group::Web->find('gmail.com');    # google

=head1 DESCRIPTION

Sisimai::Group::Web has a domain list of major web mail service providers in
the world.

=head1 CLASS METHODS

=head2 C<B<find( I<domain> )>>

C<domain()> returns a category name found by the domain name from domain list.

    print Sisimai::Group::Web->find('gmail.com');    # google

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

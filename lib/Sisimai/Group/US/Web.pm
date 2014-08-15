package Sisimai::Group::US::Web;
use parent 'Sisimai::Group::Web';
use strict;
use warnings;

sub table {
    return {
        # Major company's Webmail domains in the United States of America
        'bluetie' => [
            # EXPERIMENTAL(Not Tested), Does anyone know other domains of bluetie.com?
            # http://www.bluetie.com/
            qr/\Abluetie[.]com\z/,
        ],
        'inbox.com' => [
            # http://www.inbox.com/
            qr/\Ainbox[.]com\z/,
        ],
        'lavabit' => [
            # EXPERIMENTAL(Not Tested), Does anyone know other domains of lavabit.com?
            # http://lavabit.com/
            qr/\Alavabit[.]com\z/,
        ],
        'luxsci' => [
            # EXPERIMENTAL(Not Tested), Does anyone know other domains of luxsci.com?
            # http://luxsci.com/
            qr/\Aluxsci[.]com\z/,
        ],
        'mail.com' => [
            # http://www.mail.com/intl/
            # 2-4 characters(.com)
            qr/\A(?:dr|usa|asia|mail|oath|post|rome|skim|toke)[.]com\z/,

            # 3-8 characters(.net)
            qr/\A(?:chef|null|surfy|pigpig|fireman|bellair|graffiti)[.]net\z/,

            # 5-7 characters(.org)
            qr/\A(mcmug|dogmail)[.]org\z/,

            # 5-6 characters(.com)
            qr/\A(?:2trom|clerk|comic|email|execs|iname|japan|tamil|tokyo)[.]com\z/,
            qr/\A(?:adexec|alumni|berlin|blader|devout|doctor|dublin|europe|indiya|london)[.]com\z/,
            qr/\A(?:madrid|munich|muslim|myself|outgun|priest|reborn|techie|tvstar|umpire|wallet|worker|xposta)[.]com\z/,

            # 7-8 characters(.com)
            qr/\A(?:168city|angelic|atheist|blading|britain|chemist|diploma|inorbit|insurer|kahkaha|lovecat|madhuri)[.]com\z/,
            qr/\A(?:mail[-]me|mustbuy|newsrap|revenue|safrica|saintly|skibuff|teacher|webname|writeme)[.]com\z/,
            qr/\A(?:activist|baptized|buddhist|cheerful|cybergal|engineer|follower|gardener)[.]com\z/,
            qr/\A(?:hot[-]shot|innocent|kissfans|lobbyist|minister|optician|orthodox|samerica|theplate|therange)[.]com\z/,

            # *.usa.com
            qr/\A(?:alabama|alaska|arizona|arkansas|california|colorado|connecticut|delaware|florida|georgia)[.]usa[.]com\z/,
            qr/\A(?:hawaii|idaho|illinois|indiana|iowa|kansas|kentucky|louisiana|massachusetts|minnesota)[.]usa[.]com\z/,
            qr/\A(?:mississippi|missouri|montana|nebraska|nevada|newhampshire|newjersey|newmexico|newyork)[.]usa[.]com\z/,
            qr/\A(?:northcarolina|northdakota|ohio|oklahoma|oregon|pennsylvania|rhodeisland|southcarolina)[.]usa[.]com\z/,
            qr/\A(?:southdakota|tennessee|texas|utah|virginia|washington|washingtondc|westvirginia|wisconsin|wyoming)[.]usa[.]com\z/,

            # *mail.com
            qr/\A(?:africa|aircraft|america|arctic|argentina|asia[-]|asia|australia|belgium[-]|boarder)mail[.]com\z/,
            qr/\A(?:brazil|bsd|china[-]e|china|california|dallas|dbz|delhi|doctor|dora|dutch|england)mail[.]com\z/,
            qr/\A(?:europe|faster|finland|germany|group|hacker|home|house|india|ireland|israel|italy)mail[.]com\z/,
            qr/\A(?:japan[-]|jeddah|kero|kichi|kitty|korea|london|march|mexico|moscow|move|norway|nyc)mail[.]com\z/,
            qr/\A(?:otaku|paris|planet|poland|ranma|rave|sam|sanfran|scotland|seckin|singapore|spain)mail[.]com\z/,
            qr/\A(?:sweden|swiss|taiwan|tampa|tokyo|toronto|universal|urgent|uy|work|write|yyh)mail[.]com\z/,

            # *fan.com
            qr/\A(?:3rdeye|acdc|aerosmith|beatles|bowie|chilipeppers|clapton|disco|drslump|elvis|greenday)fan[.]com\z/,
            qr/\A(?:gundam|hendrix|hiphop|ledzep|madonna|manson|matchbox20|metal|nin|oasis|pearljam|phish)fan[.]com\z/,
            qr/\A(?:prodigy|pumpkins|radiohead|reggae|rem|robo|ska|swing|toriamos|u2|wutang)fan[.]com\z/,

            # *lover.com
            qr/\A(?:art|bird|cat|dog|pet)lover[.]com\z/,

            # 9-10 characters(.com)
            qr/\A(?:allergist|bikerider|columnist|cyberdude|diplomats|disciples)[.]com\z/,
            qr/\A(?:financier|galaxyhit|geologist|handy[-]man)[.]com\z/,
            qr/\A(?:hilarious|mailpuppy|pakistans|publicist|radiostar|religions)[.]com\z/,
            qr/\A(?:religious|repairman|scientist|selfware|singapore|snakebite)[.]com\z/,
            qr/\A(?:accountant|consultant|counsellor|customized|disposable|ilikemoney|journalism|journalist)[.]com\z/,
            qr/\A(?:legislator|politician|presidency|protestant|rescueteam|sailormoon|saopaulino|screenstar)[.]com\z/,
            qr/\A(?:surferdude|tenchiclub|toothfairy|topservice|worshipper)[.]com\z/,

            # 4u.com
            qr/\A(?:boats|cash|computer|credit|doctor|food|idea|information|job|lawyer|solution)4u[.]com\z/,

            # *mail.net
            qr/\A(?:green|planet)mail[.]net\z/,

            # Other *.com
            qr/\A(?:archaeologist|mad[.]scientist|revolutionist|sociologist|technologist)[.]com\z/,
            qr/\A(?:alumnidirector|beatthestreet|brew[-]master|brew[-]meister|cyber[-]wizard|cyberservices)[.]com\z/,
            qr/\A(?:deliveryman|digitalbuzz|fastservice|graphic[-]designer|instruction|intelligencia)[.]com\z/,
            qr/\A(?:internetaddress|meaningofitall|mmc[-]static3|net[-]shopping|nirvanafans|nonpartisan)[.]com\z/,
            qr/\A(?:pacific-ocean|pacificwest|pediatrician|qualityservice|realtyagent|registerednurses)[.]com\z/,
            qr/\A(?:reincarnate|representative|resourceful|resurrection|tech[-]center|ultrapostman)[.]com\z/,

            # Other *.net
            qr/\A(?:appraiser|auctioneer|bartender|contractor|coolsite|email2me|exterminator|hairdresser)[.]net\z/,
            qr/\A(?:humanoid|instructor|nietzsche|orthodontist|photographer|physicist|programmer|radiologist)[.]net\z/,
            qr/\A(?:salesperson|secretary|socialworker|songwriter|surgical|therapist)[.]net\z/,

            # *.org and others
            qr/\A(?:clubmember|collector|graduate|linuxmail|musician|roxette|teachers)[.]org\z/,
            qr/\A(?:hk|jp)popstarmail[.]org\z/,
            qr/\Apcmail[.]com[.]tw\z/,
        ],
        'mail2world' => [
            # http://www.mail2world.com/
            # 2000 domain names in http://www.mail2world.com/s/m2wpublic/domains/domains_firstnames.asp
            qr/\Amail2.+[.]com\z/,  # Low precision, we can not list all the domains...
        ],
        'myemail' => [
            # MyEmail.com; http://www.myemail.com/
            qr/\Amyemail[.]com\z/,
        ],
        'pobox' => [
            # http://www.pobox.com/index/
            qr/\Aonepost[.]net\z/,
            qr/\A(?:po|foo|right|topic|immer|siempre)box[.]com\z/,
            qr/\A(?:veri|foo)box[.]net\z/,
            qr/\A(?:penguin|permanental|siempre|immer)mail[.]com\z/,
            qr/\A(?:mailzone|lifetimeaddress)[.]com\z/,
        ],
        'rock.com' => [
            # Rock.com; http://www.rock.com/
            qr/\Arock[.]com\z/,
        ],
        'shtrudel' => [
            # http://www.shtrudel.com/
            qr/\Ashtrudel[.](?:at|biz|co[.]in|com|info|net|org|tk|tv|us)\z/,
            qr/\Ashtroodel[.](?:com|net|org)\z/,
            qr/\Ashtrudelmail[.](?:com|net)\z/,

            qr/\A(?:lim|53z)[.]org\z/,
            qr/\A(?:2[-]do|edited|netip)[.]biz\z/,
            qr/\A(?:4uy|7qa|augt|g37|myqtmail|pay1)[.]net\z/,
            qr/\A(?:5gmail|allwebmail|clieo|domain12|domainfive|e4dable|ema[-]il|email[-]il)[.]com\z/,
            qr/\A(?:everycorp|everylight|ez[-]webmail|faxdomain|frogemail|giganticmail|guruw)[.]com\z/,
            qr/\A(?:im7t|in[-]access|jagunda|maildn|maildone|mailwebaccess|mailx1|mailxweb|mailydaily)[.]com\z/,
            qr/\A(?:moreemails|mybzmail|mygigmail|myhugemail|myqtmail|onegiga|popju|postmymail)[.]com\z/,
            qr/\A(?:ptzu|q0p|qtwebmail|rpeat|siscs|speej|strudelmail|tipip|trywebmail|verbank)[.]com\z/,
            qr/\A(?:w8f|webmail12|wenax|whass|yseat)[.]com\z/,

            qr/\A(?:da|ismo)[.]bz\z/,
            qr/\A(?:qmail|qtmail|xweb)[.]co[.]il\z/,
            qr/\Aqttext[.](?:com|net)\z/,
        ],
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Sisimai::Group::US::Web - Major web mail service provider's domains in The 
United States of America

=head1 SYNOPSIS

    use Sisimai::Group::US::Web;
    print Sisimai::Group::US::Web->find('lovecat.com');    # mail.com

=head1 DESCRIPTION

Sisimai::Group::US::Web has a domain list of major web mail service providers
in The United States of America.

=head1 AUTHOR

azumakuniyuki

=head1 COPYRIGHT

Copyright (C) 2014 azumakuniyuki E<lt>perl.org@azumakuniyuki.orgE<gt>,
All Rights Reserved.

=head1 LICENSE

This software is distributed under The BSD 2-Clause License.

=cut

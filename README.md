         ____  _     _                 _ 
        / ___|(_)___(_)_ __ ___   __ _(_)
        \___ \| / __| | '_ ` _ \ / _` | |
         ___) | \__ \ | | | | | | (_| | |
        |____/|_|___/_|_| |_| |_|\__,_|_|
                                 

What is Sisimai ?
=================

Sisimai is a core module of bounceHammer version. 4, is a Perl module for 
analyzing email bounce. "Sisimai" stands for SISI "Mail Analyzing Interface".

System requirements
-------------------

* Perl 5.10.1 or later

Dependencies
------------
Sisimai relies on:

* __Class::Accessor::Lite__
* __Try::Tiny__
* __JSON__

Install
-------

    % sudo cpanm Sisimai

OR
    
    % cd /usr/local/src
    % git clone https://github.com/azumakuniyuki/Sisimai.git
    % cd ./Sisimai
    % sudo cpanm .


Basic usage
-----------
make() method provides feature for getting parsed data from bounced email 
messages like following.

    use Sisimai;
    my $v = Sisimai->make( '/path/to/mbox' );   # or Path to Maildir

    if( defined $v ) {
        for my $e ( @$v ) {
            print ref $e;                   # Sisimai::Data
            print $e->recipient->address;   # kijitora@example.jp
            print $e->reason;               # userunknown

            my $h = $e->damn();             # Convert to HASH reference
            my $j = $e->dump('json');       # Convert to JSON string
            print $e->dump('json');         # JSON formatted bounce data
        }
    }

REPOSITORY
----------
[github.com/azumakuniyuki/Sisimai](https://github.com/azumakuniyuki/Sisimai)

WEB SITE
--------
[bounceHammer | an open source software for handling email bounces](http://bouncehammer.jp/)

AUTHOR
------
azumakuniyuki

COPYRIGHT
---------
Copyright (C) 2014 azumakuniyuki <perl.org@azumakuniyuki.org>,
All Rights Reserved.

LICENSE
-------
This software is distributed under The BSD 2-Clause License.


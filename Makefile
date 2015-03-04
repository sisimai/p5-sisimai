# p5-Sisimai/Makefile
#  __  __       _         __ _ _      
# |  \/  | __ _| | _____ / _(_) | ___ 
# | |\/| |/ _` | |/ / _ \ |_| | |/ _ \
# | |  | | (_| |   <  __/  _| | |  __/
# |_|  |_|\__,_|_|\_\___|_| |_|_|\___|
# ---------------------------------------------------------------------------
SHELL = /bin/sh
HERE  = $(shell `pwd`)
TIME  = $(shell date '+%s')
NAME  = Sisimai
PERL  = perl
CPANM = http://xrl.us/cpanm
WGET  = wget -c
CURL  = curl -LOk
CHMOD = chmod
MKDIR = mkdir -p
PROVE = prove -Ilib --timer
MINIL = minil
LS    = ls -1
CP    = cp
RM    = rm -f
MP    = /usr/local/bouncehammer/bin/mailboxparser -Tvvvvvv
GIT   = /usr/bin/git

EMAIL_PARSER = ./tmp/emparser -fjson
EMAIL_SAMPLE = ./tmp/sample
FOR_EMPARSER = ./tmp/data
FOR_MAKETEST = ./eg/maildir-as-a-sample/new
MAILBOX_FILE = ./eg/mbox-as-a-sample
MTAMODULEDIR = ./lib/$(NAME)/MTA
MSPMODULEDIR = ./lib/$(NAME)/MSP
ACCURACYLIST = ./ANALYSIS-ACCURACY
TABLE_LENGTH = 24

.PHONY: clean
test: user-test author-test
user-test:
	$(PROVE) t/

author-test:
	for v in `find $(FOR_MAKETEST) -name '*.eml' -type f`; do \
		n=`basename $$v` ;\
		l=`echo $$n | wc -c` ;\
		printf "[%s] %s " `date '+%T'` `basename $$v` ;\
		while [ $$l -le 30 ]; do \
			printf "%s" '.' ;\
			l=`expr $$l + 1` ;\
		done ;\
		printf ' ' ;\
		nkf --guess $$v | grep '(LF)' > /dev/null || exit 1 && echo 'ok';\
	done
	$(PROVE) xt/

cover-test:
	cover -test

accuracy-table:
	@ printf " %s\n" 'bounceHammer 2.7.13 + bounceHammer nails(*)'
	@ printf " %s\n" 'MTA MODULE NAME          CAN PARSE   RATIO   NOTES'
	@ printf "%s\n" '-------------------------------------------------------------------------------'
	@ for v in `$(LS) $(MTAMODULEDIR)/*.pm`; do \
		m="MTA::`echo $$v | cut -d/ -f5 | sed 's/.pm//g'`" ;\
		d="`echo $$v | cut -d/ -f5 | tr '[A-Z]' '[a-z]' | sed 's/.pm//g'`" ;\
		l="`echo $$m | wc -c`" ;\
		printf "%s " $$m ;\
		while [ $$l -le $(TABLE_LENGTH) ]; do \
			printf "%s" '.' ;\
			l=`expr $$l + 1` ;\
		done ;\
		printf "%s" ' ' ;\
		r0=`$(MP) $(EMAIL_SAMPLE)/$$d 2>&1 | grep 'debug0:' \
			| sed 's/^.*debug0:/0 /g' | cut -d' ' -f9,10` ;\
		rn="`echo $$r0 | cut -d/ -f1`" ;\
		rd="`echo $$r0 | cut -d/ -f2 | cut -d' ' -f1`" ;\
		rr="`echo $$r0 | cut -d ' ' -f2 | tr -d '()'`" ;\
		printf "%4d/%04d  %s  " $$rn $$rd $$rr ;\
		$(PERL) -Ilib -MSisimai::$$m -lE "print Sisimai::$$m->description" ;\
	done
	@ for c in `$(LS) $(MSPMODULEDIR)`; do \
		for v in `$(LS) $(MSPMODULEDIR)/$$c/*.pm`; do \
			m="$$c::"`echo $$v | cut -d/ -f6 | sed 's/.pm//g'` ;\
			d="`echo $$m | tr '[A-Z]' '[a-z]' | sed 's/::/-/'`" ;\
			l="`echo MSP::$$m | wc -c`" ;\
			printf "MSP::%s " $$m ;\
			while [ $$l -le $(TABLE_LENGTH) ]; do \
				printf "%s" '.' ;\
				l=`expr $$l + 1` ;\
			done ;\
			printf "%s" ' ' ;\
			r0=`$(MP) $(EMAIL_SAMPLE)/$$d 2>&1 | grep 'debug0:' \
				| sed 's/^.*debug0:/0 /g' | cut -d' ' -f9,10` ;\
			rn="`echo $$r0 | cut -d/ -f1`" ;\
			rd="`echo $$r0 | cut -d/ -f2 | cut -d' ' -f1`" ;\
			rr="`echo $$r0 | cut -d ' ' -f2 | tr -d '()'`" ;\
			printf "%4d/%04d  %s  " $$rn $$rd $$rr ;\
			$(PERL) -Ilib -MSisimai::MSP::$$m -lE "print Sisimai::MSP::$$m->description" ;\
		done ;\
	done
	@ for v in ARF RFC3464; do \
		m=$$v ;\
		d="`echo $$v | tr '[A-Z]' '[a-z]'`" ;\
		l="`echo $$m | wc -c`" ;\
		printf "%s " $$m ;\
		while [ $$l -le $(TABLE_LENGTH) ]; do \
			printf "%s" '.' ;\
			l=`expr $$l + 1` ;\
		done ;\
		printf "%s" ' ' ;\
		r0=`$(MP) $(EMAIL_SAMPLE)/$$d 2>&1 | grep 'debug0:' \
			| sed 's/^.*debug0:/0 /g' | cut -d' ' -f9,10` ;\
		rn="`echo $$r0 | cut -d/ -f1`" ;\
		rd="`echo $$r0 | cut -d/ -f2 | cut -d' ' -f1`" ;\
		rr="`echo $$r0 | cut -d ' ' -f2 | tr -d '()'`" ;\
		printf "%4d/%04d  %s  " $$rn $$rd $$rr ;\
		$(PERL) -Ilib -MSisimai::$$m -lE "print Sisimai::$$m->description" ;\
	done
	@ printf "%s\n" '-------------------------------------------------------------------------------'

update-analysis-accuracy: sample
	$(CP) /dev/null $(ACCURACYLIST)
	make accuracy-table >> $(ACCURACYLIST)
	grep '^[A-Z]' $(ACCURACYLIST) | tr '/' ' ' | \
		awk '{ x += $$3; y += $$4 } END { \
			printf(" %s %4d/%04d  %0.4f\n %s  %4d/%04d  %0.4f\n", \
				"bounceHammer 2.7.X+nails", x, y, x / y, \
				"Sisimai(bounceHammer 4)", y, y, 1 ) }' \
			>> $(ACCURACYLIST)

release-test:
	$(CP) ./README.md /tmp/$(NAME)-README.$(TIME).md
	$(MAKE) clean
	$(MINIL) test
	$(CP) /tmp/$(NAME)-README.$(TIME).md ./README.md
	$(PERL) -i -ple 's|<az.+ki[@]gmail.com>|<perl.org\@azumakuniyuki.org>|' META.json

dist:
	$(CP) ./README.md /tmp/$(NAME)-README.$(TIME).md
	$(MAKE) clean
	$(MINIL) dist
	$(CP) /tmp/$(NAME)-README.$(TIME).md ./README.md
	$(PERL) -i -ple 's|<az.+ki[@]gmail.com>|<perl.org\@azumakuniyuki.org>|' META.json

push:
	for G in `grep -E '^[[]remote' .git/config | cut -d' ' -f2 | tr -d '"]'`; do \
		$(GIT) push --tags $$G master; \
	done

sample:
	for v in `$(LS) $(MTAMODULEDIR)/*.pm`; do \
		MTA=`echo $$v | cut -d/ -f5 | tr '[A-Z]' '[a-z]' | sed 's/.pm//g'` ;\
		$(MKDIR) $(EMAIL_SAMPLE)/$$MTA ;\
		$(CP) $(FOR_MAKETEST)/$$MTA-*.eml $(EMAIL_SAMPLE)/$$MTA/ ;\
		$(CP) $(FOR_EMPARSER)/$$MTA/* $(EMAIL_SAMPLE)/$$MTA/ ;\
	done
	for c in `$(LS) $(MSPMODULEDIR)`; do \
		for v in `$(LS) $(MSPMODULEDIR)/$$c/*.pm`; do \
			DIR=`echo $$c | tr '[A-Z]' '[a-z]' | tr -d '/'` ;\
			MSP="`echo $$v | cut -d/ -f6 | tr '[A-Z]' '[a-z]' | sed 's/.pm//g'`" ;\
			$(MKDIR) $(EMAIL_SAMPLE)/$$DIR-$$MSP ;\
			$(CP) $(FOR_MAKETEST)/$$DIR-$$MSP-*.eml $(EMAIL_SAMPLE)/$$DIR-$$MSP/ ;\
			$(CP) $(FOR_EMPARSER)/$$DIR-$$MSP/* $(EMAIL_SAMPLE)/$$DIR-$$MSP/ ;\
		done ;\
	done
	for v in arf rfc3464; do \
		$(MKDIR) $(EMAIL_SAMPLE)/$$v ;\
		$(CP) $(FOR_MAKETEST)/$$v*.eml $(EMAIL_SAMPLE)/$$v/ ;\
		$(CP) $(FOR_EMPARSER)/$$v/* $(EMAIL_SAMPLE)/$$v/ ;\
	done

profile:
	$(PERL) -d:NYTProf $(EMAIL_PARSER) $(FOR_MAKETEST) $(MAILBOX_FILE) > /dev/null
	nytprofhtml

benchmark-mbox:
	$(MKDIR) -p tmp/benchmark
	$(CP) `find $(EMAIL_SAMPLE) -type f` tmp/benchmark/

cpanm:
	$(WGET) $(CPANM) || $(CURL) $(CPANM)
	test -f ./$@ && $(CHMOD) a+x ./$@

install-from-cpan: cpanm
	sudo ./cpanm $(NAME)

install-from-local:
	sudo ./cpanm .

clean:
	yes | $(MINIL) clean
	$(RM) -r nytprof*
	$(RM) -r cover_db
	$(RM) -r ./build
	$(RM) -r $(EMAIL_SAMPLE)


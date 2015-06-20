# p5-Sisimai/Makefile
#  __  __       _         __ _ _      
# |  \/  | __ _| | _____ / _(_) | ___ 
# | |\/| |/ _` | |/ / _ \ |_| | |/ _ \
# | |  | | (_| |   <  __/  _| | |  __/
# |_|  |_|\__,_|_|\_\___|_| |_|_|\___|
# ---------------------------------------------------------------------------
SHELL := /bin/sh
HERE  := $(shell pwd)
TIME  := $(shell date '+%s')
NAME  := Sisimai
PERL  := perl
CPANM := http://xrl.us/cpanm
WGET  := wget -c
CURL  := curl -LOk
CHMOD := chmod
MKDIR := mkdir -p
PROVE := prove -Ilib --timer
MINIL := minil
LS    := ls -1
CP    := cp
RM    := rm -f
MP    := /usr/local/bouncehammer/bin/mailboxparser -Tvvvvvv
GIT   := /usr/bin/git

EMAIL_PARSER := ./tmp/emparser
EMAIL_SAMPLE := ./tmp/sample
FOR_EMPARSER := ./tmp/data
PARSERLOGDIR := ./tmp/log
FOR_MAKETEST := ./eg/maildir-as-a-sample/new
CRLF_SAMPLES := ./eg/maildir-as-a-sample/dos
CRFORMATMAIL := ./eg/maildir-as-a-sample/mac
MAILBOX_FILE := ./eg/mbox-as-a-sample
MTAMODULEDIR := ./lib/$(NAME)/MTA
MSPMODULEDIR := ./lib/$(NAME)/MSP
PRECISIONTAB := ./ANALYTICAL-PRECISION
INDEX_LENGTH := 24
DESCR_LENGTH := 48

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
	@ for v in `grep -E '^[[]remote' .git/config | cut -d' ' -f2 | tr -d '"]'`; do \
		printf "[%s]\n" $$v; \
		$(GIT) push --tags $$v master; \
	done

cpanm:
	$(WGET) $(CPANM) || $(CURL) $(CPANM)
	test -f ./$@ && $(CHMOD) a+x ./$@

install-from-cpan: cpanm
	sudo ./cpanm $(NAME)

install-from-local:
	sudo ./cpanm .

# -----------------------------------------------------------------------------
#  _____                    _          __                  _                _   
# |_   _|_ _ _ __ __ _  ___| |_ ___   / _| ___  _ __    __| | _____   _____| |  
#   | |/ _` | '__/ _` |/ _ \ __/ __| | |_ / _ \| '__|  / _` |/ _ \ \ / / _ \ |  
#   | | (_| | | | (_| |  __/ |_\__ \ |  _| (_) | |    | (_| |  __/\ V /  __/ |_ 
#   |_|\__,_|_|  \__, |\___|\__|___/ |_|  \___/|_|     \__,_|\___| \_/ \___|_(_)
#                |___/                                                          
# -----------------------------------------------------------------------------
accuracy-table:
	@ printf " %s\n" 'bounceHammer 2.7.13'
	@ printf " %s\n" 'MTA MODULE NAME          CAN PARSE   RATIO   NOTES'
	@ printf "%s\n" '-------------------------------------------------------------------------------'
	@ for v in `$(LS) $(MTAMODULEDIR)/*.pm`; do \
		m="MTA::`echo $$v | cut -d/ -f5 | sed 's/.pm//g'`" ;\
		d="`echo $$v | cut -d/ -f5 | tr '[A-Z]' '[a-z]' | sed 's/.pm//g'`" ;\
		l="`echo $$m | wc -c`" ;\
		printf "%s " $$m ;\
		while [ $$l -le $(INDEX_LENGTH) ]; do \
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
			while [ $$l -le $(INDEX_LENGTH) ]; do \
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
		while [ $$l -le $(INDEX_LENGTH) ]; do \
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

update-analytical-precision-table: sample
	$(CP) /dev/null $(PRECISIONTAB)
	make accuracy-table >> $(PRECISIONTAB)
	grep '^[A-Z]' $(PRECISIONTAB) | tr '/' ' ' | \
		awk ' { \
				x += $$3; \
				y += $$4; \
			} END { \
				sisimai_cmd = "$(PERL) -Ilib -M$(NAME) -E '\''print $(NAME)->version'\''"; \
				sisimai_cmd | getline sisimai_ver; \
				close(sisimai_cmd); \
				printf(" %s %4d/%04d  %0.4f\n %s %s %9s %4d/%04d  %0.4f\n", \
					"bounceHammer 2.7.13     ", x, y, x / y, \
					"Sisimai", sisimai_ver, " ", y, y, 1 ); \
			} ' \
			>> $(PRECISIONTAB)

mta-module-table:
	@ printf "%s\n"  '| Module Name(Sisimai::)   | Description                                       |'
	@ printf "%s\n"  '|--------------------------|---------------------------------------------------|'
	@ for v in `$(LS) $(MTAMODULEDIR)/*.pm`; do \
		m="MTA::`echo $$v | cut -d/ -f5 | sed 's/.pm//g'`" ;\
		d="`echo $$v | cut -d/ -f5 | tr '[A-Z]' '[a-z]' | sed 's/.pm//g'`" ;\
		l="`echo $$m | wc -c`" ;\
		printf "| %s " $$m ;\
		while [ $$l -le $(INDEX_LENGTH) ]; do \
			printf "%s" ' ' ;\
			l=`expr $$l + 1` ;\
		done ;\
		printf "%s" '|' ;\
		r=`$(PERL) -Ilib -MSisimai::$$m -le "print Sisimai::$$m->description"` ;\
		x="`echo $$r | wc -c`" ;\
		printf " %s" $$r ;\
		while [ $$x -le $(DESCR_LENGTH) ]; do \
			printf "%s" ' ' ;\
			x=`expr $$x + 1` ;\
		done ;\
		printf " %s\n" ' |' ;\
	done
	@ for c in `$(LS) $(MSPMODULEDIR)`; do \
		for v in `$(LS) $(MSPMODULEDIR)/$$c/*.pm`; do \
			m="$$c::"`echo $$v | cut -d/ -f6 | sed 's/.pm//g'` ;\
			d="`echo $$m | tr '[A-Z]' '[a-z]' | sed 's/::/-/'`" ;\
			l="`echo MSP::$$m | wc -c`" ;\
			printf "| MSP::%s " $$m ;\
			while [ $$l -le $(INDEX_LENGTH) ]; do \
				printf "%s" ' ' ;\
				l=`expr $$l + 1` ;\
			done ;\
			printf "%s" '|' ;\
			r=`$(PERL) -Ilib -MSisimai::MSP::$$m -le "print Sisimai::MSP::$$m->description"` ;\
			x="`echo $$r | wc -c`" ;\
			printf " %s" $$r ;\
			while [ $$x -le $(DESCR_LENGTH) ]; do \
				printf "%s" ' ' ;\
				x=`expr $$x + 1` ;\
			done ;\
			printf " %s\n" ' |' ;\
		done ;\
	done
	@ for v in ARF RFC3464; do \
		m=$$v ;\
		d="`echo $$v | tr '[A-Z]' '[a-z]'`" ;\
		l="`echo $$m | wc -c`" ;\
		printf "| %s " $$m ;\
		while [ $$l -le $(INDEX_LENGTH) ]; do \
			printf "%s" ' ' ;\
			l=`expr $$l + 1` ;\
		done ;\
		printf "%s" '|' ;\
		r=`$(PERL) -Ilib -MSisimai::$$m -lE "print Sisimai::$$m->description"` ;\
		x="`echo $$r | wc -c`" ;\
		printf " %s" $$r ;\
		while [ $$x -le $(DESCR_LENGTH) ]; do \
			printf "%s" ' ' ;\
			x=`expr $$x + 1` ;\
		done ;\
		printf " %s\n" ' |' ;\
	done

update-sample-emails:
	for v in `find $(FOR_MAKETEST) -name '*-01.eml' -type f`; do \
		f="`basename $$v`" ;\
		nkf -Lw $$v > $(CRLF_SAMPLES)/$$f ;\
		nkf -Lm $$v > $(CRFORMATMAIL)/$$f ;\
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

parser-log:
	$(MKDIR) $(PARSERLOGDIR)
	for v in `$(LS) $(FOR_EMPARSER)`; do \
		$(CP) /dev/null $(PARSERLOGDIR)/$$v.log; \
		for r in `find $(FOR_EMPARSER)/$$v -type f -name '*.eml'`; do \
			echo $$r; \
			echo $$r >> $(PARSERLOGDIR)/$$v.log; \
			$(EMAIL_PARSER) -Fddp $$r | grep -E 'reason|diagnosticcode|deliverystatus' >> $(PARSERLOGDIR)/$$v.log; \
			echo >> $(PARSERLOGDIR)/$$v.log; \
		done; \
	done

profile:
	$(PERL) -d:NYTProf $(EMAIL_PARSER) -Fjson $(FOR_MAKETEST) $(MAILBOX_FILE) > /dev/null
	nytprofhtml

benchmark-mbox:
	$(MKDIR) -p tmp/benchmark
	$(CP) `find $(EMAIL_SAMPLE) -type f` tmp/benchmark/

loc:
	@ for v in `find lib -type f -name '*.pm'`; do \
		x=`wc -l $$v | awk '{ print $$1 }'`; \
		y=`cat -n $$v | grep '\t1;' | tail -n 1 | awk '{ print $$1 }'`; \
		z=`grep -E '^\s*#|^$$' $$v | wc -l | awk '{ print $$1 }'`; \
		echo "$$x - ( $$x - $$y ) - $$z" | bc ;\
	done | awk '{ s += $$1 } END { print s }'

clean:
	yes | $(MINIL) clean
	$(RM) -r nytprof*
	$(RM) -r cover_db
	$(RM) -r ./build
	$(RM) -r $(EMAIL_SAMPLE)


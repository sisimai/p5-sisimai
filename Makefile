# p5-Sisimai/Makefile
#  __  __       _         __ _ _      
# |  \/  | __ _| | _____ / _(_) | ___ 
# | |\/| |/ _` | |/ / _ \ |_| | |/ _ \
# | |  | | (_| |   <  __/  _| | |  __/
# |_|  |_|\__,_|_|\_\___|_| |_|_|\___|
# -----------------------------------------------------------------------------
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

.DEFAULT_GOAL = git-status
BH_LATESTVER := 2.7.13p1
EMAIL_PARSER := ./sbin/emparser
EMAIL_SAMPLE := ./tmp/sample
BENCHMARKDIR := ./tmp/benchmark
FOR_EMPARSER := ./var/data
PARSERLOGDIR := ./var/log
FOR_MAKETEST := ./eg/maildir-as-a-sample/new
CRLF_SAMPLES := ./eg/maildir-as-a-sample/dos
CRFORMATMAIL := ./eg/maildir-as-a-sample/mac
MAILBOX_FILE := ./eg/mbox-as-a-sample
MTAMODULEDIR := ./lib/$(NAME)/MTA
MSPMODULEDIR := ./lib/$(NAME)/MSP
MTARELATIVES := ARF RFC3464 RFC3834
PRECISIONTAB := ./ANALYTICAL-PRECISION
INDEX_LENGTH := 24
DESCR_LENGTH := 48

# -----------------------------------------------------------------------------
.PHONY: clean
cpanm:
	$(WGET) $(CPANM) || $(CURL) $(CPANM)
	test -f ./$@ && $(CHMOD) a+x ./$@

install-from-cpan: cpanm
	sudo ./cpanm $(NAME)

install-from-local: cpanm
	sudo ./cpanm .

# -----------------------------------------------------------------------------
#  _____                    _          __                  _                _   
# |_   _|_ _ _ __ __ _  ___| |_ ___   / _| ___  _ __    __| | _____   _____| |  
#   | |/ _` | '__/ _` |/ _ \ __/ __| | |_ / _ \| '__|  / _` |/ _ \ \ / / _ \ |  
#   | | (_| | | | (_| |  __/ |_\__ \ |  _| (_) | |    | (_| |  __/\ V /  __/ |_ 
#   |_|\__,_|_|  \__, |\___|\__|___/ |_|  \___/|_|     \__,_|\___| \_/ \___|_(_)
#                |___/                                                          
# -----------------------------------------------------------------------------
test: user-test author-test
user-test:
	$(PROVE) t/

author-test:
	$(PROVE) xt/

cover-test:
	cover -test

release-test:
	$(CP) ./README.md /tmp/$(NAME)-README.$(TIME).md
	$(MAKE) clean
	$(MINIL) test
	$(CP) /tmp/$(NAME)-README.$(TIME).md ./README.md
	$(PERL) -i -ple 's|<az.+ki[@]gmail.com>|<github.com\@azumakuniyuki.org>|' META.json

dist:
	$(CP) ./README.md /tmp/$(NAME)-README.$(TIME).md
	$(MAKE) clean
	$(MINIL) dist
	$(CP) /tmp/$(NAME)-README.$(TIME).md ./README.md
	$(PERL) -i -ple 's|<az.+ki[@]gmail.com>|<github.com\@azumakuniyuki.org>|' META.json

push:
	@ for v in `git remote show | grep -v origin`; do \
		printf "[%s]\n" $$v; \
		$(GIT) push --tags $$v master; \
	done

git-status:
	git status

fix-commit-message:
	git commit --amend

private-sample:
	@test -n "$(E)" || ( echo 'Usage: make $@ E=/path/to/email' && exit 1 )
	test -f $(E)
	$(EMAIL_PARSER) $(E)
	@echo
	@while true; do \
		d=`$(EMAIL_PARSER) -Fjson ./$(E) | jq -M '.[].smtpagent' | tr '[A-Z]' '[a-z]' \
			| sed -e 's/"//g' -e 's/::/-/g'`; \
		if [ -d "$(FOR_EMPARSER)/$$d" ]; then \
			latestfile=`ls -1 $(FOR_EMPARSER)/$$d/*.eml | tail -1`; \
			curr_index=`basename $$latestfile | cut -d'-' -f1`; \
			next_index=`echo $$curr_index + 1 | bc`; \
		else \
			$(MAKEDIR) $(FOR_EMPARSER)/$$d; \
			next_index=1001; \
		fi; \
		hash_value=`md5 -q $(E)`; \
		printf "[%05d] %s %s\n" $$next_index $$hash_value \
			`$(EMAIL_PARSER) -Fjson ./$(SAMPLE) | jq -M '.[].reason'`; \
		mv -v $(E) $(FOR_EMPARSER)/$$d/0$${next_index}-$${hash_value}.eml; \
		break; \
	done

precision-table:
	@ printf " %s\n" 'bounceHammer $(BH_LATESTVER)'
	@ printf " %s\n" 'MTA MODULE NAME          CAN PARSE   RATIO   NOTES'
	@ printf "%s\n" '-------------------------------------------------------------------------------'
	@ for v in `$(LS) $(MTAMODULEDIR)/*.pm | grep -v 'UserDefined'`; do \
		m="MTA::`echo $$v | cut -d/ -f5 | sed 's/.pm//g'`" ;\
		d="`echo $$v | cut -d/ -f5 | tr '[A-Z]' '[a-z]' | sed 's/.pm//g'`" ;\
		l="`echo $$m | wc -c`" ;\
		printf "%s " $$m ;\
		while [ $$l -le $(INDEX_LENGTH) ]; do \
			printf "%s" '.' ;\
			l=`expr $$l + 1` ;\
		done ;\
		printf "%s" ' ' ;\
		n0=`$(EMAIL_PARSER) --count-only $(EMAIL_SAMPLE)/$$d` ;\
		r0=`$(MP) $(EMAIL_SAMPLE)/$$d 2>&1 | grep 'debug0:' \
			| sed 's/^.*debug0:/0 /g' | cut -d' ' -f9,10` ;\
		rn="`echo $$r0 | cut -d/ -f1`" ;\
		rr="`echo $$r0 | cut -d ' ' -f2 | tr -d '()'`" ;\
		printf "%4d/%04d  %s  " $$rn $$n0 $$rr ;\
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
			n0=`$(EMAIL_PARSER) --count-only $(EMAIL_SAMPLE)/$$d` ;\
			r0=`$(MP) $(EMAIL_SAMPLE)/$$d 2>&1 | grep 'debug0:' \
				| sed 's/^.*debug0:/0 /g' | cut -d' ' -f9,10` ;\
			rn="`echo $$r0 | cut -d/ -f1`" ;\
			rr="`echo $$r0 | cut -d ' ' -f2 | tr -d '()'`" ;\
			printf "%4d/%04d  %s  " $$rn $$n0 $$rr ;\
			$(PERL) -Ilib -MSisimai::MSP::$$m -lE "print Sisimai::MSP::$$m->description" ;\
		done ;\
	done
	@ for v in $(MTARELATIVES); do \
		m=$$v ;\
		d="`echo $$v | tr '[A-Z]' '[a-z]'`" ;\
		l="`echo $$m | wc -c`" ;\
		printf "%s " $$m ;\
		while [ $$l -le $(INDEX_LENGTH) ]; do \
			printf "%s" '.' ;\
			l=`expr $$l + 1` ;\
		done ;\
		printf "%s" ' ' ;\
		n0=`$(EMAIL_PARSER) --count-only $(EMAIL_SAMPLE)/$$d` ;\
		r0=`$(MP) $(EMAIL_SAMPLE)/$$d 2>&1 | grep 'debug0:' \
			| sed 's/^.*debug0:/0 /g' | cut -d' ' -f9,10` ;\
		rn="`echo $$r0 | cut -d/ -f1`" ;\
		rr="`echo $$r0 | cut -d ' ' -f2 | tr -d '()'`" ;\
		printf "%4d/%04d  %s  " $$rn $$n0 $$rr ;\
		$(PERL) -Ilib -MSisimai::$$m -lE "print Sisimai::$$m->description" ;\
	done
	@ printf "%s\n" '-------------------------------------------------------------------------------'

update-analytical-precision-table: sample
	$(CP) /dev/null $(PRECISIONTAB)
	make precision-table >> $(PRECISIONTAB)
	grep '^[A-Z]' $(PRECISIONTAB) | tr '/' ' ' | \
		awk ' { \
				x += $$3; \
				y += $$4; \
			} END { \
				sisimai_cmd = "$(PERL) -Ilib -M$(NAME) -E '\''print $(NAME)->version'\''"; \
				sisimai_cmd | getline sisimai_ver; \
				close(sisimai_cmd); \
				printf(" %s %4d/%04d  %0.4f\n %s %s %9s %4d/%04d  %0.4f\n", \
					"bounceHammer $(BH_LATESTVER)   ", x, y, x / y, \
					"Sisimai", sisimai_ver, " ", y, y, 1 ); \
			} ' \
			>> $(PRECISIONTAB)

mta-module-table:
	@ printf "%s\n"  '| Module Name(Sisimai::)   | Description                                       |'
	@ printf "%s\n"  '|--------------------------|---------------------------------------------------|'
	@ for v in `$(LS) $(MTAMODULEDIR)/*.pm | grep -v UserDefined`; do \
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
	@ for v in $(MTARELATIVES); do \
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
	for v in `$(LS) $(MTAMODULEDIR)/*.pm | grep -v UserDefined`; do \
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
	for v in arf rfc3464 rfc3834; do \
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

profile: benchmark-mbox
	$(PERL) -d:NYTProf $(EMAIL_PARSER) -Fjson $(BENCHMARKDIR) > /dev/null
	nytprofhtml

benchmark-mbox: sample
	$(MKDIR) -p $(BENCHMARKDIR)
	$(CP) `find $(EMAIL_SAMPLE) -type f` $(BENCHMARKDIR)/

loc:
	@ for v in `find lib -type f -name '*.pm'`; do \
		x=`wc -l $$v | awk '{ print $$1 }'`; \
		y=`cat -n $$v | grep '\t1;' | tail -n 1 | awk '{ print $$1 }'`; \
		z=`grep -E '^\s*#|^$$' $$v | wc -l | awk '{ print $$1 }'`; \
		echo "$$x - ( $$x - $$y ) - $$z" | bc ;\
	done | awk '{ s += $$1 } END { print s }'

clean:
	$(RM) -r nytprof*
	$(RM) -r cover_db
	$(RM) -r ./build
	$(RM) -r $(EMAIL_SAMPLE)
	$(RM) -r $(BENCHMARKDIR)


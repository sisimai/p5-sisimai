# p5-Sisimai/Developers.mk
#  ____                 _                                       _    
# |  _ \  _____   _____| | ___  _ __   ___ _ __ ___   _ __ ___ | | __
# | | | |/ _ \ \ / / _ \ |/ _ \| '_ \ / _ \ '__/ __| | '_ ` _ \| |/ /
# | |_| |  __/\ V /  __/ | (_) | |_) |  __/ |  \__ \_| | | | | |   < 
# |____/ \___| \_/ \___|_|\___/| .__/ \___|_|  |___(_)_| |_| |_|_|\_\
#                              |_|                                   
# -----------------------------------------------------------------------------
SHELL := /bin/sh
HERE  := $(shell pwd)
NAME  := Sisimai
PERL  := perl
MKDIR := mkdir -p
LS    := ls -1
CP    := cp

BH_LATESTVER := 2.7.13p3
MBOXPARSERV0 := /usr/local/bouncehammer/bin/mailboxparser -T
MBOXPARSERV6 := /usr/local/bouncehammer/bin/mailboxparser -Tvvvvvv
PRECISIONTAB := ANALYTICAL-PRECISION
PARSERLOGDIR := var/log
MTAMODULEDIR := lib/$(NAME)/MTA
MSPMODULEDIR := lib/$(NAME)/MSP
MTARELATIVES := ARF RFC3464 RFC3834
EMAIL_PARSER := sbin/emparser
BENCHMARKEMP := sbin/mp
BENCHMARKDIR := tmp/benchmark
BENCHMARKSET := tmp/sample
VELOCITYTEST := tmp/emails-for-velocity-measurement
SET_OF_EMAIL := set-of-emails
PRIVATEMAILS := $(SET_OF_EMAIL)/private
PUBLICEMAILS := $(SET_OF_EMAIL)/maildir/bsd
DOSFORMATSET := $(SET_OF_EMAIL)/maildir/dos
MACFORMATSET := $(SET_OF_EMAIL)/maildir/mac
INDEX_LENGTH := 24
DESCR_LENGTH := 48
BH_CAN_PARSE := courier exim messagingserver postfix sendmail surfcontrol x5 \
				jp-ezweb jp-kddi ru-yandex uk-messagelabs us-amazonses us-aol \
				us-bigfoot us-facebook us-outlook us-verizon

# -----------------------------------------------------------------------------
.PHONY: clean

private-sample:
	@test -n "$(E)" || ( echo 'Usage: make -f Developers.mk $@ E=/path/to/email' && exit 1 )
	test -f $(E)
	$(EMAIL_PARSER) $(E)
	@echo
	@while true; do \
		d=`$(EMAIL_PARSER) -Fjson $(E) | jq -M '.[].smtpagent' | head -1 \
			| tr '[A-Z]' '[a-z]' | sed -e 's/"//g' -e 's/::/-/g'`; \
		if [ -d "$(PRIVATEMAILS)/$$d" ]; then \
			latestfile=`ls -1 $(PRIVATEMAILS)/$$d/*.eml | tail -1`; \
			curr_index=`basename $$latestfile | cut -d'-' -f1`; \
			next_index=`echo $$curr_index + 1 | bc`; \
		else \
			$(MKDIR) $(PRIVATEMAILS)/$$d; \
			next_index=1001; \
		fi; \
		hash_value=`md5 -q $(E)`; \
		printf "[%05d] %s %s\n" $$next_index $$hash_value \
			`$(EMAIL_PARSER) -Fjson ./$(SAMPLE) | jq -M '.[].reason'`; \
		mv -v $(E) $(PRIVATEMAILS)/$$d/0$${next_index}-$${hash_value}.eml; \
		break; \
	done

precision-table:
	@ printf " %s\n" 'bounceHammer $(BH_LATESTVER)'
	@ printf " %s\n" 'MTA MODULE NAME          CAN PARSE   RATIO   NOTES'
	@ printf "%s\n" '-------------------------------------------------------------------------------'
	@ for v in `$(LS) ./$(MTAMODULEDIR)/*.pm | grep -v 'UserDefined'`; do \
		m="MTA::`echo $$v | cut -d/ -f5 | sed 's/.pm//g'`" ;\
		d="`echo $$v | cut -d/ -f5 | tr '[A-Z]' '[a-z]' | sed 's/.pm//g'`" ;\
		l="`echo $$m | wc -c`" ;\
		printf "%s " $$m ;\
		while [ $$l -le $(INDEX_LENGTH) ]; do \
			printf "%s" '.' ;\
			l=`expr $$l + 1` ;\
		done ;\
		printf "%s" ' ' ;\
		n0=`$(EMAIL_PARSER) --count-only $(BENCHMARKSET)/$$d` ;\
		r0=`$(MBOXPARSERV6) $(BENCHMARKSET)/$$d 2>&1 | grep 'debug0:' \
			| sed 's/^.*debug0:/0 /g' | cut -d' ' -f9,10` ;\
		rn="`echo $$r0 | cut -d/ -f1`" ;\
		if [ $$rn -lt $$n0 ]; then \
			rr=`$(PERL) -le "printf('%.4f', $$rn / $$n0 );"`; \
		else \
			rr='1.0000'; \
		fi; \
		printf "%4d/%04d  %s  " $$rn $$n0 $$rr ;\
		$(PERL) -Ilib -MSisimai::$$m -lE "print Sisimai::$$m->description" ;\
	done
	@ for c in `$(LS) ./$(MSPMODULEDIR)`; do \
		for v in `$(LS) ./$(MSPMODULEDIR)/$$c/*.pm`; do \
			m="$$c::"`echo $$v | cut -d/ -f6 | sed 's/.pm//g'` ;\
			d="`echo $$m | tr '[A-Z]' '[a-z]' | sed 's/::/-/'`" ;\
			l="`echo MSP::$$m | wc -c`" ;\
			printf "MSP::%s " $$m ;\
			while [ $$l -le $(INDEX_LENGTH) ]; do \
				printf "%s" '.' ;\
				l=`expr $$l + 1` ;\
			done ;\
			printf "%s" ' ' ;\
			n0=`$(EMAIL_PARSER) --count-only $(BENCHMARKSET)/$$d` ;\
			r0=`$(MBOXPARSERV6) $(BENCHMARKSET)/$$d 2>&1 | grep 'debug0:' \
				| sed 's/^.*debug0:/0 /g' | cut -d' ' -f9,10` ;\
			rn="`echo $$r0 | cut -d/ -f1`" ;\
			if [ $$rn -lt $$n0 ]; then \
				rr=`$(PERL) -le "printf('%.4f', $$rn / $$n0 );"`; \
			else \
				rr='1.0000'; \
			fi; \
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
		n0=`$(EMAIL_PARSER) --count-only $(BENCHMARKSET)/$$d` ;\
		r0=`$(MBOXPARSERV6) $(BENCHMARKSET)/$$d 2>&1 | grep 'debug0:' \
			| sed 's/^.*debug0:/0 /g' | cut -d' ' -f9,10` ;\
		rn="`echo $$r0 | cut -d/ -f1`" ;\
		if [ $$rn -lt $$n0 ]; then \
			rr=`$(PERL) -le "printf('%.4f', $$rn / $$n0 );"`; \
		else \
			rr='1.0000'; \
		fi; \
		printf "%4d/%04d  %s  " $$rn $$n0 $$rr ;\
		$(PERL) -Ilib -MSisimai::$$m -lE "print Sisimai::$$m->description" ;\
	done
	@ printf "%s\n" '-------------------------------------------------------------------------------'

update-analytical-precision-table: sample
	$(CP) /dev/null $(PRECISIONTAB)
	$(MAKE) -f Developers.mk precision-table >> $(PRECISIONTAB)
	grep '^[A-Z]' ./$(PRECISIONTAB) | tr '/' ' ' | \
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
	@ for v in `$(LS) ./$(MTAMODULEDIR)/*.pm | grep -v UserDefined`; do \
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
	@ for c in `$(LS) ./$(MSPMODULEDIR)`; do \
		for v in `$(LS) ./$(MSPMODULEDIR)/$$c/*.pm`; do \
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
	for v in `find $(PUBLICEMAILS) -name '*-01.eml' -type f`; do \
		f="`basename $$v`" ;\
		nkf -Lw $$v > $(DOSFORMATSET)/$$f ;\
		nkf -Lm $$v > $(MACFORMATSET)/$$f ;\
	done

sample:
	for v in `$(LS) ./$(MTAMODULEDIR)/*.pm | grep -v UserDefined`; do \
		MTA=`echo $$v | cut -d/ -f5 | tr '[A-Z]' '[a-z]' | sed 's/.pm//g'` ;\
		$(MKDIR) $(BENCHMARKSET)/$$MTA ;\
		$(CP) $(PUBLICEMAILS)/$$MTA-*.eml $(BENCHMARKSET)/$$MTA/ ;\
		$(CP) $(PRIVATEMAILS)/$$MTA/* $(BENCHMARKSET)/$$MTA/ ;\
	done
	for c in `$(LS) ./$(MSPMODULEDIR)`; do \
		for v in `$(LS) ./$(MSPMODULEDIR)/$$c/*.pm`; do \
			DIR=`echo $$c | tr '[A-Z]' '[a-z]' | tr -d '/'` ;\
			MSP="`echo $$v | cut -d/ -f6 | tr '[A-Z]' '[a-z]' | sed 's/.pm//g'`" ;\
			$(MKDIR) $(BENCHMARKSET)/$$DIR-$$MSP ;\
			$(CP) $(PUBLICEMAILS)/$$DIR-$$MSP-*.eml $(BENCHMARKSET)/$$DIR-$$MSP/ ;\
			$(CP) $(PRIVATEMAILS)/$$DIR-$$MSP/* $(BENCHMARKSET)/$$DIR-$$MSP/ ;\
		done ;\
	done
	for v in arf rfc3464 rfc3834; do \
		$(MKDIR) $(BENCHMARKSET)/$$v ;\
		$(CP) $(PUBLICEMAILS)/$$v*.eml $(BENCHMARKSET)/$$v/ ;\
		$(CP) $(PRIVATEMAILS)/$$v/* $(BENCHMARKSET)/$$v/ ;\
	done

parser-log:
	$(MKDIR) $(PARSERLOGDIR)
	for v in `$(LS) $(PRIVATEMAILS)`; do \
		$(CP) /dev/null $(PARSERLOGDIR)/$$v.log; \
		for r in `find $(PRIVATEMAILS)/$$v -type f -name '*.eml'`; do \
			echo $$r; \
			echo $$r >> $(PARSERLOGDIR)/$$v.log; \
			$(EMAIL_PARSER) -Fddp $$r | grep -E 'reason|diagnosticcode|deliverystatus' >> $(PARSERLOGDIR)/$$v.log; \
			echo >> $(PARSERLOGDIR)/$$v.log; \
		done; \
	done

profile: benchmark-mbox
	$(PERL) -d:NYTProf $(EMAIL_PARSER) -Fjson $(BENCHMARKDIR) > /dev/null
	nytprofhtml

velocity-measurement:
	@ $(MKDIR) $(VELOCITYTEST)
	@ for v in $(BH_CAN_PARSE); do \
		$(CP) $(PUBLICEMAILS)/$$v-*.eml $(VELOCITYTEST)/; \
		$(CP) $(PRIVATEMAILS)/$$v/*.eml $(VELOCITYTEST)/; \
	done
	@ echo -------------------------------------------------------------------
	@ echo `$(LS) $(VELOCITYTEST) | wc -l` emails in $(VELOCITYTEST)
	@ echo -n 'Calculating the velocity of 1000 mails: multiply by '
	@ echo "scale=4; 1000 / `$(LS) $(VELOCITYTEST) | wc -l`" | bc
	@ echo -n 'Calculating the velocity of 2000 mails: multiply by '
	@ echo "scale=4; 2000 / `$(LS) $(VELOCITYTEST) | wc -l`" | bc
	@ echo -------------------------------------------------------------------
	@ echo 'Sisimai(1)' $(BENCHMARKEMP)
	@ n=1; while [ $$n -le 5 ]; do \
		/usr/bin/time $(BENCHMARKEMP) $(VELOCITYTEST) > /dev/null ;\
		sleep 1; \
		n=`expr $$n + 1`; \
	done
	@ echo -------------------------------------------------------------------
	@ echo 'Sisimai(2)' $(EMAIL_PARSER)
	@ n=1; while [ $$n -le 5 ]; do \
		/usr/bin/time $(EMAIL_PARSER) -Fjson $(VELOCITYTEST) > /dev/null ;\
		sleep 1; \
		n=`expr $$n + 1`; \
	done
	@ echo -------------------------------------------------------------------
	@ echo bounceHammer $(BH_LATESTVER)
	@ n=1; while [ $$n -le 5 ]; do \
		/usr/bin/time $(MBOXPARSERV0) -Fjson $(VELOCITYTEST) > /dev/null ;\
		sleep 1; \
		n=`expr $$n + 1`; \
	done

benchmark-mbox: sample
	$(MKDIR) -p $(BENCHMARKDIR)
	$(CP) `find $(BENCHMARKSET) -type f` $(BENCHMARKDIR)/

header-content-list: sample
	/bin/cp /dev/null ./subject-list
	/bin/cp /dev/null ./senders-list
	for v in `ls -1 $(BENCHMARKSET) | grep -v rfc | grep -v arf`; do \
		for w in `find $(BENCHMARKSET)/$$v -type f`; do \
			grep '^Subject:' $$w | head -1 | sed -e "s/^Subject:/[$$v]/g" >> ./subject-list; \
			grep '^From: ' $$w | head -1 | sed -e "s/^From:/[$$v]/g" >> ./senders-list; \
		done; \
	done
	cat subject-list | sort | uniq > tmp/subject-list
	cat senders-list | sort | uniq > tmp/senders-list
	rm ./subject-list ./senders-list

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
	$(RM) -r ./$(BENCHMARKSET)
	$(RM) -r ./$(BENCHMARKDIR)
	$(RM) -f tmp/subject-list tmp/senders-list


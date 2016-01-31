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
MP    := /usr/local/bouncehammer/bin/mailboxparser -Tvvvvvv

BH_LATESTVER := 2.7.13p3
PRECISIONTAB := ANALYTICAL-PRECISION
PARSERLOGDIR := var/log
MTAMODULEDIR := lib/$(NAME)/MTA
MSPMODULEDIR := lib/$(NAME)/MSP
MTARELATIVES := ARF RFC3464 RFC3834
EMAIL_PARSER := sbin/emparser
BENCHMARKDIR := tmp/benchmark
BENCHMARKSET := tmp/sample
SET_OF_EMAIL := set-of-emails
PRIVATEMAILS := $(SET_OF_EMAIL)/private
PUBLICEMAILS := $(SET_OF_EMAIL)/maildir/bsd
DOSFORMATSET := $(SET_OF_EMAIL)/maildir/dos
MACFORMATSET := $(SET_OF_EMAIL)/maildir/mac
INDEX_LENGTH := 24
DESCR_LENGTH := 48

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
		r0=`$(MP) $(BENCHMARKSET)/$$d 2>&1 | grep 'debug0:' \
			| sed 's/^.*debug0:/0 /g' | cut -d' ' -f9,10` ;\
		rn="`echo $$r0 | cut -d/ -f1`" ;\
		rr="`echo $$r0 | cut -d ' ' -f2 | tr -d '()'`" ;\
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
			r0=`$(MP) $(BENCHMARKSET)/$$d 2>&1 | grep 'debug0:' \
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
		n0=`$(EMAIL_PARSER) --count-only $(BENCHMARKSET)/$$d` ;\
		r0=`$(MP) $(BENCHMARKSET)/$$d 2>&1 | grep 'debug0:' \
			| sed 's/^.*debug0:/0 /g' | cut -d' ' -f9,10` ;\
		rn="`echo $$r0 | cut -d/ -f1`" ;\
		rr="`echo $$r0 | cut -d ' ' -f2 | tr -d '()'`" ;\
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


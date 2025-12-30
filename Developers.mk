# p5-sisimai/Developers.mk
#  ____                 _                                       _    
# |  _ \  _____   _____| | ___  _ __   ___ _ __ ___   _ __ ___ | | __
# | | | |/ _ \ \ / / _ \ |/ _ \| '_ \ / _ \ '__/ __| | '_ ` _ \| |/ /
# | |_| |  __/\ V /  __/ | (_) | |_) |  __/ |  \__ \_| | | | | |   < 
# |____/ \___| \_/ \___|_|\___/| .__/ \___|_|  |___(_)_| |_| |_|_|\_\
#                              |_|                                   
# -------------------------------------------------------------------------------------------------
SHELL := /bin/sh
HERE  := $(shell pwd)
NAME  := Sisimai
PERL  ?= perl
MKDIR := mkdir -p
LS    := ls -1
CP    := cp

PARSERLOGDIR := tmp/parser-logs
MAILCLASSDIR := lib/$(NAME)/Lhost
MTARELATIVES := ARF RFC3464 RFC3834
SAMPLEPREFIX := eml
PARSERSCRIPT := $(PERL) sbin/emparser --delivered
RELEASEVERMP := $(PERL) -MSisimai
DEVELOPVERMP := $(PERL) -I./lib -MSisimai

SET_OF_EMAIL := set-of-emails
PRIVATEMAILS := $(SET_OF_EMAIL)/private
PUBLICEMAILS := $(SET_OF_EMAIL)/maildir/bsd
DOSFORMATSET := $(SET_OF_EMAIL)/maildir/dos
MACFORMATSET := $(SET_OF_EMAIL)/maildir/mac

INDEX_LENGTH := 24
DESCR_LENGTH := 50
REASON_TABLE := AuthFailure BadReputation Blocked ContentError Delivered EmailTooLarge Expired \
				Feedback Filtered HasMoved HostUnknown MailboxFull MailerError NetworkError \
				NoRelaying NotAccept NotCompliantRFC OnHold PolicyViolation RequirePTR RateLimited \
				Rejected SecurityError SpamDetected Suspend SyntaxError SystemError SystemFull \
				Undefined UserUnknown Vacation VirusDetected
# -------------------------------------------------------------------------------------------------
.PHONY: clean

private-sample:
	@test -n "$(E)" || ( echo 'Usage: make -f Developers.mk $@ E=/path/to/email' && exit 1 )
	@test -x sbin/emparser
	test -f $(E)
	$(PARSERSCRIPT) $(E)
	@echo
	@while true; do \
		d=`$(PARSERSCRIPT) -Fjson $(E) | jq -M '.[].decodedby' | head -1 \
			| tr '[A-Z]' '[a-z]' | tr -d '-' | sed -e 's/"//g' -e 's/^/lhost-/g'`; \
		if [ -d "$(PRIVATEMAILS)/$$d" ]; then \
			latestfile=`ls -1 $(PRIVATEMAILS)/$$d/*.$(SAMPLEPREFIX) | tail -1`; \
			curr_index=`basename $$latestfile | cut -d'-' -f1`; \
			next_index=`echo $$curr_index + 1 | bc`; \
		else \
			$(MKDIR) $(PRIVATEMAILS)/$$d; \
			next_index=1001; \
		fi; \
		hash_value=`md5 -q $(E) | cut -c 1-8`; \
		if [ -n "`ls -1 $(PRIVATEMAILS)/$$d/ | grep $$hash_value`" ]; then \
			echo 'Already exists:' `ls -1 $(PRIVATEMAILS)/$$d/*$$hash_value.$(SAMPLEPREFIX)`; \
		else \
			printf "[%04d] %s %s\n" $$next_index $$hash_value; \
			mv -v $(E) $(PRIVATEMAILS)/$$d/$${next_index}-$${hash_value}.$(SAMPLEPREFIX); \
		fi; \
		break; \
	done

mta-module-table:
	@ printf "%s\n"  '| Module (Sisimai::Lhost)  | Description                                         |'
	@ printf "%s\n"  '|--------------------------|-----------------------------------------------------|'
	@ for v in `$(LS) ./$(MAILCLASSDIR)/*.pm`; do \
		m="`echo $$v | cut -d/ -f5 | sed 's/.pm//g'`" ;\
		d="`echo $$v | cut -d/ -f5 | tr '[A-Z]' '[a-z]' | sed 's/.pm//g'`" ;\
		l="`echo $$m | wc -c`" ;\
		printf "| %s " $$m ;\
		while [ $$l -le $(INDEX_LENGTH) ]; do \
			printf "%s" ' ' ;\
			l=`expr $$l + 1` ;\
		done ;\
		printf "%s" '|' ;\
		r=`$(PERL) -Ilib -MSisimai::Lhost::$$m -le "print Sisimai::Lhost::$$m->description"` ;\
		x="`echo $$r | wc -c`" ;\
		printf " %s" $$r ;\
		while [ $$x -le $(DESCR_LENGTH) ]; do \
			printf "%s" ' ' ;\
			x=`expr $$x + 1` ;\
		done ;\
		printf " %s\n" ' |' ;\
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

update-other-format-emails:
	for v in `find $(PUBLICEMAILS) -name '*-01.eml' -type f`; do \
		f="`basename $$v`" ;\
		nkf -Lw $$v > $(DOSFORMATSET)/$$f ;\
		nkf -Lm $$v > $(MACFORMATSET)/$$f ;\
	done

parser-log:
	$(MKDIR) $(PARSERLOGDIR)
	test -d $(PRIVATEMAILS)
	for v in `$(LS) $(PRIVATEMAILS)`; do \
		$(CP) /dev/null $(PARSERLOGDIR)/$$v.log; \
		for r in `find $(PRIVATEMAILS)/$$v -type f -name '*.eml'`; do \
			echo $$r; \
			echo $$r >> $(PARSERLOGDIR)/$$v.log; \
			$(PARSERSCRIPT) -Fddp $$r | grep -E 'reason|diagnosticcode|deliverystatus' >> $(PARSERLOGDIR)/$$v.log; \
			echo >> $(PARSERLOGDIR)/$$v.log; \
		done; \
	done

reason-coverage:
	@ for v in `ls -1 $(MAILCLASSDIR) | sort | tr '[A-Z]' '[a-z]' | sed -e 's|.pm||g' -e 's|^|lhost-|g'`; do \
		for e in `echo $(REASON_TABLE) | tr '[A-Z]' '[a-z]'`; do \
			printf "%d," `grep $$e xt/*-$$v.t t/*-$$v.t | wc -l`; \
		done; \
		echo; \
	done
	@ for v in rfc3464 rfc3834 arf mda; do \
		for e in `echo $(REASON_TABLE) | tr '[A-Z]' '[a-z]'`; do \
			printf "%d," `grep $$e xt/*-$$v t/*-$$v.t 2> /dev/null | wc -l`; \
		done; \
		echo; \
	done

clean:
	$(RM) -r cover_db
	$(RM) -r ./build


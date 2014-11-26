# Sisimai/Makefile
#  __  __       _         __ _ _      
# |  \/  | __ _| | _____ / _(_) | ___ 
# | |\/| |/ _` | |/ / _ \ |_| | |/ _ \
# | |  | | (_| |   <  __/  _| | |  __/
# |_|  |_|\__,_|_|\_\___|_| |_|_|\___|
# ---------------------------------------------------------------------------
HERE  = $(shell `pwd`)
TIME  = $(shell date '+%s')
NAME  = Sisimai
MAKE  = /usr/bin/make
PERL  = /usr/local/bin/perl
MKDIR = mkdir -p
PROVE = /usr/local/bin/prove -Ilib --timer
MINIL = /usr/local/bin/minil
LS    = /bin/ls
CP    = /bin/cp
RM    = /bin/rm -f
MV    = /bin/mv
GIT   = /usr/bin/git

EMAIL_SAMPLE = ./tmp/sample
FOR_EMPARSER = ./tmp/data
FOR_MAKETEST = ./eg/maildir-as-a-sample/new
MTAMODULEDIR = ./lib/$(NAME)/MTA
MSPMODULEDIR = ./lib/$(NAME)/MSP
 
.PHONY: clean
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
	$(PERL) -i -ple 's|<.+[@]gmail.com>|<perl.org\@azumakuniyuki.org>|' META.json

dist:
	$(CP) ./README.md /tmp/$(NAME)-README.$(TIME).md
	$(MAKE) clean
	$(MINIL) dist
	$(CP) /tmp/$(NAME)-README.$(TIME).md ./README.md
	$(PERL) -i -ple 's|<.+[@]gmail.com>|<perl.org\@azumakuniyuki.org>|' META.json

push:
	for G in pchan github; do \
		$(GIT) push --tags $$G master; \
	done

sample:
	@for v in `$(LS) -1 $(MTAMODULEDIR)/*.pm`; do \
		MTA=`echo $$v | cut -d/ -f5 | tr '[A-Z]' '[a-z]' | sed 's/.pm//g'` ;\
		$(MKDIR) $(EMAIL_SAMPLE)/$$MTA ;\
		$(CP) $(FOR_MAKETEST)/$$MTA-*.eml $(EMAIL_SAMPLE)/$$MTA/ ;\
		$(CP) $(FOR_EMPARSER)/$$MTA/* $(EMAIL_SAMPLE)/$$MTA/ ;\
	done
	@for c in `$(LS) -1 $(MSPMODULEDIR)`; do \
		for v in `$(LS) -1 $(MSPMODULEDIR)/$$c/*.pm`; do \
			DIR=`echo $$c | tr '[A-Z]' '[a-z]' | tr -d '/'` ;\
			MSP="`echo $$v | cut -d/ -f6 | tr '[A-Z]' '[a-z]' | sed 's/.pm//g'`" ;\
			$(MKDIR) $(EMAIL_SAMPLE)/$$DIR-$$MSP ;\
			$(CP) $(FOR_MAKETEST)/$$DIR-$$MSP-*.eml $(EMAIL_SAMPLE)/$$DIR-$$MSP/ ;\
			$(CP) $(FOR_EMPARSER)/$$DIR-$$MSP/* $(EMAIL_SAMPLE)/$$DIR-$$MSP/ ;\
		done ;\
	done
	@for v in arf rfc3464; do \
		$(MKDIR) $(EMAIL_SAMPLE)/$$v ;\
		$(CP) $(FOR_MAKETEST)/$$v*.eml $(EMAIL_SAMPLE)/$$v/ ;\
		$(CP) $(FOR_EMPARSER)/$$v/* $(EMAIL_SAMPLE)/$$v/ ;\
	done

clean:
	yes | $(MINIL) clean
	$(RM) -r nytprof*
	$(RM) -r cover_db
	$(RM) -r ./build
	$(RM) -r $(EMAIL_SAMPLE)


# p5-sisimai/Benchmarks.mk
#  ____                  _                          _                    _    
# | __ )  ___ _ __   ___| |__  _ __ ___   __ _ _ __| | _____   _ __ ___ | | __
# |  _ \ / _ \ '_ \ / __| '_ \| '_ ` _ \ / _` | '__| |/ / __| | '_ ` _ \| |/ /
# | |_) |  __/ | | | (__| | | | | | | | | (_| | |  |   <\__ \_| | | | | |   < 
# |____/ \___|_| |_|\___|_| |_|_| |_| |_|\__,_|_|  |_|\_\___(_)_| |_| |_|_|\_\
# -------------------------------------------------------------------------------------------------
SHELL := /bin/sh
HERE  := $(shell pwd)
NAME  := Sisimai
PERL  ?= perl
MKDIR := mkdir -p
LS    := ls -1
CP    := cp

EMAILROOTDIR := set-of-emails
PUBLICEMAILS := $(EMAILROOTDIR)/maildir/bsd
DOSFORMATSET := $(EMAILROOTDIR)/maildir/dos
MACFORMATSET := $(EMAILROOTDIR)/maildir/mac
PRIVATEMAILS := $(EMAILROOTDIR)/private
SPEEDTESTDIR := tmp/emails-for-speed-test

COMMANDARGVS := -I./lib -MSisimai
TOBEEXECUTED := 'Sisimai->rise(shift, delivered => 1, vacation => 1)' $(PUBLICMAILS)
HOWMANYMAILS := $(PERL) $(COMMANDARGVS) -le 'print scalar @{ Sisimai->rise(shift, delivered => 1, vacation => 1) }'

# -------------------------------------------------------------------------------------------------
.PHONY: clean

emails-for-speed-test:
	@ rm -fr ./$(SPEEDTESTDIR)
	@ $(MKDIR) $(SPEEDTESTDIR)
	@ $(CP) -Rp $(PUBLICEMAILS)/*.eml $(SPEEDTESTDIR)/
	@ test -d $(PRIVATEMAILS) && find $(PRIVATEMAILS) -type f -name '*.eml' -exec $(CP) -Rp {} $(SPEEDTESTDIR)/ \; || true

speed-test: emails-for-speed-test
	@ echo `$(HOWMANYMAILS) $(SPEEDTESTDIR)` emails in $(SPEEDTESTDIR)
	@ echo -------------------------------------------------------------------
	@ uptime
	@ echo -------------------------------------------------------------------
	@ n=1; while [ "$$n" -le "10" ]; do \
		time $(PERL) $(COMMANDARGVS) -lE $(TOBEEXECUTED) $(SPEEDTESTDIR) > /dev/null; \
		sleep 2; \
		n=`expr $$n + 1`; \
	done

profile:
	@ uptime
	$(PERL) -d:NYTProf $(COMMANDARGVS) -lE $(TOBEEXECUTED) $(SPEEDTESTDIR) > /dev/null
	nytprofhtml

loc:
	@ for v in `find lib -type f -name '*.pm'`; do \
		perl -nle 'last if $$_ =~ /\A1;\z/; next if $$_ =~ /\A[\s\t]*(?:#+.+)?\z/; print 1' $$v; \
	done | awk '{ s += $$1 } END { print s }'

clean:
	find . -type f -name 'nytprof*' -ctime +1 -delete
	rm -f -r $(SPEEDTESTDIR)


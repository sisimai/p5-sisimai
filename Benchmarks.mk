# p5-Sisimai/Benchmarks.mk
#  ____                  _                          _                    _    
# | __ )  ___ _ __   ___| |__  _ __ ___   __ _ _ __| | _____   _ __ ___ | | __
# |  _ \ / _ \ '_ \ / __| '_ \| '_ ` _ \ / _` | '__| |/ / __| | '_ ` _ \| |/ /
# | |_) |  __/ | | | (__| | | | | | | | | (_| | |  |   <\__ \_| | | | | |   < 
# |____/ \___|_| |_|\___|_| |_|_| |_| |_|\__,_|_|  |_|\_\___(_)_| |_| |_|_|\_\
# -----------------------------------------------------------------------------
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
TOBEEXECUTED := 'Sisimai->make(shift, delivered => 1)' $(PUBLICMAILS)
HOWMANYMAILS := $(PERL) $(COMMANDARGVS) -le 'print scalar @{ Sisimai->make(shift, delivered => 1) }' 

# -----------------------------------------------------------------------------
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
		x=`wc -l $$v | awk '{ print $$1 }'`; \
		y=`cat -n $$v | grep '\t1;' | tail -n 1 | awk '{ print $$1 }'`; \
		z=`grep -E '^\s*#|^$$' $$v | wc -l | awk '{ print $$1 }'`; \
		echo "$$x - ( $$x - $$y ) - $$z" | bc ;\
	done | awk '{ s += $$1 } END { print s }'

clean:
	find . -type f -name 'nytprof*' -ctime +1 -delete
	rm -r $(SPEEDTESTDIR)


# Sisimai.mk
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
CURL  = /usr/bin/curl -X POST
PROVE = /usr/local/bin/prove -Ilib --timer
MINIL = /usr/local/bin/minil
CP    = /bin/cp
RM    = /bin/rm -f
MV    = /bin/mv
GIT   = /usr/bin/git
 
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
	$(MAKE) -f $(NAME).mk clean
	$(MINIL) test
	$(CP) /tmp/$(NAME)-README.$(TIME).md ./README.md
	$(PERL) -i -ple 's|<.+[@]gmail.com>|<perl.org\@azumakuniyuki.org>|' META.json

dist:
	$(CP) ./README.md /tmp/$(NAME)-README.$(TIME).md
	$(MAKE) -f $(NAME).mk clean
	$(MINIL) dist
	$(CP) /tmp/$(NAME)-README.$(TIME).md ./README.md
	$(PERL) -i -ple 's|<.+[@]gmail.com>|<perl.org\@azumakuniyuki.org>|' META.json

push:
	for G in pchan github; do \
		$(GIT) push --tags $$G master; \
	done

clean:
	yes | $(MINIL) clean
	$(RM) -r nytprof*
	$(RM) -r cover_db
	$(RM) -r ./build


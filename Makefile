# p5-Sisimai/Makefile
#  __  __       _         __ _ _      
# |  \/  | __ _| | _____ / _(_) | ___ 
# | |\/| |/ _` | |/ / _ \ |_| | |/ _ \
# | |  | | (_| |   <  __/  _| | |  __/
# |_|  |_|\__,_|_|\_\___|_| |_|_|\___|
# -----------------------------------------------------------------------------
SHELL := /bin/sh
TIME  := $(shell date '+%s')
NAME  := Sisimai
PERL  := perl
CPANM := http://xrl.us/cpanm
WGET  := wget -c
CURL  := curl -LOk
CHMOD := chmod
PROVE := prove -Ilib --timer
MINIL := minil
CP    := cp
RM    := rm -f
GIT   := /usr/bin/git
.DEFAULT_GOAL = git-status

# -----------------------------------------------------------------------------
.PHONY: clean
cpanm:
	$(WGET) $(CPANM) || $(CURL) $(CPANM)
	test -f ./$@ && $(CHMOD) a+x ./$@

install-from-cpan: cpanm
	sudo ./cpanm $(NAME)

install-from-local: cpanm
	sudo ./cpanm .

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

clean:
	$(MAKE) -f Development.mk clean


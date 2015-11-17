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

.DEFAULT_GOAL = git-status
REPOS_TARGETS = git-status git-push git-commit-amend git-tag-list git-diff \
				git-reset-soft git-rm-cached git-branch
STATS_TARGETS = profile private-sample update-analytical-precision-table loc

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

$(REPOS_TARGETS):
	$(MAKE) -f Repository.mk $@

$(STATS_TARGETS):
	$(MAKE) -f Statistics.mk $@

diff push branch:
	@$(MAKE) git-$@
fix-commit-message: git-commit-amend
cancel-the-latest-commit: git-reset-soft
remove-added-file: git-rm-cached

clean:
	$(MAKE) -f Repository.mk clean
	$(MAKE) -f Statistics.mk clean


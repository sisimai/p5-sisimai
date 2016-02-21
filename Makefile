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
DEVEL_TARGETS = profile private-sample update-analytical-precision-table loc

# -----------------------------------------------------------------------------
.PHONY: clean
cpanm:
	$(WGET) $(CPANM) || $(CURL) $(CPANM)
	test -f ./$@ && $(CHMOD) a+x ./$@

install-from-cpan:
	curl -L https://cpanmin.us | perl - -M https://cpan.metacpan.org -n $(NAME)

install-from-local: cpanm
	./cpanm .

test: user-test author-test
user-test:
	$(PROVE) t/

author-test:
	$(PROVE) xt/

cover-test:
	cover -test

backup-readme:
	$(CP) ./README.md /tmp/$(NAME)-README.$(TIME).md

restore-readme:
	$(CP) /tmp/$(NAME)-README.$(TIME).md ./README.md

check-version:
	grep cpan-`$(PERL) -Ilib -M$(NAME) -e 'print Sisimai->version' | tr '.' '-'` README.md

release-test:
	$(MAKE) backup-readme
	$(MAKE) clean
	$(MINIL) test
	$(MAKE) restore-readme
	$(MAKE) check-version

dist:
	$(MAKE) backup-readme
	$(MAKE) clean
	$(MINIL) dist
	$(MAKE) restore-readme
	$(MAKE) check-version

$(REPOS_TARGETS):
	$(MAKE) -f Repository.mk $@

$(DEVEL_TARGETS):
	$(MAKE) -f Developers.mk $@

diff push branch:
	@$(MAKE) git-$@
fix-commit-message: git-commit-amend
cancel-the-latest-commit: git-reset-soft
remove-added-file: git-rm-cached

clean:
	$(MAKE) -f Repository.mk clean
	$(MAKE) -f Developers.mk clean


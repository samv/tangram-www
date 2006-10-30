
check:
	rsync --exclude .svn --exclude .git --exclude Makefile --exclude .publish* -ruav `cat .publish_target`/. .
	git-status

publish:
	(cd docs; make all)
	if git-status | grep '^#'; then /bin/false; else :; fi
	rsync --exclude .git\* --exclude Makefile --exclude .publish\* -ruav --delete . `cat .publish_target`
	cg-push -r HEAD



check:
	rsync --exclude .svn --exclude .git --exclude Makefile --exclude .publish* -ruav `cat .publish_target`/. .
	git-status

publish:
	(cd docs; make all)
	if git diff-files --name-status | grep '.'; then /bin/false; else :; fi
	rsync -O --exclude .git\* --exclude Makefile --exclude .publish\* -ruv --delete . `cat .publish_target`
	git push origin HEAD


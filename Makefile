
check:
	rsync --exclude .svn --exclude .git --exclude Makefile --exclude .publish* -ruav `cat .publish_target`/. .
	git-status

publish:
	rsync --exclude .git\* --exclude Makefile --exclude .publish\* -ruav --delete . `cat .publish_target`



check:
	rsync -ruav `cat .publish_target`/. .
	git-status

publish:
	rsync -ruav --delete . `cat .publish_target`





find . -name \*.\*.tt -print | while read fn
do
	dest=`expr "$fn" : '\(.*\).tt'`
	echo "Processing $fn => $dest"
	if tpage $fn > $dest
	then
		:
	else
		bad="$bad $fn"
	fi
done

if [ -n "$bad" ]
then
	echo "FAILED: $bad"
	exit 1
fi

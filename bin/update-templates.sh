


find . -name \*.\*.tt -print | while read fn
do
	dest=`expr "$fn" : '\(.*\).tt'`
	if [ $dest -nt $fn ]
	then
		continue
	fi
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

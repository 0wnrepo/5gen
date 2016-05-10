while [ 1 ]
do
	date >> mem.log && free -g >> mem.log
	sleep 5
done

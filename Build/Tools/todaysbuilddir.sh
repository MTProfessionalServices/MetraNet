BUILDSDEPLOY=\\\\$COMPUTERNAME\\Archive\\_Dev
##
## Get the date string
##
dom=`date +%d`
month=`date +%b`
year=`date +%Y`
datestring="$dom$month$year"

TODAYSBUILDDIR=$BUILDSDEPLOY/$datestring
echo $TODAYSBUILDDIR

dom=`date +%2d`
month=`date +%2m`
year=`date +%Y`
datestring="$month$dom$year"
branchstring=$1
labelname=""

##
## GET StarTeam Branch off of MetraTech\Development or NOT
##
if [ "$branchstring" != "" ]; then
     labelname="$datestring$branchstring"
else
     labelname=$datestring
     branchstring="Development"
fi

echo "Accessing Branch: MetraTech/Development$branchstring"
echo Labeling build $datestring
"//c/program files/StarTeam 4.0/stcmd.exe" label -p "buildmeister:password@OBLIVION/MetraTech/$branchstring" /nl "$labelname" /b /x

RETVAL=$?
if [ "$RETVAL" != "0" ]; then
    echo "Label status: Label FAILED!"
    exit 1
else
    echo "Label status: Label SUCCEEDED."
fi


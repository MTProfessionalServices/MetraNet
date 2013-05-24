dom=`date +%2d`
month=`date +%2m`
year=`date +%Y`
datestring="$month$dom$year"
branchstring=$1
labelname=""
btips="1"

##
## GET StarTeam Branch off of MetraTech\Development or NOT
##
if [ "$branchstring" != "" ]; then
     labelname="$datestring$branchstring"
     btips="0"
else
     labelname=$datestring
     branchstring="Development"
     btips="1"
fi


echo "Check Out status: Getting Source Code MetraTech/Development/$branchstring"

if [ "$btips" = "1" ]; then
    echo "Check Out status: Getting Development TIPS.  Missing or Out of Date files only."
    "//c/program files/StarTeam 4.0/stcmd.exe" co -p "buildmeister:password@OBLIVION/MetraTech/$branchstring"  -f NCO -is -rp "D:\Builds\S2\development" /x
    RETVAL=$?
else
    echo "Check Out status: Getting Development TIPS.  Force Check Out All"
    "//c/program files/StarTeam 4.0/stcmd.exe" co -p "buildmeister:password@OBLIVION/MetraTech/$branchstring/" -o -is -rp "D:\Builds\S2\development" -vl "$labelname" /x
    RETVAL=$?
fi


if [ "$RETVAL" != "0" ]; then
    echo "Check Out status: GET FAILED!"
    exit 1
else
    echo "Check Out status: GET SUCCEEDED."
fi


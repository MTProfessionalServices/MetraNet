mkdir $MTOUTDIR\\install
mkdir $MTOUTDIR\\install\\debug
mkdir $MTOUTDIR\\install\\release

EDDIR=$INSTALLROOTDIR\\Staging
if ["$TRUECOVERAGE" = "1"]; then  
  EDDIR=$INSTALLROOTDIR\\StagingTC
fi

mkdir $EDDIR$
mkdir $EDDIR$\debug
mkdir $EDDIR$\release

INSTALLTYPE=DEBUG
if [ "$DEBUG" = "0" ]; then
	INSTALLTYPE=RELEASE
fi

MT_TEMP=$1
if [ "$MT_TEMP" = "CLEAN" ]; then
	echo rename $MTOUTDIR\\install\\$INSTALLTYPE tempclean
	cd $MTOUTDIR\\install
	cmd /c rm -rf $MTOUTDIR\\install\\tempclean
	cmd /c ren $MTOUTDIR\\install\\$INSTALLTYPE tempclean
	RETVAL=$?
	if [ "$RETVAL" != "0" ]; then
		echo "*** ERROR: $MTOUTDIR\\install\\$INSTALLTYPE is in use, cannot CLEAN this folder."
		exit 1
	fi 
	cd $ROOTDIR\\Build\\Tools
	echo Deleting previous $INSTALLTYPE folder
	cmd /c rm -rf $MTOUTDIR\\install\\tempclean
	echo Previous $INSTALLTYPE folder deleted
fi



if [ "$MT_TEMP" = "CLEAN" ]; then
	echo rename $EDDIR\\$INSTALLTYPE tempclean
	cd $MTOUTDIR\\install
	cmd /c rm -rf $EDDIR\\tempclean
	cmd /c ren $EDDIR\\$INSTALLTYPE tempclean
	RETVAL=$?
	if [ "$RETVAL" != "0" ]; then
		echo "*** ERROR: $EDDIR\\$INSTALLTYPE is in use, cannot CLEAN this folder."
		exit 1
	fi 
	cd $INSTALLROOTDIR\\Tools
	echo Deleting previous $INSTALLTYPE folder
	cmd /c rm -rf $EDDIR\\tempclean
	echo Previous $INSTALLTYPE folder deleted
fi



echo Working on $INSTALLTYPE install repackaging



echo ======================================
echo Gathering v2.0 Main Install Files...
echo ======================================
cd $INSTALLROOTDIR/Tools
nmake -f staging.mak
RETVAL=$?
if [ "$RETVAL" != "0" ]; then
    echo "repack status: staging FAILED!"
    exit 1
else
    echo "repack status: staging SUCCEEDED"
fi


# REMOVED 06182001 -Charlie
#
#echo ======================================
#echo Gathering Main Install Files...
#echo ======================================
#cd $ROOTDIR/Build
#nmake -f makeinstalltree.mak
#RETVAL=$?
#if [ "$RETVAL" != "0" ]; then
#    echo "repack status: makeinstalltree FAILED!"
#    exit 1
#else
#    echo "repack status: makeinstalltree SUCCEEDED"
#fi
#



echo ======================================
echo Gathering NT SDK Files...
echo ======================================
cd $ROOTDIR/Build
nmake -f makesdkinstalltree.mak
RETVAL=$?
if [ "$RETVAL" != "0" ]; then
    echo "repack status: makesdkinstalltree FAILED!"
    exit 1
else
    echo "repack status: makesdkinstalltree SUCCEEDED"
fi


echo ======================================
echo Building install kit...
echo ======================================
cd $ROOTDIR/Build/Tools
cmd /c installkit.cmd
RETVAL=$?
if [ "$RETVAL" != "0" ]; then
    echo "repack status: installkit FAILED!"
    exit 1
else
    echo "repack status: installkit SUCCEEDED"
fi



TODAYSBUILDDIR=`bash todaysbuilddir.sh`
INSTALLARCHIVE=$TODAYSBUILDDIR/bld/install/$INSTALLTYPE
NEWINSTALL=$MTOUTDIR/install/$INSTALLTYPE



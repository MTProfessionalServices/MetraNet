@ECHO OFF
@ECHO -------------------------------
@ECHO Setup machine
@ECHO -------------------------------

REM On a new dev machine run:
REM s:
REM cd %ROOTDIR%\install\scripts
REM 
REM @ECHO --- Setup MetraTech Registry
REM call Registry.vbs
REM 
REM @ECHO --- Install Virtual Directories
REM call IIS.vbs

net start w3svc

@ECHO --- Refresh web services
s:
call %ROOTDIR%\Build\Tools\refreshws.bat

@ECHO --- Clear smoke test data
t:
del "t:\Temp\SmokeTest.PropertyBag.txt"

@ECHO --- Create queues
pipeline create-queue
 
s:
cd %ROOTDIR%\install\scripts

@ECHO --- Install COMPlus
call COMPlus.vbs

@ECHO --- Crypto setup
call Crypto.vbs

@ECHO --- Create database
rem call Database.vbs
call Database.vbs /userid:kevinb /dbserver:SUN-V210-1 /dbtype:oracle /datafile:"/space/oradata/netmeter/kevinb.dbf" /stgdatafile:"/space/oradata/netmeter/kevinb_GUINNESS2.dbf"

@ECHO -------------------------------
@ECHO DONE!
@ECHO -------------------------------

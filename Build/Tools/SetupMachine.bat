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
REM call IIS.vbs or IIS7ConfigMgr.exe if on IIS7

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
%WINDIR%\SysWOW64\CScript.exe COMPlus.vbs

@ECHO --- Crypto setup
rem call Crypto.vbs
o:\debug\bin\cryptosetup.exe -createkeys
o:\debug\bin\cryptosetup.exe -encryptconfig

@ECHO --- Create database
%WINDIR%\SysWOW64\CScript.exe Database.vbs
rem call Database.vbs /userid:kevinb /dbserver:QA-RHAS642 /dbtype:oracle /datafile:"/space/oradata/netmeter/kevinb.dbf" /stgdatafile:"/space/oradata/netmeter/kevinb_magichat9.dbf
rem - good - call Database.vbs /userid:kevinb /dbserver:QA-RHAS642 /dbtype:oracle

@ECHO -------------------------------
@ECHO DONE!
@ECHO -------------------------------

@echo off
setlocal

Rem Clear logfile
set MY_LOGFILE=%TEMP%\%~n0.log
@echo %DATE% %TIME% Executing %0 ... > "%MY_LOGFILE%"

:GET_ORACLE_HOME_KEY

Rem Get the ORACLE_HOME_KEY for Oracle Services for MTS
set ORACLE_HOME_KEY=
set REG_CMD=reg query "HKLM\SOFTWARE\ORACLE\OracleMTSRecoveryService\Setup\Current Version" /v "Home"
for /F "usebackq tokens=2,3*" %%i IN (`%REG_CMD%`) DO if [%%i]==[REG_SZ] set ORACLE_HOME_KEY=%%j
@echo ORACLE_HOME_KEY=%ORACLE_HOME_KEY% >> "%MY_LOGFILE%"
if ["%ORACLE_HOME_KEY%"]==[""] goto BAD_ORACLE_HOME_KEY

:GET_ORACLE_HOME

Rem Get the ORACLE_HOME for Oracle Services for MTS
set ORACLE_HOME=
set REG_CMD=reg query "HKLM\%ORACLE_HOME_KEY%" /v "ORACLE_HOME"
for /F "usebackq tokens=2,3*" %%i IN (`%REG_CMD%`) DO if [%%i]==[REG_SZ] set ORACLE_HOME=%%j
@echo ORACLE_HOME=%ORACLE_HOME% >> "%MY_LOGFILE%"
if ["%ORACLE_HOME%"]==[""] goto BAD_ORACLE_HOME

Rem Make ORACLE_HOME the current directory
pushd "%ORACLE_HOME%"
if errorlevel 1 goto BAD_ORACLE_HOME

:GET_ODPREG

Rem Build expected paths to ODPREG binaries
SET ODPREG_1X=%ORACLE_HOME%\odp.net\bin\1.x\ODPReg.exe
SET ODPREG_2X=%ORACLE_HOME%\odp.net\bin\2.x\ODPReg.exe

if exist "%ODPREG_1X%" goto ODP_DEL_GAC_CHECK
if exist "%ODPREG_2X%" goto ODP_DEL_GAC_CHECK
@echo *** No ODP.NET providers were found! >> "%MY_LOGFILE%"
goto CLEANUP

:ODP_DEL_GAC_CHECK
Rem Check for existings providers, and remove from GAC

:ODP_1X_DEL_GAC_CHECK
if exist "%ODPREG_1X%" goto ODP_1X_DEL_GAC
goto ODP_2X_DEL_GAC_CHECK

:ODP_1X_DEL_GAC
@echo Removing ODP.NET 1.x Assemblies from the GAC >> "%MY_LOGFILE%"
"%ODPREG_1X%" /u Oracle.DataAccess
"%ODPREG_1X%" /u Policy.1.102.Oracle.DataAccess
"%ODPREG_1X%" /u Policy.10.1.Oracle.DataAccess
"%ODPREG_1X%" /u Policy.10.2.Oracle.DataAccess
"%ODPREG_1X%" /u Policy.9.2.Oracle.DataAccess

:ODP_2X_DEL_GAC_CHECK
if exist "%ODPREG_2X%" goto ODP_2X_DEL_GAC
goto ODP_ADD_GAC_CHECK

:ODP_2X_DEL_GAC
@echo Removing ODP.NET 2.x Assemblies from the GAC >> "%MY_LOGFILE%"
"%ODPREG_2X%" /u Oracle.DataAccess
"%ODPREG_2X%" /u Policy.2.102.Oracle.DataAccess

:ODP_ADD_GAC_CHECK
Rem Check for existings providers, and add to GAC

:ODP_1X_ADD_GAC_CHECK
if exist "%ODPREG_1X%" goto ODP_1X_ADD_GAC
goto ODP_2X_ADD_GAC_CHECK

:ODP_1X_ADD_GAC
@echo Adding ODP.NET 1.x Assemblies to the GAC >> "%MY_LOGFILE%"
cd /d "%ORACLE_HOME%\odp.net\bin\1.x"
"%ODPREG_1X%" Oracle.DataAccess.dll
cd /d "%ORACLE_HOME%\odp.net\PublisherPolicy\1.x"
"%ODPREG_1X%" Policy.1.102.Oracle.DataAccess.dll
"%ODPREG_1X%" Policy.10.1.Oracle.DataAccess.dll
"%ODPREG_1X%" Policy.10.2.Oracle.DataAccess.dll
"%ODPREG_1X%" Policy.9.2.Oracle.DataAccess.dll

:ODP_2X_ADD_GAC_CHECK
if exist "%ODPREG_2X%" goto ODP_2X_ADD_GAC
goto CLEANUP

:ODP_2X_ADD_GAC
@echo Adding ODP.NET 2.x Assemblies to the GAC >> "%MY_LOGFILE%"
cd /d "%ORACLE_HOME%\odp.net\bin\2.x"
"%ODPREG_2X%" Oracle.DataAccess.dll
cd /d "%ORACLE_HOME%\odp.net\PublisherPolicy\2.x"
"%ODPREG_2X%" Policy.2.102.Oracle.DataAccess.dll

:CLEANUP
popd
goto DONE

:BAD_ORACLE_HOME_KEY
@echo *** Registry key for Oracle Services for MTS was not found! >> "%MY_LOGFILE%"
goto DONE

:BAD_ORACLE_HOME
@echo *** Error determining ORACLE_HOME! >> "%MY_LOGFILE%"
goto DONE

:DONE
@type "%MY_LOGFILE%"

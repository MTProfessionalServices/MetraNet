@ECHO OFF
CLS

REM Start AutoSDK test
REM create hierarchy 
REM move Account in the Hierarchy
REM change Payment redirection
REM change Account Status from Active to Suspended
REM change Account Status from Active to Closed

ECHO ************************
ECHO Start AutoSDK test
ECHO Create Corporate Account
ECHO ************************

autosdk.exe localhost corporateAccount.xml

ECHO ************************
ECHO Create first Folder under Corporate Account
ECHO ************************
autosdk.exe localhost createFolder1.xml

ECHO ************************
ECHO Create second Folder under Corporate Account
ECHO ************************
autosdk.exe localhost createFolder2.xml

ECHO ************************
ECHO Create two accounts under first Folder 
ECHO ************************
autosdk.exe localhost createAcc1underFolder1.xml
autosdk.exe localhost createAcc2underFolder1.xml

ECHO ************************
ECHO Create two accounts under second Folder
ECHO ************************
autosdk.exe localhost createAcc1underFolder2.xml
autosdk.exe localhost createAcc2underFolder2.xml

ECHO ************************
ECHO Move account under different folder
ECHO ************************
autosdk.exe localhost moveAcc1underFolder2.xml

ECHO ************************
ECHO Change account status from Active to Suspended
ECHO ************************
autosdk.exe localhost changeStatusToSuspended.xml

ECHO ************************
ECHO Change account status from Active to Closed
ECHO ************************
autosdk.exe localhost changeStatusToClosed.xml

ECHO ************************
ECHO Change account status from Suspended to Active
ECHO ************************
autosdk.exe localhost changeStatusToActive.xml

ECHO ************************
ECHO Change account Payment Redirection
ECHO ************************
autosdk.exe localhost changePaymentRedirection.xml

ECHO ************************
ECHO Finished AutoSDK Test

ECHO ************************
REM if errorlevel %level% goto testerror
goto testok

:testerror
ECHO FAILURE
goto end

:testok
ECHO SUCCESS

:end





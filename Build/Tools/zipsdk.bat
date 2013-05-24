@echo OFF
setlocal
rem set SDKFOLDER01=%1
rem set ZIPPED01=%2

set INSTTYPE01=DEBUG
IF %DEBUG%==0 set INSTTYPE01=RELEASE

set SDKFOLDER01=%MTOUTDIR%\install\%INSTTYPE01%\_CD\MetraTechPlatformSDK
set    ZIPPED01=%MTOUTDIR%\install\%INSTTYPE01%\_CD\MetraTechPlatformSDK.zip
set   WORKZIP01=%MTOUTDIR%\install\%INSTTYPE01%\_CD\temp
set   WORKZIP02=%WORKZIP01%\MetraTechPlatformSDK
set OUTDIRBIN01=%MTOUTDIR%\%INSTTYPE01%\bin


echo.
echo Compressing folder:  %SDKFOLDER01%
echo to Zip file:         %ZIPPED01%
echo.

rmdir %WORKZIP02% /q /s
md    %WORKZIP02%
copy  %SDKFOLDER01% %WORKZIP02%

pushd   %SDKFOLDER01%
del /Q  %ZIPPED01% > nul 2>&1
%OUTDIRBIN01%\zip -rq %ZIPPED01% .
popd

rmdir %WORKZIP02% /q /s






set SDKFOLDER01=%MTOUTDIR%\java
set    ZIPPED01=%MTOUTDIR%\install\%INSTTYPE01%\_CD\MetraTechJAVASDK.zip
set   WORKZIP01=%MTOUTDIR%\install\%INSTTYPE01%\_CD\temp
set   WORKZIP02=%WORKZIP01%\java
set OUTDIRBIN01=%MTOUTDIR%\%INSTTYPE01%\bin

echo.
echo Compressing folder:  %SDKFOLDER01%
echo to Zip file:         %ZIPPED01%
echo.


rmdir %WORKZIP02% /q /s
md    %WORKZIP02%
echo %SDKFOLDER01%\*.* %WORKZIP02% /s
xcopy  %SDKFOLDER01%\*.* %WORKZIP02% /s

pushd   %SDKFOLDER01%
del /Q  %ZIPPED01% > nul 2>&1
%OUTDIRBIN01%\zip -rq %ZIPPED01% .
popd

rmdir %WORKZIP02% /q /s




goto theend


:theend
rmdir %WORKZIP01% /q /s
endlocal

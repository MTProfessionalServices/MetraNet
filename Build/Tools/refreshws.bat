@echo off
pushd \
echo Copying assemblies for Batch web service...
%ROOTDIR%
cd %ROOTDIR%\MetraTech\Pipeline\Batch\Listener\bin\
call refresh.bat

echo Copying assemblies for ReRun web service...
cd %ROOTDIR%\MetraTech\Pipeline\ReRun\Listener\bin\
call refresh.bat

echo Copying assemblies for Hierarchy web service...
cd %ROOTDIR%\MetraTech\Accounts\Hierarchy\WebService\bin\
call refresh.bat

echo Copying assemblies for Suggest ASP.NET page...
cd %ROOTDIR%\MetraTech\UI\Suggest\bin\
call refresh.bat

echo Copying assemblies for ImageHandler ASP.NET page...
cd %ROOTDIR%\MetraTech\UI\ImageHandler\bin\
call refresh.bat

echo Copying assemblies for MetraNet ASP.NET pages...
cd %ROOTDIR%\MetraTech\UI\MetraNet\bin\
call refresh.bat

%RMPDIR%
echo Copying assemblies for MetraView ASP.NET pages...
cd %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin\
call refresh.bat

popd
echo Done!

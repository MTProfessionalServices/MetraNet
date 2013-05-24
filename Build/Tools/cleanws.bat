@echo off

echo Removing assemblies from Batch web service...
del %ROOTDIR%\MetraTech\Pipeline\Batch\Listener\bin\*.dll

echo Removing assemblies from ReRun web service...
del %ROOTDIR%\MetraTech\Pipeline\ReRun\Listener\bin\*.dll

echo Removing assemblies from Hierarchy web service...
del %ROOTDIR%\MetraTech\Accounts\Hierarchy\WebService\bin\*.dll
del %ROOTDIR%\MetraTech\Accounts\Hierarchy\WebService\bin\*.pdb

echo Removing assemblies from TransportImage ASP.NET page...
del r:\ui\mam\default\dialog\images\TransportImage\bin\*.dll

echo Removing assemblies from Suggest web service...
del %ROOTDIR%\MetraTech\UI\Suggest\bin\*.dll

echo Removing assemblies from ImageHandler web service...
del %ROOTDIR%\MetraTech\UI\ImageHandler\bin\*.dll

echo Removing assemblies from MetraNet web service...
del %ROOTDIR%\MetraTech\UI\MetraNet\bin\*.dll

echo Removing assemblies from Hierarchy Control...
del r:\UI\MAM\default\dialog\*.dll
del r:\UI\MAM\default\dialog\*.pdb

echo Done!

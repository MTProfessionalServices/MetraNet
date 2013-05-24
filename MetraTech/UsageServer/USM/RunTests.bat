@echo off
set currentDir=%CD%

S:
cd S:\Thirdparty\NUnit*\bin
@echo on
nunit-console-x86.exe %MTRMPBIN%\MetraTech.UsageServer.Test.dll /fixture:MetraTech.UsageServer.Test.SqlNativePartitionTests
::nunit-console-x86.exe %MTRMPBIN%\MetraTech.UsageServer.Test.dll /fixture:MetraTech.UsageServer.Test.PartitionTypesTests
cd %currentDir%
pause

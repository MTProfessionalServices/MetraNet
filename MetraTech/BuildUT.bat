@echo off

msbuild.exe MSBuild\UnitTest.proj /t:all /p:config=%VERSION% /p:platform=x86 /flp:ShowTimestamp;Verbosity=DIAG;Summary;LogFile=%temp%\msbuild_FunctionalTests_MetraNet_UT.log
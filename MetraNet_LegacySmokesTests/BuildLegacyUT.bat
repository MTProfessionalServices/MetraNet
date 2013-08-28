@echo off

msbuild.exe MSBuild\LegacySmokeTest.proj /t:all /p:config=%VERSION% /p:platform=x86 /fl /flp:ShowTimestamp;Verbosity=DIAG;Summary;LogFile=%temp%\msbuild_FunctionalTests_MetraNet_LegacySmokesTests.log /clp:Verbosity=M;Summary
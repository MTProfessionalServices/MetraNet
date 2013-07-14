@echo off

set buildTarget=Incremental

if not '%1' == '' (set buildTarget=%1)

Echo Building %buildTarget%
Echo.

msbuild %ROOTDIR%\Build\MSBuild\MetraNetBuild.proj /t:%buildTarget% /p:config=%VERSION%;MyTargets=Build /fl /flp:ShowTimestamp;Verbosity=N;Summary;LogFile=%temp%\msbuild.log /clp:Verbosity=M;Summary
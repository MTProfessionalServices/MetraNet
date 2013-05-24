@echo off

set buildTarget=BuildSources

if '%1' == '' (goto Error)

Echo Building %buildTarget%
Echo.

msbuild %ROOTDIR%\Build\MSBuild\MetraNetBuild.proj /t:%buildTarget% /p:config=%VERSION%;MyTargets=Build;ProjectPath=%1 /fl /flp:ShowTimestamp;Verbosity=N;Summary;LogFile=%temp%\msbuild.log /clp:Verbosity=M;Summary

Goto Exit

:Error
Echo Missing project specification...Please specify path to project directory

:Exit
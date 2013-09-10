@echo off

set buildTarget=Incremental

if not '%1' == '' (set buildTarget=%1)

Echo Building %buildTarget%
Echo.

rem Set source path to real source path beacause of submodule "ExpressionEngine_Internal" with source code. And some projects have references to it's source.
setx ROOTDIR C:\dev\MetraNet\RMP\Extensions\Legacy_Internal\Source /M 
set ROOTDIR=C:\dev\MetraNet\RMP\Extensions\Legacy_Internal\Source



msbuild %ROOTDIR%\Build\MSBuild\MetraNetBuild.proj /t:%buildTarget% /p:config=%VERSION%;MyTargets=Build /fl /flp:ShowTimestamp;Verbosity=N;Summary;LogFile=%temp%\msbuild.log /clp:Verbosity=M;Summary
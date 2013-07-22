@echo off

set buildTarget=All

if not '%1' == '' (set buildTarget=%1)

Echo Building %buildTarget%
Echo.
 
rem Set source path to real source path beacause of submodule "ExpressionEngine_Internal" with source code. And some projects have references to it's source.
setx ROOTDIR C:\dev\MetraNet\RMP\Extensions\Legacy_Internal\Source /M 
set ROOTDIR=C:\dev\MetraNet\RMP\Extensions\Legacy_Internal\Source
 
msbuild %ROOTDIR%\Build\MSBuild\MetraNetBuild.proj /m /ds /t:%buildTarget% /p:config=%VERSION%;MyTargets=Build /fl /flp:ShowTimestamp;Verbosity=DIAG;Summary;LogFile=%temp%\msbuild.log /clp:Verbosity=M;Summary
msbuild %RMPDIR%\Extensions\MVMCore_Internal\SourceCode\Mvm\MVM.sln /m /ds /p:config=%VERSION%;MyTargets=Build /fl /flp:ShowTimestamp;Verbosity=DIAG;Summary;LogFile=%temp%\MetraNetMVMBuild.log /clp:Verbosity=M;Summary
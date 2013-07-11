@echo off

set buildTarget=Incremental

if not '%1' == '' (set buildTarget=%1)

Echo Building %buildTarget%
Echo.

msbuild %ROOTDIR%\Build\MSBuild\MetraNetBuild.proj /t:%buildTarget% /p:config=%VERSION%;MyTargets=Build /fl /flp:ShowTimestamp;Verbosity=N;Summary;LogFile=%temp%\msbuild.log /clp:Verbosity=M;Summary
msbuild %(MAINWORKDIR)\RMP\Extensions\MVMCore_Internal\SourceCode\Mvm\MVM.sln /m /ds /t:%buildTarget% /p:config=%VERSION%;MyTargets=Build /fl /flp:ShowTimestamp;Verbosity=DIAG;Summary;LogFile=%temp%\MetraNetMVMBuild.log /clp:Verbosity=M;Summary
rem = These variables are referenced in this script and need to be set using the set command =
rem = Change these based on your environment =
set TEAM_BRANCH=Team4-710
set MTVERSION=7.1.0
set DEVDIR=C:\dev\MetraNet

set PF=C:\Program Files (x86)
set PF64=C:\Program Files
set WINSDK=%PF%\Microsoft SDKs\Windows\v7.0A
set TEMP=C:\temp
set VS10=%PF%\Microsoft Visual Studio 10.0
set VS9=%PF%\Microsoft Visual Studio 9.0
set NetFrameWork=C:\Windows\Microsoft.NET\Framework
set PATH=C:\oracle\app\Administrator\product\11.2.0\dbhome_2\bin;%%PF%%\git\bin;C:\Scripts;C:\Windows\SysWOW64;C:\WINDOWS\system32;%%NetFrameWork%%\v4.0.30319;%%PF%%\CollabNet\Subversion Client;%%PF%%\GnuWin32\bin;c:\tools;c:\tools\notepad2;s:\build\tools;o:\debug\bin;c:\Perl\bin;c:\cygwin\bin;%%PF%%\Internet Explorer;%%PF%%\TestHarness5.1;C:\WINDOWS\System32\Wbem;%%VS10%%\common7\IDE;%%VS10%%\common7\tools\bin;%%VS10%%\vc\bin;%%VS10%%\common7\tools;%%VS10%%\sdk\v3.5\bin;%%NetFrameWork%%\v3.5;%%NetFrameWork%%\v2.0.50727;%%NetFrameWork%%\v4.0.30319;%%PF%%\Microsoft Visual Studio\VB98;C:\WINDOWS\System32\inetsrv;%%PF%%\Microsoft SQL Server\80\Tools\BINN;%%WINSDK%%\Bin;%%PF64%%\TortoiseSVN\bin;%%PF%%\Notepad++;%%PF64%%\TortoiseGit\bin

rem =============================================

rem =============================================
rem == EXPORT ENVIRONMENT ======================
setx TEAM_BRANCH "%TEAM_BRANCH%" /M
setx DEVDIR "%DEVDIR%" /M
setx MTRMPINTERNAL %DEVDIR%\RMP
setx MTEXTENSIONS %MTRMPINTERNAL%\Extensions /M
setx ICEDIR %MTEXTENSIONS%\ICE_Internal /M

setx MTVERSION "%MTVERSION%" /M
setx PF "%PF%" /M
setx PF64 "%PF64%" /M
setx WINSDK "%WINSDK%" /M
setx VS10 "%VS10%" /M
setx VS9 "%VS9%" /M
setx NetFrameWork "%NetFrameWork%" /M
setx TEMP %TEMP% /M
setx TMP %TEMP% /M
setx ROOTDIR s: /M
setx RMPDIR r: /M
setx MTOUTDIR o: /M
setx VERSION debug /M
setx DEBUG 1 /M
setx MAKE_MODE win32 /M
setx HOMEDRIVE C: /M
setx METRATECHTESTDATABASE T:\ /M
setx METRATECHTESTDATABASETEMP T:\Temp /M
setx METRATECHTRESULTDATABASE T:\ /M
setx ORACLE_HOME C:\oracle\app\Administrator\product\11.2.0\dbhome_2 /M
setx DOTNET_3_0_BINDIR "%%PF%%\Reference Assemblies\Microsoft\Framework\v3.0" /M
setx DOTNET_3_5_BINDIR "%%PF%%\Reference Assemblies\Microsoft\Framework\v3.5" /M
setx DOTNET_4_0_BINDIR "%%PF%%\Reference Assemblies\Microsoft\Framework\.NetFrameWork\v4.0" /M

setx MTRMP r: /M
setx MTRMPBIN o:\debug\bin /M
setx PFPRO_CERT_PATH r:\extensions\Paymentsvr\config\verisign\certs /M
setx PATH "%PATH%" /M
setx INCLUDE "%%VS10%%\VC\ATLMFC\INCLUDE;%%VS10%%\VC\INCLUDE;%%WINSDK%%\include" /M
setx LIB "%%VS10%%\VC\ATLMFC\LIB;%%VS10%%\VC\LIB;%%WINSDK%%\lib" /M
rem ==============================
rem == Added 10/19/12 per Rudi Perkins request
setx ICETestReferenceData %ICEDIR%\Test\TestReferenceData
setx ICETestResults %ICEDIR%\Test\TestResults
rem == Pathes for the AMP\RAMP
setx ERLANG_HOME=c:\tools\erlang


rem ==============================
rem ==============================
rem == SETUP DRIVE SUBSTITUTIONS ==
pskill mtsubst
C: 

rem ==============================
rem == Added 10/25/12 per Josh Wheeler's request
REG DELETE "HKEY_CURRENT_USER\Volatile Environment\2" /v TEMP /f
REG DELETE "HKEY_CURRENT_USER\Volatile Environment\2" /v TMP /f
rem ==============================


mtsubst /d s: 
mtsubst /d r: 
mtsubst /d t: 
mtsubst /d o: 
mtsubst /d g:
mtsubst /d u:
mtsubst /d v:

if not exist %DEVDIR%\output (
	mkdir %DEVDIR%\output\debug
	mkdir %DEVDIR%\output\Release	
)

mtsubst s: %MTEXTENSIONS%\Legacy_Internal\source 
mtsubst r: %DEVDIR%\RMP 
mtsubst t: %MTEXTENSIONS%\TestsDatabase_Internal 
mtsubst o: %DEVDIR%\output
mtsubst g: "C:\windows\assembly\gac"
mtsubst u: %MTEXTENSIONS%\FunctionalTests_Internal
mtsubst v: %MTEXTENSIONS%

pause
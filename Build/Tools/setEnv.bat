set DEVDIR=e:\builds\6.7.0-Trunk
set VS9=C:\Program Files (x86)\Microsoft Visual Studio 10.0
set PF=C:\Program Files (x86)

setx MTVERSION 6.7.0 /M 
 
mtsubst /d s: 
mtsubst /d r: 
mtsubst /d t: 
mtsubst /d o: 
mtsubst /d g: 
mtsubst /d v:

mtsubst s: %DEVDIR%\source 
mtsubst r: %DEVDIR%\RMP 
mtsubst t: "%DEVDIR%\tests database" 
mtsubst o: %DEVDIR%\Output 
mtsubst g: "C:\windows\assembly\gac" 
mtsubst v: %DEVDIR%

setx TEMP C:\temp  /M 
setx ROOTDIR s: /M
setx RMPDIR r: /M 
setx MTOUTDIR o: /M 
setx VERSION debug /M 
setx DEBUG 1 /M 
setx MAKE_MODE win32 /M 
setx HOMEDRIVE C: /M 
setx METRATECHTESTDATABASE T:\  /M 
setx METRATECHTESTDATABASETEMP T:\\Temp  /M 
setx METRATECHTRESULTDATABASE T:\  /M 
setx ORACLE_HOME c:\oracle\product\10.2.0\client  /M
setx DOTNET_3_0_BINDIR "%PF%\Reference Assemblies\Microsoft\Framework\v3.0" /M
setx DOTNET_3_5_BINDIR "%PF%\Reference Assemblies\Microsoft\Framework\v3.5" /M
setx DOTNET_4_0_BINDIR "%PF%\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.0" /M
setx ICEDIR c:\dev\Current\ICE /M
setx MTRMP r: /M
setx MTRMPBIN o:\debug\bin /M
setx MTRMPBIN64 o:\debug\bin64 /M
setx PFPRO_CERT_PATH r:\extensions\Paymentsvr\config\verisign\certs  /M 

setx PATH "%PF%\Notepad++;%PF%\CollabNet\Subversion Client;c:\tools;c:\cygwin\bin;c:\tools\notepad2;s:\build\tools;o:\debug\bin;c:\Perl\bin;%PF%\Internet Explorer;%PF%\TestHarness5;C:\Windows\SysWOW64;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;%VS9%\common7\ide;%VS9%\vc\bin;%VS9%\common7\tools;%VS9%\sdk\v3.5\bin;C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319;C:\WINDOWS\Microsoft.NET\Framework\v3.5;C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727;%PF%\Microsoft Visual Studio\VB98;C:\WINDOWS\System32\inetsrv;%PF%\Microsoft SQL Server\80\Tools\BINN;c:\oracle\product\10.2.0\client\BIN;%PF%\Microsoft SDKs\Windows\v7.0A\Bin;%PF%\Microsoft SDKs\Windows\v7.0A\Bin;" /M 

setx INCLUDE "%VS9%\VC\ATLMFC\INCLUDE;%VS9%\VC\INCLUDE;%PF%\Microsoft SDKs\Windows\v7.0A\include;"  /M 

setx LIB "%VS9%\VC\ATLMFC\LIB;%VS9%\VC\LIB;%PF%\Microsoft SDKs\Windows\v7.0A\lib;"  /M 



set DEVDIR=C:\Builds\MetraNet
set VS9=C:\Program Files\Microsoft Visual Studio 10.0
set PF=C:\Program Files (x86)

setx MTVERSION 7.0.0 /M 
 
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
setx VERSION release /M 
setx DEBUG 0 /M 
setx MAKE_MODE win32 /M 
setx HOMEDRIVE C: /M 
setx METRATECHTESTDATABASE T:\  /M 
setx METRATECHTESTDATABASETEMP T:\\Temp  /M 
setx METRATECHTRESULTDATABASE T:\  /M 
setx ORACLE_HOME C:\oracle\product\11.2.0\client  /M
setx DOTNET_3_0_BINDIR "%PF%\Reference Assemblies\Microsoft\Framework\v3.0" /M
setx DOTNET_3_5_BINDIR "%PF%\Reference Assemblies\Microsoft\Framework\v3.5" /M
setx DOTNET_4_0_BINDIR "%PF%\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.0" /M
setx ICEDIR c:\Builds\MetraNet\ICE /M
setx MTRMP r: /M
setx MTRMPBIN o:\release\bin /M
setx MTRMPBIN64 o:\release\bin64 /M
setx PFPRO_CERT_PATH r:\extensions\Paymentsvr\config\verisign\certs  /M 

setx PATH "s:\build\tools;o:\release\bin;C:\Program Files\TortoiseSVN\bin;c:\oracle\product\11.2.0\client\bin;C:\Scripts;C:\Windows\SysWOW64;C:\WINDOWS\system32;C:\Windows\Microsoft.NET\Framework\v4.0.30319;c:\tools;c:\tools\notepad2;s:\build\tools;o:\release\bin;c:\Perl\bin;c:\cygwin\bin;%PF%\Internet Explorer;%PF%\TestHarness5.1;C:\WINDOWS\System32\Wbem;%PF%\Microsoft Visual Studio 10.0\common7\IDE;%PF%\Microsoft Visual Studio 10.0\common7\tools\bin;%PF%\Microsoft Visual Studio 10.0\vc\bin;%PF%\Microsoft Visual Studio 10.0\common7\tools;%PF%\Microsoft Visual Studio 10.0\sdk\v3.5\bin;C:\WINDOWS\Microsoft.NET\Framework\v3.5;C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727;%PF%\Microsoft Visual Studio\VB98;C:\WINDOWS\System32\inetsrv;%PF%\Microsoft SQL Server\80\Tools\BINN;%PF%\Microsoft SDKs\Windows\v7.0A\Bin;%PF%\Git\cmd;C:\Bld\Tools\Common\NAnt\bin;C:\j2sdk1.4.1_01\bin;C:\j2sdk1.4.1_01\lib;" /M
setx INCLUDE "%VS9%\VC\ATLMFC\INCLUDE;%VS9%\VC\INCLUDE;%PF%\Microsoft SDKs\Windows\v7.0A\include;"  /M 

setx LIB "%VS9%\VC\ATLMFC\LIB;%VS9%\VC\LIB;%PF%\Microsoft SDKs\Windows\v7.0A\lib;"  /M 



@ECHO OFF
rem CLS
Echo -- Test Harness Build --
rem c:
rem cd c:\MetraTech\Development\Shared\TestHarness

Copy install.bat o:\debug\bin
Copy uninstall.bat o:\debug\bin
Copy tip.txt o:\debug\bin

Echo Building UnitTest API COM object
Cd UnitTestApi
Del MTTestApi.compile.error.log
vb6.exe /m MTTestApi.vbp /out MTTestApi.compile.error.log /outdir o:\debug\bin
Type MTTestApi.compile.error.log
Echo .
Cd ..

Echo Building MTTestDatabase dll
Cd MTTestDatabase
Del MTTestDatabase.compile.error.log
vb6.exe /m MTTestDatabase.vbp /out MTTestDatabase.compile.error.log /outdir o:\debug\bin
Type MTTestDatabase.compile.error.log
Echo .
Cd ..


Echo Building TestHarness.exe
Del TestHarness.compile.error.log
vb6.exe /m TestHarness.vbp /out TestHarness.compile.error.log /outdir o:\debug\bin
Type TestHarness.compile.error.log
Echo .

cd Install\setup.source
Echo Building TestHarness.exe
Del TestHarness.setup.compile.error.log
vb6.exe /m SETUP1.VBP /out TestHarness.setup.compile.error.log
Type TestHarness.setup.compile.error.log
Echo .
                     
Echo Build Done

Copy S:\Shared\TestHarness\CommentParser\bin\Debug\MetraTech.QA.TestHarness.CommentParser.dll 	o:\debug\bin
Copy S:\Shared\TestHarness\CommentParser\bin\Debug\MetraTech.QA.Tools.dll 			o:\debug\bin

COPY "s:\Shared\TestHarness\Install\TestHarness.ini" "o:\debug\bin"
COPY "s:\Shared\TestHarness\Install\KillTestHarness.bat" o:\debug\bin
COPY "s:\Shared\TestHarness\Install\Kill.EXE" o:\debug\bin
COPY "s:\Shared\TestHarness\Install\Install.bat" o:\debug\bin

md o:\debug\bin\doc\html
md o:\debug\bin\doc\text
COPY "s:\Shared\TestHarness\doc\html\*.*" o:\debug\bin\doc\html
COPY "s:\Shared\TestHarness\doc\text\*.*" o:\debug\bin\doc\text




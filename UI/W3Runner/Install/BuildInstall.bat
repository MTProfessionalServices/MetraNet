Echo Off
Cls
Echo ---------------------------------
Echo -- Building W3Runner Install --
Echo ---------------------------------

call RegisterDLL.bat

REM -- del /Q  setup\*.*
REM -- del /Q  setup\support\*.*
REM -- rmdir  setup\support
REM -- pause
Echo Run VB Setup Maker
cd ..
REM -- "d:\Program Files\Microsoft Visual Studio\VB98\Wizards\PDWizard\PDCMDLN.EXE" W3Runner.vbp /P "Standard Setup Package 1" /l buildinstall.log
cd install

dir .
Echo Copy the Customized setup1.exe
Copy setup.source\setup1.exe setup\support


ECHO BEFORE Del /Q setup\*.*
Del /Q setup\*.*
cd setup\support
CALL W3Runner.BAT
cd ..
cd ..
rem del /Q setup\support\*.*
rem rmdir setup\support

Echo Update Tiber
rem copy setup\*.* \\tiber\public\W3Runner
call ZipAndCopyToWeb.bat 2.0.3

Echo Building setup done


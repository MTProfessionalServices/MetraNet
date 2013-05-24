@echo OFF

set INSTTYPE01=DEBUG
IF %DEBUG%==0 set INSTTYPE01=RELEASE

set TMPTHRDPTY=%ROOTDIR%\Thirdparty


rem   MetraTech AR/GL Samples
mkdir "%MTOUTDIR%\install\%INSTTYPE01%\_CD\Samples\ARGL"
copy  "%ROOTDIR%\DBServices\UsageServer\ARGLExport.zip"   "%MTOUTDIR%\install\%INSTTYPE01%\_CD\Samples\ARGL\ARGLExport.zip"


rem   MS XML
mkdir "%MTOUTDIR%\install\%INSTTYPE01%\_CD\MSXMLUpgrade"
copy  "%TMPTHRDPTY%\MSXMLUpgrade\*.*"   "%MTOUTDIR%\install\%INSTTYPE01%\_CD\MSXMLUpgrade\*.*"


rem   MS Windows Installer
mkdir "%MTOUTDIR%\install\%INSTTYPE01%\_CD\WindowsInstaller"
copy  "%TMPTHRDPTY%\WindowsInstaller\*.*"   "%MTOUTDIR%\install\%INSTTYPE01%\_CD\WindowsInstaller\*.*"



ECHO OFF
CLS

Echo Test Harness 5.1 Quick Install
Echo ------------------------------

MD "C:\Program Files (x86)\TestHarness5" >>"c:\TestHarness.Install.Txt"

Echo Copy Files To C:\Program Files (x86)\TestHarness5
Echo -------------------------------------------
XCOPY "\\corpfs01\Software\~ Static Content\Freeware\Fred\Test Harness\5.1\*.*" "C:\Program Files (x86)\TestHarness5" /e /s /y >>"c:\TestHarness.Install.Txt"


Echo Registering
Echo -----------
C:
CD "C:\Program Files (x86)\TestHarness5"
MTTestAPI.exe >>"c:\TestHarness.Install.Txt"
regsvr32 /s "C:\Program Files (x86)\TestHarness5\MTTestDatabase.dll" >>"c:\TestHarness.Install.Txt"
regasm "C:\Program Files (x86)\TestHarness5\MetraTech.QA.Tools.dll" >>"c:\TestHarness.Install.Txt"
regasm "C:\Program Files (x86)\TestHarness5\MetraTech.QA.TestHarness.CommentParser.dll" >>"c:\TestHarness.Install.Txt"

Echo TestHarness Configuration
Echo -------------------------

"C:\Program Files (x86)\TestHarness5\TestHarness.exe" /i

GOTO END
:END
Echo Done


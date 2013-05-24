@ECHO OFF
@ECHO *** Running UI Tests ***

call startallservices.bat

t:
cd t:\Development\Core\AccHierarchies
CScript.exe "Account Hierarchy Creation.vbs" -file "t:\Development\Core\AccHierarchies\DATA\metratech.xml"
CScript.exe "SalesForce.vbs" -file "t:\Development\Core\AccHierarchies\DATA\MetraTechSalesForce.xml"

cd t:\Development\Core\MTProductCatalog
CScript.exe audioconfsetup.vbs
CScript.exe simplesetup.vbs

MeterTool meter /server:localhost /file:"S:\MetraTech\Test\MeterTool\TestData\audioconfcall.xml"  /close:true /synchronous:false

MeterTool meter /server:localhost /file:"S:\MetraTech\Test\MeterTool\TestData\demo test service.xml"  /close:true /synchronous:false

o:
cd o:\debug\bin
nunit-console.exe /fixture:MetraTech.UI.Test.Selenium /assembly:o:\debug\bin\MetraTech.UI.Test.Selenium.dll

@ECHO DONE.

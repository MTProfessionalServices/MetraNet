@ECHO Stopping Services
call stopallservices

@ECHO Building Services
call build s:\metratech\core\services

@ECHO Building UI
call makeitall UI

@ECHO Building Unit Tests
v:
cd v:\UnitTests\MetraTech
call BuildUT.bat

@ECHO Starting ActivityServices
call net start activityservices

@ECHO Runnning Unit Tests
nunit-console /fixture:MetraTech.Core.Services.UnitTests.SpecificationsServiceUnitTests /assembly:O:\Debug\bin\MetraTech.Core.Services.UnitTests.dll
nunit-console.exe /include:MetraOffer /fixture:MetraTech.UI.Test.Selenium /assembly:MetraTech.UI.Test.Selenium.dll

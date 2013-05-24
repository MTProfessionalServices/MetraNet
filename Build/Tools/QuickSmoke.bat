@ECHO OFF
@ECHO -------------------------------
@ECHO Quick Smoke
@ECHO -------------------------------

t:
cd "t:\Development\Core\MTProductCatalog"
call simplesetup.vbs

@ECHO --- Start pipeline
net start pipeline

@ECHO --- Create accounts
t:
cd t:\Development\Core\AccHierarchies
call "Account Hierarchy Creation.vbs" -file "t:\\Development\Core\AccHierarchies\DATA\metratech.xml"
call "SalesForce.vbs" -file "t:\\Development\Core\AccHierarchies\DATA\MetraTechSalesForce.xml"

@ECHO --- Audioconf setup
t:
cd T:\Development\Core\MTProductCatalog
call audioConfSetup.vbs

@ECHO --- Account Type Tests
s:
cd S:\MetraTech\Accounts\Type\test
call runall.bat

@ECHO -------------------------------
@ECHO Done.
@ECHO -------------------------------
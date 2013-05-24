@ECHO OFF
@ECHO *** Creating Hierarchies ***

t:
cd t:\Development\Core\AccHierarchies

C:\Windows\SysWOW64\CScript.exe "Account Hierarchy Creation.vbs" -file "t:\\Development\Core\AccHierarchies\DATA\metratech.xml"

C:\Windows\SysWOW64\CScript.exe "SalesForce.vbs" -file "t:\\Development\Core\AccHierarchies\DATA\MetraTechSalesForce.xml"

@ECHO DONE.



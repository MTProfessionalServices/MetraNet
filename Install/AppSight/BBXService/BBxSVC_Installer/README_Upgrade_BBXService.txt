Before Installing the new version of AppSight, make sure the old version is completely removed.

*** Go to D:\BBXService\CMD\ and run the following:
BBxService_Stop.cmd
BBxService_Purge_Sessions.cmd


*** Go to Start -> Settings -> Control Panel -> Add or Remove Programs 
Click on AppSight Service Black Box
Respond to dialogs to completely uninstall the AppSight Service Black Box
Verify that AppSight Service Black Box is no longer in the list of installed programs


*** Delete the following folder, and everything below it:
C:\Program Files\BMC Software\AppSight
or
C:\Program Files\BMC Software\BMC AppSight


*** Run regedit and delete the following registry key, and everything below it:
HKEY_LOCAL_MACHINE\SOFTWARE\Identify


*** Delete the following folder (if it exists), and everything below it:
D:\BBXService\





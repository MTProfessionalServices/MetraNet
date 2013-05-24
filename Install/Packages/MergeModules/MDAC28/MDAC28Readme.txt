MDAC 2.8
=========

The new MDAC 2.8 module has three configurable values. These properties were added to work around some of the problems that occur with the older MDAC modules. When you select the MDAC 2.8 merge module (in the Redistributables View) the "Merge Module Properties" dialog should launch with the "Configurable Values" tab selected. These properties should be set from this dialog. By default the module is configured to behave just like the previous MDAC modules. That is, MDAC will be installed in the InstallExecuteSequence (Setup progress dialog) and the machine will be rebooted once the entire setup is complete. Please note that the properties described below can ONLY be set using InstallShield Developer 8.x or higher or Express 4.x or higher. The module will work without any problems on Developer 7.x and Express 3.x but the values mentioned below can NOT bet set.

MDAC 2.8 Install Location
======================
Setting this property to UI will make MDAC install before the Install Welcome dialog (in the InstallUISequence) and then reboot the machine before continuing the setup. Some users needed this because Jet failed to install or some ODBC configurations could not be made till this reboot was performed. For MDAC 2.5, 2.6 and 2.7, users would have contact InstallShield to get a customized module that does this.

MDAC 2.8 Reboot Location
=======================
This property applies ONLY if the "MDAC 2.8 Install Location" property is set to EXEC. If this property is set to 1, then MDAC will be installed in the Execute sequence and the setup will IMMEDIATELY prompt for a reboot. After the reboot setup will pick from InstallFiles and continue the setup. For a nice end user experience try adding a condition of "Not AFTERREBOOT" to the InstallWelcome action in the InstallUISequence. If this is not set, after the reboot occurs setup will go through the Install Welcome, License Agreement, Customer Information, etc, etc dialogs all over again. By setting this condition, after the reboot setup will pickup from the Setup Progress dialog. InstallShield Developer and DevStudio users can set this from the Direct Editor. InstallShield Express users will have open the built MSI in ORCA and then make this change.

We do not automatically add this condition to the setup because you won't see ANY of these dialogs if a reboot occurs before the Install Welcome dialog. A good example of this would be if you include the Windows Scripting Host (WSH) merge module as well as this MDAC 2.8 module (with this condition). In this case, setup will install WSH, reboot the machine and then go straight to the Setup Progress dialog (skipping Install Welcome, License Agreement, etc, etc).

Suppress MDAC 2.8 Reboot
=======================
This property was mainly added to support the "MDAC 2.8 Reboot Location" property. If this property is set to "Suppress" and “MDAC 2.8 Install Location” is set to EXEC and "MDAC 2.8 Reboot Location" is set to 1, then soon after MDAC is installed the user will see a message box saying that Setup needs to reboot the machine before continuing. When user presses the OK button the machine will. The user will NOT be given the option of not rebooting.



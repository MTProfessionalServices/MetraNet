Author: Michael Ross

Last Revised: 6/1/09

Project type: VB6 

Dependencies:
Has no nonstandard dependencies - should run on any standard 03 or XP machine.)

Builds:
MetraRun.exe is a wrapper for the Installation CD or Doc CD default.htm. 

Purpose:
MetraRun.exe's main purpose is to enable execution of the MetraNet and MetraConnect setup programs. (It also works with Autorun when a system has autorun enabled.)

Location:
MetraRun expects a Docs folders containing a Default.htm and a text file called settings.

Settings file:
The settings file should contain 2 lines:
-a window title
 for example, MetraNet 6.0.3
 (Other version #s must be changed directly in Default.htm)
-a banner title
 for example, Welcome to the MetraNet Installation Menu

Folder structure:

-----<CD>
      MetraRun.exe
      Autorun.inf
      -------Docs
                Default.htm
		settings
                ------------images
		------------MetraNet Documentation - Complete Set
      -------MetraNet
      -------MetraConnect
      -------Tools
	




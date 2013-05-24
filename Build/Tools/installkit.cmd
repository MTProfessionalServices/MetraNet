cd %ROOTDIR%\Build\Tools
rem cscript.exe  BuildPEKit.vbs
rem call BuildNewGUIPackage.cmd
rem cscript.exe  BuildAllPlatformExtensions.vbs
cscript.exe  GenericPackage.vbs  MetraTechPlatformSDK
call zipsdk.bat
cd %INSTALLROOTDIR%
cd Tools
call genpackages.bat
cd %ROOTDIR%\Build\Tools

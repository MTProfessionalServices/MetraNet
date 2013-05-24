@echo off
SET PATH_FOLDER=%1%
IF "none%PATH_FOLDER%"=="none" SET /P PATH_FOLDER="Enter Path Folder [..\..\]: "
IF "none%PATH_FOLDER%"=="none" SET PATH_FOLDER=..\..\

:: SVN environment
SET SVN_PATH="C:\Program Files\w3af\svn-client"
SET URL_PROJECT="svn://qaautoserv/MetraNet/branches/6.4.0-MetraNetSF-Dev/Source/MetraTech/SecurityFramework"

:: MSBUILD envirement
SET MSBULD_PATH="C:\Windows\Microsoft.NET\Framework\v4.0.30319"
SET CURRENT_PROGECT_FOLDER=SecurityFramework
SET FILE_PROJECT_TO_BUILD=%CURRENT_PROGECT_FOLDER%\SecurityFramework.sln

@echo "Folder is creating..."
@echo off 
mkdir %PATH_FOLDER%
IF EXIST %PATH_FOLDER% (
GOTO :FOLDER_CREATED
) ELSE (
@echo "Folder doesn't create."
GOTO TO_EXIT
)
:FOLDER_CREATED
@echo "Folder created."
CD %PATH_FOLDER%

@echo ==========================================================================
@echo Project is checking out...
%SVN_PATH%\svn checkout %URL_PROJECT%
@echo Project checked.
@echo ==========================================================================

@echo SecurityFramework project is building ...  
%MSBULD_PATH%\msbuild %FILE_PROJECT_TO_BUILD%
@echo SecurityFramework project built.
@echo ==========================================================================


:: Copy built fales to Pyton Test folder.
@echo "Copy From Dir O:\debug\Bin To Dir %CD%\%CURRENT_PROGECT_FOLDER%\Tests\FeatureTester\framework"
@echo ==========================================================================

copy "E:\Builds\6.4.0-Development\Source\Thirdparty\MetraTechSecurityFramework\DotNet\EnterpriseLibrary" "%CD%\%CURRENT_PROGECT_FOLDER%\Tests\FeatureTester\framework"
copy "E:\Builds\6.4.0-Development\Source\Thirdparty\MetraTechSecurityFramework\DotNet\Microsoft\Bin" "%CD%\%CURRENT_PROGECT_FOLDER%\Tests\FeatureTester\framework"
copy "E:\Builds\6.4.0-Development\Source\Thirdparty\MetraTechSecurityFramework\DotNet\SQLite" "%CD%\%CURRENT_PROGECT_FOLDER%\Tests\FeatureTester\framework"
copy "E:\Builds\6.4.0-Development\Source\Thirdparty\MetraTechSecurityFramework\DotNet\SQLite\Designer" "%CD%\%CURRENT_PROGECT_FOLDER%\Tests\FeatureTester\framework"
copy "E:\Builds\6.4.0-Development\Source\MetraTech\SecurityFramework\Configs" "%CD%\%CURRENT_PROGECT_FOLDER%\Tests\FeatureTester\framework"
copy "E:\Builds\6.4.0-Development\Source\MetraTech\SecurityFramework\Tests\SampleAspNetApp\bin\MetraTech.SecurityFramework.dll" "%CD%\%CURRENT_PROGECT_FOLDER%\Tests\FeatureTester\framework"
copy "E:\Builds\6.4.0-Development\Source\MetraTech\SecurityFramework\Tests\SampleAspNetApp\bin\MetraTech.SecurityFramework.MTLogging.dll" "%CD%\%CURRENT_PROGECT_FOLDER%\Tests\FeatureTester\framework"


@echo Finished!
1
:TO_EXIT
pause

exit


rem The Script was last updated on 10/04/2013
rem all env variables took from %ROOTDIR%\Build\Tools\setEnv.bat
@echo off

Set TARGET=%1%

IF "none%TARGET%"=="none" (
Set TARGET=skip_pull
)

IF NOT "%TARGET%"=="skip_pull" (
	IF NOT  "%TARGET%"=="with_revert" (
		IF NOT  "%TARGET%"=="full" (
			@echo The target '%TARGET%' is not recognized parameter.
			@echo Use 'full' {ALL changes will be removed} parameter to force FullCheckOut from GIT and execute makeitallparallel with clean...
			@echo Use 'with_revert' parameter to revert all changes before do git pull by all submodules 
			@echo Use 'skip_pull' to avoid pull for all submodules
			@echo Press any key to exit . . .
			pause > nul
			Exit /B
		)
	)
)

@echo.
@echo.
IF "%TARGET%"=="skip_pull" (
@echo Sets DEFAULT '%TARGET%' target ...
) ELSE (
@echo Sets '%TARGET%' target ...
)
@echo.

IF "%TARGET%"=="full" (
@echo The most time-consuming process, bit new MetraNet will be fresh. The target will do:
@echo - Remove all binary and source code
) ELSE (
@echo The current target will do:
)

IF "%TARGET%"=="skip_pull" (
@echo - Revert all uncommitted changes;
@echo - Get latest from all submodules;
)

@echo - Buld MetraNet;
@echo - Buld MVM;
@echo - Buld ICE;
if NOT "%TARGET%"=="skip_pull" (
@echo - Create security key for encripting passwords;
)
@echo - Encripts password;
@echo - Install  MSSQL DB;
@echo.
pause

Set SCRIPTSFOLDER=%ROOTDIR%\Build\Tools

call %SCRIPTSFOLDER%\StopAllServices.bat
call %SCRIPTSFOLDER%\StopAllServices.bat
SET CURRENT_FOLDER=%DEVDIR%

@pushd %CURRENT_FOLDER%

if "%TARGET%"=="skip_pull" (
GOTO SKIP_PULL
)

if "%TARGET%"=="full" (
@echo Full VM update was forced. Deleting all MN folders
rem Removes temporary files
FOR /D %%p IN ("O:\debug\*.*") DO rmdir "%%p" /s /q
FOR /D %%p IN ("O:\release\*.*") DO rmdir "%%p" /s /q
rem Source folder (Build folder will skip)
FOR /D %%p IN ("S:\*") DO if not "%%p"=="S:\Build" rmdir "%%p" /s /q
rem Removes MVM source folder
FOR /D %%p IN ("%MTEXTENSIONS%\MvmCore_Internal\SourceCode\*") DO rmdir "%%p" /s /q
rem FOR /D %%p IN ("R:\*.*") DO rmdir "%%p" /s /q
rem FOR /D %%p IN ("%CURRENT_FOLDER%\RMP_INTERNAL\Extensions\*.*") DO rmdir "%%p" /s /q
FOR /D %%p IN ("%temp%\*.*") DO rmdir "%%p" /s /q
mkdir %temp%\1\
mkdir %temp%\2\
	
FOR /D %%p IN ("%windir%\Microsoft.NET\Framework\v2.0.50727\Temporary ASP.NET Files\*.*") DO rmdir "%%p" /s /q
FOR /D %%p IN ("%windir%\Microsoft.NET\Framework\v4.0.30319\Temporary ASP.NET Files\*.*") DO rmdir "%%p" /s /q
rem git hard reset all changes second time [TODO] should be just reverted
call %SCRIPTSFOLDER%\Git\GitRevert.bat skip_set_unchange_config
)

if "%TARGET%"=="with_revert" (
call %SCRIPTSFOLDER%\Git\GitRevert.bat skip_set_unchange_config
}

rem whether show log in notepad: 0 - none; 1 - only MetraNet build log; 2 - MetraNet and MVM; 3 - MetraNet, MVM and ICE; 4 - MetraNet, MVM, ICE and DB installetion
SET WILL_SHOW_LOG_IN_NOTEPAD=0
@echo Starting get latest versions from MetraNet root repository
::call sh --login -i -c "git mt feature push"
git pull -v --progress  "origin"
IF NOT %ERRORLEVEL%==0 (
@echo error while git pull origin...
GOTO ERROR
)

@echo Starting get latest versions from all MetraNet submodules (includes MetraNet, MVM, ICE and so on.)
git submodule foreach git pull -v --progress  "origin"
IF NOT %ERRORLEVEL%==0 (
@echo error while git pull forech submodules...
GOTO ERROR
)

:SKIP_PULL

call %SCRIPTSFOLDER%\Git\SetUnchangeConfigFiles.bat skip_pause

rem Builds MetraNet
SET WILL_SHOW_LOG_IN_NOTEPAD=1
call %MTEXTENSIONS%\Legacy_Internal\Source\build\tools\MakeItAllParallel
IF NOT %ERRORLEVEL%==0 (
@echo error while build MetraNet. See opened msbuild.log in Notepad++...
GOTO ERROR
)

rem Builds MVM
SET WILL_SHOW_LOG_IN_NOTEPAD=2
@pushd %MTEXTENSIONS%\MVMCore_Internal\SourceCode\Mvm\
call msbuild MVM.sln /m /ds /p:config=%VERSION%;MyTargets=Build /fl /flp:ShowTimestamp;Verbosity=DIAG;Summary;LogFile=%temp%\MetraNetMVMBuild.log /clp:Verbosity=M;Summary /property:Platform=x86
@popd
IF NOT %ERRORLEVEL%==0 (
@echo error while build MVM. See opened MetraNetMVMBuild.log in Notepad++...
GOTO ERROR
)

rem Builds ICE
SET WILL_SHOW_LOG_IN_NOTEPAD=3
call %MTEXTENSIONS%\ICE_Internal\Build\Build.bat
IF NOT %ERRORLEVEL%==0 (
@echo error while build ICE. See opened ICE_build.log in Notepad++...
GOTO ERROR
)

cd %DEVDIR%
::pause
::echo The result of ICE build see above ...

@echo Starting install DB
rem Installs DB 

if NOT "%TARGET%"=="skip_pull" (
	call cryptosetup -createkeys	
)
call cryptosetup -encryptconfig

SET WILL_SHOW_LOG_IN_NOTEPAD=4
call %ROOTDIR%\Install\Scripts\database.vbs

:DONE
echo DONE!
@echo *** Result of DB installation see above ... ***
GOTO END

:ERROR
@echo ERROR were found (errorcode=%ERRORLEVEL%), see text above for clarification


IF WILL_SHOW_LOG_IN_NOTEPAD GEQ 1 (
notepad++ %temp%\msbuild.log
@echo *** Result of MN build see in opened notepad {title: msbuild.log} ***
)

IF WILL_SHOW_LOG_IN_NOTEPAD GEQ 2 (
notepad++ %temp%\ICE_build.log
@echo *** Result of ICE build see in opened notepad {title: ICE_build.log} ***
)

IF WILL_SHOW_LOG_IN_NOTEPAD GEQ 3 (
notepad++ %temp%\MetraNetMVMBuild.log
@echo *** Result of MVM build see in opened notepad {title: mvm_build.log} ***
)

:END
@popd
pause
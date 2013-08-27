rem The Script was last updated on 5/24/2013
rem all env variables took from %ROOTDIR%\Build\Tools\setEnv.bat
@echo off

IF NOT "none%1%"=="none" (
	IF NOT "%1%"=="full" (
		@echo '%1%' is not recognized parameter.
		@echo Use 'full' {ALL changes will be removed} parameter to force FullCheckOut from GIT and execute makeitallparallel with clean...
		Exit /B
	)
)

Set SCRIPTSFOLDER=%ROOTDIR%\Build\Tools

call %SCRIPTSFOLDER%\StopAllServices.bat
call %SCRIPTSFOLDER%\StopAllServices.bat
SET CURRENT_FOLDER=%DEVDIR%

if "%1%"=="full" (
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

@pushd %CURRENT_FOLDER%

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

call %SCRIPTSFOLDER%\Git\SetUnchangeConfigFiles.bat skip_pause

rem Builds MetraNer
call %MTEXTENSIONS%\Legacy_Internal\Source\build\tools\MakeItAllParallel
IF NOT %ERRORLEVEL%==0 (
@echo error while build MetraNet. See opened msbuild.log in Notepad++...
GOTO ERROR
)

rem Builds MVM
@pushd %MTEXTENSIONS%\MVMCore_Internal\SourceCode\Mvm\
call msbuild MVM.sln /m /ds /p:config=%VERSION%;MyTargets=Build /fl /flp:ShowTimestamp;Verbosity=DIAG;Summary;LogFile=%temp%\MetraNetMVMBuild.log /clp:Verbosity=M;Summary /property:Platform=x86
@popd
IF NOT %ERRORLEVEL%==0 (
@echo error while build MVM. See opened MetraNetMVMBuild.log in Notepad++...
GOTO ERROR
)

rem Builds ICE
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

if "%1%"=="full" (
	call cryptosetup -createkeys	
)
call cryptosetup -encryptconfig

call %ROOTDIR%\Install\Scripts\database.vbs

:DONE
echo DONE!
GOTO END

:ERROR
@echo ERROR were found (errorcode=%ERRORLEVEL%), see text above for clarification


call notepad++ %temp%\msbuild.log
call notepad++ %temp%\ICE_build.log
call notepad++ %temp%\MetraNetMVMBuild.log

@echo *** Result of DB installation see above ... ***
@echo *** Result of MN build see in opened notepad (title: msbuild.log) ***
@echo *** Result of ICE build see in opened notepad (title: ICE_build.log) ***
@echo *** Result of MVM build see in opened notepad (title: mvm_build.log) ***

:END
@popd
pause
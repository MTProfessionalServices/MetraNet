@echo off

SET /P ALLOW_BLANK="Are you going just clean up user name? [by default "n"]: "
IF "none%ALLOW_BLANK%"=="none" SET ALLOW_BLANK=n

IF NOT "%ALLOW_BLANK%"=="y" SET /P GIT_USER_NAME="Enter Git user name : "

IF "%ALLOW_BLANK%"=="y" (
SET GIT_USER_NAME=\"\"
@echo "The git user name will be cleaned up {'%GIT_USER_NAME%'} for all submodules"
) ELSE (
	IF "none%GIT_USER_NAME%"=="none" (	
		@echo please, specify the user name
		@echo if you just want to clean up current git username, set 'y' for the first argument	
		@echo Press any key to exit . . .
		pause > nul
		Exit /B
	)
@echo "The user '%GIT_USER_NAME%' will set in git configuration for all submodules"
)

pause

@pushd %DEVDIR%

git config user.name %GIT_USER_NAME%
git submodule foreach git config user.name %GIT_USER_NAME%

@popd
@pause
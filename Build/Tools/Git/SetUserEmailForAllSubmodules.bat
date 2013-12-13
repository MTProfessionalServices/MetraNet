@echo off
SET /P ALLOW_BLANK="Are you going just clean up user email? [by default "n"]: "
IF "none%ALLOW_BLANK%"=="none" SET ALLOW_BLANK=n

IF NOT "%ALLOW_BLANK%"=="y" SET /P GIT_USER_EMAIL="Enter Git user email : "

IF "%ALLOW_BLANK%"=="y" (
SET GIT_USER_EMAIL=\"\"
@echo "The git user email will be cleaned up {'%GIT_USER_EMAIL%'} for all submodules"
) ELSE (
	IF "none%GIT_USER_EMAIL%"=="none" (	
		@echo please, specify the user email
		@echo if you just want to clean up current git username, set 'y' for the first argument	
		@echo Press any key to exit . . .
		pause > nul
		Exit /B
	)
@echo "The user email'%GIT_USER_EMAIL%' will set in git configuration for all submodules"
)

pause

@pushd %DEVDIR%

git config user.email %GIT_USER_EMAIL%
git submodule foreach git config user.email %GIT_USER_EMAIL%

@popd
@pause

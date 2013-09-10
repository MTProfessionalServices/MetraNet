@call SwitchToBranchInAllFolder.bat %1
@call PullInAllFolder.bat

@echo .
@echo checkout %2 and pull
@echo .
@pause

@call SwitchToBranchInAllFolder.bat %2
@call PullInAllFolder.bat

@echo .
@echo merge from %1 to %2
@echo .
@pause

@popd

@pushd %DEVDIR%

@set submoduleName=%1
@if NOT "%submoduleName%" == "develop" set submoduleName=%submoduleName%@MetraNet

git merge %1
git submodule foreach git merge %submoduleName%

@pause

@echo .
@echo push to %1 
@echo .
@pause

@pushd %DEVDIR%

@set submoduleName=%1
@if NOT "%submoduleName%" == "develop" set submoduleName=%submoduleName%@MetraNet

git submodule foreach git push -v --progress  "origin" %submoduleName%:%submoduleName%
git push -v --progress  "origin" %1:%1

@popd

@pause

@pushd %DEVDIR%

git.exe checkout %1

@set submoduleName=%1
@if NOT "%submoduleName%" == "develop" set submoduleName=%submoduleName%@MetraNet
:echo "%submoduleName%"

git submodule foreach git checkout "%submoduleName%"

@popd
@pause

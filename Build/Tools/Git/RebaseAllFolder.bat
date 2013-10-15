@pushd %DEVDIR%

@echo Executing Rebase for all folders
git rebase "origin"
git submodule foreach git rebase "origin"

@popd

if NOT "%1%"=="skip_pause" (
pause
)

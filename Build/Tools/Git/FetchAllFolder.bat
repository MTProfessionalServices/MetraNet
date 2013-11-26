@pushd %DEVDIR%

@echo Executing Fetch for all folders
git fetch -v --progress  "origin"
git submodule foreach git fetch -v --progress  "origin"

@popd

if NOT "%1%"=="skip_pause" (
pause
)

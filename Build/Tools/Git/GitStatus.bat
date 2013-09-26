@pushd %DEVDIR%

git status
git submodule foreach git status

@popd
@pause

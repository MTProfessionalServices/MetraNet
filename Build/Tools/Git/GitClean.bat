@pushd c:\Dev\MetraNet

git submodule foreach git clean -df -xf
@popd

IF NOT "%1%"=="skip_pause" (
@pause
)

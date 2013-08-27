git reset --hard
git submodule foreach git reset --hard

if NOT "%1%"=="skip_set_unchange_config" (
call SetUnchangeConfigFiles.bat
)

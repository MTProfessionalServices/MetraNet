rem if you need skip puse after executions call "SetUnchangeConfigFiles.bat skip_pause"

git reset --hard
git submodule foreach git reset --hard

call SetUnchangeConfigFiles.bat %1%

pushd %USERPROFILE%
git clone https://github.com/MetraTech/GitTemplate.git .gittemplate
git config --global init.templatedir ~/.gittemplate
popd

pushd %DEVDIR%
git init
popd
pause

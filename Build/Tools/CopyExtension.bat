REM xcopy /E /I /Y %METRATECHTESTDATABASE%\InternalExtensions\AudioConf %RMPDIR%\extensions\AudioConf
REM xcopy /E /I /Y T:\InternalExtensions\AudioConf R:\extensions\AudioConf
ECHO Copy All Extensions Back
xcopy /E /I /Y %METRATECHTESTDATABASE%\InternalExtensions %RMPDIR%\extensions
CryptoSetup -encryptConfig
gendm.exe
%ROOTDIR%\install\scripts\RunHook.vbs all
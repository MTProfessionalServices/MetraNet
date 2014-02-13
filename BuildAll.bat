@echo ***********************************************************
@echo ****** Build MetraNet platform projects.              *****
@echo ****** See results in the file MakeItAllWithClean.log *****
@echo ***********************************************************
@echo Begin makeItAllWithClean.cmd at %time%
@call %ROOTDIR%\Build\Tools\makeItAllWithClean.cmd >MakeItAllWithClean.log 2>CON
@echo End makeItAllWithClean.cmd at %time%
@echo .
@echo .
@echo ***********************************************************
@echo ****** Encript passwords for DB connection strings.  ******
@echo ***********************************************************
@C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe -Command "& { 'Start CryptoSetup at ' + (get-date).ToLongTimeString() }"
CryptoSetup -createkeys
CryptoSetup -encryptconfig
@C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe -Command "& { 'End CryptoSetup at ' + (get-date).ToLongTimeString() }"
@echo .
@echo .
@echo ***********************************************************
@echo ****** Build MVM solution.                           ******
@echo ****** See results in the file BuildMVM.log          ******
@echo ***********************************************************
@C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe -Command "& { 'Begin MVM.sln at ' + (get-date).ToLongTimeString() }"
@msbuild %DEVDIR%\MvmCore\SourceCode\Mvm\MVM.sln /property:Platform=x86 >BuildMVM.log 2>CON
@C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe -Command "& { 'End MVM.sln at ' + (get-date).ToLongTimeString() }"
@echo .
@echo .
@echo ***********************************************************
@echo ****** Remove folders with invalid configurations.   ******
@echo ****** Need to remove this once configs are fixed.   ******
@echo ***********************************************************
rd /S /Q %DEVDIR%\ICE\Test\TestExtensions\RMP\Extensions\ValMessages
@echo .
@echo .
@echo ***********************************************************
@echo ****** Build ICE solution.                           ******
@echo ****** See results in the file BuildICE.log          ******
@echo ***********************************************************
@C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe -Command "& { 'Begin ICE.sln at ' + (get-date).ToLongTimeString() }"
@msbuild %DEVDIR%\ICE\Source\MetraTech\ICE\ICE.sln /property:Platform=x86 >BuildICE.log 2>CON
@C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe -Command "& { 'End ICE.sln at ' + (get-date).ToLongTimeString() }"
@echo .
@echo .
@echo ***********************************************************
@echo ****** Build database.                               ******
@echo ****** See results in the file BuildDatabase.log     ******
@echo ***********************************************************
@C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe -Command "& { 'Begin Database.vbs at ' + (get-date).ToLongTimeString() }"
@call %ROOTDIR%\Build\Tools\BuildDatabase.bat >BuildDatabase.log 2>CON
@C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe -Command "& { 'End Database.vbs at ' + (get-date).ToLongTimeString() }"
@echo .
@echo .
@echo ***********************************************************
@echo ****** Start all services.                           ******
@echo ***********************************************************
@call %ROOTDIR%\Build\Tools\StartAllServices.bat
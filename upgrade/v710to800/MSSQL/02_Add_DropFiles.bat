@echo off
echo Starting addidng and removing files:

del %MTRMP%\Extensions\MvmAmp\MvmConfig\DatabaseInstall\tables\agg_charge_definition.SqlServer.sql
copy .\agg_charge_definition.SqlServer.sql  %MTRMP%\Extensions\MvmAmp\MvmConfig\DatabaseInstall\views\agg_charge_definition.SqlServer.sql

echo Finished adding and removing files.
pause
for %%i in (*.dll) do regsvr32 /u /s %%i

for %%i in (*.dll) do regasm /u /s %%i
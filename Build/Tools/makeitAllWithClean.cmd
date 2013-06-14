call %ROOTDIR%\build\tools\StopAllServices.bat

Del R:\extensions\PageNav\Bin\MetraTech.PageNav.ClientProxies.*
Del R:\extensions\Account\bin\*.dll

rd /s/q o:\debug
rd /s/q r:\extensions\SystemConfig\config\EnumType\Temp
rd /s/q s:\MetraTech\UI\PreCompiled\
rd s:\MetraTech\Agreements\bin

FOR /D %%p IN ("%windir%\Microsoft.NET\Framework\v2.0.50727\Temporary ASP.NET Files\*.*") DO rmdir "%%p" /s /q

FOR /D %%p IN ("%windir%\Microsoft.NET\Framework\v4.0.30319\Temporary ASP.NET Files\*.*") DO rmdir "%%p" /s /q

call %ROOTDIR%\build\tools\MakeItAllParallel

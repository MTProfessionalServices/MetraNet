
set CURDIR=D:\metratech\development\Core\Configuration\XmlDiff\test
set VERDIR=%CURDIR%\ver
SET V1=1
set V2=2
set V3=3

set CNAME=pipeline
cscript testMerge.vbs %CURDIR%\%CNAME%%V1%.xml %CURDIR%\%CNAME%%V2%.xml %VERDIR%\%CNAME%%V3%.xml
set CNAME=viewtoaspmapping
cscript testMerge.vbs %CURDIR%\%CNAME%%V1%.xml %CURDIR%\%CNAME%%V2%.xml %VERDIR%\%CNAME%%V3%.xml
set CNAME=view_hierarchy
cscript testMerge.vbs %CURDIR%\%CNAME%%V1%.xml %CURDIR%\%CNAME%%V2%.xml %VERDIR%\%CNAME%%V3%.xml
set CNAME=service
cscript testMerge.vbs %CURDIR%\%CNAME%%V1%.xml %CURDIR%\%CNAME%%V2%.xml %VERDIR%\%CNAME%%V3%.xml

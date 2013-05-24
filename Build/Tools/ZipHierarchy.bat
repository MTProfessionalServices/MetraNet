REM Setup IIsCompressionScheme for deflate
cscript c:\inetpub\adminscripts\adsutil.vbs set W3Svc/Filters/Compression/DEFLATE/HcCompressionDll %windir%\system32\inetsrv\gzip.dll
cscript c:\inetpub\adminscripts\adsutil.vbs set W3Svc/Filters/Compression/DEFLATE/HcCreateFlags 0
cscript c:\inetpub\adminscripts\adsutil.vbs set W3Svc/Filters/Compression/DEFLATE/HcDoDynamicCompression TRUE
cscript c:\inetpub\adminscripts\adsutil.vbs set W3Svc/Filters/Compression/DEFLATE/HcDoOnDemandCompression TRUE
cscript c:\inetpub\adminscripts\adsutil.vbs set W3Svc/Filters/Compression/DEFLATE/HcDoStaticCompression TRUE
cscript c:\inetpub\adminscripts\adsutil.vbs set W3Svc/Filters/Compression/DEFLATE/HcDynamicCompressionLevel 9
cscript c:\inetpub\adminscripts\adsutil.vbs set W3Svc/Filters/Compression/DEFLATE/HcFileExtensions "htm" "html" "txt" "js" "xml" "css"
cscript c:\inetpub\adminscripts\adsutil.vbs set W3Svc/Filters/Compression/DEFLATE/HcOnDemandCompLevel 9
cscript c:\inetpub\adminscripts\adsutil.vbs set W3Svc/Filters/Compression/DEFLATE/HcPriority 1
cscript c:\inetpub\adminscripts\adsutil.vbs set W3Svc/Filters/Compression/DEFLATE/HcScriptFileExtensions "asp" "dll" "exe" "aspx" "asmx"


REM Setup IIsCompressionScheme for GZip
cscript c:\inetpub\adminscripts\adsutil.vbs set W3Svc/Filters/Compression/GZIP/HcCompressionDll %windir%\system32\inetsrv\gzip.dll
cscript c:\inetpub\adminscripts\adsutil.vbs set W3Svc/Filters/Compression/GZIP/HcCreateFlags 1
cscript c:\inetpub\adminscripts\adsutil.vbs set W3Svc/Filters/Compression/GZIP/HcDoDynamicCompression TRUE
cscript c:\inetpub\adminscripts\adsutil.vbs set W3Svc/Filters/Compression/GZIP/HcDoOnDemandCompression TRUE
cscript c:\inetpub\adminscripts\adsutil.vbs set W3Svc/Filters/Compression/GZIP/HcDoStaticCompression TRUE
cscript c:\inetpub\adminscripts\adsutil.vbs set W3Svc/Filters/Compression/GZIP/HcDynamicCompressionLevel 9
cscript c:\inetpub\adminscripts\adsutil.vbs set W3Svc/Filters/Compression/GZIP/HcFileExtensions "htm" "html" "txt" "js" "xml" "css"
cscript c:\inetpub\adminscripts\adsutil.vbs set W3Svc/Filters/Compression/GZIP/HcOnDemandCompLevel 9
cscript c:\inetpub\adminscripts\adsutil.vbs set W3Svc/Filters/Compression/GZIP/HcPriority 1
cscript c:\inetpub\adminscripts\adsutil.vbs set W3Svc/Filters/Compression/GZIP/HcScriptFileExtensions "asp" "dll" "exe" "aspx" "asmx"


REM Setup IIsCompressionSchemes parameters
cscript c:\inetpub\adminscripts\adsutil.vbs set W3SVC/Filters/Compression/Parameters/HcCacheControlHeader max-age=86400
cscript c:\inetpub\adminscripts\adsutil.vbs set W3SVC/Filters/Compression/Parameters/HcCompressionBufferSize 102400
cscript c:\inetpub\adminscripts\adsutil.vbs set W3SVC/Filters/Compression/Parameters/HcCompressionDirectory %windir%\"IIS Temporary Compressed Files"
cscript c:\inetpub\adminscripts\adsutil.vbs set W3SVC/Filters/Compression/Parameters/HcDoDiskSpaceLimiting FALSE
cscript c:\inetpub\adminscripts\adsutil.vbs set W3SVC/Filters/Compression/Parameters/HcDoDynamicCompression FALSE
cscript c:\inetpub\adminscripts\adsutil.vbs set W3SVC/Filters/Compression/Parameters/HcDoOnDemandCompression TRUE
cscript c:\inetpub\adminscripts\adsutil.vbs set W3SVC/Filters/Compression/Parameters/HcDoStaticCompression FALSE
cscript c:\inetpub\adminscripts\adsutil.vbs set W3SVC/Filters/Compression/Parameters/HcExpiresHeader "Wed, 01 Jan 1997 12:00:00 GMT"
cscript c:\inetpub\adminscripts\adsutil.vbs set W3SVC/Filters/Compression/Parameters/HcFilesDeletedPerDiskFree 256
cscript c:\inetpub\adminscripts\adsutil.vbs set W3SVC/Filters/Compression/Parameters/HcIoBufferSize 102400
cscript c:\inetpub\adminscripts\adsutil.vbs set W3SVC/Filters/Compression/Parameters/HcMaxDiskSpaceUsage 0
cscript c:\inetpub\adminscripts\adsutil.vbs set W3SVC/Filters/Compression/Parameters/HcMaxQueueLength 1000
cscript c:\inetpub\adminscripts\adsutil.vbs set W3SVC/Filters/Compression/Parameters/HcMinFileSizeForComp 1
cscript c:\inetpub\adminscripts\adsutil.vbs set W3SVC/Filters/Compression/Parameters/HcNoCompressionForHttp10 FALSE
cscript c:\inetpub\adminscripts\adsutil.vbs set W3SVC/Filters/Compression/Parameters/HcNoCompressionForProxies FALSE
cscript c:\inetpub\adminscripts\adsutil.vbs set W3SVC/Filters/Compression/Parameters/HcNoCompressionForRange FALSE
cscript c:\inetpub\adminscripts\adsutil.vbs set W3SVC/Filters/Compression/Parameters/HcSendCacheHeaders FALSE

REM Setup AccountHierarchy IIsCompressionScheme 
cscript C:\Inetpub\AdminScripts\adsutil.vbs set w3Svc/1/root/AccountHierarchy/DoDynamicCompression TRUE
cscript C:\Inetpub\AdminScripts\adsutil.vbs set w3Svc/1/root/AccountHierarchy/DoStaticCompression FALSE
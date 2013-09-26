REM Make sure there is nothing running that will prevent linking
Net stop pipeline
Net stop activityservices
Net stop iisadmin /y
Net stop w3svc
Net stop msmq /y
Net stop metrapay
Net stop metratech.fileservice
Net stop billingserver
Net stop MetraTechDataExportService

REM Kill MetraTime
taskkill /IM metratime.exe
taskkill /IM consolehost.exe
taskkill /IM MVM.exe /F 
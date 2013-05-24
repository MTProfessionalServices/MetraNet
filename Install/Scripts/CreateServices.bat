@echo pipeline
pipeline create-service

@echo billing service
call s:\Install\Scripts\BillingServer.vbs

@echo activity services
call s:\MetraTech\ActivityServices\Service\install.bat

@echo metrapay
call s:\Metratech\MetraPay\install.bat

@echo data export service
installutil o:\%VERSION%\bin\MetraTechDataExportService.exe

@echo file landing service
installutil o:\%VERSION%\bin\MetraTech.FileLandingService.exe

@echo file landing service
installutil o:\%VERSION%\bin\MetraTech.Messaging.MessagingService.exe

pause

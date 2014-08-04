@echo pipeline
%MTRMPBIN%\pipeline create-service

@echo billing service
call s:\Install\Scripts\BillingServer.vbs

@echo activity services
call s:\MetraTech\ActivityServices\Service\install.bat

@echo metrapay
call s:\Metratech\MetraPay\install.bat

@echo data export service
installutil %MTRMPBIN%\MetraTechDataExportService.exe

@echo file landing service
installutil %MTRMPBIN%\MetraTech.FileLandingService.exe

@echo file landing service
installutil %MTRMPBIN%\MetraTech.Messaging.MessagingService.exe

pause

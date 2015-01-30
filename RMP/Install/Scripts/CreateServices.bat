@echo pipeline
%MTRMPBIN%\pipeline create-service

@echo billing service
call cscript.exe %ROOTDIR%\Install\Scripts\BillingServer.vbs

@echo activity services
call %ROOTDIR%\MetraTech\ActivityServices\Service\install.bat

@echo metrapay
call %ROOTDIR%\Metratech\MetraPay\install.bat

@echo data export service
installutil %MTRMPBIN%\MetraTechDataExportService.exe

@echo file landing service
installutil %MTRMPBIN%\MetraTech.FileLandingService.exe

@echo Messaging Service
installutil %MTRMPBIN%\MetraTech.Messaging.MessagingService.exe

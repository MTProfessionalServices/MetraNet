@ECHO OFF

Set SrcDir = ''
Set TargetDir = ''

if not '%1' == '' (set SrcDir=%1)
if not '%2' == '' (set TargetDir=%2)

if '%1' == '' (goto :Error)
if '%2' == '' (goto :Error)

REM Remove the old, unneeded files
IF EXIST %TargetDir%\BIN\MetraPayService.exe.config del /F %TargetDir%\BIN\MetraPayService.exe.config
IF EXIST %TargetDir%\BIN\MetraTech.ActivityServices.Interfaces.dll del /F %TargetDir%\BIN\MetraTech.ActivityServices.Interfaces.dll
IF EXIST %TargetDir%\BIN\MetraTech.ActivityServices.Interfaces.pdb del /F %TargetDir%\BIN\MetraTech.ActivityServices.Interfaces.pdb

IF EXIST %TargetDir%\Config\Workflow rd /S /Q %TargetDir%\Config\Workflow
IF EXIST %TargetDir%\Extensions\Account\config\AccountView\myadapter.com rd /S /Q %TargetDir%\Extensions\Account\config\AccountView\myadapter.com
IF EXIST %TargetDir%\UI\MAM\default\localized\us\help rd /S /Q %TargetDir%\UI\MAM\default\localized\us\help
IF EXIST %TargetDir%\UI\MCM\default\localized\us\Help rd /S /Q %TargetDir%\UI\MCM\default\localized\us\Help
IF EXIST %TargetDir%\UI\MetraCare\Account\AddAccountContact.aspx del /F %TargetDir%\UI\MetraCare\Account\AddAccountContact.aspx
IF EXIST %TargetDir%\UI\MetraCare\Account\AddAccountContact.aspx.cs del /F %TargetDir%\UI\MetraCare\Account\AddAccountContact.aspx.cs
IF EXIST %TargetDir%\UI\MetraCare\Account\AddAccountSummary.aspx del /F %TargetDir%\UI\MetraCare\Account\AddAccountSummary.aspx
IF EXIST %TargetDir%\UI\MetraCare\Account\AddAccountSummary.aspx.cs del /F %TargetDir%\UI\MetraCare\Account\AddAccountSummary.aspx.cs
IF EXIST %TargetDir%\UI\MetraCare\Account\SystemUserAccountSummary.aspx del /F %TargetDir%\UI\MetraCare\Account\SystemUserAccountSummary.aspx
IF EXIST %TargetDir%\UI\MetraCare\Account\SystemUserAccountSummary.aspx.cs del /F %TargetDir%\UI\MetraCare\Account\SystemUserAccountSummary.aspx.cs
IF EXIST %TargetDir%\UI\MetraCare\App_GlobalResources\MainMenu.fr.resx del /F %TargetDir%\UI\MetraCare\App_GlobalResources\MainMenu.fr.resx
IF EXIST %TargetDir%\UI\MetraCare\App_GlobalResources\Resource.ar.resx del /F %TargetDir%\UI\MetraCare\App_GlobalResources\Resource.ar.resx
IF EXIST %TargetDir%\UI\MetraCare\App_GlobalResources\Resource.fr.resx del /F %TargetDir%\UI\MetraCare\App_GlobalResources\Resource.fr.resx
IF EXIST %TargetDir%\UI\MetraCare\App_LocalResources\LocaleTest.aspx.fr.resx del /F %TargetDir%\UI\MetraCare\App_LocalResources\LocaleTest.aspx.fr.resx
IF EXIST %TargetDir%\UI\MetraCare\App_LocalResources\LocaleTest.aspx.resx del /F %TargetDir%\UI\MetraCare\App_LocalResources\LocaleTest.aspx.resx
IF EXIST %TargetDir%\UI\MetraCare\App_LocalResources\UIPText.resx del /F %TargetDir%\UI\MetraCare\App_LocalResources\UIPText.resx
IF EXIST %TargetDir%\UI\MetraCare\Aptana rd /S /Q %TargetDir%\UI\MetraCare\Aptana
IF EXIST %TargetDir%\UI\MetraCare\Config\AppConfig.xml del /F %TargetDir%\UI\MetraCare\Config\AppConfig.xml
IF EXIST %TargetDir%\UI\MetraCare\bin\MetraTech.ActivityServices.Interfaces.dll del /F %TargetDir%\UI\MetraCare\bin\MetraTech.ActivityServices.Interfaces.dll
IF EXIST %TargetDir%\UI\MetraCare\bin\MetraTech.ActivityServices.Interfaces.pdb del /F %TargetDir%\UI\MetraCare\bin\MetraTech.ActivityServices.Interfaces.pdb
IF EXIST %TargetDir%\UI\MetraCare\EMailTemplate rd /S /Q %TargetDir%\UI\MetraCare\EMailTemplate
IF EXIST %TargetDir%\UI\MetraCare\Ext rd /S /Q %TargetDir%\UI\MetraCare\Ext
IF EXIST %TargetDir%\UI\MetraCare\Images\login rd /S /Q %TargetDir%\UI\MetraCare\Images\login
IF EXIST %TargetDir%\UI\MetraCare\JavaScript\OnReadyHack.js del /F %TargetDir%\UI\MetraCare\JavaScript\OnReadyHack.js
IF EXIST %TargetDir%\UI\MetraCare\Templates rd /S /Q %TargetDir%\UI\MetraCare\Templates
IF EXIST %TargetDir%\UI\MetraCareHelp\en-us rd /S /Q %TargetDir%\UI\MetraCareHelp\en-us
IF EXIST %TargetDir%\UI\MOM\default\localized\us\help rd /S /Q %TargetDir%\UI\MOM\default\localized\us\help

REM Apply modified files
Copy /Y %SrcDir%\Bin %TargetDir%\Bin
Copy /Y %SrcDir%\Config\EmailTemplate\AddAccountEmailNotificationTemplate.xml %TargetDir%\Config\EmailTemplate\AddAccountEmailNotificationTemplate.xml
Copy /Y %SrcDir%\Config\Queries\AccHierarchies\CommonQueries.xml %TargetDir%\Config\Queries\AccHierarchies\CommonQueries.xml
Copy /Y %SrcDir%\Config\Queries\Account\MTAccountViewQueries.xml %TargetDir%\Config\Queries\Account\MTAccountViewQueries.xml
Copy /Y %SrcDir%\Config\Queries\Account\MTAccountViewQueries_Oracle.xml %TargetDir%\Config\Queries\Account\MTAccountViewQueries_Oracle.xml
Copy /Y %SrcDir%\Config\Queries\AccountCreation\CommonQueries.xml %TargetDir%\Config\Queries\AccountCreation\CommonQueries.xml
Copy /Y %SrcDir%\Config\Queries\AccountCreation\MTPresServer.xml %TargetDir%\Config\Queries\AccountCreation\MTPresServer.xml
Copy /Y %SrcDir%\Config\Queries\AccountCreation\MTPresServer_Oracle.xml %TargetDir%\Config\Queries\AccountCreation\MTPresServer_Oracle.xml
Copy /Y %SrcDir%\Config\Queries\Database\MTSQLServer.xml %TargetDir%\Config\Queries\Database\MTSQLServer.xml
Copy /Y %SrcDir%\Config\Queries\DBInstall\AccHierarchies\Queries.xml %TargetDir%\Config\Queries\DBInstall\AccHierarchies\Queries.xml
Copy /Y %SrcDir%\Config\Queries\DBInstall\AccHierarchies\Queries_Oracle.xml %TargetDir%\Config\Queries\DBInstall\AccHierarchies\Queries_Oracle.xml
Copy /Y %SrcDir%\Config\Queries\DBInstall\ActivityServices\MTDBObjects.xml %TargetDir%\Config\Queries\DBInstall\ActivityServices\MTDBObjects.xml
Copy /Y %SrcDir%\Config\Queries\DBInstall\ActivityServices\MTDBObjects_Oracle.xml %TargetDir%\Config\Queries\DBInstall\ActivityServices\MTDBObjects_Oracle.xml
Copy /Y %SrcDir%\Config\Queries\DBInstall\ActivityServices\Queries.xml %TargetDir%\Config\Queries\DBInstall\ActivityServices\Queries.xml
Copy /Y %SrcDir%\Config\Queries\DBInstall\ActivityServices\Queries_Oracle.xml %TargetDir%\Config\Queries\DBInstall\ActivityServices\Queries_Oracle.xml
Copy /Y %SrcDir%\Config\Queries\DBInstall\MetraPay\MTDBObjects.xml %TargetDir%\Config\Queries\DBInstall\MetraPay\MTDBObjects.xml
Copy /Y %SrcDir%\Config\Queries\DBInstall\MetraPay\MTDBObjects_Oracle.xml %TargetDir%\Config\Queries\DBInstall\MetraPay\MTDBObjects_Oracle.xml
Copy /Y %SrcDir%\Config\Queries\DBInstall\MetraPay\Payment_uninstall.xml %TargetDir%\Config\Queries\DBInstall\MetraPay\Payment_uninstall.xml
Copy /Y %SrcDir%\Config\Queries\DBInstall\MetraPay\Queries.xml %TargetDir%\Config\Queries\DBInstall\MetraPay\Queries.xml
Copy /Y %SrcDir%\Config\Queries\DBInstall\MetraPay\Queries_Oracle.xml %TargetDir%\Config\Queries\DBInstall\MetraPay\Queries_Oracle.xml
Copy /Y %SrcDir%\Config\Queries\DBInstall\Pipeline\Queries_Oracle.xml %TargetDir%\Config\Queries\DBInstall\Pipeline\Queries_Oracle.xml 
Copy /Y %SrcDir%\Config\Queries\DBInstall\ProductCatalog\Queries.xml %TargetDir%\Config\Queries\DBInstall\ProductCatalog\Queries.xml 
Copy /Y %SrcDir%\Config\Queries\DBInstall\ProductCatalog\Queries_Oracle.xml %TargetDir%\Config\Queries\DBInstall\ProductCatalog\Queries_Oracle.xml 
Copy /Y %SrcDir%\Config\Queries\DBInstall\views\views.xml %TargetDir%\Config\Queries\DBInstall\views\views.xml 
Copy /Y %SrcDir%\Config\Queries\DBInstall\views\views_Oracle.xml %TargetDir%\Config\Queries\DBInstall\views\views_Oracle.xml 
Copy /Y %SrcDir%\Config\Queries\DBInstall\MTDBObjects.xml %TargetDir%\Config\Queries\DBInstall\MTDBObjects.xml 
Copy /Y %SrcDir%\Config\Queries\DBInstall\MTDBObjects_Oracle.xml %TargetDir%\Config\Queries\DBInstall\MTDBObjects_Oracle.xml 
Copy /Y %SrcDir%\Config\Queries\DBInstall\Queries.xml %TargetDir%\Config\Queries\DBInstall\Queries.xml 
Copy /Y %SrcDir%\Config\Queries\DBInstall\Queries_Oracle.xml %TargetDir%\Config\Queries\DBInstall\Queries_Oracle.xml 
Copy /Y %SrcDir%\Config\Queries\ElectronicPaymentService\CommonQueries.xml %TargetDir%\Config\Queries\ElectronicPaymentService\CommonQueries.xml 
Copy /Y %SrcDir%\Config\Queries\ElectronicPaymentService\QueriesOracle.xml %TargetDir%\Config\Queries\ElectronicPaymentService\QueriesOracle.xml 
Copy /Y %SrcDir%\Config\Queries\ElectronicPaymentService\QueriesSQL.xml %TargetDir%\Config\Queries\ElectronicPaymentService\QueriesSQL.xml 
Copy /Y %SrcDir%\Config\Queries\MaterializedViews\Samples\MetraViewQueries_Oracle.xml %TargetDir%\Config\Queries\MaterializedViews\Samples\MetraViewQueries_Oracle.xml 
Copy /Y %SrcDir%\Config\Queries\MaterializedViews\MTMaterializedViewQueries_Oracle.xml %TargetDir%\Config\Queries\MaterializedViews\MTMaterializedViewQueries_Oracle.xml 
Copy /Y %SrcDir%\Config\Queries\PresServer\CommonQueries.xml %TargetDir%\Config\Queries\PresServer\CommonQueries.xml 
Copy /Y %SrcDir%\Config\Queries\ProductCatalog\CommonQueries.xml %TargetDir%\Config\Queries\ProductCatalog\CommonQueries.xml 
Copy /Y %SrcDir%\Config\Queries\ProductCatalog\Oracle.xml %TargetDir%\Config\Queries\ProductCatalog\Oracle.xml 
Copy /Y %SrcDir%\Config\Queries\ProductCatalog\SQLServer.xml %TargetDir%\Config\Queries\ProductCatalog\SQLServer.xml 
Copy /Y %SrcDir%\Config\Queries\Security\MTSecurityQueries_Common.xml %TargetDir%\Config\Queries\Security\MTSecurityQueries_Common.xml 
Copy /Y %SrcDir%\Config\Queries\ServiceDef\MTServiceDefQueries.xml %TargetDir%\Config\Queries\ServiceDef\MTServiceDefQueries.xml 
Copy /Y %SrcDir%\Config\Queries\ServiceDef\MTServiceDefQueries_Oracle.xml %TargetDir%\Config\Queries\ServiceDef\MTServiceDefQueries_Oracle.xml 
Copy /Y %SrcDir%\Config\Queries\UsageServer\Test\CommonQueries.xml %TargetDir%\Config\Queries\UsageServer\Test\CommonQueries.xml 
Copy /Y %SrcDir%\Extensions\Account\config\ActivityServices\AccountCreation.xml %TargetDir%\Extensions\Account\config\ActivityServices\AccountCreation.xml 
Copy /Y %SrcDir%\Extensions\Account\config\Service\metratech.com\SystemAccountCreation.msixdef %TargetDir%\Extensions\Account\config\Service\metratech.com\SystemAccountCreation.msixdef 
Copy /Y %SrcDir%\Extensions\Core\config\AuditEvents\auditevents.xml %TargetDir%\Extensions\Core\config\AuditEvents\auditevents.xml 
Copy /Y %SrcDir%\Extensions\Core\config\EnumType\metratech.com\metratech.com.xml %TargetDir%\Extensions\Core\config\EnumType\metratech.com\metratech.com.xml 
Copy /Y %SrcDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_auditevents_cn.xml %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_auditevents_cn.xml 
Copy /Y %SrcDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_auditevents_de.xml %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_auditevents_de.xml 
Copy /Y %SrcDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_auditevents_us.xml %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_auditevents_us.xml 
Copy /Y %SrcDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_us.xml %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_us.xml 
Copy /Y %SrcDir%\Extensions\Core\config\PageLayouts\ControlTypes.xml %TargetDir%\Extensions\Core\config\PageLayouts\ControlTypes.xml 
Copy /Y %SrcDir%\Extensions\Core\config\PageLayouts\DataTypes.xml %TargetDir%\Extensions\Core\config\PageLayouts\DataTypes.xml 
Copy /Y %SrcDir%\Extensions\Core\config\PageLayouts\ValidatorTypes.xml %TargetDir%\Extensions\Core\config\PageLayouts\ValidatorTypes.xml 
Copy /Y %SrcDir%\Extensions\Core\config\PageLayouts\*.png %TargetDir%\Extensions\Core\config\PageLayouts\
Copy /Y %SrcDir%\Extensions\Core\config\ParamTable\metratech.com\Calendar.msixdef %TargetDir%\Extensions\Core\config\ParamTable\metratech.com\Calendar.msixdef 
Copy /Y %SrcDir%\Extensions\Core\config\ParamTable\metratech.com\FlatDiscount.msixdef %TargetDir%\Extensions\Core\config\ParamTable\metratech.com\FlatDiscount.msixdef 
Copy /Y %SrcDir%\Extensions\Core\config\ParamTable\metratech.com\FlatDiscount_NoCond.msixdef %TargetDir%\Extensions\Core\config\ParamTable\metratech.com\FlatDiscount_NoCond.msixdef 
Copy /Y %SrcDir%\Extensions\Core\config\ParamTable\metratech.com\FlatRecurringCharge.msixdef %TargetDir%\Extensions\Core\config\ParamTable\metratech.com\FlatRecurringCharge.msixdef 
Copy /Y %SrcDir%\Extensions\Core\config\ParamTable\metratech.com\NonRecurringCharge.msixdef %TargetDir%\Extensions\Core\config\ParamTable\metratech.com\NonRecurringCharge.msixdef 
Copy /Y %SrcDir%\Extensions\Core\config\ParamTable\metratech.com\PercentDiscount.msixdef %TargetDir%\Extensions\Core\config\ParamTable\metratech.com\PercentDiscount.msixdef 
Copy /Y %SrcDir%\Extensions\Core\config\ParamTable\metratech.com\PercentDiscount_NoCond.msixdef %TargetDir%\Extensions\Core\config\ParamTable\metratech.com\PercentDiscount_NoCond.msixdef 
Copy /Y %SrcDir%\Extensions\Core\config\ParamTable\metratech.com\UDRCTapered.msixdef %TargetDir%\Extensions\Core\config\ParamTable\metratech.com\UDRCTapered.msixdef 
Copy /Y %SrcDir%\Extensions\Core\config\ParamTable\metratech.com\UDRCTiered.msixdef %TargetDir%\Extensions\Core\config\ParamTable\metratech.com\UDRCTiered.msixdef 
Copy /Y %SrcDir%\Extensions\Core\config\Pipeline\BalanceAdjustments\stage.xml %TargetDir%\Extensions\Core\config\Pipeline\BalanceAdjustments\stage.xml 
Copy /Y %SrcDir%\Extensions\Core\config\Service\metratech.com\AddCharge.msixdef %TargetDir%\Extensions\Core\config\Service\metratech.com\AddCharge.msixdef 
Copy /Y %SrcDir%\Extensions\Core\config\Service\metratech.com\TestService.msixdef %TargetDir%\Extensions\Core\config\Service\metratech.com\TestService.msixdef 
Copy /Y %SrcDir%\Extensions\PageNav\Config\ActivityServices\AddAccountInterfaces.xml %TargetDir%\Extensions\PageNav\Config\ActivityServices\AddAccountInterfaces.xml 
Copy /Y %SrcDir%\Extensions\PageNav\Config\ActivityServices\ContactUpdateInterfaces.xml %TargetDir%\Extensions\PageNav\Config\ActivityServices\ContactUpdateInterfaces.xml 
Copy /Y %SrcDir%\Extensions\PageNav\Config\ActivityServices\SubscriptionsInterfaces.xml %TargetDir%\Extensions\PageNav\Config\ActivityServices\SubscriptionsInterfaces.xml 
Copy /Y %SrcDir%\Extensions\PageNav\Config\ActivityServices\UpdateAccountInterfaces.xml %TargetDir%\Extensions\PageNav\Config\ActivityServices\UpdateAccountInterfaces.xml 
Copy /Y %SrcDir%\Extensions\PaymentSvr\config\PaymentServer\Queries.xml %TargetDir%\Extensions\PaymentSvr\config\PaymentServer\Queries.xml 
Copy /Y %SrcDir%\Extensions\PaymentSvr\config\PaymentServer\Queries_Oracle.xml %TargetDir%\Extensions\PaymentSvr\config\PaymentServer\Queries_Oracle.xml 
Copy /Y %SrcDir%\Extensions\PaymentSvr\config\paymentserverAsp\Queries.xml %TargetDir%\Extensions\PaymentSvr\config\paymentserverAsp\Queries.xml 
Copy /Y %SrcDir%\Extensions\PaymentSvrClient\config\enumtype\metratech.com\metratech.com_paymentserver.xml %TargetDir%\Extensions\PaymentSvrClient\config\enumtype\metratech.com\metratech.com_paymentserver.xml 
Copy /Y %SrcDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_paymentserver_de.xml %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_paymentserver_de.xml 
Copy /Y %SrcDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_paymentserver_fr.xml %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_paymentserver_fr.xml 
Copy /Y %SrcDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_paymentserver_it.xml %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_paymentserver_it.xml 
Copy /Y %SrcDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_paymentserver_jp.xml %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_paymentserver_jp.xml 
Copy /Y %SrcDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_paymentserver_us.xml %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_paymentserver_us.xml 
Copy /Y %SrcDir%\Extensions\Reporting\Config\Queries\PopulateQueries.xml %TargetDir%\Extensions\Reporting\Config\Queries\PopulateQueries.xml 
Copy /Y %SrcDir%\Extensions\Reporting\Config\Templates\Invoice.rpt %TargetDir%\Extensions\Reporting\Config\Templates\Invoice.rpt
Copy /Y %SrcDir%\Extensions\Reporting\Config\Templates\Invoice_Jpn.rpt %TargetDir%\Extensions\Reporting\Config\Templates\Invoice_Jpn.rpt
Copy /Y %SrcDir%\Extensions\Reporting\Config\Templates\InvoiceOracle.rpt %TargetDir%\Extensions\Reporting\Config\Templates\InvoiceOracle.rpt
Copy /Y %SrcDir%\Extensions\Reporting\Config\Templates\InvoiceOracle_Jpn.rpt %TargetDir%\Extensions\Reporting\Config\Templates\InvoiceOracle_Jpn.rpt
Copy /Y %SrcDir%\Extensions\Reporting\WebService\MetraTech.Reports.WebService.dll %TargetDir%\Extensions\Reporting\WebService\MetraTech.Reports.WebService.dll 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\siteconfig\de\TextLookUp\LocalizedText.xml %TargetDir%\Extensions\SampleSite\MPS\siteconfig\de\TextLookUp\LocalizedText.xml 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\siteconfig\fr\TextLookUp\LocalizedText.xml %TargetDir%\Extensions\SampleSite\MPS\siteconfig\fr\TextLookUp\LocalizedText.xml 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\siteconfig\it\TextLookUp\LocalizedText.xml %TargetDir%\Extensions\SampleSite\MPS\siteconfig\it\TextLookUp\LocalizedText.xml 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\siteconfig\jp\TextLookUp\LocalizedText.xml %TargetDir%\Extensions\SampleSite\MPS\siteconfig\jp\TextLookUp\LocalizedText.xml 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\siteconfig\us\TextLookUp\LocalizedText.xml %TargetDir%\Extensions\SampleSite\MPS\siteconfig\us\TextLookUp\LocalizedText.xml 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\siteconfig\Validation.xml %TargetDir%\Extensions\SampleSite\MPS\siteconfig\Validation.xml 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\de\styles\styles.css %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\de\styles\styles.css 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\de\displayPDF.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\de\displayPDF.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\de\login.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\de\login.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\de\options.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\de\options.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\de\optionsPaymentCreditCard.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\de\optionsPaymentCreditCard.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\de\optionsPaymentMethods.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\de\optionsPaymentMethods.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\de\SelectStaticReport.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\de\SelectStaticReport.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\de\showpdf.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\de\showpdf.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\de\ticketToMAM.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\de\ticketToMAM.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\fr\styles\styles.css %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\fr\styles\styles.css 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\fr\displayPDF.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\fr\displayPDF.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\fr\login.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\fr\login.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\fr\options.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\fr\options.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\fr\optionsPaymentCreditCard.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\fr\optionsPaymentCreditCard.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\fr\optionsPaymentMethods.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\fr\optionsPaymentMethods.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\fr\SelectStaticReport.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\fr\SelectStaticReport.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\fr\showpdf.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\fr\showpdf.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\fr\ticketToMAM.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\fr\ticketToMAM.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\include\psdefs.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\include\psdefs.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\include\utilSite.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\include\utilSite.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\it\styles\styles.css %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\it\styles\styles.css 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\it\displayPDF.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\it\displayPDF.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\it\login.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\it\login.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\it\options.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\it\options.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\it\optionsPaymentCreditCard.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\it\optionsPaymentCreditCard.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\it\optionsPaymentMethods.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\it\optionsPaymentMethods.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\it\SelectStaticReport.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\it\SelectStaticReport.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\it\showpdf.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\it\showpdf.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\it\ticketToMAM.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\it\ticketToMAM.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\jp\styles\styles.css %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\jp\styles\styles.css 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\jp\displayPDF.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\jp\displayPDF.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\jp\login.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\jp\login.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\jp\options.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\jp\options.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\jp\optionsPaymentCreditCard.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\jp\optionsPaymentCreditCard.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\jp\optionsPaymentMethods.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\jp\optionsPaymentMethods.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\jp\SelectStaticReport.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\jp\SelectStaticReport.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\jp\showpdf.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\jp\showpdf.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\jp\ticketToMAM.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\jp\ticketToMAM.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\us\styles\styles.css %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\us\styles\styles.css 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\us\displayPDF.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\us\displayPDF.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\us\login.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\us\login.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\us\options.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\us\options.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\us\optionsPaymentCreditCard.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\us\optionsPaymentCreditCard.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\us\optionsPaymentMethods.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\us\optionsPaymentMethods.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\us\SelectStaticReport.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\us\SelectStaticReport.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\us\showpdf.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\us\showpdf.asp 
Copy /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\main.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\main.asp 
Copy /Y %SrcDir%\Install\Scripts\Common.vbs %TargetDir%\Install\Scripts\Common.vbs 
Copy /Y %SrcDir%\Install\Scripts\COMPlus.vbs %TargetDir%\Install\Scripts\COMPlus.vbs 
Copy /Y %SrcDir%\Install\Scripts\Database.vbs %TargetDir%\Install\Scripts\Database.vbs 
Copy /Y %SrcDir%\Install\Scripts\Registry.vbs %TargetDir%\Install\Scripts\Registry.vbs 
Copy /Y %SrcDir%\Install\Scripts\staging.mak %TargetDir%\Install\Scripts\staging.mak 
Copy /Y %SrcDir%\Test\Database\billingrerun.vbs %TargetDir%\Test\Database\billingrerun.vbs 
XCOPY /E /V /H /Y /Z %SrcDir%\UI\ImageHandler\bin\* %TargetDir%\UI\ImageHandler\bin
Copy /Y %SrcDir%\UI\MAM\default\dialog\capabilities\CapabilityEditor.asp %TargetDir%\UI\MAM\default\dialog\capabilities\CapabilityEditor.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\capabilities\OwnedAccountsCapability.asp %TargetDir%\UI\MAM\default\dialog\capabilities\OwnedAccountsCapability.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\capabilities\SalesForceCapability.asp %TargetDir%\UI\MAM\default\dialog\capabilities\SalesForceCapability.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\js\dragdrop.js %TargetDir%\UI\MAM\default\dialog\js\dragdrop.js 
Copy /Y %SrcDir%\UI\MAM\default\dialog\SubTemplate\AccountTemplate.Properties.htm  %TargetDir%\UI\MAM\default\dialog\SubTemplate\AccountTemplate.Properties.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\SubTemplate\Subscriber.AccountInformation.AccountStatus.htm  %TargetDir%\UI\MAM\default\dialog\SubTemplate\Subscriber.AccountInformation.AccountStatus.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\SubTemplate\Subscriber.AccountInformation.Payer.htm  %TargetDir%\UI\MAM\default\dialog\SubTemplate\Subscriber.AccountInformation.Payer.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\SubTemplate\Subscriber.LoginInformation.htm  %TargetDir%\UI\MAM\default\dialog\SubTemplate\Subscriber.LoginInformation.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\AccountTemplate.ApplyToMultiMovedAccount.asp %TargetDir%\UI\MAM\default\dialog\AccountTemplate.ApplyToMultiMovedAccount.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\AccountTemplate.Edit.asp %TargetDir%\UI\MAM\default\dialog\AccountTemplate.Edit.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\AccountTemplate.Edit.Generic.asp %TargetDir%\UI\MAM\default\dialog\AccountTemplate.Edit.Generic.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\AccountTemplate.Selector.asp %TargetDir%\UI\MAM\default\dialog\AccountTemplate.Selector.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\BulkAdjustment.Edit.asp %TargetDir%\UI\MAM\default\dialog\BulkAdjustment.Edit.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\BulkRebill.Edit.asp %TargetDir%\UI\MAM\default\dialog\BulkRebill.Edit.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\ChargeAccountUpdate.htm  %TargetDir%\UI\MAM\default\dialog\ChargeAccountUpdate.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\DefaultDialogAccountSummary.htm  %TargetDir%\UI\MAM\default\dialog\DefaultDialogAccountSummary.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\DefaultDialogAdvancedFind.htm  %TargetDir%\UI\MAM\default\dialog\DefaultDialogAdvancedFind.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\DefaultDialogLogin.asp %TargetDir%\UI\MAM\default\dialog\DefaultDialogLogin.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\DefaultDialogLogin.htm  %TargetDir%\UI\MAM\default\dialog\DefaultDialogLogin.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\DefaultDialogSubscription.asp %TargetDir%\UI\MAM\default\dialog\DefaultDialogSubscription.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\DefaultDialogSubscription.htm  %TargetDir%\UI\MAM\default\dialog\DefaultDialogSubscription.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\ErrorResolutionRoadmap.asp %TargetDir%\UI\MAM\default\dialog\ErrorResolutionRoadmap.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\FindAccountPopup.htm  %TargetDir%\UI\MAM\default\dialog\FindAccountPopup.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\FolderOwnerAdd.asp %TargetDir%\UI\MAM\default\dialog\FolderOwnerAdd.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\FolderOwnerAdd.htm  %TargetDir%\UI\MAM\default\dialog\FolderOwnerAdd.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\FolderOwnerUpdate.htm  %TargetDir%\UI\MAM\default\dialog\FolderOwnerUpdate.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\GroupAdd.asp %TargetDir%\UI\MAM\default\dialog\GroupAdd.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\GroupAdd.htm  %TargetDir%\UI\MAM\default\dialog\GroupAdd.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\GroupMemberAdd.asp %TargetDir%\UI\MAM\default\dialog\GroupMemberAdd.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\GroupMemberAdd.htm  %TargetDir%\UI\MAM\default\dialog\GroupMemberAdd.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\GroupMemberRemove.asp %TargetDir%\UI\MAM\default\dialog\GroupMemberRemove.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\GroupMemberRemove.htm  %TargetDir%\UI\MAM\default\dialog\GroupMemberRemove.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\HierarchyMoveDate.asp %TargetDir%\UI\MAM\default\dialog\HierarchyMoveDate.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\HierarchyMoveDate.htm  %TargetDir%\UI\MAM\default\dialog\HierarchyMoveDate.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\ManageRoles.asp %TargetDir%\UI\MAM\default\dialog\ManageRoles.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\ManageSecurity.htm  %TargetDir%\UI\MAM\default\dialog\ManageSecurity.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\MetraTech.Accounts.Hierarchy.ClientControl.dll %TargetDir%\UI\MAM\default\dialog\MetraTech.Accounts.Hierarchy.ClientControl.dll 
Copy /Y %SrcDir%\UI\MAM\default\dialog\MetraTech.Accounts.Hierarchy.ClientControl.pdb %TargetDir%\UI\MAM\default\dialog\MetraTech.Accounts.Hierarchy.ClientControl.pdb 
Copy /Y %SrcDir%\UI\MAM\default\dialog\OwnedAdd.asp %TargetDir%\UI\MAM\default\dialog\OwnedAdd.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\OwnedAdd.htm %TargetDir%\UI\MAM\default\dialog\OwnedAdd.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\OwnedDeleteBatch.asp %TargetDir%\UI\MAM\default\dialog\OwnedDeleteBatch.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\OwnerAdd.asp %TargetDir%\UI\MAM\default\dialog\OwnerAdd.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\OwnerAdd.htm  %TargetDir%\UI\MAM\default\dialog\OwnerAdd.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\PayerAdd.asp %TargetDir%\UI\MAM\default\dialog\PayerAdd.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\PayerAdd.htm  %TargetDir%\UI\MAM\default\dialog\PayerAdd.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\PayerUpdate.htm  %TargetDir%\UI\MAM\default\dialog\PayerUpdate.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\Rates.RateSchedule.List.asp %TargetDir%\UI\MAM\default\dialog\Rates.RateSchedule.List.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\RoleMemberAdd.asp %TargetDir%\UI\MAM\default\dialog\RoleMemberAdd.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\RoleMemberAdd.htm  %TargetDir%\UI\MAM\default\dialog\RoleMemberAdd.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\SystemUserFind.htm  %TargetDir%\UI\MAM\default\dialog\SystemUserFind.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\SystemUserHierarchyMoveDate.asp %TargetDir%\UI\MAM\default\dialog\SystemUserHierarchyMoveDate.asp 
Copy /Y %SrcDir%\UI\MAM\default\dialog\SystemUserHierarchyMoveDate.htm  %TargetDir%\UI\MAM\default\dialog\SystemUserHierarchyMoveDate.htm  
Copy /Y %SrcDir%\UI\MAM\default\dialog\webservice.htc %TargetDir%\UI\MAM\default\dialog\webservice.htc 
Copy /Y %SrcDir%\UI\MAM\default\Lib\CAccountTemplateHelper.asp %TargetDir%\UI\MAM\default\Lib\CAccountTemplateHelper.asp 
Copy /Y %SrcDir%\UI\MAM\default\Lib\CAdjustmentHelper.asp %TargetDir%\UI\MAM\default\Lib\CAdjustmentHelper.asp 
Copy /Y %SrcDir%\UI\MAM\default\Lib\CReBillHelper.asp %TargetDir%\UI\MAM\default\Lib\CReBillHelper.asp 
Copy /Y %SrcDir%\UI\MAM\default\Lib\DropAccountsLib.asp %TargetDir%\UI\MAM\default\Lib\DropAccountsLib.asp 
Copy /Y %SrcDir%\UI\MAM\default\Lib\MamLibrary.asp %TargetDir%\UI\MAM\default\Lib\MamLibrary.asp 
Copy /Y %SrcDir%\UI\MAM\default\LinkLookUp\GlobalLinks.xml %TargetDir%\UI\MAM\default\LinkLookUp\GlobalLinks.xml 
Copy /Y %SrcDir%\UI\MAM\default\LinkLookUp\MainMenuLinks.xml %TargetDir%\UI\MAM\default\LinkLookUp\MainMenuLinks.xml 
Copy /Y %SrcDir%\UI\MAM\default\localized\us\styles\Grid.css %TargetDir%\UI\MAM\default\localized\us\styles\Grid.css 
Copy /Y %SrcDir%\UI\MAM\default\localized\us\styles\ListTabs.css %TargetDir%\UI\MAM\default\localized\us\styles\ListTabs.css 
Copy /Y %SrcDir%\UI\MAM\default\localized\us\styles\styles.css %TargetDir%\UI\MAM\default\localized\us\styles\styles.css 
Copy /Y %SrcDir%\UI\MAM\default\localized\us\TextLookUp\CSR.xml %TargetDir%\UI\MAM\default\localized\us\TextLookUp\CSR.xml 
Copy /Y %SrcDir%\UI\MAM\default\localized\us\TextLookUp\LocaleInformation.xml %TargetDir%\UI\MAM\default\localized\us\TextLookUp\LocaleInformation.xml 
Copy /Y %SrcDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedAccountHierarhcy.xml %TargetDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedAccountHierarhcy.xml 
Copy /Y %SrcDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedAuditMessages.xml %TargetDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedAuditMessages.xml 
Copy /Y %SrcDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedEffectiveDateErrors.xml %TargetDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedEffectiveDateErrors.xml 
Copy /Y %SrcDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedErrorResolutionRoadmap.xml %TargetDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedErrorResolutionRoadmap.xml 
Copy /Y %SrcDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedErrors.xml %TargetDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedErrors.xml 
Copy /Y %SrcDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedKeyTerms.xml %TargetDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedKeyTerms.xml 
Copy /Y %SrcDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedMPTETexts.xml %TargetDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedMPTETexts.xml 
Copy /Y %SrcDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedPaymentMethodsConst.xml %TargetDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedPaymentMethodsConst.xml 
Copy /Y %SrcDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedServiceEndpoints.xml %TargetDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedServiceEndpoints.xml 
Copy /Y %SrcDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedSystemUsers.xml %TargetDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedSystemUsers.xml 
Copy /Y %SrcDir%\UI\MAM\default.htm  %TargetDir%\UI\MAM\default.htm  
Copy /Y %SrcDir%\UI\MAM\default.html %TargetDir%\UI\MAM\default.html 
Copy /Y %SrcDir%\UI\MAM\EntryPoint.asp %TargetDir%\UI\MAM\EntryPoint.asp 
Copy /Y %SrcDir%\UI\MAM\global.asa %TargetDir%\UI\MAM\global.asa 
Copy /Y %SrcDir%\UI\MCM\default\dialog\wizard\AddDiscount\WizardEnd.asp %TargetDir%\UI\MCM\default\dialog\wizard\AddDiscount\WizardEnd.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\wizard\AddDiscount\WizardStart.asp %TargetDir%\UI\MCM\default\dialog\wizard\AddDiscount\WizardStart.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\wizard\AddNonRecurringCharge\WizardEnd.asp %TargetDir%\UI\MCM\default\dialog\wizard\AddNonRecurringCharge\WizardEnd.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\wizard\AddNonRecurringCharge\WizardStart.asp %TargetDir%\UI\MCM\default\dialog\wizard\AddNonRecurringCharge\WizardStart.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\wizard\AddRecurringCharge\WizardEnd.asp %TargetDir%\UI\MCM\default\dialog\wizard\AddRecurringCharge\WizardEnd.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\wizard\AddRecurringCharge\WizardInclude.asp %TargetDir%\UI\MCM\default\dialog\wizard\AddRecurringCharge\WizardInclude.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\wizard\AddRecurringCharge\WizardStart.asp %TargetDir%\UI\MCM\default\dialog\wizard\AddRecurringCharge\WizardStart.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\wizard\CreateCounterParameter\WizardInclude.asp %TargetDir%\UI\MCM\default\dialog\wizard\CreateCounterParameter\WizardInclude.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\wizard\CreatePO\WizardEnd.asp %TargetDir%\UI\MCM\default\dialog\wizard\CreatePO\WizardEnd.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\wizard\CreatePO\WizardInclude.asp %TargetDir%\UI\MCM\default\dialog\wizard\CreatePO\WizardInclude.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\wizard\CreatePO\WizardStart.asp %TargetDir%\UI\MCM\default\dialog\wizard\CreatePO\WizardStart.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\wizard\CreatePriceList\WizardStart.asp %TargetDir%\UI\MCM\default\dialog\wizard\CreatePriceList\WizardStart.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\wizard\CreateRateSchedule\WizardStart.asp %TargetDir%\UI\MCM\default\dialog\wizard\CreateRateSchedule\WizardStart.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\Adjustment.Instances.Edit.asp %TargetDir%\UI\MCM\default\dialog\Adjustment.Instances.Edit.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\Adjustment.Template.Edit.htm  %TargetDir%\UI\MCM\default\dialog\Adjustment.Template.Edit.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\Adjustment.Templates.Edit.asp %TargetDir%\UI\MCM\default\dialog\Adjustment.Templates.Edit.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\Adjustment.Templates.Edit.htm  %TargetDir%\UI\MCM\default\dialog\Adjustment.Templates.Edit.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\AuditLog.List.asp %TargetDir%\UI\MCM\default\dialog\AuditLog.List.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\AuditLog.List.htm  %TargetDir%\UI\MCM\default\dialog\AuditLog.List.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\BulkSubscription.Change.asp %TargetDir%\UI\MCM\default\dialog\BulkSubscription.Change.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\Calendars.List.htm  %TargetDir%\UI\MCM\default\dialog\Calendars.List.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\Counter.List.htm  %TargetDir%\UI\MCM\default\dialog\Counter.List.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\Discount.ViewEdit.htm  %TargetDir%\UI\MCM\default\dialog\Discount.ViewEdit.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\Discounts.List.htm  %TargetDir%\UI\MCM\default\dialog\Discounts.List.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\Header.asp %TargetDir%\UI\MCM\default\dialog\Header.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\Login.htm  %TargetDir%\UI\MCM\default\dialog\Login.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\ManageDiscountCounters.htm  %TargetDir%\UI\MCM\default\dialog\ManageDiscountCounters.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\PriceableItem.Discount.Edit.htm  %TargetDir%\UI\MCM\default\dialog\PriceableItem.Discount.Edit.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\PriceableItem.Discount.ViewEdit.htm  %TargetDir%\UI\MCM\default\dialog\PriceableItem.Discount.ViewEdit.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\PriceAbleItem.NonRecurring.Edit.htm  %TargetDir%\UI\MCM\default\dialog\PriceAbleItem.NonRecurring.Edit.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\PriceAbleItem.NonRecurring.ViewEdit.htm  %TargetDir%\UI\MCM\default\dialog\PriceAbleItem.NonRecurring.ViewEdit.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\PriceAbleItem.RecurringCharge.Edit.htm  %TargetDir%\UI\MCM\default\dialog\PriceAbleItem.RecurringCharge.Edit.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\PriceAbleItem.RecurringCharge.ViewEdit.htm  %TargetDir%\UI\MCM\default\dialog\PriceAbleItem.RecurringCharge.ViewEdit.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\PriceAbleItem.Usage.Edit.htm  %TargetDir%\UI\MCM\default\dialog\PriceAbleItem.Usage.Edit.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\PriceAbleItem.Usage.ViewEdit.htm  %TargetDir%\UI\MCM\default\dialog\PriceAbleItem.Usage.ViewEdit.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\PriceList.List.asp %TargetDir%\UI\MCM\default\dialog\PriceList.List.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\PriceList.List.htm  %TargetDir%\UI\MCM\default\dialog\PriceList.List.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\PriceList.Picker.htm  %TargetDir%\UI\MCM\default\dialog\PriceList.Picker.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\PriceList.ViewEdit.htm  %TargetDir%\UI\MCM\default\dialog\PriceList.ViewEdit.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\ProductOffering.Edit.htm  %TargetDir%\UI\MCM\default\dialog\ProductOffering.Edit.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\ProductOffering.Hidden.List.asp %TargetDir%\UI\MCM\default\dialog\ProductOffering.Hidden.List.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\ProductOffering.List.asp %TargetDir%\UI\MCM\default\dialog\ProductOffering.List.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\ProductOffering.List.htm  %TargetDir%\UI\MCM\default\dialog\ProductOffering.List.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\ProductOffering.ViewEdit.htm  %TargetDir%\UI\MCM\default\dialog\ProductOffering.ViewEdit.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\ProductOffering.ViewEdit.Items.htm  %TargetDir%\UI\MCM\default\dialog\ProductOffering.ViewEdit.Items.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\Rates.AllPriceLists.List.asp %TargetDir%\UI\MCM\default\dialog\Rates.AllPriceLists.List.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\Rates.AllPriceLists.List.htm  %TargetDir%\UI\MCM\default\dialog\Rates.AllPriceLists.List.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\Rates.PriceableItem.List.htm  %TargetDir%\UI\MCM\default\dialog\Rates.PriceableItem.List.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\Rates.PriceList.List.asp %TargetDir%\UI\MCM\default\dialog\Rates.PriceList.List.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\Rates.PriceList.List.htm  %TargetDir%\UI\MCM\default\dialog\Rates.PriceList.List.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\Rates.RateSchedule.List.asp %TargetDir%\UI\MCM\default\dialog\Rates.RateSchedule.List.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\Rates.RateSchedule.List.htm  %TargetDir%\UI\MCM\default\dialog\Rates.RateSchedule.List.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\Rates.ViewEffectedSubscribersForProductOffering.htm  %TargetDir%\UI\MCM\default\dialog\Rates.ViewEffectedSubscribersForProductOffering.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\Rates.ViewEffectedSubscribersForRateSchedules.htm  %TargetDir%\UI\MCM\default\dialog\Rates.ViewEffectedSubscribersForRateSchedules.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\ReasonCode.List.htm  %TargetDir%\UI\MCM\default\dialog\ReasonCode.List.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\RecurringCharge.Edit.htm  %TargetDir%\UI\MCM\default\dialog\RecurringCharge.Edit.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\RecurringCharge.ViewEdit.htm  %TargetDir%\UI\MCM\default\dialog\RecurringCharge.ViewEdit.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\ServiceChargePriceAbleItem.List.asp %TargetDir%\UI\MCM\default\dialog\ServiceChargePriceAbleItem.List.asp 
Copy /Y %SrcDir%\UI\MCM\default\dialog\ServiceChargePriceAbleItem.List.htm  %TargetDir%\UI\MCM\default\dialog\ServiceChargePriceAbleItem.List.htm  
Copy /Y %SrcDir%\UI\MCM\default\dialog\TestLinks.asp %TargetDir%\UI\MCM\default\dialog\TestLinks.asp 
Copy /Y %SrcDir%\UI\MCM\default\localized\us\dictionary\Text\LocalizedGeneral.xml %TargetDir%\UI\MCM\default\localized\us\dictionary\Text\LocalizedGeneral.xml 
Copy /Y %SrcDir%\UI\MCM\default\localized\us\styles\styles.css %TargetDir%\UI\MCM\default\localized\us\styles\styles.css 
Copy /Y %SrcDir%\UI\MCM\default\localized\us\styles\wizard_styles.css %TargetDir%\UI\MCM\default\localized\us\styles\wizard_styles.css 
Copy /Y %SrcDir%\UI\MCM\helpmenu.asp %TargetDir%\UI\MCM\helpmenu.asp 
Copy /Y %SrcDir%\UI\MDM\Common\Widgets\Calendar\Calendar.footer.htm  %TargetDir%\UI\MDM\Common\Widgets\Calendar\Calendar.footer.htm  
Copy /Y %SrcDir%\UI\MDM\Common\Widgets\Calendar\pupdate_finalization.js %TargetDir%\UI\MDM\Common\Widgets\Calendar\pupdate_finalization.js 
Copy /Y %SrcDir%\UI\MDM\internal\mdm.JavaScript.lib.js %TargetDir%\UI\MDM\internal\mdm.JavaScript.lib.js 
Copy /Y %SrcDir%\UI\MDM\internal\ProductViewBrowserToolBar.htm  %TargetDir%\UI\MDM\internal\ProductViewBrowserToolBar.htm  
Copy /Y %SrcDir%\UI\MDM\mdmPVBEvents.asp %TargetDir%\UI\MDM\mdmPVBEvents.asp 
Copy /Y %SrcDir%\UI\MetraCare\Account\App_LocalResources\SelectAccountType.aspx.resx %TargetDir%\UI\MetraCare\Account\App_LocalResources\SelectAccountType.aspx.resx 
Copy /Y %SrcDir%\UI\MetraCare\Account\AccountCreated.aspx %TargetDir%\UI\MetraCare\Account\AccountCreated.aspx 
Copy /Y %SrcDir%\UI\MetraCare\Account\AccountCreated.aspx.cs %TargetDir%\UI\MetraCare\Account\AccountCreated.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\Account\AccountUpdated.aspx %TargetDir%\UI\MetraCare\Account\AccountUpdated.aspx 
Copy /Y %SrcDir%\UI\MetraCare\Account\AccountUpdated.aspx.cs %TargetDir%\UI\MetraCare\Account\AccountUpdated.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\Account\AddAccount.aspx %TargetDir%\UI\MetraCare\Account\AddAccount.aspx 
Copy /Y %SrcDir%\UI\MetraCare\Account\AddAccount.aspx.cs %TargetDir%\UI\MetraCare\Account\AddAccount.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\Account\AddSystemUser.aspx %TargetDir%\UI\MetraCare\Account\AddSystemUser.aspx 
Copy /Y %SrcDir%\UI\MetraCare\Account\AddSystemUser.aspx.cs %TargetDir%\UI\MetraCare\Account\AddSystemUser.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\Account\ContactGrid.aspx %TargetDir%\UI\MetraCare\Account\ContactGrid.aspx 
Copy /Y %SrcDir%\UI\MetraCare\Account\ContactGrid.aspx.cs %TargetDir%\UI\MetraCare\Account\ContactGrid.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\Account\ContactUpdate.aspx %TargetDir%\UI\MetraCare\Account\ContactUpdate.aspx 
Copy /Y %SrcDir%\UI\MetraCare\Account\ContactUpdate.aspx.cs %TargetDir%\UI\MetraCare\Account\ContactUpdate.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\Account\GenericAccountSummary.aspx %TargetDir%\UI\MetraCare\Account\GenericAccountSummary.aspx
Copy /Y %SrcDir%\UI\MetraCare\Account\GenericAccountSummary.aspx.cs %TargetDir%\UI\MetraCare\Account\GenericAccountSummary.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\Account\GenericAddAccount.aspx %TargetDir%\UI\MetraCare\Account\GenericAddAccount.aspx 
Copy /Y %SrcDir%\UI\MetraCare\Account\GenericAddAccount.aspx.cs %TargetDir%\UI\MetraCare\Account\GenericAddAccount.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\Account\GenericUpdateAccount.aspx %TargetDir%\UI\MetraCare\Account\GenericUpdateAccount.aspx 
Copy /Y %SrcDir%\UI\MetraCare\Account\GenericUpdateAccount.aspx.cs %TargetDir%\UI\MetraCare\Account\GenericUpdateAccount.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\Account\GotoAccountSummary.aspx.cs %TargetDir%\UI\MetraCare\Account\GotoAccountSummary.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\Account\SelectAccountType.aspx %TargetDir%\UI\MetraCare\Account\SelectAccountType.aspx 
Copy /Y %SrcDir%\UI\MetraCare\Account\SelectAccountType.aspx.cs %TargetDir%\UI\MetraCare\Account\SelectAccountType.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\Account\UpdateAccount.aspx %TargetDir%\UI\MetraCare\Account\UpdateAccount.aspx 
Copy /Y %SrcDir%\UI\MetraCare\Account\UpdateAccount.aspx.cs %TargetDir%\UI\MetraCare\Account\UpdateAccount.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\Account\UpdateSystemAccount.aspx %TargetDir%\UI\MetraCare\Account\UpdateSystemAccount.aspx 
Copy /Y %SrcDir%\UI\MetraCare\Account\UpdateSystemAccount.aspx.cs %TargetDir%\UI\MetraCare\Account\UpdateSystemAccount.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\AjaxServices\FindAccount.aspx.cs %TargetDir%\UI\MetraCare\AjaxServices\FindAccount.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\AjaxServices\FindAccountSvc.aspx.cs %TargetDir%\UI\MetraCare\AjaxServices\FindAccountSvc.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\AjaxServices\GetData.aspx.cs %TargetDir%\UI\MetraCare\AjaxServices\GetData.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\AjaxServices\Hierarchy.aspx.cs %TargetDir%\UI\MetraCare\AjaxServices\Hierarchy.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\AjaxServices\Logout.aspx.cs %TargetDir%\UI\MetraCare\AjaxServices\Logout.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\AjaxServices\PageNav.aspx.cs %TargetDir%\UI\MetraCare\AjaxServices\PageNav.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\AjaxServices\RegisterState.aspx.cs %TargetDir%\UI\MetraCare\AjaxServices\RegisterState.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\AjaxServices\UpdateSettings.aspx.cs %TargetDir%\UI\MetraCare\AjaxServices\UpdateSettings.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\App_Code\Exceptions.cs %TargetDir%\UI\MetraCare\App_Code\Exceptions.cs 
Copy /Y %SrcDir%\UI\MetraCare\App_Code\RecentAccounts.cs %TargetDir%\UI\MetraCare\App_Code\RecentAccounts.cs 
Copy /Y %SrcDir%\UI\MetraCare\App_Code\RenderMenu.cs %TargetDir%\UI\MetraCare\App_Code\RenderMenu.cs 
Copy /Y %SrcDir%\UI\MetraCare\App_GlobalResources\ErrorMessages.resx %TargetDir%\UI\MetraCare\App_GlobalResources\ErrorMessages.resx 
Copy /Y %SrcDir%\UI\MetraCare\App_GlobalResources\MainMenu.resx %TargetDir%\UI\MetraCare\App_GlobalResources\MainMenu.resx 
Copy /Y %SrcDir%\UI\MetraCare\App_GlobalResources\Resource.resx %TargetDir%\UI\MetraCare\App_GlobalResources\Resource.resx 
Copy /Y %SrcDir%\UI\MetraCare\App_LocalResources\ChangePassword.aspx.resx %TargetDir%\UI\MetraCare\App_LocalResources\ChangePassword.aspx.resx 
XCOPY /E /V /H /Y /Z %SrcDir%\UI\MetraCare\bin\* %TargetDir%\UI\MetraCare\bin
Copy /Y %SrcDir%\UI\MetraCare\Config\AccountTypes.xml %TargetDir%\UI\MetraCare\Config\AccountTypes.xml 
Copy /Y %SrcDir%\UI\MetraCare\Config\Menu.xml %TargetDir%\UI\MetraCare\Config\Menu.xml 
Copy /Y %SrcDir%\UI\MetraCare\Config\UiPageMapper.xml %TargetDir%\UI\MetraCare\Config\UiPageMapper.xml 
Copy /Y %SrcDir%\UI\MetraCare\JavaScript\Account.js %TargetDir%\UI\MetraCare\JavaScript\Account.js 
Copy /Y %SrcDir%\UI\MetraCare\JavaScript\Common.js %TargetDir%\UI\MetraCare\JavaScript\Common.js 
Copy /Y %SrcDir%\UI\MetraCare\JavaScript\Localized.fr.js %TargetDir%\UI\MetraCare\JavaScript\Localized.fr.js 
Copy /Y %SrcDir%\UI\MetraCare\JavaScript\Localized.js %TargetDir%\UI\MetraCare\JavaScript\Localized.js 
Copy /Y %SrcDir%\UI\MetraCare\JavaScript\PageNav.js %TargetDir%\UI\MetraCare\JavaScript\PageNav.js 
Copy /Y %SrcDir%\UI\MetraCare\JavaScript\Renderers.js %TargetDir%\UI\MetraCare\JavaScript\Renderers.js 
Copy /Y %SrcDir%\UI\MetraCare\JavaScript\ViewPort.js %TargetDir%\UI\MetraCare\JavaScript\ViewPort.js 
Copy /Y %SrcDir%\UI\MetraCare\MasterPages\MetraCareExt.master %TargetDir%\UI\MetraCare\MasterPages\MetraCareExt.master 
Copy /Y %SrcDir%\UI\MetraCare\MasterPages\MetraCareExt.master.cs %TargetDir%\UI\MetraCare\MasterPages\MetraCareExt.master.cs 
Copy /Y %SrcDir%\UI\MetraCare\MasterPages\NoMenuPageExt.master %TargetDir%\UI\MetraCare\MasterPages\NoMenuPageExt.master 
Copy /Y %SrcDir%\UI\MetraCare\MasterPages\NoMenuPageExt.master.cs %TargetDir%\UI\MetraCare\MasterPages\NoMenuPageExt.master.cs 
Copy /Y %SrcDir%\UI\MetraCare\MasterPages\PageExt.master %TargetDir%\UI\MetraCare\MasterPages\PageExt.master 
Copy /Y %SrcDir%\UI\MetraCare\MasterPages\PageExt.master.cs %TargetDir%\UI\MetraCare\MasterPages\PageExt.master.cs 
Copy /Y %SrcDir%\UI\MetraCare\Styles\baseStyle.css %TargetDir%\UI\MetraCare\Styles\baseStyle.css 
Copy /Y %SrcDir%\UI\MetraCare\Styles\grid.css %TargetDir%\UI\MetraCare\Styles\grid.css 
Copy /Y %SrcDir%\UI\MetraCare\Styles\menuStyle.css %TargetDir%\UI\MetraCare\Styles\menuStyle.css 
Copy /Y %SrcDir%\UI\MetraCare\Styles\MiscField.css %TargetDir%\UI\MetraCare\Styles\MiscField.css 
Copy /Y %SrcDir%\UI\MetraCare\Subscriptions\App_LocalResources\DeleteSubscription.aspx.resx %TargetDir%\UI\MetraCare\Subscriptions\App_LocalResources\DeleteSubscription.aspx.resx 
Copy /Y %SrcDir%\UI\MetraCare\Subscriptions\App_LocalResources\SaveSubscriptions.aspx.resx %TargetDir%\UI\MetraCare\Subscriptions\App_LocalResources\SaveSubscriptions.aspx.resx 
Copy /Y %SrcDir%\UI\MetraCare\Subscriptions\App_LocalResources\SelectPO.aspx.resx %TargetDir%\UI\MetraCare\Subscriptions\App_LocalResources\SelectPO.aspx.resx 
Copy /Y %SrcDir%\UI\MetraCare\Subscriptions\App_LocalResources\SetSubscriptionDate.aspx.resx %TargetDir%\UI\MetraCare\Subscriptions\App_LocalResources\SetSubscriptionDate.aspx.resx 
Copy /Y %SrcDir%\UI\MetraCare\Subscriptions\App_LocalResources\SetUDRCValues.aspx.resx %TargetDir%\UI\MetraCare\Subscriptions\App_LocalResources\SetUDRCValues.aspx.resx 
Copy /Y %SrcDir%\UI\MetraCare\Subscriptions\App_LocalResources\Subscriptions.aspx.resx %TargetDir%\UI\MetraCare\Subscriptions\App_LocalResources\Subscriptions.aspx.resx 
Copy /Y %SrcDir%\UI\MetraCare\Subscriptions\App_LocalResources\Unsubscribe.aspx.resx %TargetDir%\UI\MetraCare\Subscriptions\App_LocalResources\Unsubscribe.aspx.resx 
Copy /Y %SrcDir%\UI\MetraCare\Subscriptions\DeleteSubscription.aspx %TargetDir%\UI\MetraCare\Subscriptions\DeleteSubscription.aspx 
Copy /Y %SrcDir%\UI\MetraCare\Subscriptions\SaveSubscriptions.aspx %TargetDir%\UI\MetraCare\Subscriptions\SaveSubscriptions.aspx 
Copy /Y %SrcDir%\UI\MetraCare\Subscriptions\SelectPO.aspx %TargetDir%\UI\MetraCare\Subscriptions\SelectPO.aspx 
Copy /Y %SrcDir%\UI\MetraCare\Subscriptions\SetSubscriptionDate.aspx %TargetDir%\UI\MetraCare\Subscriptions\SetSubscriptionDate.aspx 
Copy /Y %SrcDir%\UI\MetraCare\Subscriptions\SetSubscriptionDate.aspx.cs %TargetDir%\UI\MetraCare\Subscriptions\SetSubscriptionDate.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\Subscriptions\SetUDRCValues.aspx.cs %TargetDir%\UI\MetraCare\Subscriptions\SetUDRCValues.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\Subscriptions\Subscriptions.aspx %TargetDir%\UI\MetraCare\Subscriptions\Subscriptions.aspx 
Copy /Y %SrcDir%\UI\MetraCare\Subscriptions\Subscriptions.aspx.cs %TargetDir%\UI\MetraCare\Subscriptions\Subscriptions.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\Subscriptions\Unsubscribe.aspx %TargetDir%\UI\MetraCare\Subscriptions\Unsubscribe.aspx 
Copy /Y %SrcDir%\UI\MetraCare\Subscriptions\Unsubscribe.aspx.cs %TargetDir%\UI\MetraCare\Subscriptions\Unsubscribe.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\UserControls\AccountMenu.ascx.cs %TargetDir%\UI\MetraCare\UserControls\AccountMenu.ascx.cs 
Copy /Y %SrcDir%\UI\MetraCare\UserControls\Error.ascx.cs %TargetDir%\UI\MetraCare\UserControls\Error.ascx.cs 
Copy /Y %SrcDir%\UI\MetraCare\UserControls\Events.ascx %TargetDir%\UI\MetraCare\UserControls\Events.ascx 
Copy /Y %SrcDir%\UI\MetraCare\UserControls\Hierarchy.ascx.cs %TargetDir%\UI\MetraCare\UserControls\Hierarchy.ascx.cs 
Copy /Y %SrcDir%\UI\MetraCare\UserControls\LocalizedIncludes.ascx %TargetDir%\UI\MetraCare\UserControls\LocalizedIncludes.ascx 
Copy /Y %SrcDir%\UI\MetraCare\UserControls\LocalizedIncludes.ascx.cs %TargetDir%\UI\MetraCare\UserControls\LocalizedIncludes.ascx.cs 
Copy /Y %SrcDir%\UI\MetraCare\UserControls\Menu.ascx.cs %TargetDir%\UI\MetraCare\UserControls\Menu.ascx.cs 
Copy /Y %SrcDir%\UI\MetraCare\ux\form\DateRangeField.js %TargetDir%\UI\MetraCare\ux\form\DateRangeField.js 
Copy /Y %SrcDir%\UI\MetraCare\ux\form\MiscField.js %TargetDir%\UI\MetraCare\ux\form\MiscField.js 
Copy /Y %SrcDir%\UI\MetraCare\ux\form\NumericOperationField.js %TargetDir%\UI\MetraCare\ux\form\NumericOperationField.js 
Copy /Y %SrcDir%\UI\MetraCare\ux\form\PasswordMeter.js %TargetDir%\UI\MetraCare\ux\form\PasswordMeter.js 
Copy /Y %SrcDir%\UI\MetraCare\ux\grid\filter\BooleanFilter.js %TargetDir%\UI\MetraCare\ux\grid\filter\BooleanFilter.js 
Copy /Y %SrcDir%\UI\MetraCare\ux\grid\filter\DateFilter.js %TargetDir%\UI\MetraCare\ux\grid\filter\DateFilter.js 
Copy /Y %SrcDir%\UI\MetraCare\ux\grid\filter\Filter.js %TargetDir%\UI\MetraCare\ux\grid\filter\Filter.js 
Copy /Y %SrcDir%\UI\MetraCare\ux\grid\filter\ListFilter.js %TargetDir%\UI\MetraCare\ux\grid\filter\ListFilter.js 
Copy /Y %SrcDir%\UI\MetraCare\ux\grid\filter\NumericFilter.js %TargetDir%\UI\MetraCare\ux\grid\filter\NumericFilter.js 
Copy /Y %SrcDir%\UI\MetraCare\ux\grid\filter\StringFilter.js %TargetDir%\UI\MetraCare\ux\grid\filter\StringFilter.js 
Copy /Y %SrcDir%\UI\MetraCare\ux\grid\GridFilters.js %TargetDir%\UI\MetraCare\ux\grid\GridFilters.js 
Copy /Y %SrcDir%\UI\MetraCare\ux\grid\RowExpander.js %TargetDir%\UI\MetraCare\ux\grid\RowExpander.js 
Copy /Y %SrcDir%\UI\MetraCare\AdvancedFind.aspx %TargetDir%\UI\MetraCare\AdvancedFind.aspx 
Copy /Y %SrcDir%\UI\MetraCare\AdvancedFind.aspx.cs %TargetDir%\UI\MetraCare\AdvancedFind.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\ChangePassword.aspx %TargetDir%\UI\MetraCare\ChangePassword.aspx 
Copy /Y %SrcDir%\UI\MetraCare\ChangePassword.aspx.cs %TargetDir%\UI\MetraCare\ChangePassword.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\Default.aspx.cs %TargetDir%\UI\MetraCare\Default.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\Global.asax %TargetDir%\UI\MetraCare\Global.asax 
Copy /Y %SrcDir%\UI\MetraCare\Login.aspx %TargetDir%\UI\MetraCare\Login.aspx 
Copy /Y %SrcDir%\UI\MetraCare\Login.aspx.cs %TargetDir%\UI\MetraCare\Login.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\ManageAccount.aspx %TargetDir%\UI\MetraCare\ManageAccount.aspx 
Copy /Y %SrcDir%\UI\MetraCare\ManageAccount.aspx.cs %TargetDir%\UI\MetraCare\ManageAccount.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\StartWorkFlow.aspx.cs %TargetDir%\UI\MetraCare\StartWorkFlow.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\TestControls.aspx %TargetDir%\UI\MetraCare\TestControls.aspx 
Copy /Y %SrcDir%\UI\MetraCare\TicketToMAM.aspx %TargetDir%\UI\MetraCare\TicketToMAM.aspx 
Copy /Y %SrcDir%\UI\MetraCare\TicketToMAM.aspx.cs %TargetDir%\UI\MetraCare\TicketToMAM.aspx.cs
Copy /Y %SrcDir%\UI\MetraCare\UnlockAccount.aspx.cs %TargetDir%\UI\MetraCare\UnlockAccount.aspx.cs 
Copy /Y %SrcDir%\UI\MetraCare\Welcome.aspx %TargetDir%\UI\MetraCare\Welcome.aspx 
XCOPY /E /V /H /Y /Z %SrcDir%\UI\MetraNet\bin\* %TargetDir%\UI\MetraNet\bin 
Copy /Y %SrcDir%\UI\MetraNet\default.aspx %TargetDir%\UI\MetraNet\default.aspx 
Copy /Y %SrcDir%\UI\MetraNet\MetraView.aspx %TargetDir%\UI\MetraNet\MetraView.aspx 
Copy /Y %SrcDir%\UI\MOM\default\dialog\AdapterManagement.RunDetails.List.htm  %TargetDir%\UI\MOM\default\dialog\AdapterManagement.RunDetails.List.htm  
Copy /Y %SrcDir%\UI\MOM\default\dialog\BackoutRerun.List.htm  %TargetDir%\UI\MOM\default\dialog\BackoutRerun.List.htm  
Copy /Y %SrcDir%\UI\MOM\default\dialog\BatchManagement.List.htm  %TargetDir%\UI\MOM\default\dialog\BatchManagement.List.htm  
Copy /Y %SrcDir%\UI\MOM\default\dialog\BatchManagement.Statistics.Render.htm  %TargetDir%\UI\MOM\default\dialog\BatchManagement.Statistics.Render.htm  
Copy /Y %SrcDir%\UI\MOM\default\dialog\DefaultDialogLogin.htm  %TargetDir%\UI\MOM\default\dialog\DefaultDialogLogin.htm  
Copy /Y %SrcDir%\UI\MOM\default\dialog\DefaultDialogUsageStatisticsQuery.htm  %TargetDir%\UI\MOM\default\dialog\DefaultDialogUsageStatisticsQuery.htm  
Copy /Y %SrcDir%\UI\MOM\default\dialog\DefaultDialogUsageStatisticsQueryChild.htm  %TargetDir%\UI\MOM\default\dialog\DefaultDialogUsageStatisticsQueryChild.htm  
Copy /Y %SrcDir%\UI\MOM\default\dialog\DefaultDialogUSMManual.htm  %TargetDir%\UI\MOM\default\dialog\DefaultDialogUSMManual.htm  
Copy /Y %SrcDir%\UI\MOM\default\dialog\IntervalManagement.RunHistory.List.htm  %TargetDir%\UI\MOM\default\dialog\IntervalManagement.RunHistory.List.htm  
Copy /Y %SrcDir%\UI\MOM\default\dialog\IntervalManagement.Statistics.Render.asp %TargetDir%\UI\MOM\default\dialog\IntervalManagement.Statistics.Render.asp 
Copy /Y %SrcDir%\UI\MOM\default\dialog\IntervalManagement.Statistics.Render.htm  %TargetDir%\UI\MOM\default\dialog\IntervalManagement.Statistics.Render.htm  
Copy /Y %SrcDir%\UI\MOM\default\dialog\IntervalManagement.ViewEdit.asp %TargetDir%\UI\MOM\default\dialog\IntervalManagement.ViewEdit.asp 
Copy /Y %SrcDir%\UI\MOM\default\dialog\ScheduledAdapter.Instance.List.htm  %TargetDir%\UI\MOM\default\dialog\ScheduledAdapter.Instance.List.htm  
Copy /Y %SrcDir%\UI\MOM\default\dialog\ScheduledAdapter.List.htm  %TargetDir%\UI\MOM\default\dialog\ScheduledAdapter.List.htm  
Copy /Y %SrcDir%\UI\MOM\default\dialog\ScheduledAdapter.Run.List.htm  %TargetDir%\UI\MOM\default\dialog\ScheduledAdapter.Run.List.htm  
Copy /Y %SrcDir%\UI\MOM\default\dialog\Usage.Statistics.Render.htm  %TargetDir%\UI\MOM\default\dialog\Usage.Statistics.Render.htm  
Copy /Y %SrcDir%\UI\MOM\default\localized\us\styles\DialogStyles.css %TargetDir%\UI\MOM\default\localized\us\styles\DialogStyles.css 
Copy /Y %SrcDir%\UI\MOM\default\localized\us\styles\styles.css %TargetDir%\UI\MOM\default\localized\us\styles\styles.css 
Copy /Y %SrcDir%\UI\MOM\helpmenu.asp %TargetDir%\UI\MOM\helpmenu.asp 
Copy /Y %SrcDir%\UI\MPM\default\dialog\DynamicService\WizardInitialize.asp %TargetDir%\UI\MPM\default\dialog\DynamicService\WizardInitialize.asp 
Copy /Y %SrcDir%\UI\MPM\default\dialog\Help\WebHelp\whcsh_home.htm %TargetDir%\UI\MPM\default\dialog\Help\WebHelp\whcsh_home.htm 
Copy /Y %SrcDir%\UI\MPM\default\dialog\PI\Popups\EditCompositeAdjustmentType.asp %TargetDir%\UI\MPM\default\dialog\PI\Popups\EditCompositeAdjustmentType.asp 
Copy /Y %SrcDir%\UI\MPM\default\dialog\PIWizard\Include\ExtendedPropertyInclude.asp %TargetDir%\UI\MPM\default\dialog\PIWizard\Include\ExtendedPropertyInclude.asp 
Copy /Y %SrcDir%\UI\MPM\default\dialog\PIWizard\WizardInitialize.asp %TargetDir%\UI\MPM\default\dialog\PIWizard\WizardInitialize.asp 
Copy /Y %SrcDir%\UI\MPM\default\dialog\StaticData\WizardInitialize.asp %TargetDir%\UI\MPM\default\dialog\StaticData\WizardInitialize.asp 
Copy /Y %SrcDir%\UI\MPM\default\dialog\Header.asp %TargetDir%\UI\MPM\default\dialog\Header.asp 
Copy /Y %SrcDir%\UI\MPM\default\localized\us\styles\Styles.css %TargetDir%\UI\MPM\default\localized\us\styles\Styles.css 
Copy /Y %SrcDir%\UI\MPM\default\localized\us\styles\wizard_styles.css %TargetDir%\UI\MPM\default\localized\us\styles\wizard_styles.css 
Copy /Y %SrcDir%\UI\MPM\Login.asp %TargetDir%\UI\MPM\Login.asp 
XCOPY /E /V /H /Y /Z %SrcDir%\UI\Suggest\bin\* %TargetDir%\UI\Suggest\bin 
XCOPY /E /V /H /Y /Z %SrcDir%\WebServices\AccountHierarchy\bin\* %TargetDir%\WebServices\AccountHierarchy\bin 
XCOPY /E /V /H /Y /Z %SrcDir%\WebServices\Batch\bin\* %TargetDir%\WebServices\Batch\bin 
XCOPY /E /V /H /Y /Z %SrcDir%\WebServices\BillingRerun\bin\* %TargetDir%\WebServices\BillingRerun\bin

REM Apply new files
IF NOT EXIST %TargetDir%\Config\DomainModel md %TargetDir%\Config\DomainModel
Copy /Y %SrcDir%\Config\DomainModel %TargetDir%\Config\DomainModel
Copy /Y %SrcDir%\Config\EMailTemplate\UpdatePasswordEMailNotificationTemplate.xml %TargetDir%\Config\EMailTemplate\UpdatePasswordEMailNotificationTemplate.xml
IF NOT EXIST %TargetDir%\Config\Queries\UsageServer\Adapters\PaymentAuthorizationAdapter md %TargetDir%\Config\Queries\UsageServer\Adapters\PaymentAuthorizationAdapter
XCOPY /E /V /H /Y /Z %SrcDir%\Config\Queries\UsageServer\Adapters\PaymentAuthorizationAdapter\* %TargetDir%\Config\Queries\UsageServer\Adapters\PaymentAuthorizationAdapter
IF NOT EXIST %TargetDir%\Config\Queries\UsageServer\Adapters\PaymentSubmissionAdapter md %TargetDir%\Config\Queries\UsageServer\Adapters\PaymentSubmissionAdapter
XCOPY /E /V /H /Y /Z %SrcDir%\Config\Queries\UsageServer\Adapters\PaymentSubmissionAdapter\* %TargetDir%\Config\Queries\UsageServer\Adapters\PaymentSubmissionAdapter
IF NOT EXIST %TargetDir%\Extensions\Account\config\ActivityServices\Workflows md %TargetDir%\Extensions\Account\config\ActivityServices\Workflows
XCOPY /E /V /H /Y /Z %SrcDir%\Extensions\Account\config\ActivityServices\Workflows\* %TargetDir%\Extensions\Account\config\ActivityServices\Workflows
IF NOT EXIST %TargetDir%\Extensions\Account\config\GridLayouts md %TargetDir%\Extensions\Account\config\GridLayouts
XCOPY /E /V /H /Y /Z %SrcDir%\Extensions\Account\config\GridLayouts\* %TargetDir%\Extensions\Account\config\GridLayouts
Copy /Y %SrcDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_Account_us.xml %TargetDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_Account_us.xml
Copy /Y %SrcDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_Contact_cn.xml %TargetDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_Contact_cn.xml
Copy /Y %SrcDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_Contact_de.xml %TargetDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_Contact_de.xml
Copy /Y %SrcDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_Contact_fr.xml %TargetDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_Contact_fr.xml
Copy /Y %SrcDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_Contact_it.xml %TargetDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_Contact_it.xml
Copy /Y %SrcDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_Contact_jp.xml %TargetDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_Contact_jp.xml
Copy /Y %SrcDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_Contact_uk.xml %TargetDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_Contact_uk.xml
Copy /Y %SrcDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_Contact_us.xml %TargetDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_Contact_us.xml
Copy /Y %SrcDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_internal_us.xml %TargetDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_internal_us.xml
IF NOT EXIST  %SrcDir%\Extensions\Account\config\PageLayouts md %TargetDir%\Extensions\Account\config\PageLayouts
XCOPY /E /V /H /Y /Z %SrcDir%\Extensions\Account\config\PageLayouts\* %TargetDir%\Extensions\Account\config\PageLayouts
Copy /Y %SrcDir%\Extensions\AR\_MetraNet_6.0.1 %TargetDir%\Extensions\AR\_MetraNet_6.0.1
Copy /Y %SrcDir%\Extensions\ARSample\_MetraNet_6.0.1 %TargetDir%\Extensions\ARSample\_MetraNet_6.0.1
IF NOT EXIST %TargetDir%\Extensions\Core\config\ActivityServices md %TargetDir%\Extensions\Core\config\ActivityServices
XCOPY /E /V /H /Y /Z %SrcDir%\Extensions\Core\config\ActivityServices\* %TargetDir%\Extensions\Core\config\ActivityServices
Copy /Y %SrcDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTCheckBox.png %TargetDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTCheckBox.png
Copy /Y %SrcDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTDatePicker.png %TargetDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTDatePicker.png
Copy /Y %SrcDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTDropDown.png %TargetDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTDropDown.png
Copy /Y %SrcDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTExtControl.png %TargetDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTExtControl.png
Copy /Y %SrcDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTFilterGrid.png %TargetDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTFilterGrid.png
Copy /Y %SrcDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTHtmlEditor.png %TargetDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTHtmlEditor.png
Copy /Y %SrcDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTInlineSearch.png %TargetDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTInlineSearch.png
Copy /Y %SrcDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTLabel.png %TargetDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTLabel.png
Copy /Y %SrcDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTLiteral.png %TargetDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTLiteral.png
Copy /Y %SrcDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTNumberField.png %TargetDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTNumberField.png
Copy /Y %SrcDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTRadio.png %TargetDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTRadio.png
Copy /Y %SrcDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTTextBox.png %TargetDir%\Extensions\Core\config\PageLayouts\MetraTech.UI.Controls.MTTextBox.png
IF NOT EXIST %TargetDir%\Extensions\PageNav\Config\ActivityServices\Workflows md %TargetDir%\Extensions\PageNav\Config\ActivityServices\Workflows
XCOPY /E /V /H /Y /Z %SrcDir%\Extensions\PageNav\Config\ActivityServices\Workflows\* %TargetDir%\Extensions\PageNav\Config\ActivityServices\Workflows
IF NOT EXIST %TargetDir%\Extensions\PaymentSvr\config\MetraPay md %TargetDir%\Extensions\PaymentSvr\config\MetraPay
XCOPY /E /V /H /Y /Z %SrcDir%\Extensions\PaymentSvr\config\MetraPay\* %TargetDir%\Extensions\PaymentSvr\config\MetraPay
Copy /Y %SrcDir%\Extensions\PaymentSvr\_MetraNet_6.0.1 %TargetDir%\Extensions\PaymentSvr\_MetraNet_6.0.1
IF NOT EXIST %TargetDir%\Extensions\PaymentSvrClient\config\ActivityServices md %TargetDir%\Extensions\PaymentSvrClient\config\ActivityServices
XCOPY /E /V /H /Y /Z %SrcDir%\Extensions\PaymentSvrClient\config\ActivityServices\* %TargetDir%\Extensions\PaymentSvrClient\config\ActivityServices
IF NOT EXIST %TargetDir%\Extensions\PaymentSvrClient\config\MetraPay md %TargetDir%\Extensions\PaymentSvrClient\config\MetraPay
XCOPY /E /V /H /Y /Z %SrcDir%\Extensions\PaymentSvrClient\config\MetraPay\* %TargetDir%\Extensions\PaymentSvrClient\config\MetraPay
IF NOT EXIST %TargetDir%\Extensions\PaymentSvrClient\config\UsageServer\Workflows md %TargetDir%\Extensions\PaymentSvrClient\config\UsageServer\Workflows
XCOPY /E /V /H /Y /Z %SrcDir%\Extensions\PaymentSvrClient\config\UsageServer\Workflows\* %TargetDir%\Extensions\PaymentSvrClient\config\UsageServer\Workflows
Copy /Y %SrcDir%\Extensions\PaymentSvrClient\config\UsageServer\PayAuthAdapter_US.xml %TargetDir%\Extensions\PaymentSvrClient\config\UsageServer\PayAuthAdapter_US.xml
Copy /Y %SrcDir%\Extensions\PaymentSvrClient\config\UsageServer\PaymentAuthorizationAdapter.xml %TargetDir%\Extensions\PaymentSvrClient\config\UsageServer\PaymentAuthorizationAdapter.xml
Copy /Y %SrcDir%\Extensions\PaymentSvrClient\config\UsageServer\PaymentSubmissionAdapter.xml %TargetDir%\Extensions\PaymentSvrClient\config\UsageServer\PaymentSubmissionAdapter.xml
Copy /Y %SrcDir%\Extensions\PaymentSvrClient\_MetraNet_6.0.1 %TargetDir%\Extensions\PaymentSvrClient\_MetraNet_6.0.1
Copy /Y %SrcDir%\Extensions\Reporting\_MetraNet_6.0.1 %TargetDir%\Extensions\Reporting\_MetraNet_6.0.1
Copy /Y %SrcDir%\Extensions\SampleSite\_MetraNet_6.0.1 %TargetDir%\Extensions\SampleSite\_MetraNet_6.0.1
Copy /Y %SrcDir%\Extensions\_MetraNet_6.0.1 %TargetDir%\Extensions\_MetraNet_6.0.1
Copy /Y %SrcDir%\Install\Scripts\PaymentServer.vbs %TargetDir%\Install\Scripts\PaymentServer.vbs
Copy /Y %SrcDir%\Install\Scripts\registerAssemblies.vbs %TargetDir%\Install\Scripts\registerAssemblies.vbs
Copy /Y %SrcDir%\Install\Scripts\replaceCfgPaths.vbs %TargetDir%\Install\Scripts\replaceCfgPaths.vbs
Copy /Y %SrcDir%\UI\MAM\AppTime.asp %TargetDir%\UI\MAM\AppTime.asp
IF NOT EXIST %TargetDir%\UI\MAM\default\localized\us\help md %TargetDir%\UI\MAM\default\localized\us\help
XCOPY /E /V /H /Y /Z %SrcDir%\UI\MAM\default\localized\us\help\* %TargetDir%\UI\MAM\default\localized\us\help
IF NOT EXIST %TargetDir%\UI\MCM\default\localized\us\help md %TargetDir%\UI\MCM\default\localized\us\help
XCOPY /E /V /H /Y /Z %SrcDir%\UI\MCM\default\localized\us\help\* %TargetDir%\UI\MCM\default\localized\us\help
Copy /Y %SrcDir%\UI\MetraCare\Account\App_LocalResources\AccountCreated.aspx.resx %TargetDir%\UI\MetraCare\Account\App_LocalResources\AccountCreated.aspx.resx
Copy /Y %SrcDir%\UI\MetraCare\Account\App_LocalResources\AccountUpdated.aspx.resx %TargetDir%\UI\MetraCare\Account\App_LocalResources\AccountUpdated.aspx.resx
Copy /Y %SrcDir%\UI\MetraCare\Account\App_LocalResources\AddAccount.aspx.resx %TargetDir%\UI\MetraCare\Account\App_LocalResources\AddAccount.aspx.resx
Copy /Y %SrcDir%\UI\MetraCare\Account\App_LocalResources\AddSystemUser.aspx.resx %TargetDir%\UI\MetraCare\Account\App_LocalResources\AddSystemUser.aspx.resx
Copy /Y %SrcDir%\UI\MetraCare\Account\App_LocalResources\ContactGrid.aspx.resx %TargetDir%\UI\MetraCare\Account\App_LocalResources\ContactGrid.aspx.resx
Copy /Y %SrcDir%\UI\MetraCare\Account\App_LocalResources\ContactUpdate.aspx.resx %TargetDir%\UI\MetraCare\Account\App_LocalResources\ContactUpdate.aspx.resx
Copy /Y %SrcDir%\UI\MetraCare\Account\App_LocalResources\ContactUpdated.aspx.resx %TargetDir%\UI\MetraCare\Account\App_LocalResources\ContactUpdated.aspx.resx
Copy /Y %SrcDir%\UI\MetraCare\Account\App_LocalResources\UpdateAccount.aspx.resx %TargetDir%\UI\MetraCare\Account\App_LocalResources\UpdateAccount.aspx.resx
Copy /Y %SrcDir%\UI\MetraCare\Account\ContactUpdated.aspx %TargetDir%\UI\MetraCare\Account\ContactUpdated.aspx
Copy /Y %SrcDir%\UI\MetraCare\Account\ContactUpdated.aspx.cs %TargetDir%\UI\MetraCare\Account\ContactUpdated.aspx.cs
Copy /Y %SrcDir%\UI\MetraCare\AjaxServices\AncestorList.aspx %TargetDir%\UI\MetraCare\AjaxServices\AncestorList.aspx
Copy /Y %SrcDir%\UI\MetraCare\AjaxServices\AncestorList.aspx.cs %TargetDir%\UI\MetraCare\AjaxServices\AncestorList.aspx.cs
Copy /Y %SrcDir%\UI\MetraCare\AjaxServices\FindCCSvc.aspx %TargetDir%\UI\MetraCare\AjaxServices\FindCCSvc.aspx
Copy /Y %SrcDir%\UI\MetraCare\AjaxServices\FindCCSvc.aspx.cs %TargetDir%\UI\MetraCare\AjaxServices\FindCCSvc.aspx.cs
Copy /Y %SrcDir%\UI\MetraCare\App_GlobalResources\KeyTerms.resx %TargetDir%\UI\MetraCare\App_GlobalResources\KeyTerms.resx
Copy /Y %SrcDir%\UI\MetraCare\App_LocalResources\GeneratePassword.aspx.resx %TargetDir%\UI\MetraCare\App_LocalResources\GeneratePassword.aspx.resx
Copy /Y %SrcDir%\UI\MetraCare\App_LocalResources\Login.aspx.resx %TargetDir%\UI\MetraCare\App_LocalResources\Login.aspx.resx
Copy /Y %SrcDir%\UI\MetraCare\App_LocalResources\UnlockAccount.aspx.resx %TargetDir%\UI\MetraCare\App_LocalResources\UnlockAccount.aspx.resx
IF NOT EXIST %TargetDir%\UI\MetraCare\Bin md %TargetDir%\UI\MetraCare\Bin
XCOPY /E /V /H /Y /Z %SrcDir%\UI\MetraCare\Bin\* %TargetDir%\UI\MetraCare\Bin
IF NOT EXIST %TargetDir%\UI\MetraCare\Ext md %TargetDir%\UI\MetraCare\Ext
XCOPY /E /V /H /Y /Z %SrcDir%\UI\MetraCare\Ext\* %TargetDir%\UI\MetraCare\Ext
Copy /Y %SrcDir%\UI\MetraCare\Images\icons\bullet_arrow_right.png %TargetDir%\UI\MetraCare\Images\icons\bullet_arrow_right.png
Copy /Y %SrcDir%\UI\MetraCare\Images\icons\bullet_hierarchy.png %TargetDir%\UI\MetraCare\Images\icons\bullet_hierarchy.png
IF NOT EXIST %TargetDir%\UI\MetraCare\Images\login md %TargetDir%\UI\MetraCare\Images\login
XCOPY /E /V /H /Y /Z %SrcDir%\UI\MetraCare\Images\login\* %TargetDir%\UI\MetraCare\Images\login
Copy /Y %SrcDir%\UI\MetraCare\Images\sprites\row-radio-sprite.gif %TargetDir%\UI\MetraCare\Images\sprites\row-radio-sprite.gif
Copy /Y %SrcDir%\UI\MetraCare\Images\bizman-cliff.jpg %TargetDir%\UI\MetraCare\Images\bizman-cliff.jpg
Copy /Y %SrcDir%\UI\MetraCare\JavaScript\ExtHacks.js %TargetDir%\UI\MetraCare\JavaScript\ExtHacks.js
Copy /Y %SrcDir%\UI\MetraCare\JavaScript\min.bat %TargetDir%\UI\MetraCare\JavaScript\min.bat
Copy /Y %SrcDir%\UI\MetraCare\JavaScript\RowSelectionModelOverride.js %TargetDir%\UI\MetraCare\JavaScript\RowSelectionModelOverride.js
Copy /Y %SrcDir%\UI\MetraCare\JavaScript\Validators.js %TargetDir%\UI\MetraCare\JavaScript\Validators.js
IF NOT EXIST %TargetDir%\UI\MetraCare\Payments md %TargetDir%\UI\MetraCare\Payments
XCOPY /E /V /H /Y /Z %SrcDir%\UI\MetraCare\Payments\* %TargetDir%\UI\MetraCare\Payments
IF NOT EXIST %TargetDir%\UI\MetraCare\ux\jpath md %TargetDir%\UI\MetraCare\ux\jpath
XCOPY /E /V /H /Y /Z %SrcDir%\UI\MetraCare\ux\jpath\* %TargetDir%\UI\MetraCare\ux\jpath
Copy /Y %SrcDir%\UI\MetraCare\AccountNavigation.aspx %TargetDir%\UI\MetraCare\AccountNavigation.aspx
Copy /Y %SrcDir%\UI\MetraCare\AccountNavigation.aspx.cs %TargetDir%\UI\MetraCare\AccountNavigation.aspx.cs
Copy /Y %SrcDir%\UI\MetraCare\AccountSelector.aspx %TargetDir%\UI\MetraCare\AccountSelector.aspx
Copy /Y %SrcDir%\UI\MetraCare\AccountSelector.aspx.cs %TargetDir%\UI\MetraCare\AccountSelector.aspx.cs
Copy /Y %SrcDir%\UI\MetraCare\GeneratePassword.aspx %TargetDir%\UI\MetraCare\GeneratePassword.aspx
Copy /Y %SrcDir%\UI\MetraCare\GeneratePassword.aspx.cs %TargetDir%\UI\MetraCare\GeneratePassword.aspx.cs
Copy /Y %SrcDir%\UI\MetraCare\GenericAdvancedFind.aspx %TargetDir%\UI\MetraCare\GenericAdvancedFind.aspx
Copy /Y %SrcDir%\UI\MetraCare\GenericAdvancedFind.aspx.cs %TargetDir%\UI\MetraCare\GenericAdvancedFind.aspx.cs
Copy /Y %SrcDir%\UI\MetraCare\Welcome.htm %TargetDir%\UI\MetraCare\Welcome.htm
IF NOT EXIST %TargetDir%\UI\MetraCareHelp\en-us md %TargetDir%\UI\MetraCareHelp\en-us
XCOPY /E /V /H /Y /Z %SrcDir%\UI\MetraCareHelp\en-us\* %TargetDir%\UI\MetraCareHelp\en-us
IF NOT EXIST %TargetDir%\UI\MOM\default\localized\us\help md %TargetDir%\UI\MOM\default\localized\us\help
XCOPY /E /V /H /Y /Z %SrcDir%\UI\MOM\default\localized\us\help\* %TargetDir%\UI\MOM\default\localized\us\help
Copy /Y %SrcDir%\WebServices\_MetraNet_6.0.1 %TargetDir%\WebServices\_MetraNet_6.0.1
Copy /Y %SrcDir%\_MetraNet_6.0.1 %TargetDir%\_MetraNet_6.0.1

goto :end

:Error
echo Command parameters not specified
echo Usage: ApplyCorePackage [srcDir] [targetDir]

:end
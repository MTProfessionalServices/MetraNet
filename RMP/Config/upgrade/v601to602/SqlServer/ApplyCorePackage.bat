@ECHO OFF

Set SrcDir = ''
Set TargetDir = ''

if not '%1' == '' (set SrcDir=%1)
if not '%2' == '' (set TargetDir=%2)

if '%1' == '' (goto :Error)
if '%2' == '' (goto :Error)


REM Remove the old, unneeded files
IF EXISTS %TargetDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_accountcreation_cn.xml DEL /F %TargetDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_accountcreation_cn.xml
IF EXISTS %TargetDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_Contact_cn.xml DEL /F %TargetDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_Contact_cn.xml
IF EXISTS %TargetDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_Contact_uk.xml DEL /F %TargetDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_Contact_uk.xml
IF EXISTS %TargetDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_systemaccountcreation_cn.xml DEL /F %TargetDir%\Extensions\Account\config\Localization\metratech.com\metratech.com_systemaccountcreation_cn.xml
IF EXISTS %TargetDir%\Extensions\AR\_MetraNet_6.0.1 DEL /F %TargetDir%\Extensions\AR\_MetraNet_6.0.1
IF EXISTS %TargetDir%\Extensions\ARSample\config\localization\metratech.com\metratech.com_arsalespersoncreation_cn.xml DEL /F %TargetDir%\Extensions\ARSample\config\localization\metratech.com\metratech.com_arsalespersoncreation_cn.xml
IF EXISTS %TargetDir%\Extensions\ARSample\_MetraNet_6.0.1 DEL /F %TargetDir%\Extensions\ARSample\_MetraNet_6.0.1
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\Global\Global_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\Global\Global_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\Global\Global_SystemCurrencies_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\Global\Global_SystemCurrencies_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\Global\global_uk.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\Global\global_uk.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_AccountCredit_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_AccountCredit_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_AccountCreditRequest_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_AccountCreditRequest_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_AddCharge_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_AddCharge_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_ARAdjustment_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_ARAdjustment_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_audit_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_audit_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_auditevents_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_auditevents_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_auditevents_custom_mam_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_auditevents_custom_mam_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_balanceadjustments_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_balanceadjustments_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_billingcycle_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_billingcycle_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_bundleddiscount_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_bundleddiscount_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_calendar_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_calendar_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_endpointtestservice_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_endpointtestservice_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_flatdiscount_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_flatdiscount_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_flatdiscount_nocond_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_flatdiscount_nocond_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_flatrecurringcharge_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_flatrecurringcharge_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_nonrecurringcharge_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_nonrecurringcharge_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_payment_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_payment_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_percentdiscount_nocond_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_percentdiscount_nocond_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_serviceendpoint_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_serviceendpoint_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_SubscriberCreditAccountRequestReason_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_SubscriberCreditAccountRequestReason_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_SubscriberCreditAccountRequestStatus_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_SubscriberCreditAccountRequestStatus_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_tariffs_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_tariffs_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_testparent_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_testparent_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_testservice_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_testservice_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_UnbundledDiscount_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\metratech.com\metratech.com_UnbundledDiscount_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\config\Localization\pipeline\pipeline_error_cn.xml DEL /F %TargetDir%\Extensions\Core\config\Localization\pipeline\pipeline_error_cn.xml
IF EXISTS %TargetDir%\Extensions\Core\test\autoSDK\metratech.com\testservice_cn.xml DEL /F %TargetDir%\Extensions\Core\test\autoSDK\metratech.com\testservice_cn.xml
IF EXISTS %TargetDir%\Extensions\PaymentSvr\_MetraNet_6.0.1 DEL /F %TargetDir%\Extensions\PaymentSvr\_MetraNet_6.0.1
IF EXISTS %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_paymentserver_cn.xml DEL /F %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_paymentserver_cn.xml
IF EXISTS %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_ps_ach_credit_cn.xml DEL /F %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_ps_ach_credit_cn.xml
IF EXISTS %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_ps_ach_debit_cn.xml DEL /F %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_ps_ach_debit_cn.xml
IF EXISTS %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_ps_ach_inquiry_cn.xml DEL /F %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_ps_ach_inquiry_cn.xml
IF EXISTS %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_ps_ach_prenote_cn.xml DEL /F %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_ps_ach_prenote_cn.xml
IF EXISTS %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_ps_archiveauthorization_cn.xml DEL /F %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_ps_archiveauthorization_cn.xml
IF EXISTS %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_ps_cc_credit_cn.xml DEL /F %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_ps_cc_credit_cn.xml
IF EXISTS %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_ps_cc_postauth_cn.xml DEL /F %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_ps_cc_postauth_cn.xml
IF EXISTS %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_ps_cc_preauth_cn.xml DEL /F %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_ps_cc_preauth_cn.xml
IF EXISTS %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_ps_cc_validatecardwithoutaccount_cn.xml DEL /F %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_ps_cc_validatecardwithoutaccount_cn.xml
IF EXISTS %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_ps_paymentscheduler_cn.xml DEL /F %TargetDir%\Extensions\PaymentSvrClient\config\localization\metratech.com\metratech.com_ps_paymentscheduler_cn.xml
IF EXISTS %TargetDir%\Extensions\PaymentSvrClient\_MetraNet_6.0.1 DEL /F %TargetDir%\Extensions\PaymentSvrClient\_MetraNet_6.0.1
IF EXISTS %TargetDir%\Extensions\Reporting\_MetraNet_6.0.1 DEL /F %TargetDir%\Extensions\Reporting\_MetraNet_6.0.1
IF EXISTS %TargetDir%\Extensions\SampleSite\_MetraNet_6.0.1 DEL /F %TargetDir%\Extensions\SampleSite\_MetraNet_6.0.1
IF EXISTS %TargetDir%\Extensions\SystemConfig\config\localization\metratech.com\metratech.com_failedtransaction_cn.xml DEL /F %TargetDir%\Extensions\SystemConfig\config\localization\metratech.com\metratech.com_failedtransaction_cn.xml
IF EXISTS %TargetDir%\Extensions\_MetraNet_6.0.1 DEL /F %TargetDir%\Extensions\_MetraNet_6.0.1
IF EXISTS %TargetDir%\UI\MCM\default\localized\us\Help\* DEL /F %TargetDir%\UI\MCM\default\localized\us\Help\*
IF EXISTS %TargetDir%\UI\MetraCareHelp\en-us rd /S /Q %TargetDir%\UI\MetraCareHelp\en-us
IF EXISTS %TargetDir%\UI\MetraNet\bin rd /S /Q %TargetDir%\UI\MetraNet\bin
IF EXISTS %TargetDir%\UI\MOM\default\localized\us\help rd /S /Q %TargetDir%\UI\MOM\default\localized\us\help
IF EXISTS %TargetDir%\UI\Suggest\bin rd /S /Q %TargetDir%\UI\Suggest\bin
IF EXISTS %TargetDir%\WebServices\AccountHierarchy\bin rd /S /Q %TargetDir%\WebServices\AccountHierarchy\bin
IF EXISTS %TargetDir%\WebServices\Batch\bin rd /S /Q %TargetDir%\WebServices\Batch\bin
IF EXISTS %TargetDir%\WebServices\BillingRerun\bin rd /S /Q %TargetDir%\WebServices\BillingRerun\bin
IF EXISTS %TargetDir%\WebServices\_MetraNet_6.0.1 DEL /F %TargetDir%\WebServices\_MetraNet_6.0.1
IF EXISTS %TargetDir%\_MetraNet_6.0.1 DEL /F %TargetDir%\_MetraNet_6.0.1

REM Apply modified files
XCOPY /E /V /H /Y /Z %SrcDir%\Bin\* %TargetDir%\Bin\
Copy /Y %SrcDir%\Config\EmailTemplate\UpdatePasswordEMailNotificationTemplate.xml %TargetDir%\Config\EmailTemplate\UpdatePasswordEMailNotificationTemplate.xml
COPY /Y %SrcDir%\Config\Queries\Account\MTAccountViewQueries.xml %TargetDir%\Config\Queries\Account\MTAccountViewQueries.xml
COPY /Y %SrcDir%\Config\Queries\Account\MTAccountViewQueries_Oracle.xml %TargetDir%\Config\Queries\Account\MTAccountViewQueries_Oracle.xml
COPY /Y %SrcDir%\Config\Queries\Adjustments\CommonQueries.xml %TargetDir%\Config\Queries\Adjustments\CommonQueries.xml
COPY /Y %SrcDir%\Config\Queries\DBInstall\AccHierarchies\Queries.xml %TargetDir%\Config\Queries\DBInstall\AccHierarchies\Queries.xml
COPY /Y %SrcDir%\Config\Queries\DBInstall\AccHierarchies\Queries_Oracle.xml %TargetDir%\Config\Queries\DBInstall\AccHierarchies\Queries_Oracle.xml
COPY /Y %SrcDir%\Config\Queries\DBInstall\Auth\SP\Queries.xml %TargetDir%\Config\Queries\DBInstall\Auth\SP\Queries.xml
COPY /Y %SrcDir%\Config\Queries\DBInstall\ProductCatalog\Queries.xml %TargetDir%\Config\Queries\DBInstall\ProductCatalog\Queries.xml
COPY /Y %SrcDir%\Config\Queries\DBInstall\ProductCatalog\Queries_Oracle.xml %TargetDir%\Config\Queries\DBInstall\ProductCatalog\Queries_Oracle.xml
COPY /Y %SrcDir%\Config\Queries\DBInstall\Queries.xml %TargetDir%\Config\Queries\DBInstall\Queries.xml
COPY /Y %SrcDir%\Config\Queries\DBInstall\Queries_Oracle.xml %TargetDir%\Config\Queries\DBInstall\Queries_Oracle.xml
COPY /Y %SrcDir%\Config\Queries\ElectronicPaymentService\QueriesSQL.xml %TargetDir%\Config\Queries\ElectronicPaymentService\QueriesSQL.xml
COPY /Y %SrcDir%\Config\Queries\PresServer\CommonQueries.xml %TargetDir%\Config\Queries\PresServer\CommonQueries.xml
COPY /Y %SrcDir%\Config\Queries\PresServer\MTPresServer.xml %TargetDir%\Config\Queries\PresServer\MTPresServer.xml
COPY /Y %SrcDir%\Config\Queries\PresServer\MTPresServer_Oracle.xml %TargetDir%\Config\Queries\PresServer\MTPresServer_Oracle.xml
COPY /Y %SrcDir%\Config\Queries\ProductCatalog\CommonQueries.xml %TargetDir%\Config\Queries\ProductCatalog\CommonQueries.xml
COPY /Y %SrcDir%\Config\Queries\UsageServer\Adapters\PaymentAuthorizationAdapter\Queries_Oracle.xml %TargetDir%\Config\Queries\UsageServer\Adapters\PaymentAuthorizationAdapter\Queries_Oracle.xml
COPY /Y %SrcDir%\Extensions\Account\config\GridLayouts %TargetDir%\Extensions\Account\config\GridLayouts
COPY /Y %SrcDir%\Extensions\Account\config\Localization\metratech.com %TargetDir%\Extensions\Account\config\Localization\metratech.com
COPY /Y %SrcDir%\Extensions\Account\config\PageLayouts %TargetDir%\Extensions\Account\config\PageLayouts
COPY /Y %SrcDir%\Extensions\Core\config\ActivityServices\CoreServices.XML %TargetDir%\Extensions\Core\config\ActivityServices\CoreServices.XML
COPY /Y %SrcDir%\Extensions\Core\config\PageLayouts\DataTypes.xml %TargetDir%\Extensions\Core\config\PageLayouts\DataTypes.xml
COPY /Y %SrcDir%\Extensions\Core\config\ProductView\metratech.com\testparent.msixdef %TargetDir%\Extensions\Core\config\ProductView\metratech.com\testparent.msixdef
COPY /Y %SrcDir%\Extensions\Core\config\ProductView\metratech.com\testservice.msixdef %TargetDir%\Extensions\Core\config\ProductView\metratech.com\testservice.msixdef
COPY /Y %SrcDir%\Extensions\PageNav\Config\ActivityServices\Workflows\AddAccountWorkflow.csproj %TargetDir%\Extensions\PageNav\Config\ActivityServices\Workflows\AddAccountWorkflow.csproj
COPY /Y %SrcDir%\Extensions\PaymentSvrClient\config\UsageServer\PayAuthAdapter_US.xml %TargetDir%\Extensions\PaymentSvrClient\config\UsageServer\PayAuthAdapter_US.xml
COPY /Y %SrcDir%\Extensions\PaymentSvrClient\config\UsageServer\PaymentSubmissionAdapter.xml %TargetDir%\Extensions\PaymentSvrClient\config\UsageServer\PaymentSubmissionAdapter.xml
COPY /Y %SrcDir%\Extensions\Reporting\WebService\MetraTech.Reports.WebService.dll %TargetDir%\Extensions\Reporting\WebService\MetraTech.Reports.WebService.dll
COPY /Y %SrcDir%\Extensions\SampleSite\MPS\siteconfig\Validation.xml %TargetDir%\Extensions\SampleSite\MPS\siteconfig\Validation.xml
COPY /Y %SrcDir%\Extensions\SampleSite\MPS\SiteRoot\us\optionsPaymentCreditCard.asp %TargetDir%\Extensions\SampleSite\MPS\SiteRoot\us\optionsPaymentCreditCard.asp
COPY /Y %SrcDir%\Install\Scripts\Common.vbs %TargetDir%\Install\Scripts\Common.vbs
COPY /Y %SrcDir%\Install\Scripts\Crypto.vbs %TargetDir%\Install\Scripts\Crypto.vbs
COPY /Y %SrcDir%\Install\Scripts\Database.vbs %TargetDir%\Install\Scripts\Database.vbs
COPY /Y %SrcDir%\Install\Scripts\staging.mak %TargetDir%\Install\Scripts\staging.mak
COPY /Y %SrcDir%\UI\ImageHandler\Bin %TargetDir%\UI\ImageHandler\Bin
COPY /Y %SrcDir%\UI\MAM\default\dialog\capabilities\OwnedAccountsCapability.asp %TargetDir%\UI\MAM\default\dialog\capabilities\OwnedAccountsCapability.asp
COPY /Y %SrcDir%\UI\MAM\default\dialog\AccountStateEdit.htm %TargetDir%\UI\MAM\default\dialog\AccountStateEdit.htm
COPY /Y %SrcDir%\UI\MAM\default\dialog\AccountStateSetup.asp %TargetDir%\UI\MAM\default\dialog\AccountStateSetup.asp
COPY /Y %SrcDir%\UI\MAM\default\dialog\AccountStateUpdate.asp %TargetDir%\UI\MAM\default\dialog\AccountStateUpdate.asp
COPY /Y %SrcDir%\UI\MAM\default\dialog\Adjustment.Edit.Parent.htm %TargetDir%\UI\MAM\default\dialog\Adjustment.Edit.Parent.htm
COPY /Y %SrcDir%\UI\MAM\default\dialog\BulkAdjustment.Edit.htm %TargetDir%\UI\MAM\default\dialog\BulkAdjustment.Edit.htm
COPY /Y %SrcDir%\UI\MAM\default\dialog\BulkAdjustment.PVB.asp %TargetDir%\UI\MAM\default\dialog\BulkAdjustment.PVB.asp
COPY /Y %SrcDir%\UI\MAM\default\dialog\BulkRebill.Edit.htm %TargetDir%\UI\MAM\default\dialog\BulkRebill.Edit.htm
COPY /Y %SrcDir%\UI\MAM\default\dialog\DefaultDialogAddCSR.asp %TargetDir%\UI\MAM\default\dialog\DefaultDialogAddCSR.asp
COPY /Y %SrcDir%\UI\MAM\default\dialog\GroupAdd.asp %TargetDir%\UI\MAM\default\dialog\GroupAdd.asp
COPY /Y %SrcDir%\UI\MAM\default\dialog\ManageRoles.asp %TargetDir%\UI\MAM\default\dialog\ManageRoles.asp
COPY /Y %SrcDir%\UI\MAM\default\dialog\MetraTech.Accounts.Hierarchy.ClientControl.dll %TargetDir%\UI\MAM\default\dialog\MetraTech.Accounts.Hierarchy.ClientControl.dll
COPY /Y %SrcDir%\UI\MAM\default\dialog\MetraTech.Accounts.Hierarchy.ClientControl.pdb %TargetDir%\UI\MAM\default\dialog\MetraTech.Accounts.Hierarchy.ClientControl.pdb
COPY /Y %SrcDir%\UI\MAM\default\Lib\CAccountTemplateHelper.asp %TargetDir%\UI\MAM\default\Lib\CAccountTemplateHelper.asp
COPY /Y %SrcDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedConst.xml %TargetDir%\UI\MAM\default\localized\us\TextLookUp\LocalizedConst.xml
COPY /Y %SrcDir%\UI\MCM\default\dialog\Login.htm %TargetDir%\UI\MCM\default\dialog\Login.htm
COPY /Y %SrcDir%\UI\MCM\default\dialog\ProductOffering.ViewEdit.Items.asp %TargetDir%\UI\MCM\default\dialog\ProductOffering.ViewEdit.Items.asp
COPY /Y %SrcDir%\UI\MCM\default\dialog\upgradeBrowser.htm %TargetDir%\UI\MCM\default\dialog\upgradeBrowser.htm
COPY /Y %SrcDir%\UI\MDM\mdmLibrary.asp %TargetDir%\UI\MDM\mdmLibrary.asp
COPY /Y %SrcDir%\UI\MetraCare\Account\App_LocalResources\AddAccount.aspx.resx %TargetDir%\UI\MetraCare\Account\App_LocalResources\AddAccount.aspx.resx
COPY /Y %SrcDir%\UI\MetraCare\Account\App_LocalResources\AddSystemUser.aspx.resx %TargetDir%\UI\MetraCare\Account\App_LocalResources\AddSystemUser.aspx.resx
COPY /Y %SrcDir%\UI\MetraCare\Account\App_LocalResources\UpdateAccount.aspx.resx %TargetDir%\UI\MetraCare\Account\App_LocalResources\UpdateAccount.aspx.resx
COPY /Y %SrcDir%\UI\MetraCare\Account\AccountCreated.aspx %TargetDir%\UI\MetraCare\Account\AccountCreated.aspx
COPY /Y %SrcDir%\UI\MetraCare\Account\AddAccount.aspx %TargetDir%\UI\MetraCare\Account\AddAccount.aspx
COPY /Y %SrcDir%\UI\MetraCare\Account\AddSystemUser.aspx %TargetDir%\UI\MetraCare\Account\AddSystemUser.aspx
COPY /Y %SrcDir%\UI\MetraCare\Account\GenericAccountSummary.aspx.cs %TargetDir%\UI\MetraCare\Account\GenericAccountSummary.aspx.cs
COPY /Y %SrcDir%\UI\MetraCare\Account\GenericAddAccount.aspx %TargetDir%\UI\MetraCare\Account\GenericAddAccount.aspx
COPY /Y %SrcDir%\UI\MetraCare\Account\GenericUpdateAccount.aspx %TargetDir%\UI\MetraCare\Account\GenericUpdateAccount.aspx
COPY /Y %SrcDir%\UI\MetraCare\Account\GenericUpdateAccount.aspx.cs %TargetDir%\UI\MetraCare\Account\GenericUpdateAccount.aspx.cs
COPY /Y %SrcDir%\UI\MetraCare\Account\UpdateAccount.aspx %TargetDir%\UI\MetraCare\Account\UpdateAccount.aspx
COPY /Y %SrcDir%\UI\MetraCare\Account\UpdateSystemAccount.aspx %TargetDir%\UI\MetraCare\Account\UpdateSystemAccount.aspx
COPY /Y %SrcDir%\UI\MetraCare\AjaxServices\FindAccountSvc.aspx.cs %TargetDir%\UI\MetraCare\AjaxServices\FindAccountSvc.aspx.cs
COPY /Y %SrcDir%\UI\MetraCare\AjaxServices\FindCCSvc.aspx.cs %TargetDir%\UI\MetraCare\AjaxServices\FindCCSvc.aspx.cs
COPY /Y %SrcDir%\UI\MetraCare\AjaxServices\GetData.aspx.cs %TargetDir%\UI\MetraCare\AjaxServices\GetData.aspx.cs
COPY /Y %SrcDir%\UI\MetraCare\AjaxServices\UpdateSettings.aspx.cs %TargetDir%\UI\MetraCare\AjaxServices\UpdateSettings.aspx.cs
COPY /Y %SrcDir%\UI\MetraCare\App_Code\RenderMenu.cs %TargetDir%\UI\MetraCare\App_Code\RenderMenu.cs
COPY /Y %SrcDir%\UI\MetraCare\App_GlobalResources\ErrorMessages.resx %TargetDir%\UI\MetraCare\App_GlobalResources\ErrorMessages.resx
COPY /Y %SrcDir%\UI\MetraCare\App_GlobalResources\Resource.resx %TargetDir%\UI\MetraCare\App_GlobalResources\Resource.resx
XCOPY /E /V /H /Y /Z %SrcDir%\UI\MetraCare\Bin\* %TargetDir%\UI\MetraCare\Bin\
COPY /Y %SrcDir%\UI\MetraCare\JavaScript\Common.js %TargetDir%\UI\MetraCare\JavaScript\Common.js
COPY /Y %SrcDir%\UI\MetraCare\JavaScript\Localized.js %TargetDir%\UI\MetraCare\JavaScript\Localized.js
COPY /Y %SrcDir%\UI\MetraCare\JavaScript\Renderers.js %TargetDir%\UI\MetraCare\JavaScript\Renderers.js
COPY /Y %SrcDir%\UI\MetraCare\JavaScript\RowSelectionModelOverride.js %TargetDir%\UI\MetraCare\JavaScript\RowSelectionModelOverride.js
COPY /Y %SrcDir%\UI\MetraCare\JavaScript\ViewPort.js %TargetDir%\UI\MetraCare\JavaScript\ViewPort.js
COPY /Y %SrcDir%\UI\MetraCare\MasterPages\MetraCareExt.master %TargetDir%\UI\MetraCare\MasterPages\MetraCareExt.master
COPY /Y %SrcDir%\UI\MetraCare\MasterPages\MetraCareExt.master.cs %TargetDir%\UI\MetraCare\MasterPages\MetraCareExt.master.cs
COPY /Y %SrcDir%\UI\MetraCare\MasterPages\NoMenuPageExt.master %TargetDir%\UI\MetraCare\MasterPages\NoMenuPageExt.master
COPY /Y %SrcDir%\UI\MetraCare\MasterPages\PageExt.master %TargetDir%\UI\MetraCare\MasterPages\PageExt.master
COPY /Y %SrcDir%\UI\MetraCare\Payments\CreditCardAdd.aspx.cs %TargetDir%\UI\MetraCare\Payments\CreditCardAdd.aspx.cs
COPY /Y %SrcDir%\UI\MetraCare\Payments\CreditCardRemove.aspx.cs %TargetDir%\UI\MetraCare\Payments\CreditCardRemove.aspx.cs
COPY /Y %SrcDir%\UI\MetraCare\Payments\CreditCardUpdate.aspx.cs %TargetDir%\UI\MetraCare\Payments\CreditCardUpdate.aspx.cs
COPY /Y %SrcDir%\UI\MetraCare\Styles\baseStyle.css %TargetDir%\UI\MetraCare\Styles\baseStyle.css
COPY /Y %SrcDir%\UI\MetraCare\Styles\grid.css %TargetDir%\UI\MetraCare\Styles\grid.css
COPY /Y %SrcDir%\UI\MetraCare\Subscriptions\App_LocalResources\SelectPO.aspx.resx %TargetDir%\UI\MetraCare\Subscriptions\App_LocalResources\SelectPO.aspx.resx
COPY /Y %SrcDir%\UI\MetraCare\Subscriptions\App_LocalResources\Subscriptions.aspx.resx %TargetDir%\UI\MetraCare\Subscriptions\App_LocalResources\Subscriptions.aspx.resx
COPY /Y %SrcDir%\UI\MetraCare\Subscriptions\DeleteSubscription.aspx.cs %TargetDir%\UI\MetraCare\Subscriptions\DeleteSubscription.aspx.cs
COPY /Y %SrcDir%\UI\MetraCare\Subscriptions\SaveSubscriptions.aspx.cs %TargetDir%\UI\MetraCare\Subscriptions\SaveSubscriptions.aspx.cs
COPY /Y %SrcDir%\UI\MetraCare\Subscriptions\SelectPO.aspx %TargetDir%\UI\MetraCare\Subscriptions\SelectPO.aspx
COPY /Y %SrcDir%\UI\MetraCare\Subscriptions\SelectPO.aspx.cs %TargetDir%\UI\MetraCare\Subscriptions\SelectPO.aspx.cs
COPY /Y %SrcDir%\UI\MetraCare\Subscriptions\SetUDRCValues.aspx.cs %TargetDir%\UI\MetraCare\Subscriptions\SetUDRCValues.aspx.cs
COPY /Y %SrcDir%\UI\MetraCare\Subscriptions\Subscriptions.aspx %TargetDir%\UI\MetraCare\Subscriptions\Subscriptions.aspx
COPY /Y %SrcDir%\UI\MetraCare\UserControls\AccountMenu.ascx.cs %TargetDir%\UI\MetraCare\UserControls\AccountMenu.ascx.cs 
COPY /Y %SrcDir%\UI\MetraCare\UserControls\Error.ascx %TargetDir%\UI\MetraCare\UserControls\Error.ascx
COPY /Y %SrcDir%\UI\MetraCare\ux\grid\GridFilters.js %TargetDir%\UI\MetraCare\ux\grid\GridFilters.js
COPY /Y %SrcDir%\UI\MetraCare\ux\grid\RowSelectionPaging.js %TargetDir%\UI\MetraCare\ux\grid\RowSelectionPaging.js
COPY /Y %SrcDir%\UI\MetraCare\AccountNavigation.aspx %TargetDir%\UI\MetraCare\AccountNavigation.aspx
COPY /Y %SrcDir%\UI\MetraCare\AccountNavigation.aspx.cs %TargetDir%\UI\MetraCare\AccountNavigation.aspx.cs
COPY /Y %SrcDir%\UI\MetraCare\AccountSelector.aspx %TargetDir%\UI\MetraCare\AccountSelector.aspx
COPY /Y %SrcDir%\UI\MetraCare\AccountSelector.aspx.cs %TargetDir%\UI\MetraCare\AccountSelector.aspx.cs
COPY /Y %SrcDir%\UI\MetraCare\AdvancedFind.aspx %TargetDir%\UI\MetraCare\AdvancedFind.aspx
COPY /Y %SrcDir%\UI\MetraCare\AdvancedFind.aspx.cs %TargetDir%\UI\MetraCare\AdvancedFind.aspx.cs
COPY /Y %SrcDir%\UI\MetraCare\ChangePassword.aspx.cs %TargetDir%\UI\MetraCare\ChangePassword.aspx.cs
COPY /Y %SrcDir%\UI\MetraCare\Default.aspx.cs %TargetDir%\UI\MetraCare\Default.aspx.cs
COPY /Y %SrcDir%\UI\MetraCare\EntryPoint.aspx.cs %TargetDir%\UI\MetraCare\EntryPoint.aspx.cs
COPY /Y %SrcDir%\UI\MetraCare\Global.asax %TargetDir%\UI\MetraCare\Global.asax
COPY /Y %SrcDir%\UI\MetraCare\Login.aspx.cs %TargetDir%\UI\MetraCare\Login.aspx.cs
COPY /Y %SrcDir%\UI\MetraCare\ManageAccount.aspx.cs %TargetDir%\UI\MetraCare\ManageAccount.aspx.cs
COPY /Y %SrcDir%\UI\MetraCare\UnlockAccount.aspx.cs %TargetDir%\UI\MetraCare\UnlockAccount.aspx.cs


REM Apply new files
Copy /Y %SrcDir%\Config\EmailTemplate\FinalPaymentRetryEmailTemplate.xml %TargetDir%\Config\EmailTemplate\FinalPaymentRetryEmailTemplate.xml
Copy /Y %SrcDir%\Config\EmailTemplate\PaymentRetryFailedTemplate.xml %TargetDir%\Config\EmailTemplate\PaymentRetryFailedTemplate.xml
IF NOT EXISTS %TargetDir%\Config\Logging\HighResolutionTimer md %TargetDir%\Config\Logging\HighResolutionTimer
COPY /Y %SrcDir%\Config\Logging\HighResolutionTimer %TargetDir%\Config\Logging\HighResolutionTimer
IF NOT EXISTS %TargetDir%\Config\Queries\UsageServer\Adapters\CreditCardDunningAdapter MD %TargetDir%\Config\Queries\UsageServer\Adapters\CreditCardDunningAdapter
COPY /Y %SrcDir%\Config\Queries\UsageServer\Adapters\CreditCardDunningAdapter %TargetDir%\Config\Queries\UsageServer\Adapters\CreditCardDunningAdapter
IF EXISTS %TargetDir%\Extensions\AR COPY /Y %SrcDir%\Extensions\AR\_MetraNet_6.0.2 %TargetDir%\Extensions\AR\_MetraNet_6.0.2
IF EXISTS %TargetDir%\Extensions\ARSample COPY /Y %SrcDir%\Extensions\ARSample\_MetraNet_6.0.2 %TargetDir%\Extensions\AR\_MetraNet_6.0.2
IF NOT EXISTS %TargetDir%\Extensions\PaymentSvr\config\MetraPay MD %TargetDir%\Extensions\PaymentSvr\config\MetraPay
COPY \Y %SrcDir%\Extensions\PaymentSvr\config\MetraPay\TestGatewayStub.xml %TargetDir%\Extensions\PaymentSvr\config\MetraPay\TestGatewayStub.xml
IF EXISTS %TargetDir%\Extensions\PaymentSvr COPY /Y %SrcDir%\Extensions\PaymentSvr\_MetraNet_6.0.2 %TargetDir%\Extensions\PaymentSvr\_MetraNet_6.0.2
COPY /Y %SrcDir%\Extensions\PaymentSvrClient\config\MetraPay\MetraPayRouter.csproj %TargetDir%\Extensions\PaymentSvrClient\config\MetraPay\MetraPayRouter.csproj
COPY /Y %SrcDir%\Extensions\PaymentSvrClient\config\UsageServer\Workflows\CreditCardDunningAdapterWorkflow.rules %TargetDir%\Extensions\PaymentSvrClient\config\UsageServer\Workflows\CreditCardDunningAdapterWorkflow.rules
COPY /Y %SrcDir%\Extensions\PaymentSvrClient\config\UsageServer\Workflows\CreditCardDunningAdapterWorkflow.xoml %TargetDir%\Extensions\PaymentSvrClient\config\UsageServer\Workflows\CreditCardDunningAdapterWorkflow.xoml
COPY /Y %SrcDir%\Extensions\PaymentSvrClient\config\UsageServer\Workflows\CreditCardDunningAdapterWorkflow_info.xml %TargetDir%\Extensions\PaymentSvrClient\config\UsageServer\Workflows\CreditCardDunningAdapterWorkflow_info.xml
COPY /Y %SrcDir%\Extensions\PaymentSvrClient\config\UsageServer\CreditCardDunningAdapter.xml %TargetDir%\Extensions\PaymentSvrClient\config\UsageServer\CreditCardDunningAdapter.xml
IF EXISTS %TargetDir%\Extensions\PaymentSvrClient COPY /Y %SrcDir%\Extensions\PaymentSvrClient\_MetraNet_6.0.2 %TargetDir%\Extensions\PaymentSvrClient\_MetraNet_6.0.2
IF EXISTS %TargetDir%\Extensions\Reporting COPY /Y %SrcDir%\Extensions\Reporting\_MetraNet_6.0.2 %TargetDir%\Extensions\Reporting\_MetraNet_6.0.2
IF EXISTS %TargetDir%\Extensions\SampleSite COPY /Y %SrcDir%\Extensions\SampleSite\_MetraNet_6.0.2 %TargetDir%\Extensions\SampleSite\_MetraNet_6.0.2
IF EXISTS %TargetDir%\Extensions COPY /Y %SrcDir%\Extensions\_MetraNet_6.0.2 %TargetDir%\Extensions\_MetraNet_6.0.2
COPY /Y %SrcDir%\Test\Database\NetMeter601sql.erwin %TargetDir%\Test\Database\NetMeter601sql.erwin
COPY /Y %SrcDir%\UI\MCM\default\localized\us\Help %TargetDir%\UI\MCM\default\localized\us\Help
COPY /Y %SrcDir%\UI\MetraCare\Account\App_LocalResources\GenericUpdateAccount.aspx.resx %TargetDir%\UI\MetraCare\Account\App_LocalResources\GenericUpdateAccount.aspx.resx
COPY /Y %SrcDir%\UI\MetraCare\App_Code\GridRenderer.cs %TargetDir%\UI\MetraCare\App_Code\GridRenderer.cs
COPY /Y %SrcDir%\UI\MetraCare\App_LocalResources\AccountNavigation.aspx.resx %TargetDir%\UI\MetraCare\App_LocalResources\AccountNavigation.aspx.resx
COPY /Y %SrcDir%\UI\MetraCare\App_LocalResources\AccountSelector.aspx.resx %TargetDir%\UI\MetraCare\App_LocalResources\AccountSelector.aspx.resx
COPY /Y %SrcDir%\UI\MetraCare\App_LocalResources\AdvancedFind.aspx.resx %TargetDir%\UI\MetraCare\App_LocalResources\AdvancedFind.aspx.resx
COPY /Y %SrcDir%\UI\MetraCare\Images\icons\disabled_checkbox.PNG %TargetDir%\UI\MetraCare\Images\icons\disabled_checkbox.PNG
COPY /Y %SrcDir%\UI\MetraCare\ux\grid\RowSelectionPaging.js %TargetDir%\UI\MetraCare\ux\grid\RowSelectionPaging.js
XCOPY /E /V /H /Y /Z %SrcDir%\UI\MetraCareHelp\en-us\* %TargetDir%\UI\MetraCareHelp\en-us
XCOPY /E /V /H /Y /Z %SrcDir%\UI\MetraNet\bin\* %TargetDir%\UI\MetraNet\bin
XCOPY /E /V /H /Y /Z %SrcDir%\UI\MOM\default\localized\us\help\* %TargetDir%\UI\MOM\default\localized\us\help
XCOPY /E /V /H /Y /Z %SrcDir%\UI\Suggest\bin\* %TargetDir%\UI\Suggest\bin
XCOPY /E /V /H /Y /Z %SrcDir%\WebServices\AccountHierarchy\bin\* %TargetDir%\WebServices\AccountHierarchy\bin
XCOPY /E /V /H /Y /Z %SrcDir%\WebServices\Batch\bin\* %TargetDir%\WebServices\Batch\bin
XCOPY /E /V /H /Y /Z %SrcDir%\WebServices\BillingRerun\bin\* %TargetDir%\WebServices\BillingRerun\bin
COPY /Y %SrcDir%\WebServices\_MetraNet_6.0.2 %TargetDir%\WebServices\_MetraNet_6.0.2
COPY /Y %SrcDir%\_MetraNet_6.0.2 %TargetDir%\_MetraNet_6.0.2


ECHO Blacklisted Files That Require Manual Merging:
ECHO RMP\Config\ActivityServices\ActivityServicesHost.xml
ECHO RMP\Config\MetraPay\MetraPayHost.xml
ECHO RMP\Extensions\PaymentSvrClient\config\UsageServer\recurring_events.xml
ECHO RMP\UI\MetraCare\Web.Config

goto :end

:Error
echo Command parameters not specified
echo Usage: ApplyCorePackage [srcDir] [targetDir]

:end
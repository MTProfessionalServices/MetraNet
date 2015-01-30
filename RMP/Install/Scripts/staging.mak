############################################################################
#
# staging.mak
# 
# This makefile is used to populate the staging area.
#
# Required environment variables:
#  VERSION
#  LABEL
#  DEBUG
#  INSTALLRELDIR
#  THIRDPARTY
#
###########################################################################


################################################
## Commands and General Macros
################################################

CP       = cp -pu
CPDIR    = perl S:\install\scripts\copyTree.pl -s
MKDIR    = perl S:\install\scripts\makePath.pl
RMDIR    = perl S:\install\scripts\removeTree.pl
CD       = cd
REMOVE   = rm -Rf
CPWEBSVC = perl S:\install\scripts\copyWebSvcFiles.pl
PVK2PFX  = pvk2pfx -pvk MetraTech.pvk -spc MetraTech.spc -pi MetraTech2 -pfx MetraTech.pfx -f

DELIM    = ---------------------------------------------------------------------------
DDELIM   = ===========================================================================


################################################
# Debug or Release
################################################

!if "$(DEBUG)" == "" || "$(DEBUG)" == "1"
BLDTYPE=debug
!else
BLDTYPE=release
!endif


################################################
# SOURCE LOCATIONS
################################################

S_BASE_DIR         = S:
S_METRANET_DIR     = R:
S_METRACONNECT_DIR = V:\MetraConnect
S_TECHDOC_DIR      = P:\TechDoc
S_3RDPARTY_DIR     = $(THIRDPARTY)
S_KEY_DIR          = $(S_BASE_DIR)\build\keys

S_METRATECH_DIR    = $(S_BASE_DIR)\MetraTech
S_MVMEXTCORE_DIR     = R:\Extensions\MvmCore
S_MVMEXTAMP_DIR     = R:\Extensions\MvmAmp


################################################
# OUTPUT LOCATIONS
################################################

O_BASE_DIR         = O:\$(BLDTYPE)

O_BIN_DIR          = $(O_BASE_DIR)\bin
O_LIB_DIR          = $(O_BASE_DIR)\lib
O_INCLUDE_DIR      = $(O_BASE_DIR)\include
O_JAVA_DIR         = $(O_BASE_DIR)\java


################################################
# STAGING LOCATIONS
################################################

P_BASE_DIR         = $(INSTALLRELDIR)

P_DATABASE_DIR     = $(P_BASE_DIR)\Database


################################################
# OTHER CONSTANTS
################################################

PLACEHOLDER=_MetraNet_$(VERSION)


################################################
# Binaries
################################################

# All binary files that do not require COM registration and do not require MSI to register them for COM interop
# These files will be copied to RMP bin - when in doubt, put your new stuff in here

BINARIES = \
  AccountImportExport.exe \
  AccountImportExport.exe.config \
  AccountImportExport.pdb \
  AccountImportTool.exe \
  AccountImportTool.exe.config \
  AccountImportTool.pdb \
  AddAccountMappings.exe \
  AddAccountMappings.pdb \
  AddDefaultAccounts.exe \
  AddDefaultAccounts.pdb \
  AddKey.exe \
  AddKey.pdb \
  AddProductView.exe \
  AddProductView.pdb \
  AddViewHierarchy.exe \
  AddViewHierarchy.pdb \
  agsXMPP.dll \
  antlr.runtime.dll \
  Antlr3.Runtime.dll \
  Antlr4.Runtime.v4.0.dll \
  ARSetup.exe \
  ARSetup.pdb \
  autosdk.exe \
  autosdk.pdb \
  BillSoftInstallationHelper.exe \
  BillSoftInstallationHelper.pdb \
  BMEImportExport.exe \
  BMEImportExport.pdb \
  BmeSync.exe \
  BmeSync.pdb \
  Castle.Core.dll \
  Castle.DynamicProxy2.dll \
  Castle.MicroKernel.dll \
  Castle.Windsor.dll \
  CCHashGenerator.exe \
  CCHashGenerator.pdb \
  cmdmem.exe \
  cmdmem.pdb \
  cmdprof.exe \
  cmdprof.pdb \
  cmdstage.exe \
  cmdstage.pdb \
  CodeLookup.dll \
  CodeLookup.pdb \
  CommonServiceLocator.WindsorAdapter.dll \
  ConfigReaders.dll \
  ConfigReaders.pdb \
  controlpipeline.exe \
  controlpipeline.pdb \
  Core.Common.Entity.dll \
  Core.Common.Entity.pdb \
  Core.Interface.dll \
  Core.UI.Entity.dll \
  CoreServicesClientProxyHook.exe \
  CoreServicesClientProxyHook.pdb \
  CreateKeyBlob.exe \
  CreateKeyBlob.pdb \
  CryptoSetup.exe \
  CryptoSetup.pdb \
  DataAnalysisView.dll \
  DataAnalysisView.pdb \
  DatabaseInstall.exe \
  DatabaseInstall.pdb \
  DatabaseInstaller.exe \
  DatabaseInstaller.exe.config \
  DatabaseInstaller.pdb \
  DBAccess.dll \
  DBAccess.pdb \
  DBInstall.dll \
  DBInstall.pdb \
  DbInstallComments.exe \
  DbInstallComments.pdb \
  DBObjects.dll \
  DBObjects.pdb \
  DBUpgradeExec.exe \
  DBUpgradeExec.pdb \
  DescLoad.exe \
  DescLoad.pdb \
  DTCTest.exe \
  DTCTest.pdb \
  EntityFramework.dll \
  EZTax.net.dll \
  gendm.exe \
  gendm.pdb \
  GenerateKeyBlob.exe \
  GenerateKeyBlob.pdb \
  generatekeyblob511.exe \
  generatekeyblob511.pdb \
  ICSharpCode.SharpZipLib.dll \
  Iesi.Collections.dll \
  InstallUtil.dll \
  InstallUtil.pdb \
  InstallUtilTest.exe \
  InstallUtilTest.pdb \
  Interop.ADOX.dll \
  JabberClient.exe \
  JabberClient.pdb \
  Kiosk.dll \
  Kiosk.pdb \
  kmclient.dll \
  LinFu.Core.dll \
  LinFu.DynamicProxy.dll \
  Listener.dll \
  Listener.pdb \
  Listener_msg.dll \
  log4net.dll \
  makequeues.exe \
  makequeues.pdb \
  mappedviewtest.exe \
  mappedviewtest.pdb \
  MASClientProxyHook.exe \
  MASClientProxyHook.pdb \
  MASHostService.exe \
  MASHostService.pdb \
  MASPerfConfigEditor.exe \
  MASPerfConfigEditor.pdb \
  MASPerfTraceViewer.exe \
  MASPerfTraceViewer.pdb \
  MASRegClientCert.exe \
  MASRegClientCert.pdb \
  MemoryTable.dll \
  MemoryTable.pdb \
  MessagingServiceConsoleHost.exe \
  MessagingServiceConsoleHost.exe.config \
  MessagingServiceConsoleHost.pdb \
  MeterTool.exe \
  MeterTool.pdb \
  MetraCareWorkflowLibrary.dll \
  MetraCareWorkflowLibrary.dll \
  MetraCareWorkflowLibrary.pdb \
  MetraConnect-DB.exe \
  MetraConnect-DB.pdb \
  MetraFlowAdapters.dll \
  MetraFlowAdapters.pdb \
  MetraFlowShell.exe \
  MetraFlowShell.pdb \
  MetraPayService.exe \
  MetraPayService.pdb \
  MetraTech.ActivityServices.Activities.dll \
  MetraTech.ActivityServices.Activities.pdb \
  MetraTech.ActivityServices.ClientCodeGenerators.dll \
  MetraTech.ActivityServices.ClientCodeGenerators.pdb \
  MetraTech.ActivityServices.Common.dll \
  MetraTech.ActivityServices.Common.pdb \
  MetraTech.ActivityServices.Configuration.dll \
  MetraTech.ActivityServices.Configuration.pdb \
  MetraTech.ActivityServices.PersistenceService.dll \
  MetraTech.ActivityServices.PersistenceService.pdb \
  MetraTech.ActivityServices.Runtime.Dll \
  MetraTech.ActivityServices.Runtime.pdb \
  MetraTech.ActivityServices.Services.Common.dll \
  MetraTech.ActivityServices.Services.Common.pdb \
  MetraTech.Application.dll \
  MetraTech.Application.pdb \
  MetraTech.Approvals.dll \
  MetraTech.Approvals.pdb \
  MetraTech.AR.eConnectCOMShim.dll \
  MetraTech.AR.eConnectCOMShim.pdb \
  MetraTech.Audit.dll \
  MetraTech.Audit.pdb \
  MetraTech.Baseline.Adapters.ExecuteExternalApp.dll \
  MetraTech.Basic.dll \
  MetraTech.Basic.pdb \
  MetraTech.BusinessEntity.Core.dll \
  MetraTech.BusinessEntity.Core.pdb \
  MetraTech.BusinessEntity.DataAccess.dll \
  MetraTech.BusinessEntity.DataAccess.pdb \
  MetraTech.BusinessEntity.Hook.dll \
  MetraTech.BusinessEntity.Hook.pdb \
  MetraTech.BusinessEntity.ImportExport.dll \
  MetraTech.BusinessEntity.ImportExport.pdb \
  MetraTech.BusinessEntity.Service.ClientProxies.dll \
  MetraTech.BusinessEntity.Service.ClientProxies.pdb \
  MetraTech.BusinessEntity.Service.dll \
  MetraTech.BusinessEntity.Service.pdb \
  MetraTech.CmdLine.Tool.exe.config \
  MetraTech.CmdLine.Tool.exe \
  MetraTech.CmdLine.Tool.pdb \
  MetraTech.Core.Activities.Dll \
  MetraTech.Core.Activities.pdb \
  MetraTech.Core.Client.Dll \
  MetraTech.Core.Client.pdb \
  MetraTech.Core.RESTAPI.dll \
  MetraTech.Core.RESTAPI.pdb \
  MetraTech.Core.Services.ClientProxies.dll \
  MetraTech.Core.Services.ClientProxies.pdb \
  MetraTech.Core.Services.Dll \
  MetraTech.Core.Services.pdb \
  MetraTech.Core.Services.ProxyActivities.dll \
  MetraTech.Core.Services.ProxyActivities.pdb \
  MetraTech.Core.Workflows.Dll \
  MetraTech.Core.Workflows.pdb \
  MetraTech.CreditNotes.dll \
  MetraTech.CreditNotes.pdb \
  MetraTech.Crypto511.dll \
  MetraTech.Crypto511.pdb \
  MetraTech.DataAccess.Hinter.dll \
  MetraTech.DataAccess.Hinter.pdb \
  MetraTech.DataAccess.QueryManagement.dll \
  MetraTech.DataExportFramework.Adapters.EOPQueueReports.dll \
  MetraTech.DataExportFramework.Adapters.EOPQueueReports.pdb \
  MetraTech.DataExportFramework.Adapters.QueueScheduledReportsAdapter.dll \
  MetraTech.DataExportFramework.Adapters.QueueScheduledReportsAdapter.pdb \
  MetraTech.DataExportFramework.Components.DataExporter.dll \
  MetraTech.DataExportFramework.Components.DataExporter.pdb \
  MetraTech.DataExportFramework.Components.DataFormatters.dll \
  MetraTech.DataExportFramework.Components.DataFormatters.pdb \
  MetraTech.DataExportFramework.Common.dll \
  MetraTech.DataExportFramework.Common.pdb \
  MetraTech.Dataflow.dll \
  MetraTech.Dataflow.pdb \
  MetraTech.Dataflow.Template.dll \
  MetraTech.Dataflow.Template.pdb \
  MetraTech.Debug.Diagnostics.dll \
  MetraTech.Debug.Diagnostics.pdb \
  MetraTech.Debug.DTCTestLib.dll \
  MetraTech.Debug.DTCTestLib.pdb \
  MetraTech.Domain.dll \
  MetraTech.Domain.pdb \
  MetraTech.DomainModel.AccountTypes.Generated.dll \
  MetraTech.DomainModel.AccountTypes.Generated.pdb \
  MetraTech.DomainModel.BaseTypes.dll \
  MetraTech.DomainModel.BaseTypes.pdb \
  MetraTech.DomainModel.Billing.dll \
  MetraTech.DomainModel.Billing.Generated.dll \
  MetraTech.DomainModel.Billing.Generated.pdb \
  MetraTech.DomainModel.Billing.pdb \
  MetraTech.DomainModel.CodeGenerator.dll \
  MetraTech.DomainModel.CodeGenerator.pdb \
  MetraTech.DomainModel.Common.dll \
  MetraTech.DomainModel.Common.pdb \
  MetraTech.DomainModel.Enums.dll \
  MetraTech.DomainModel.Enums.Generated.dll \
  MetraTech.DomainModel.Enums.Generated.pdb \
  MetraTech.DomainModel.Enums.pdb \
  MetraTech.DomainModel.Hooks.dll \
  MetraTech.DomainModel.Hooks.pdb \
  MetraTech.DomainModel.MetraPay.dll \
  MetraTech.DomainModel.MetraPay.pdb \
  MetraTech.DomainModel.ProductCatalog.dll \
  MetraTech.DomainModel.ProductCatalog.Generated.dll \
  MetraTech.DomainModel.ProductCatalog.Generated.pdb \
  MetraTech.DomainModel.ProductCatalog.pdb \
  MetraTech.DomainModel.Validators.dll \
  MetraTech.DomainModel.Validators.pdb \
  MetraTech.FileLandingService.exe.config \
  MetraTech.Events.dll \
  MetraTech.Events.pdb \
  MetraTech.NotificationEvents.EventHandler.dll \
  MetraTech.NotificationEvents.EventHandler.pdb \
  MetraTech.Messaging.Framework.dll \
  MetraTech.Messaging.Framework.pdb \
  MetraTech.Messaging.MessagingService.exe \
  MetraTech.Messaging.MessagingService.pdb \
  MetraTech.Metering.DatabaseMetering.dll \
  MetraTech.Metering.DatabaseMetering.pdb \
  MetraTech.MetraPay.Client.dll \
  MetraTech.MetraPay.Client.pdb \
  MetraTech.MetraPay.PaymentGateway.dll \
  MetraTech.MetraPay.PaymentGateway.pdb \
  MetraTech.Security.Common.dll \
  MetraTech.Security.Common.pdb \
  MetraTech.Security.Crypto.dll \
  MetraTech.Security.Crypto.pdb \
  MetraTech.Security.dll \
  MetraTech.Security.DPAPI.dll \
  MetraTech.Security.DPAPI.pdb \
  MetraTech.Security.pdb \
  MetraTech.Security.Hooks.dll \
  MetraTech.Security.Hooks.pdb \
  MetraTech.SecurityFramework.Core.Common.dll \
  MetraTech.SecurityFramework.Core.Common.pdb \
  MetraTech.SecurityFramework.MTLogging.dll \
  MetraTech.SecurityFramework.MTLogging.pdb \
  MetraTech.SecurityFramework.Serialization.dll \
  MetraTech.SecurityFramework.Serialization.pdb \
  MetraTech.Tax.Framework.dll \
  MetraTech.Tax.Framework.pdb \
  MetraTech.Tax.Plugins.BillSoft.PCodeLookup.dll \
  MetraTech.Tax.Plugins.BillSoft.PCodeLookup.pdb \
  MetraTech.Tax.Plugins.TaxCalculateMetraTax.dll \
  MetraTech.Tax.Plugins.TaxCalculateVertexQ.dll \
  MetraTech.Tax.Plugins.TaxCalculateVertexQ.pdb \
  MetraTech.Test.dll \
  MetraTech.Test.Harness.dll \
  MetraTech.Test.Harness.pdb \
  MetraTech.Test.MeterTool.MeterToolLib.dll \
  MetraTech.Test.MeterTool.MeterToolLib.pdb \
  MetraTech.Test.MeterTool.Plugins.dll \
  MetraTech.Test.MeterTool.Plugins.pdb \
  MetraTech.Test.pdb \
  MetraTech.Test.Plugins.dll \
  MetraTech.Test.Plugins.pdb \
  MetraTech.Tools.Library.dll \
  MetraTech.Tools.Library.pdb \
  MetraTech.Presentation.dll \
  MetraTech.Presentation.pdb \
  MetraTech.UI.CDT.dll \
  MetraTech.UI.CDT.pdb \
  MetraTech.UI.Common.dll \
  MetraTech.UI.Common.pdb \
  MetraTech.UI.Controls.CDT.dll \
  MetraTech.UI.Controls.CDT.pdb \
  MetraTech.UI.Controls.dll \
  MetraTech.UI.Controls.pdb \
  MetraTech.UI.ServiceCaller.dll \
  MetraTech.UI.ServiceCaller.pdb \
  MetraTech.UI.Tools.dll \
  MetraTech.UI.Tools.pdb \
  MetraTech.UI.Utility.RowsetExport.dll \
  MetraTech.UI.Utility.RowsetExport.pdb \
  MetraTechDataExportService.exe \
  MetraTechDataExportService.exe.config \
  MetraTechDataExportService.pdb \
  MetraViewTest.exe \
  MetraViewTest.pdb \
  Microsoft.Practices.EnterpriseLibrary.Common.dll \
  Microsoft.Practices.EnterpriseLibrary.Common.pdb \
  Microsoft.Practices.EnterpriseLibrary.ExceptionHandling.dll \
  Microsoft.Practices.EnterpriseLibrary.ExceptionHandling.pdb \
  MetraTech.Product.Hooks.IISConfigurationManager.dll \
  MetraTech.Product.Hooks.IISConfigurationManager.pdb \
  Microsoft.Practices.ServiceLocation.dll \
  Microsoft.Practices.Unity.dll \
  Microsoft.Practices.Unity.Interception.dll \
  Microsoft.ServiceBus.dll \
  Microsoft.VisualStudio.TextTemplating.dll \
  Microsoft.Web.Infrastructure.dll \
  Microsoft.Web.Mvc.dll \
  Microsoft.WindowsAzure.Configuration.dll \
  msmqtest.exe \
  msmqtest.pdb \
  msscript.interop.dll \
  msscript.interop.dll \
  mtauditor.exe \
  mtauditor.pdb \
  MTGlobal_msg.dll \
  MTODBC.dll \
  MTODBC.dll \
  MTODBC.pdb \
  MTODBCUtils.dll \
  MTODBCUtils.pdb \
  MTSDK.dll \
  MTSDK.dll \
  MTSDK.pdb \
  mtsl.dll \
  mtsl.dll \
  mtsl.pdb \
  MTSQL.dll \
  MTSQL.dll \
  MTSQL.pdb \
  MTSQLTest.exe \
  MTSQLTest.pdb \
  mvm.exe \
  mvm.exe.config \
  mvm.pdb \
  mvm_lib.dll \
  mvm_lib.pdb \
  MvmExtensions.dll \
  MvmChannelLib.dll \
  MvmChannelLib.pdb \
  mvmListener.exe \
  mvmListener.exe.config \
  mvmListener.pdb \
  MvmSerialize2.dll \
  MvmSerialize2.pdb \
  MvmServerConfig.dll \
  MvmServerConfig.pdb \
  Newtonsoft.Json.dll \
  NGenerics.dll \
  NHibernate.ByteCode.Castle.dll \
  NHibernate.ByteCode.Linfu.dll \
  NHibernate.dll \
  NHibernate.LambdaExtensions.dll \
  NHibernate.Validator.dll \
  NHibernate.Validator.Specific.dll \
  NLog.dll \
  nonettest.exe \
  nonettest.pdb \
  NonStandardChargePlugin.dll \
  NonStandardChargePlugin.pdb \
  NTLogger.dll \
  NTLogger.pdb \
  NTLoggerRollover.exe \
  NTLoggerRollover.pdb \
  ParallelExtensionsExtras.dll \
  ParallelExtensionsExtras.pdb \
  PCCache.dll \
  PCCache.pdb \
  PCImportExport.exe \
  pdh.dll \
  PerfLog.dll \
  PerfLog.pdb \
  PFPro.dll \
  pipesvc.exe \
  pipesvc.pdb \
  PPerf.dll \
  PPerf.pdb \
  proptest.exe \
  proptest.pdb \
  QuickGraph.dll \
  QuickGraph.Graphviz.dll \
  RabbitMQ.Client.dll \
  RaptorDB.dll \
  RegisterServicedComponents.exe \
  RegisterServicedComponents.pdb \
  Route.dll \
  Route.pdb \
  RsaKmc.dll \
  RSCacheStats.exe \
  RSCacheStats.pdb \
  SchemaUpgrade.exe \
  SchemaUpgrade.exe.config \
  SchemaUpgrade.pdb \
  Sdk_Msg.dll \
  SessServerBase.dll \
  SessServerBase.pdb \
  sesstest.exe \
  sesstest.pdb \
  SharedSess.dll \
  SharedSess.pdb \
  ShellLink.exe \
  SimplePlugin.dll \
  SimplePlugin.pdb \
  Stage.dll \
  Stage.pdb \
  StageInfo.exe \
  StageInfo.pdb \
  StringTemplate.dll \
  syscontest.exe \
  syscontest.pdb \
  System.Net.Http.dll \
  System.Net.Http.Formatting.dll \
  System.Net.Http.WebRequest.dll \
  System.Web.Helpers.dll \
  System.Web.Http.dll \
  System.Web.Http.WebHost.dll \
  System.Web.Mvc.dll \
  System.Web.Optimization.dll \
  System.Web.Razor.dll \
  System.Web.WebPages.Deployment.dll \
  System.Web.WebPages.dll \
  System.Web.WebPages.Razor.dll \
  TestBatchClient.exe \
  TestBatchClient.pdb \
  TransactionConfig.dll \
  TransactionConfig.pdb \
  UpgradeEncryption.exe \
  UpgradeEncryption.pdb \
  UsageServer.dll \
  UsageServer.pdb \
  USM.exe \
  USM.pdb \
  WebActivator.dll \
  WebGrease.dll \
  XMLConfig.dll \
  XMLConfig.pdb \
  xmlconfigtest.exe \
  xmlconfigtest.pdb \
  zlib1.dll \
  gudusoft.gsqlparser.dll \
  $(MPI_DLLS) \
  $(MEMALLOC_DLL) \
  
  

!if "$(BLDTYPE)" == "release"
MPI_DLLS = \
  mpich2.dll \
  mpich2mpi.dll \
  mpich2ssm.dll \
  mpich2shm.dll \
!else
MPI_DLLS = \
  mpich2.dll \
  mpich2mpi.dll \
  mpich2ssm.dll \
  mpich2shm.dll \
!endif

!if "$(BLDTYPE)" == "release"
MEMALLOC_DLL = libtcmalloc_minimal.dll \
!else
MEMALLOC_DLL = libtcmalloc_minimal-debug.dll \
!endif

NOREG_TLBS = \
  MetraTech.Debug.DTCTestLib.tlb \
  MetraTech.Product.Hooks.InsertProdProperties.tlb \
   
# COM_DLLS

COM_DLLS = \
  AccountCredit.dll \
  AccountCreditPlugin.dll \
  AccountCreditRequest.dll \
  AccountCreditRequestPlugin.dll \
  AccountTableCreation.dll \
  AdminEnumEdit.dll \
  ARPropagationExec.dll \
  AuditHook.dll \
  BatchAccountResolution.dll \
  BatchAccountTableCreation.dll \
  BatchApplyRoleMembership.dll \
  BatchApplyTemplateProperties.dll \
  BatchAuditPlugin.dll \
  BatchCopyAccountProperties.dll \
  BatchPCRate.dll \
  BatchPILookup.dll \
  BatchUpdate.dll \
  BatchUsageIntervalResolution.dll \
  BatchSubscription.dll \
  BatchWriteProductView.dll \
  BillingCycleConfig.dll \
  BuildPCSprocs.dll \
  CalendarCodeLookup.dll \
  ClearQueues.dll \
  COMDBObjects.dll \
  COMInterpreter.dll \
  COMKiosk.dll \
  COMLogger.dll \
  COMMeter.dll \
  COMPlusPlugin.dll \
  COMPlusWrapper.dll \
  COMSecureStore.dll \
  COMticketagent.dll \
  ConfigLoader.dll \
  ConfigRefresh.dll \
  CopyAccountProperties.dll \
  Counter.dll \
  CreditCard.dll \
  DecTest.dll \
  DBLockPlugin.dll \
  DeployLocale.dll \
  DeployProductView.dll \
  DTCGetWhereAboutsPlugin.dll \
  DumpPC.dll \
  Email.dll \
  EmailMessage.dll \
  EmailPaymentNoticePlugin.dll \
  ExecutionInfo.dll \
  ExTablehook.dll \
  ExtPropLookup.dll \
  GenericCollection.dll \
  GenericInsertPlugin.dll \
  HierarchyPath.dll \
  InstallConfig.dll \
  Logging.dll \
  MeterRowset.dll \
  MetraTime.dll \
  MetraTech.AR.eConnectCOMShim.dll \
  ModifyAccountMapping.dll \
  MTAccount.dll \
  MTAccountStateCheck.dll \
  MTAccountStates.dll \
  MTAccountUtils.dll \
  MTAdminNavbar.dll \
  MTAggRate.dll \
  MTARInterfaceExec.dll \
  MTAuditDBWriter.dll \
  MTAuditEvents.dll \
  MTAuditPlugin.dll \
  MTAuth.dll \
  MTAuthCapabilities.dll \
  MTAuthCapabilitiesVB.dll \
  MTAuthCheck.dll \
  MTAuthExec.dll \
  MTBitemporalSprocsHook.dll \
  MTCalendar.dll \
  MTCallUomPlugin.dll \
  MTCapabilityHook.dll \
  MTConfigHelper.dll \
  MTCounterTypeHook.dll \
  MTCreateBrandingVdirs.dll \
  MTDecimalOps.dll \
  MTEnumConfig.dll \
  MTEnumtl.dll \
  MTFleXML.dll \
  MTGenericDBExec.dll \
  MTGreatPlainsExec.dll \
  MTHierarchyHelper.dll \
  MTHierarchyReports.dll \
  MTHookHandler.dll \
  MTLeaderPlugin.dll \
  MTLocaleConfig.dll \
  MTLogin.dll \
  MTMAM.dll \
  MTModuleReader.dll \
  MTMSIX.dll \
  MTNetUser.dll \
  MTNonRecurringChargeAdapter.dll \
  MTPaymentServerHelper.dll \
  MTPCImportExportExec.dll \
  MTPhoneCrack.dll \
  MTProductCatalog.dll \
  MTProductCatalogExec.dll \
  MTProductView.dll \
  MTProductViewExec.dll \
  MTProgressExec.dll \
  MTQuoteConfig.dll \
  MTReMeterPlugin.dll \
  MTRoundPlugin.dll \
  MTRuleSet.dll \
  MTSecurityPolicyHook.dll \
  MTServerAccess.dll \
  MTServiceLevelPlugin.dll \
  MTServiceWizard.dll \
  MTSignio.dll \
  MTSiteConfig.dll \
  MTSQLBatchquery.dll \
  MTSQL_Plugin.dll \
  MTStdUsageCycle.dll \
  MTSubscriberAccount.dll \
  MTSubscriptionExec.dll \
  MTSubStr.dll \
  MTTabRuleSetReader.dll \
  MTUsageServer.dll \
  MTVBLib.dll \
  MTVBAdapter.dll \
  MTVersion.dll \
  MTYAAC.dll \
  MTYAACExec.dll \
  NameID.dll \
  ParamTableHook.dll \
  ParentCopy.dll \
  PCConfig.dll \
  PeriodicallySubmitTransactions.dll \
  PhoneLookup.dll \
  PipelineControl.dll \
  PipelineTransaction.dll \
  PipeStartStop.dll \
  PreAuthLookup.dll \
  PriceListLookup.dll \
  PropagateProperties.dll \
  PropGen.dll \
  PropSet.dll \
  PSAccountMgmt.dll \
  QueryAdapter.dll \
  QuotePlugin.dll \
  RCD.dll \
  RecurringChargeAdapter.dll \
  RecurringChargeProration.dll \
  RegisterExtensionObjects.dll \
  RemoveSessionBin.dll \
  ReportingInfo.dll \
  RetrieveTransactionStatus.dll \
  RoundRobin.dll \
  Rowset.dll \
  RuleSetEval.dll \
  SchedulePayment.dll \
  ScriptHost.dll \
  ServiceMonitor.dll \
  SessServer.dll \
  SetCompoundProp.dll \
  Subscription.dll \
  Summation.dll \
  SysContext.dll \
  TimestampOverride.dll \
  TOD.dll \
  TransactionsOps.dll \
  UpdatePaymentScheduler.dll \
  UpdatePaymentSchedulerWithConfirm.dll \
  VBPlugInDebugger.dll \
  VBSubscribeExec.dll \
  VBTest.dll \
  VersionReporting.dll \
  ViewAllRates.dll \
  WeightedRate.dll \
  XMLTranslator.dll \
  MetraTech.MTPCImportDynamicProperties.dll \
  ## Commented out ExpressionEngine, due to it was excluded from the build
  ## MetraTech.ExpressionEngine.Metadata.Hook.dll \
  
  # COM_DLLS -- PDBs

COM_DLLSPDB = \
  AccountCredit.pdb \
  AccountCreditPlugin.pdb \
  AccountCreditRequest.pdb \
  AccountCreditRequestPlugin.pdb \
  AccountTableCreation.pdb \
  ARPropagationExec.pdb \
  AuditHook.pdb \
  BatchAccountResolution.pdb \
  BatchAccountTableCreation.pdb \
  BatchApplyRoleMembership.pdb \
  BatchApplyTemplateProperties.pdb \
  BatchAuditPlugin.pdb \
  BatchCopyAccountProperties.pdb \
  BatchPCRate.pdb \
  BatchPILookup.pdb \
  BatchUpdate.pdb \
  BatchUsageIntervalResolution.pdb \
  BatchSubscription.pdb \
  BatchWriteProductView.pdb \
  BillingCycleConfig.pdb \
  BuildPCSprocs.pdb \
  CalendarCodeLookup.pdb \
  ClearQueues.pdb \
  COMDBObjects.pdb \
  COMInterpreter.pdb \
  COMKiosk.pdb \
  COMLogger.pdb \
  COMMeter.pdb \
  COMPlusPlugin.pdb \
  COMSecureStore.pdb \
  COMticketagent.pdb \
  ConfigLoader.pdb \
  ConfigRefresh.pdb \
  CopyAccountProperties.pdb \
  Counter.pdb \
  CreditCard.pdb \
  DecTest.pdb \
  DBLockPlugin.pdb \
  DeployLocale.pdb \
  DeployProductView.pdb \
  DTCGetWhereAboutsPlugin.pdb \
  Email.pdb \
  EmailMessage.pdb \
  EmailPaymentNoticePlugin.pdb \
  ExecutionInfo.pdb \
  ExTablehook.pdb \
  ExtPropLookup.pdb \
  GenericCollection.pdb \
  GenericInsertPlugin.pdb \
  HierarchyPath.pdb \
  InstallConfig.pdb \
  MeterRowset.pdb \
  MetraTime.pdb \
  MetraTech.AR.eConnectCOMShim.pdb \
  ModifyAccountMapping.pdb \
  MTAccount.pdb \
  MTAccountStateCheck.pdb \
  MTAccountStates.pdb \
  MTAccountUtils.pdb \
  MTAggRate.pdb \
  MTARInterfaceExec.pdb \
  MTAuditDBWriter.pdb \
  MTAuditEvents.pdb \
  MTAuditPlugin.pdb \
  MTAuth.pdb \
  MTAuthCapabilities.pdb \
  MTAuthCheck.pdb \
  MTAuthExec.pdb \
  MTBitemporalSprocsHook.pdb \
  MTCalendar.pdb \
  MTCallUomPlugin.pdb \
  MTCapabilityHook.pdb \
  MTCounterTypeHook.pdb \
  MTCreateBrandingVdirs.pdb \
  MTDecimalOps.pdb \
  MTEnumConfig.pdb \
  MTEnumtl.pdb \
  MTGenericDBExec.pdb \
  MTHierarchyReports.pdb \
  MTHookHandler.pdb \
  MTLeaderPlugin.pdb \
  MTLocaleConfig.pdb \
  MTLogin.pdb \
  MTModuleReader.pdb \
  MTNonRecurringChargeAdapter.pdb \
  MTPhoneCrack.pdb \
  MTProductCatalog.pdb \
  MTProductCatalogExec.pdb \
  MTProductView.pdb \
  MTProductViewExec.pdb \
  MTProgressExec.pdb \
  MTQuoteConfig.pdb \
  MTReMeterPlugin.pdb \
  MTRoundPlugin.pdb \
  MTRuleSet.pdb \
  MTSecurityPolicyHook.pdb \
  MTServerAccess.pdb \
  MTServiceLevelPlugin.pdb \
  MTSignio.pdb \
  MTSiteConfig.pdb \
  MTSQLBatchquery.pdb \
  MTSQL_Plugin.pdb \
  MTStdUsageCycle.pdb \
  MTSubscriptionExec.pdb \
  MTSubStr.pdb \
  MTUsageServer.pdb \
  MTYAAC.pdb \
  MTYAACExec.pdb \
  NameID.pdb \
  ParamTableHook.pdb \
  ParentCopy.pdb \
  PCConfig.pdb \
  PeriodicallySubmitTransactions.pdb \
  PhoneLookup.pdb \
  PipelineControl.pdb \
  PipelineTransaction.pdb \
  PipeStartStop.pdb \
  PreAuthLookup.pdb \
  PriceListLookup.pdb \
  PropagateProperties.pdb \
  PropGen.pdb \
  PropSet.pdb \
  PSAccountMgmt.pdb \
  QueryAdapter.pdb \
  QuotePlugin.pdb \
  RCD.pdb \
  RecurringChargeAdapter.pdb \
  RecurringChargeProration.pdb \
  RegisterExtensionObjects.pdb \
  RemoveSessionBin.pdb \
  ReportingInfo.pdb \
  RetrieveTransactionStatus.pdb \
  RoundRobin.pdb \
  Rowset.pdb \
  RuleSetEval.pdb \
  SchedulePayment.pdb \
  ScriptHost.pdb \
  SessServer.pdb \
  SetCompoundProp.pdb \
  Subscription.pdb \
  Summation.pdb \
  SysContext.pdb \
  TimestampOverride.pdb \
  TOD.pdb \
  TransactionsOps.pdb \
  UpdatePaymentScheduler.pdb \
  UpdatePaymentSchedulerWithConfirm.pdb \
  VersionReporting.pdb \
  WeightedRate.pdb \
  MetraTech.MTPCImportDynamicProperties.pdb \
  
  # COM_DLLS -- Interops

COM_DLLS_INTOPS = \
  AccountCreditRequest.interop.dll \
  ARPropagationExec.interop.dll \
  BillingCycleConfig.interop.dll \
  COMDBObjects.interop.dll \
  COMInterpreter.interop.dll \
  COMKiosk.interop.dll \
  COMLogger.interop.dll \
  COMMeter.interop.dll \
  COMSecureStore.interop.dll \
  COMticketagent.interop.dll \
  ConfigLoader.interop.dll \
  Counter.interop.dll \
  CreditCard.interop.dll \
  Email.interop.dll \
  EmailMessage.interop.dll \
  ExecutionInfo.interop.dll \
  GenericCollection.interop.dll \
  HierarchyPath.interop.dll \
  InstallConfig.interop.dll \
  MeterRowset.interop.dll \
  MetraTime.interop.dll \
  MTAccount.interop.dll \
  MTAccountStates.interop.dll \
  MTAccountUtils.interop.dll \
  MTARInterfaceExec.interop.dll \
  MTAuditDBWriter.interop.dll \
  MTAuditEvents.interop.dll \
  MTAuth.interop.dll \
  MTAuthCapabilities.interop.dll \
  MTAuthExec.interop.dll \
  MTCalendar.interop.dll \
  MTDecimalOps.interop.dll \
  MTEnumConfig.interop.dll \
  MTGenericDBExec.interop.dll \
  MTHierarchyReports.interop.dll \
  MTHookHandler.interop.dll \
  MTLocaleConfig.interop.dll \
  MTModuleReader.interop.dll \
  MTProductCatalog.interop.dll \
  MTProductCatalogExec.interop.dll \
  MTProductView.interop.dll \
  MTProductViewExec.interop.dll \
  MTProgressExec.interop.dll \
  MTQuoteConfig.interop.dll \
  MTRuleSet.interop.dll \
  MTServerAccess.interop.dll \
  MTSiteConfig.interop.dll \
  MTStdUsageCycle.interop.dll \
  MTSubscriptionExec.interop.dll \
  MTUsageServer.interop.dll \
  MTYAAC.interop.dll \
  MTYAACExec.interop.dll \
  NameID.interop.dll \
  PCConfig.interop.dll \
  PhoneLookup.interop.dll \
  PipelineControl.interop.dll \
  PipelineTransaction.interop.dll \
  PropGen.interop.dll \
  PropSet.interop.dll \
  QueryAdapter.interop.dll \
  RCD.interop.dll \
  RecurringChargeAdapter.interop.dll \
  ReportingInfo.interop.dll \
  Rowset.interop.dll \
  RuleSetEval.interop.dll \
  ScriptHost.interop.dll \
  SessServer.interop.dll \
  Subscription.interop.dll \
  Summation.interop.dll \
  SysContext.interop.dll \
  TOD.interop.dll \
  VersionReporting.interop.dll \
  
# these interops are not derived directly from COM DLLs

EXTRA_INTEROPS = \
  IMTAccountType.interop.dll \
  MTBillingRerun.interop.dll \
  MTDataExporter.interop.dll \
  MTHooklib.interop.dll \
  MTPipelineLib.interop.dll \
  MTPipelineLibExt.interop.dll \
  MTProductCatalogInterfacesLib.interop.dll \

# .NET Assemblies (registered for COM interop by COMPlus.vbs)
###########################################################################
# DO NOT ADD ANYTHING TO THE ASSEMBLIES SECTION - THESE ARE HARDCODED INTO THE INSTALLSHIELD
# PROJECT AND THIS REALLY NEEDS TO BE CLEANED UP IN THE INSTALLER
###########################################################################

ASSEMBLIES = \
  MetraTech.Accounts.Ownership.dll \
  MetraTech.Accounts.PlugIns.dll \
  MetraTech.Accounts.Type.dll \
  MetraTech.Adjustments.Adapters.dll \
  MetraTech.Adjustments.dll \
  MetraTech.Adjustments.Hooks.dll \
  MetraTech.Adjustments.ReRun.dll \
  MetraTech.AR.Adapters.dll \
  MetraTech.AR.dll \
  MetraTech.AR.Reporting.dll \
  MetraTech.AR.ReRun.dll \
  MetraTech.Auth.Capabilities.dll \
  MetraTech.Collections.dll \
  MetraTech.Common.dll \
  MetraTech.Crypto.dll \
  MetraTech.DataAccess.dll \
  MetraTech.DataAccess.DMO.dll \
  MetraTech.DataAccess.MaterializedViews.dll \
  MetraTech.Debug.Transaction.dll \
  MetraTech.Localization.dll \
  MetraTech.MTSQL.dll \
  MetraTech.OnlineBill.dll \
  MetraTech.Payments.PlugIns.dll \
  MetraTech.Performance.dll \
  MetraTech.Pipeline.Batch.dll \
  MetraTech.Pipeline.Batch.Listener.dll \
  MetraTech.Pipeline.dll \
  MetraTech.Pipeline.Messages.dll \
  MetraTech.Pipeline.PlugIns.dll \
  MetraTech.Pipeline.ReRun.dll \
  MetraTech.Pipeline.ReRun.Listener.dll \
  MetraTech.Pipeline.SessServer.dll \
  MetraTech.Product.Hooks.dll \
  MetraTech.Product.Hooks.DynamicTableUpdate.dll \
  MetraTech.Product.Hooks.InsertProdProperties.dll \
  MetraTech.Product.Hooks.UIValidation.dll \
  MetraTech.Product.Hooks.IISConfigurationManager.dll \
  MetraTech.Reports.Adapters.dll \
  MetraTech.Reports.CrystalEnterprise.dll \
  MetraTech.Reports.dll \
  MetraTech.Reports.Hooks.dll \
  MetraTech.Reports.ReportViewer.dll \
  MetraTech.Statistics.dll \
  MetraTech.UI.DifferenceEngine.dll \
  MetraTech.UI.DifferenceViewer.dll \
  MetraTech.UI.ProductCatalogXml.dll \
  MetraTech.UI.Utility.dll \
  MetraTech.UI.Utility.RulesetImportExport.dll \
  MetraTech.UsageServer.Adapters.dll \
  MetraTech.UsageServer.dll \
  MetraTech.UsageServer.Service.dll \
  MetraTech.Utils.dll \
  MetraTech.Xml.dll \
  PipelineInterop.dll \

ASSEMBLIES_PDB = \
  MetraTech.Accounts.Ownership.pdb \
  MetraTech.Accounts.PlugIns.pdb \
  MetraTech.Accounts.Type.pdb \
  MetraTech.Adjustments.Adapters.pdb \
  MetraTech.Adjustments.pdb \
  MetraTech.Adjustments.Hooks.pdb \
  MetraTech.Adjustments.ReRun.pdb \
  MetraTech.AR.Adapters.pdb \
  MetraTech.AR.pdb \
  MetraTech.AR.Reporting.pdb \
  MetraTech.AR.ReRun.pdb \
  MetraTech.Auth.Capabilities.pdb \
  MetraTech.Collections.pdb \
  MetraTech.Common.pdb \
  MetraTech.Crypto.pdb \
  MetraTech.DataAccess.pdb \
  MetraTech.DataAccess.DMO.pdb \
  MetraTech.DataAccess.MaterializedViews.pdb \
  MetraTech.Debug.Transaction.pdb \
  MetraTech.Localization.pdb \
  MetraTech.Localization.pdb \
  MetraTech.MTSQL.pdb \
  MetraTech.OnlineBill.pdb \
  MetraTech.Payments.PlugIns.pdb \
  MetraTech.Performance.pdb \
  MetraTech.Pipeline.Batch.pdb \
  MetraTech.Pipeline.Batch.Listener.pdb \
  MetraTech.Pipeline.pdb \
  MetraTech.Pipeline.Messages.pdb \
  MetraTech.Pipeline.PlugIns.pdb \
  MetraTech.Pipeline.ReRun.pdb \
  MetraTech.Pipeline.ReRun.Listener.pdb \
  MetraTech.Pipeline.SessServer.pdb \
  MetraTech.Product.Hooks.pdb \
  MetraTech.Product.Hooks.DynamicTableUpdate.pdb \
  MetraTech.Product.Hooks.InsertProdProperties.pdb \
  MetraTech.Product.Hooks.UIValidation.pdb \
  MetraTech.Product.Hooks.IISConfigurationManager.pdb \
  MetraTech.Reports.Adapters.pdb \
  MetraTech.Reports.CrystalEnterprise.pdb \
  MetraTech.Reports.pdb \
  MetraTech.Reports.Hooks.pdb \
  MetraTech.Reports.ReportViewer.pdb \
  MetraTech.UI.DifferenceEngine.pdb \
  MetraTech.UI.DifferenceViewer.pdb \
  MetraTech.UI.ProductCatalogXml.pdb \
  MetraTech.UI.Utility.pdb \
  MetraTech.UI.Utility.RulesetImportExport.pdb \
  MetraTech.UsageServer.Adapters.pdb \
  MetraTech.UsageServer.pdb \
  MetraTech.UsageServer.Service.pdb \
  MetraTech.Utils.pdb \
  MetraTech.Xml.pdb \
  PipelineInterop.pdb \

TPP_ASSEMBLIES = \
  Oracle.*.dll \
  SQLDMODotNet.dll \
  ASP.interop.dll \
  MetraTech.SecurityFramework.dll \
  AntiXssLibrary.dll \
  Microsoft.Data.Schema.ScriptDom.dll \
  Microsoft.Data.Schema.ScriptDom.Sql.dll \

MANAGED_TLBS = \
  MetraTech.Accounts.Ownership.tlb \
  MetraTech.Accounts.Plugins.tlb \
  MetraTech.Accounts.Type.tlb \
  MetraTech.Adjustments.tlb \
  MetraTech.Adjustments.Hooks.tlb \
  MetraTech.Adjustments.ReRun.tlb \
  MetraTech.AR.tlb \
  MetraTech.AR.Adapters.tlb \
  MetraTech.AR.Reporting.tlb \
  MetraTech.AR.ReRun.tlb \
  MetraTech.Auth.Capabilities.tlb \
  MetraTech.DataAccess.tlb \
  MetraTech.DataAccess.MaterializedViews.tlb \
  MetraTech.DataAccess.QueryManagement.tlb \
  MetraTech.Debug.Transaction.tlb \
  MetraTech.Localization.tlb \
  MetraTech.Payments.PlugIns.tlb \
  MetraTech.Pipeline.tlb \
  MetraTech.Pipeline.Messages.tlb \
  MetraTech.Pipeline.PlugIns.tlb \
  MetraTech.Pipeline.ReRun.tlb \
  MetraTech.Pipeline.ReRun.Listener.tlb \
  MetraTech.Product.Hooks.tlb \
  MetraTech.Security.Crypto.tlb \
  MetraTech.Security.tlb \
  MetraTech.UsageServer.tlb \
  MetraTech.XML.tlb \

COM_INTEROP_TLBS = \
  MTHookLib.tlb \
  MTPipelineLib.tlb \
  MTPipelineLibExt.tlb \
  MTProductCatalogInterfacesLib.tlb \
  MetraTech.MTPCImportDynamicProperties.tlb \

SHARED_TLBS = \
  $(MANAGED_TLBS) \
  $(COM_INTEROP_TLBS) \

SERVICE_EXES = \
  MTServices.exe \
  pipeline.exe \
  MetraPayService.exe \
  MASHostService.exe \

SERVICE_EXES_PDB = \
  MTServices.pdb \
  pipeline.pdb \
  MetraPayService.pdb \
  MASHostService.pdb \

REPORTING_DLL = \
  MetraTech.Reports.WebService.dll \


################################################
# Rules 
################################################

default:  all
all:      start DISK1 finish
DISK1:    MetraNet MetraConnect installer
MetraNet: createdir RMP attrib_set
RMP:      RMP_Bin RMP_Config RMP_Tenants RMP_Extensions RMP_UI RMP_WebServices RMP_Samples RMP_Test RMP_GacDlls

start:
  @echo $(DDELIM)
  @echo Begin Install Staging
  @echo $(DDELIM)
  @echo Environment Variables:
  @echo VERSION       = $(VERSION)
  @echo LABEL         = $(LABEL)
  @echo DEBUG         = $(DEBUG)
  @echo INSTALLRELDIR = $(INSTALLRELDIR)
  @echo THIRDPARTY    = $(THIRDPARTY)

finish:
  @echo $(DDELIM)
  @echo Install Staging Done!
  @echo $(DDELIM)

################################################
# Create directory structure
################################################
createdir:
  @echo $(DELIM)
  @echo Creating directories
  $(RMDIR) $(P_BASE_DIR)
  $(MKDIR) $(P_BASE_DIR)
  @echo $(LABEL) > $(P_BASE_DIR)\$(PLACEHOLDER)
  $(MKDIR) $(P_DATABASE_DIR)
  @echo $(LABEL) > $(P_DATABASE_DIR)\$(PLACEHOLDER)


################################################
# RMP\Config
################################################

S_CONFIG_DIR    = $(S_METRANET_DIR)\Config
S_MC_CONFIG_DIR = $(S_METRACONNECT_DIR)\Config
P_CONFIG_DIR    = $(P_BASE_DIR)\Config

RMP_Config:
  @echo $(DELIM)
  @echo Working on Config directory...
  $(MKDIR) $(P_CONFIG_DIR)
  $(CD) $(S_CONFIG_DIR)
  $(CPDIR) . $(P_CONFIG_DIR) .svn
  $(CD) $(S_MC_CONFIG_DIR)
  $(CPDIR) . $(P_CONFIG_DIR) .svn
  
################################################
# RMP\Tenants
################################################

S_TENANTS_DIR	= $(S_METRANET_DIR)\Tenants
P_TENANTS_DIR	= $(P_BASE_DIR)\Tenants

RMP_Tenants:
	@echo $(DELIM)
	@echo Working on Tenants directory ...
	$(MKDIR) $(P_TENANTS_DIR)
	$(CD) $(S_TENANTS_DIR)
	$(CPDIR) . $(P_TENANTS_DIR) .svn
	
################################################
# RMP\Bin
# SZafar 03/21/13 Removed cp *test*. Test dlls should not be part of MN install.
################################################

S_SERVICECALLER_DIR = $(S_BASE_DIR)\MetraTech\UI\ServiceCaller

P_BIN_DIR        = $(P_BASE_DIR)\Bin
P_ASSEMBLIES_DIR = $(P_BASE_DIR)\Assemblies
P_INTEROPS_DIR   = $(P_BASE_DIR)\Interops
P_COM_DLLS_DIR   = $(P_BASE_DIR)\COMDLLs
P_SERVICES_DIR   = $(P_BASE_DIR)\Services
P_SERVICECALLER_DIR = $(P_BASE_DIR)\ServiceCaller

################################################
# Temporary fix for smoke test problems. The two assemblies
# copied from the extensions\Account folder must be in RMP\bin
# on the target system for smokes to work.
# MJP - 01-13-2011
################################################
R_BASE_DIR 			= R:
R_EXTENSIONS_DIR 	= $(R_BASE_DIR)\extensions
R_EXT_ACCOUNT_DIR 	= $(R_EXTENSIONS_DIR)\Account\bin
               
RMP_Bin:
  @echo $(DELIM)
  @echo Working on Bin directory...
  $(MKDIR) $(P_BIN_DIR)
  $(CD) $(O_BIN_DIR)
  $(CP) $(BINARIES) $(P_BIN_DIR)
  $(CP) $(COM_DLLSPDB) $(P_BIN_DIR)
  $(CP) $(ASSEMBLIES_PDB) $(P_BIN_DIR)
  $(CP) $(SERVICE_EXES_PDB) $(P_BIN_DIR)
  
  $(CD) $(O_INCLUDE_DIR)
  $(CP) $(NOREG_TLBS) $(P_BIN_DIR)

  @echo $(DELIM)
  @echo Working on assemblies for smoke tests ...
  $(CD) $(R_EXT_ACCOUNT_DIR)
  $(CP) MetraTech.Account.ClientProxies.dll $(P_BIN_DIR)
  $(CP) MetraTech.Account.ProxyActivities.dll $(P_BIN_DIR)

  $(CD) $(O_INCLUDE_DIR)
  $(CP) MTProgressExec.tlb $(P_BIN_DIR)
    
  @echo $(DELIM)
  @echo Working on Assemblies directory...
  $(MKDIR) $(P_ASSEMBLIES_DIR)
  $(CD) $(O_BIN_DIR)
  $(CP) $(ASSEMBLIES) $(P_ASSEMBLIES_DIR)
  $(CP) $(TPP_ASSEMBLIES) $(P_BIN_DIR)
  $(CP) $(TPP_ASSEMBLIES) $(P_ASSEMBLIES_DIR)

  @echo $(DELIM)
  @echo Working on Interops directory...
  $(MKDIR) $(P_INTEROPS_DIR)
  $(CP) $(COM_DLLS_INTOPS) $(P_INTEROPS_DIR)
  $(CP) $(EXTRA_INTEROPS) $(P_INTEROPS_DIR)
  
  @echo $(DELIM)
  @echo Working on COMDLLs directory...
  $(MKDIR) $(P_COM_DLLS_DIR)
  $(CD) $(O_BIN_DIR)
  $(CP) $(COM_DLLS) $(P_COM_DLLS_DIR)
  $(CD) $(O_INCLUDE_DIR)
  $(CP) $(SHARED_TLBS) $(P_COM_DLLS_DIR)

  @echo $(DELIM)
  @echo Working on Services directory...
  $(MKDIR) $(P_SERVICES_DIR)
  $(CD) $(O_BIN_DIR)
  $(CP) $(SERVICE_EXES) $(P_SERVICES_DIR)
  
  @echo $(DELIM)
  @echo Working on ServiceCaller ...
  $(MKDIR) $(P_SERVICECALLER_DIR)
  $(CD) $(S_SERVICECALLER_DIR)
  $(CP) w3wp.exe.config $(P_SERVICECALLER_DIR)

	
###############################################
# RMP\UI
###############################################

S_UI_DIR              = $(S_METRANET_DIR)\UI
S_UI_METRANET_DIR     = $(S_METRATECH_DIR)\UI\MetraNet
S_UI_METRANETHELP_DIR = $(S_METRATECH_DIR)\UI\MetraNetHelp
S_UI_RES_DIR         = $(S_METRATECH_DIR)\UI\Res
S_UI_IMGHANDLER_DIR  = $(S_METRATECH_DIR)\UI\ImageHandler
S_UI_SUGGEST_DIR     = $(S_METRATECH_DIR)\UI\Suggest
S_DOTNET_DIR         = $(S_3RDPARTY_DIR)\Microsoft\DotNET\2.0

P_UI_DIR             = $(P_BASE_DIR)\UI
P_METRANET_DIR       = $(P_UI_DIR)\MetraNet
P_METRANETHELP_DIR   = $(P_UI_DIR)\MetraNetHelp
P_RES_DIR            = $(P_UI_DIR)\Res
P_IMGHANDLER_DIR     = $(P_UI_DIR)\ImageHandler
P_SUGGEST_DIR        = $(P_UI_DIR)\Suggest
P_MAM_HIER_CNTRL_BIN = $(P_UI_DIR)\mam\default\dialog

RMP_UI:
  @echo $(DELIM)
  @echo Working on UI Applications
  $(MKDIR) $(P_UI_DIR)
  $(CD) $(S_UI_DIR)
  $(CPDIR) . $(P_UI_DIR) "^GSM.*" .svn

  @echo Copying UI DLLs
  $(REMOVE) $(P_MAM_HIER_TXIMG_BIN)\CreateDir.txt
  
  @echo Copying .NET redistributable 
  $(CD) $(S_DOTNET_DIR)
  $(CP) dotnetfx.exe $(P_METRANET_DIR)\redist

  @echo Working on ImageHandler virtual directory
  $(REMOVE) $(P_IMGHANDLER_DIR)\source_location.txt
  $(MKDIR) $(P_IMGHANDLER_DIR)\bin
  $(MKDIR) $(P_IMGHANDLER_DIR)\images
  $(CD) $(S_UI_IMGHANDLER_DIR)
  $(CP) *.aspx *.asax *.resx Web.config $(P_IMGHANDLER_DIR)
  $(CD) $(S_UI_IMGHANDLER_DIR)\images
  $(CPDIR) . $(P_IMGHANDLER_DIR)\images .svn
  $(CD) $(O_BIN_DIR)
  $(CPWEBSVC) $(S_UI_IMGHANDLER_DIR) $(P_IMGHANDLER_DIR)

  @echo Working on Suggest virtual directory
  $(REMOVE) $(P_SUGGEST_DIR)\source_location.txt
  $(MKDIR) $(P_SUGGEST_DIR)\bin
  $(CD) $(S_UI_SUGGEST_DIR)
  $(CP) *.aspx *.asax *.resx Web.config *.gif *.css *.js $(P_SUGGEST_DIR)
  $(CD) $(O_BIN_DIR)
  $(CPWEBSVC) $(S_UI_SUGGEST_DIR) $(P_SUGGEST_DIR)

  @echo Working on MetraNet virtual directory
  $(REMOVE) $(P_METRANET_DIR)\source_location.txt
  XCOPY $(S_UI_METRANET_DIR) $(P_METRANET_DIR) /Y /E /I /C
  $(CD) $(O_BIN_DIR)
  $(CPWEBSVC) $(S_UI_METRANET_DIR) $(P_METRANET_DIR)

  @echo Working on MetraNetHelp virtual directory
  $(REMOVE) $(P_METRANETHELP_DIR)\source_location.txt
  XCOPY $(S_UI_METRANETHELP_DIR) $(P_METRANETHELP_DIR) /Y /E /I /C
  $(CD) $(O_BIN_DIR)

  @echo Working on Res virtual directory
  $(REMOVE) $(P_RES_DIR)\source_location.txt
  XCOPY $(S_UI_RES_DIR) $(P_RES_DIR) /Y /E /I /C
  $(CD) $(O_BIN_DIR)
 
###############################################
# RMP\GacDlls
###############################################
S_GACDLLS_DIR        = $(S_BASE_DIR)\Thirdparty\GacDlls
P_GACDLLS_DIR        = $(P_BASE_DIR)\GacDlls

RMP_GacDlls:
  @echo $(DELIM)
  @echo Working on GacDlls directory...
  $(MKDIR) $(P_GACDLLS_DIR)
  XCOPY $(S_GACDLLS_DIR)\* $(P_GACDLLS_DIR) /Y /E /I /C
  
###############################################
# RMP\Test
###############################################

S_TEST_DIR = $(S_METRANET_DIR)\Test
P_TEST_DIR = $(P_BASE_DIR)\Test

RMP_Test:
  @echo $(DELIM)
  @echo Working on TEST Applications...
  $(CD) $(S_TEST_DIR)
  $(CPDIR) . $(P_TEST_DIR) .svn


###############################################
# RMP\Samples
###############################################

S_SAMPLES_DIR = $(S_METRANET_DIR)\Samples
P_SAMPLES_DIR = $(P_BASE_DIR)\Samples

RMP_Samples:
  @echo $(DELIM)
  @echo Working on Samples directory...
  $(MKDIR) $(P_SAMPLES_DIR)
  $(CD) $(S_SAMPLES_DIR)
  $(CPDIR) . $(P_SAMPLES_DIR) .svn


###############################################
# RMP\WebServices
###############################################

S_BATCH_WEBSVC_DIR     = $(S_METRATECH_DIR)\Pipeline\Batch\Listener
S_RERUN_WEBSVC_DIR     = $(S_METRATECH_DIR)\Pipeline\ReRun\Listener
S_HIERARCHY_WEBSVC_DIR = $(S_METRATECH_DIR)\Accounts\Hierarchy\WebService
S_RESTAPI_WEBSVC_DIR = $(S_METRATECH_DIR)\RESTAPI

P_WEBSVCS_DIR          = $(P_BASE_DIR)\WebServices
P_BATCH_WEBSVC_DIR     = $(P_WEBSVCS_DIR)\Batch
P_RERUN_WEBSVC_DIR     = $(P_WEBSVCS_DIR)\BillingRerun
P_HIERARCHY_WEBSVC_DIR = $(P_WEBSVCS_DIR)\AccountHierarchy
P_RESTAPI_WEBSVC_DIR = $(P_WEBSVCS_DIR)\RESTAPI

RMP_WebServices:
  @echo $(DELIM)
  @echo Working on Web Services...
  $(MKDIR) $(P_WEBSVCS_DIR)
  @echo $(LABEL) > $(P_WEBSVCS_DIR)\$(PLACEHOLDER)

  @echo   Batch
  $(MKDIR) $(P_BATCH_WEBSVC_DIR)
  $(MKDIR) $(P_BATCH_WEBSVC_DIR)\bin
  $(CD) $(S_BATCH_WEBSVC_DIR)
  $(CP) *.asmx $(P_BATCH_WEBSVC_DIR)
  $(CP) Web.Config $(P_BATCH_WEBSVC_DIR)
  $(CD) $(O_BIN_DIR)
  $(CPWEBSVC) $(S_BATCH_WEBSVC_DIR) $(P_BATCH_WEBSVC_DIR)

  @echo $(DELIM)
  @echo   Billing Rerun
  $(MKDIR) $(P_RERUN_WEBSVC_DIR)
  $(MKDIR) $(P_RERUN_WEBSVC_DIR)\bin
  $(CD) $(S_RERUN_WEBSVC_DIR)
  $(CP) *.asmx  $(P_RERUN_WEBSVC_DIR)
  $(CP) Web.Config $(P_RERUN_WEBSVC_DIR)
  $(CD) $(O_BIN_DIR)
  $(CPWEBSVC) $(S_RERUN_WEBSVC_DIR) $(P_RERUN_WEBSVC_DIR)

  @echo $(DELIM)
  @echo   Account Hierarchy
  $(MKDIR) $(P_HIERARCHY_WEBSVC_DIR)
  $(MKDIR) $(P_HIERARCHY_WEBSVC_DIR)\bin
  $(CD) $(S_HIERARCHY_WEBSVC_DIR)
  $(CP) *.asmx  $(P_HIERARCHY_WEBSVC_DIR)
  $(CP) Web.Config $(P_HIERARCHY_WEBSVC_DIR)
  $(CD) $(O_BIN_DIR)
  $(CPWEBSVC) $(S_HIERARCHY_WEBSVC_DIR) $(P_HIERARCHY_WEBSVC_DIR)
 
 
  @echo $(DELIM)
  @echo   RESTAPI
  $(MKDIR) $(P_RESTAPI_WEBSVC_DIR)
  $(MKDIR) $(P_RESTAPI_WEBSVC_DIR)\bin
  $(CD) $(S_RESTAPI_WEBSVC_DIR)
  $(CP) *.asax  $(P_RESTAPI_WEBSVC_DIR)
  $(CP) packages.config  $(P_RESTAPI_WEBSVC_DIR)
  $(CP) Web.Config $(P_RESTAPI_WEBSVC_DIR)
  $(CD) $(O_BIN_DIR)
  $(CPWEBSVC) $(S_RESTAPI_WEBSVC_DIR) $(P_RESTAPI_WEBSVC_DIR)
 
###############################################
# Installer
###############################################

S_INSTALL_SCRIPTS_DIR  = $(S_BASE_DIR)\Install\Scripts
S_BRANDING_DIR         = $(S_BASE_DIR)\Install\Branding
S_PACKAGE_DIR          = $(S_BASE_DIR)\Install\Packages
S_APPSIGHT_DIR		   = $(S_BASE_DIR)\Install\AppSight
S_PREREQ_DIR           = $(S_BASE_DIR)\Install\Prereq
P_INSTALL_SCRIPTS_DIR  = $(P_BASE_DIR)\InstallScripts
P_BRANDING_DIR         = $(P_BASE_DIR)\Branding
P_PACKAGE_DIR          = $(P_BASE_DIR)\ISM
P_APPSIGHT_DIR		   = $(P_BASE_DIR)\AppSight
P_PREREQ_DIR           = $(P_BASE_DIR)\Prereq

installer:
  @echo $(DELIM)
  @echo Working on Install Scripts
  $(MKDIR) $(P_INSTALL_SCRIPTS_DIR)
  $(CD) $(S_INSTALL_SCRIPTS_DIR)
  $(CP) *.*  $(P_INSTALL_SCRIPTS_DIR)
  @echo Working on Install Branding Files
  $(MKDIR) $(P_BRANDING_DIR)
  $(CD) $(S_BRANDING_DIR)
  $(CP) *.*  $(P_BRANDING_DIR)
  @echo Working on Install Packages
  $(MKDIR) $(P_PACKAGE_DIR)
  $(CD) $(S_PACKAGE_DIR)
  $(CP) *.*  $(P_PACKAGE_DIR)
  @echo $(DELIM)
  @echo Working on AppSight BlackBox Redist Files
  $(MKDIR) $(P_APPSIGHT_DIR)
  $(CD) $(S_APPSIGHT_DIR)
  $(CPDIR) . $(P_APPSIGHT_DIR) .svn
  @echo $(DELIM)
  @echo Working on installer prerequisites
  $(MKDIR) $(P_PREREQ_DIR)
  $(CD) $(S_PREREQ_DIR)
  $(CP) *.* $(P_PREREQ_DIR)
  @echo $(DELIM)
  
###############################################
# RMP\Extensions
###############################################

S_EXT_DIR             = $(S_METRANET_DIR)\Extensions

P_BASE_REQEXT_DIR     = $(P_BASE_DIR)\RequiredExtensions
P_BASE_OPTEXT_DIR     = $(P_BASE_DIR)\OptionalExtensions

P_CORE_PE_DIR         = $(P_BASE_REQEXT_DIR)\Core
P_SYSTEMCONFIG_PE_DIR = $(P_BASE_REQEXT_DIR)\SystemConfig
P_ACCOUNT_PE_DIR      = $(P_BASE_REQEXT_DIR)\Account
P_PAGENAV_PE_DIR      = $(P_BASE_REQEXT_DIR)\PageNav
P_METRAVIEW_PE_DIR	  = $(P_BASE_REQEXT_DIR)\MetraView
P_DATAEXPORT_PE_DIR   = $(P_BASE_REQEXT_DIR)\DataExport
P_MVMAMP_PE_DIR       = $(P_BASE_REQEXT_DIR)\MvmAmp
P_MVMCORE_PE_DIR      = $(P_BASE_REQEXT_DIR)\MvmCore
P_TAX_PE_DIR          = $(P_BASE_REQEXT_DIR)\Tax

P_PYMTSVR_PE_DIR      = $(P_BASE_OPTEXT_DIR)\PaymentSvr
P_PYMTSVRCLI_PE_DIR   = $(P_BASE_OPTEXT_DIR)\PaymentSvrClient
# P_SAMPLESITE_PE_DIR   = $(P_BASE_OPTEXT_DIR)\SampleSite
P_AR_PE_DIR           = $(P_BASE_OPTEXT_DIR)\AR
P_ARSAMPLE_PE_DIR     = $(P_BASE_OPTEXT_DIR)\ARSample
P_REPORTING_PE_DIR    = $(P_BASE_OPTEXT_DIR)\Reporting
P_METRATAX_PE_DIR     = $(P_BASE_OPTEXT_DIR)\MetraTax
P_TAXWARE_PE_DIR      = $(P_BASE_OPTEXT_DIR)\TaxWare
P_BILLSOFT_PE_DIR     = $(P_BASE_OPTEXT_DIR)\BillSoft
P_VERTEXQ_PE_DIR      = $(P_BASE_OPTEXT_DIR)\VertexQ
P_PARTITIONS_PE_DIR   = $(P_BASE_REQEXT_DIR)\Partitions

RMP_Extensions:
  @echo $(DELIM)
  @echo Working on Required Platform Extensions...
  $(MKDIR) $(P_BASE_REQEXT_DIR)
  @echo $(LABEL) > $(P_BASE_REQEXT_DIR)\$(PLACEHOLDER)

  @echo   Core
  $(CD) $(S_EXT_DIR)\Core
  $(CPDIR) . $(P_CORE_PE_DIR) .svn

  @echo   SystemConfig
  $(CD) $(S_EXT_DIR)\SystemConfig
  $(CPDIR) . $(P_SYSTEMCONFIG_PE_DIR) .svn

  @echo   Account
  $(CD) $(S_EXT_DIR)\Account
  $(CPDIR) . $(P_ACCOUNT_PE_DIR) .svn
  
  @echo   PageNav
  $(CD) $(S_EXT_DIR)\PageNav
  $(CPDIR) . $(P_PAGENAV_PE_DIR) .svn

  @echo MetraView
  $(CD) $(S_EXT_DIR)\MetraView
  $(CPDIR) . $(P_METRAVIEW_PE_DIR) .svn
  
  @echo DataExport
  $(CD) $(S_EXT_DIR)\DataExport
  $(CPDIR) . $(P_DATAEXPORT_PE_DIR) .svn

  @echo MvmAmp
  $(CD) $(S_MVMEXTAMP_DIR)
  $(CPDIR) . $(P_MVMAMP_PE_DIR) .git .md
  
  @echo MvmCore
  $(CD) $(S_MVMEXTCORE_DIR)
  $(CPDIR) . $(P_MVMCORE_PE_DIR) .git .md
  
  @echo   Tax
  $(CD) $(S_EXT_DIR)\Tax
  $(CPDIR) . $(P_TAX_PE_DIR) .svn
  
  @echo $(DELIM)
  @echo Working on Optional Platform Extensions...
  $(MKDIR) $(P_BASE_OPTEXT_DIR)
  @echo $(LABEL) > $(P_BASE_OPTEXT_DIR)\$(PLACEHOLDER).opt

  @echo   PaymentSvr
  $(CD) $(S_EXT_DIR)\PaymentSvr
  $(CPDIR) . $(P_PYMTSVR_PE_DIR) .svn
  @echo $(LABEL) > $(P_PYMTSVR_PE_DIR)\$(PLACEHOLDER)

  @echo   PaymentSvrClient
  $(CD) $(S_EXT_DIR)\PaymentSvrClient
  $(CPDIR) . $(P_PYMTSVRCLI_PE_DIR) .svn
  @echo $(LABEL) > $(P_PYMTSVRCLI_PE_DIR)\$(PLACEHOLDER)

  @echo   AR
  $(CD) $(S_EXT_DIR)\AR
  $(CPDIR) . $(P_AR_PE_DIR) .svn
  @echo $(LABEL) > $(P_AR_PE_DIR)\$(PLACEHOLDER)

  @echo   ARSample
  $(CD) $(S_EXT_DIR)\ARSample
  $(CPDIR) . $(P_ARSAMPLE_PE_DIR) .svn
  @echo $(LABEL) > $(P_ARSAMPLE_PE_DIR)\$(PLACEHOLDER)
  
  @echo   Reporting
  $(CD) $(S_EXT_DIR)\Reporting
  $(CPDIR) . $(P_REPORTING_PE_DIR) .svn
  @echo $(LABEL) > $(P_REPORTING_PE_DIR)\$(PLACEHOLDER)
  $(CD) $(O_BIN_DIR)
  $(CP) $(REPORTING_DLL) $(P_REPORTING_PE_DIR)\WebService
  
  @echo   MetraTax
  $(CD) $(S_EXT_DIR)\MetraTax
  $(CPDIR) . $(P_METRATAX_PE_DIR) .svn
  @echo $(LABEL) > $(P_METRATAX_PE_DIR)\$(PLACEHOLDER)

  @echo   TaxWare
  $(CD) $(S_EXT_DIR)\TaxWare
  $(CPDIR) . $(P_TAXWARE_PE_DIR) .svn
  @echo $(LABEL) > $(P_TAXWARE_PE_DIR)\$(PLACEHOLDER)
  
  @echo   VertexQ
  $(CD) $(S_EXT_DIR)\VertexQ
  $(CPDIR) . $(P_VERTEXQ_PE_DIR) .svn
  @echo $(LABEL) > $(P_VERTEXQ_PE_DIR)\$(PLACEHOLDER)

  @echo   BillSoft
  $(CD) $(S_EXT_DIR)\BillSoft
  $(MKDIR) $(P_BILLSOFT_PE_DIR)\config
  $(MKDIR) $(P_BILLSOFT_PE_DIR)\config\PluginTypes
  $(MKDIR) $(P_BILLSOFT_PE_DIR)\config\UsageServer
  $(MKDIR) $(P_BILLSOFT_PE_DIR)\config\Security
  $(MKDIR) $(P_BILLSOFT_PE_DIR)\config\GridLayouts
  $(MKDIR) $(P_BILLSOFT_PE_DIR)\config\ActivityServices
  @echo   Copying Xml files
  $(CD) $(S_EXT_DIR)\BillSoft\config
  $(CP) *.xml $(P_BILLSOFT_PE_DIR)\config
  @echo   Copying PluginTypes
  $(CD) $(S_EXT_DIR)\BillSoft\config\PluginTypes
  $(CPDIR) . $(P_BILLSOFT_PE_DIR)\config\PluginTypes .svn
  @echo   Copying UsageServer
  $(CD) $(S_EXT_DIR)\BillSoft\config\UsageServer
  $(CPDIR) . $(P_BILLSOFT_PE_DIR)\config\UsageServer .svn
  @echo   Copying Security
  $(CD) $(S_EXT_DIR)\BillSoft\config\Security
  $(CPDIR) . $(P_BILLSOFT_PE_DIR)\config\Security .svn
  @echo   Copying GridLayouts
  $(CD) $(S_EXT_DIR)\BillSoft\config\GridLayouts
  $(CPDIR) . $(P_BILLSOFT_PE_DIR)\config\GridLayouts .svn
  @echo   Copying ActivityServices
  $(CD) $(S_EXT_DIR)\BillSoft\config\ActivityServices
  $(CPDIR) . $(P_BILLSOFT_PE_DIR)\config\ActivityServices .svn
  @echo $(LABEL) > $(P_BILLSOFT_PE_DIR)\$(PLACEHOLDER)

  @echo Partitions
  $(CD) $(S_EXT_DIR)\Partitions
  $(CPDIR) . $(P_PARTITIONS_PE_DIR) .svn

################################################
# Attributes Reset
################################################

attrib_set:
  @echo $(DELIM)
  @echo Resetting file attributes...
  -attrib -R /S $(P_BASE_DIR)\*.*


################################################
# MetraConnect
################################################

METRACONNECT_COM_DLLS = \
  COMMeter.dll \
  COMTicketAgent.dll \
  GenericCollection.dll \
  
METRACONNECT_COM_DLLSPDB = \
  COMMeter.pdb \
  COMTicketAgent.pdb \
  GenericCollection.pdb \
  

METRACONNECT_DLLS = \
  mtsdk.dll \
  mtsl.dll \
  sdk_msg.dll \
  mtglobal_msg.dll \
  xmlconfig.dll \
  zlib1.dll \
  
METRACONNECT_DLLSPDB = \
  mtsdk.pdb \
  mtsl.pdb \
  xmlconfig.pdb \


METRACONNECT_EXES = \
  batch.exe \
  compound.exe \
  sessionset.exe \
  simple.exe \
  
METRACONNECT_EXESPDB = \
  batch.pdb \
  compound.pdb \
  sessionset.pdb \
  simple.pdb \

METRACONNECT_DBMETERING = \
  COMMeter.interop.dll \
  MetraTech.Metering.DatabaseMetering.dll \
  MetraConnect-DB.exe \
  msix2sql.exe \
  
METRACONNECT_DBMETERINGPDB = \
  MetraTech.Metering.DatabaseMetering.pdb \
  MetraConnect-DB.pdb \

METRACONNECT_LIBRARIES = \
  mtsdk.lib \

S_SDK_DIR          = $(S_BASE_DIR)\SDK
S_MC_CONFIG_DIR    = $(S_METRACONNECT_DIR)\Config
P_METRACONNECT_DIR = $(P_BASE_DIR)\MetraConnect

MetraConnect:
  @echo $(DELIM)
  @echo Working on MetraConnect...
  @echo   Creating Directories
  $(MKDIR) $(P_METRACONNECT_DIR)
  $(MKDIR) $(P_METRACONNECT_DIR)\bin
  $(MKDIR) $(P_METRACONNECT_DIR)\COMDLLs
  $(MKDIR) $(P_METRACONNECT_DIR)\DBMetering
  $(MKDIR) $(P_METRACONNECT_DIR)\lib
  $(MKDIR) $(P_METRACONNECT_DIR)\include
  $(MKDIR) $(P_METRACONNECT_DIR)\java
  $(MKDIR) $(P_METRACONNECT_DIR)\web
  $(MKDIR) $(P_METRACONNECT_DIR)\web\doc
  $(MKDIR) $(P_METRACONNECT_DIR)\config
  $(MKDIR) $(P_METRACONNECT_DIR)\samples\DBMetering
  @echo   Copying Binaries
  $(CD) $(O_BIN_DIR)
  $(CP) $(METRACONNECT_COM_DLLS) $(P_METRACONNECT_DIR)\COMDLLs
  $(CP) $(METRACONNECT_DLLS) $(P_METRACONNECT_DIR)\bin
  $(CP) $(METRACONNECT_EXES) $(P_METRACONNECT_DIR)\bin
  $(CP) $(METRACONNECT_DBMETERING) $(P_METRACONNECT_DIR)\DBMetering
  $(CP) $(METRACONNECT_COM_DLLSPDB) $(P_METRACONNECT_DIR)\COMDLLs
  $(CP) $(METRACONNECT_DLLSPDB) $(P_METRACONNECT_DIR)\bin
  $(CP) $(METRACONNECT_EXESPDB) $(P_METRACONNECT_DIR)\bin
  $(CP) $(METRACONNECT_DBMETERINGPDB) $(P_METRACONNECT_DIR)\DBMetering
  
  @echo   Copying Libraries
  $(CD) $(O_LIB_DIR)
  $(CP) $(METRACONNECT_LIBRARIES) $(P_METRACONNECT_DIR)\lib
  @echo   Copying Includes
  $(CD) $(S_SDK_DIR)\include
  $(CP) mtsdk.h $(P_METRACONNECT_DIR)\include
  $(CD) $(O_INCLUDE_DIR)      
  $(CP) sdk_msg.h $(P_METRACONNECT_DIR)\include
  @echo   Copying Java
  $(CD) $(O_JAVA_DIR)\dist      
  $(CP) *.jar $(P_METRACONNECT_DIR)\java
  @echo   Copying Samples
  $(CD) $(S_SDK_DIR)\Samples
  $(CPDIR) batch $(P_METRACONNECT_DIR)\samples\batch .svn
  $(CPDIR) simple $(P_METRACONNECT_DIR)\samples\simple .svn
  $(CPDIR) compound $(P_METRACONNECT_DIR)\samples\compound .svn
  $(CPDIR) sessionset $(P_METRACONNECT_DIR)\samples\sessionset .svn
  $(CD) $(O_JAVA_DIR)\dist\samples      
  $(CPDIR) . $(P_METRACONNECT_DIR)\samples\java .svn
  @echo   Copying Runtime files
  $(CD) $(S_METRACONNECT_DIR)
  $(CPDIR) . $(P_METRACONNECT_DIR) .svn
  @echo   Copying Config Files
  $(CD) $(S_METRATECH_DIR)\Metering\DatabaseMetering
  $(CP) *.xml $(P_METRACONNECT_DIR)\samples\DBMetering


################################################
# DISK1 (install CD image)
################################################

S_DOCS_DIR        = $(S_TECHDOC_DIR)\Published
P_DISK1_DIR       = $(P_BASE_DIR)\DISK1
P_DISK1_TOOLS_DIR = $(P_DISK1_DIR)\Tools

DISK1_BINARIES = \
  browser.exe \

DISK1_Extras:
  @echo $(DELIM)
  @echo Working on DISK1 Extras...
  @echo   Creating Directories
  $(MKDIR) $(P_DISK1_DIR)
  $(MKDIR) $(P_DISK1_TOOLS_DIR)
  @echo   Copying Binaries
  $(CD) $(O_BIN_DIR)
  $(CP) $(DISK1_BINARIES) $(P_DISK1_TOOLS_DIR)
  @echo   Copying Documentation
  $(CD) $(S_DOCS_DIR)\CD
  $(CPDIR) . $(P_DISK1_DIR) .svn
  
 

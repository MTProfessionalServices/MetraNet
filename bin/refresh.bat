@ECHO . . . REFRESHING MetraNet . . .

copy %MTOUTDIR%\%VERSION%\bin\Microsoft.Web.Infrastructure.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\Microsoft.Web.Mvc.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\System.Web.Helpers.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\System.Web.Mvc.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\System.Web.Razor.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\System.Web.WebPages.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\System.Web.WebPages.Razor.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\WebActivator.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\System.Web.WebPages.Deployment.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin

copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Performance.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin

copy %MTOUTDIR%\%VERSION%\bin\AntiXssLibrary.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.SecurityFramework.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\Microsoft.Data.Schema.ScriptDom.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\Microsoft.Data.Schema.ScriptDom.Sql.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin

copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Dataflow.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Dataflow.pdb %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Pipeline.ReRun.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MTBillingReRun.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Collections.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MTProductCatalogExec.interop.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Utils.* %ROOTDIR%\MetraTech\UI\MetraNet\bin

copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Approvals.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.MetraAR.*.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Localization.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\quickgraph* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\agsXMPP* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\\Castle.Core.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\\Castle.DynamicProxy2.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\\Castle.MicroKernel.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\\Castle.Windsor.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\\CommonServiceLocator.WindsorAdapter.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\\Iesi.Collections.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\\LinFu.Core.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\\log4net.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\\Microsoft.Practices.ServiceLocation.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\\Microsoft.Practices.Unity.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\\Microsoft.Practices.EnterpriseLibrary.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\\Microsoft.VisualStudio.TextTemplating.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\\Newtonsoft.Json.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\\NHibernate.ByteCode.Castle.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\\NHibernate.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\\NHibernate.LambdaExtensions.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\\NHibernate.Validator.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\\NHibernate.Validator.Specific.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\\NHibernate.XmlSerializers.* %ROOTDIR%\MetraTech\UI\MetraNet\bin

copy %MTOUTDIR%\%VERSION%\bin\MetraTech.BusinessEntity.Core.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Basic.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.BusinessEntity.DataAccess.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.BusinessEntity.Service.ClientProxies.* %ROOTDIR%\MetraTech\UI\MetraNet\bin

copy %MTOUTDIR%\%VERSION%\bin\*entity* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\*.Interface* %ROOTDIR%\MetraTech\UI\MetraNet\bin

copy %MTOUTDIR%\%VERSION%\bin\Core.Common.* %ROOTDIR%\MetraTech\UI\MetraNet\bin

copy %RMPDIR%\Extensions\PageNav\bin\MetraTech.PageNav.ClientProxies.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.DomainModel.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Core.Services.ClientProxies.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %RMPDIR%\Extensions\Account\bin\MetraTech.Account.ClientProxies.* %ROOTDIR%\MetraTech\UI\MetraNet\bin

copy %MTOUTDIR%\%VERSION%\bin\MetraTech.UI.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Events* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Security* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MTAuditEvents* %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Debug.Diagnostics* %ROOTDIR%\MetraTech\UI\MetraNet\bin

copy %MTOUTDIR%\%VERSION%\bin\COMMeter.interop.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\COMSecureStore.interop.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\comticketagent.interop.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.OnlineBill.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.OnlineBill.pdb %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.ActivityServices.Services.Common.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.ActivityServices.Services.Common.pdb %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Common.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Common.pdb %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.DataAccess.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.DataAccess.pdb %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.DataAccess.QueryManagement.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.DataAccess.QueryManagement.pdb %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.DataExportFramework.Common.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.DataExportFramework.Common.pdb %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.ActivityServices.Common.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.ActivityServices.Common.pdb %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Pipeline.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Pipeline.Messages.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Pipeline.Messages.pdb %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Pipeline.pdb %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Xml.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Xml.pdb %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTime.interop.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MTAuth.interop.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MTEnumConfig.interop.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MTPipelineLib.interop.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MTProductCatalog.interop.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MTProductViewExec.interop.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MTServerAccess.interop.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\NameID.interop.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\Oracle.DataAccess.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\PipelineControl.interop.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\PipelineInterop.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\PipelineInterop.pdb %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\PipelineTransaction.interop.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\QueryAdapter.interop.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\RCD.interop.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\Rowset.interop.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\SysContext.interop.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MTYAAC.interop.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Accounts.Type.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\IMTAccountType.interop.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\GenericCollection.interop.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Statistics.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Auth.Capabilities.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Auth.Capabilities.pdb %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.UsageServer.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.UsageServer.pdb %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\RsaKmc.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\kmclient.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.MetraPay.PaymentGateway.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.NotificationEvents.EventHandler.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin

copy %MTOUTDIR%\%VERSION%\bin\MetraTech.ExpressionEngine.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.ExpressionEngine.pdb %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.ExpressionEngine.Metadata.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.ExpressionEngine.Metadata.pdb %ROOTDIR%\MetraTech\UI\MetraNet\bin

copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Domain.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Application.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\EntityFramework.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.CreditNotes.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin

copy %MTOUTDIR%\%VERSION%\bin\MetraTech.NotificationEvents.EventHandler.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Notifications.UIConfiguration.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin

IF NOT EXIST %ROOTDIR%\MetraTech\UI\MetraNet\bin\da MKDIR 		%ROOTDIR%\MetraTech\UI\MetraNet\bin\da
IF NOT EXIST %ROOTDIR%\MetraTech\UI\MetraNet\bin\de MKDIR 		%ROOTDIR%\MetraTech\UI\MetraNet\bin\de
IF NOT EXIST %ROOTDIR%\MetraTech\UI\MetraNet\bin\en MKDIR 		%ROOTDIR%\MetraTech\UI\MetraNet\bin\en
IF NOT EXIST %ROOTDIR%\MetraTech\UI\MetraNet\bin\en-GB MKDIR 	%ROOTDIR%\MetraTech\UI\MetraNet\bin\en-GB
IF NOT EXIST %ROOTDIR%\MetraTech\UI\MetraNet\bin\es MKDIR 		%ROOTDIR%\MetraTech\UI\MetraNet\bin\es
IF NOT EXIST %ROOTDIR%\MetraTech\UI\MetraNet\bin\es-mx MKDIR 	%ROOTDIR%\MetraTech\UI\MetraNet\bin\es-mx
IF NOT EXIST %ROOTDIR%\MetraTech\UI\MetraNet\bin\fr MKDIR 		%ROOTDIR%\MetraTech\UI\MetraNet\bin\fr
IF NOT EXIST %ROOTDIR%\MetraTech\UI\MetraNet\bin\it MKDIR 		%ROOTDIR%\MetraTech\UI\MetraNet\bin\it
IF NOT EXIST %ROOTDIR%\MetraTech\UI\MetraNet\bin\ja MKDIR 		%ROOTDIR%\MetraTech\UI\MetraNet\bin\ja
IF NOT EXIST %ROOTDIR%\MetraTech\UI\MetraNet\bin\pt-br MKDIR 	%ROOTDIR%\MetraTech\UI\MetraNet\bin\pt-br
IF NOT EXIST %ROOTDIR%\MetraTech\UI\MetraNet\bin\zh-CN MKDIR 	%ROOTDIR%\MetraTech\UI\MetraNet\bin\zh-CN

copy %MTOUTDIR%\%VERSION%\bin\da\* 		%ROOTDIR%\MetraTech\UI\MetraNet\bin\da
copy %MTOUTDIR%\%VERSION%\bin\de\* 		%ROOTDIR%\MetraTech\UI\MetraNet\bin\de
copy %MTOUTDIR%\%VERSION%\bin\en\* 		%ROOTDIR%\MetraTech\UI\MetraNet\bin\en
copy %MTOUTDIR%\%VERSION%\bin\en-GB\* 	%ROOTDIR%\MetraTech\UI\MetraNet\bin\en-GB
copy %MTOUTDIR%\%VERSION%\bin\es\* 		%ROOTDIR%\MetraTech\UI\MetraNet\bin\es
copy %MTOUTDIR%\%VERSION%\bin\es-mx\* 	%ROOTDIR%\MetraTech\UI\MetraNet\bin\es-mx
copy %MTOUTDIR%\%VERSION%\bin\fr\* 		%ROOTDIR%\MetraTech\UI\MetraNet\bin\fr
copy %MTOUTDIR%\%VERSION%\bin\it\* 		%ROOTDIR%\MetraTech\UI\MetraNet\bin\it
copy %MTOUTDIR%\%VERSION%\bin\ja\* 		%ROOTDIR%\MetraTech\UI\MetraNet\bin\ja
copy %MTOUTDIR%\%VERSION%\bin\pt-br\* 	%ROOTDIR%\MetraTech\UI\MetraNet\bin\pt-br
copy %MTOUTDIR%\%VERSION%\bin\zh-CN\* 	%ROOTDIR%\MetraTech\UI\MetraNet\bin\zh-CN


REM copy %MTOUTDIR%\%VERSION%\bin\Ajax* %ROOTDIR%\MetraTech\UI\MetraNet\bin
REM copy %MTOUTDIR%\%VERSION%\bin\Microsoft.* %ROOTDIR%\MetraTech\UI\MetraNet\bin

copy %MTOUTDIR%\%VERSION%\bin\EasyNetQ.Management.Client.dll %ROOTDIR%\MetraTech\UI\MetraNet\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Presentation.* %ROOTDIR%\MetraTech\UI\MetraNet\bin
REM Pause

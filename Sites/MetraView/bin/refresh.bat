@ECHO . . . REFRESHING MetraView . . .

copy %MTOUTDIR%\%VERSION%\bin\AntiXssLibrary.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.SecurityFramework.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\Microsoft.Data.Schema.ScriptDom.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\Microsoft.Data.Schema.ScriptDom.Sql.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin

copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Accounts.Ownership.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Localization.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\COMDBObjects.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MTHierarchyReports.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin

copy %MTOUTDIR%\%VERSION%\bin\MetraTech.ActivityServices.Services.Common.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\agsXMPP* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\\Castle.Core.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\\Castle.DynamicProxy2.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\\Castle.MicroKernel.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\\Castle.Windsor.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\\CommonServiceLocator.WindsorAdapter.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\\Iesi.Collections.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\\LinFu.Core.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\\log4net.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\\Microsoft.Practices.ServiceLocation.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\\Microsoft.Practices.Unity.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\\Microsoft.Practices.EnterpriseLibrary.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\\Microsoft.VisualStudio.TextTemplating.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\\Newtonsoft.Json.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\\NHibernate.ByteCode.Castle.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\\NHibernate.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\\NHibernate.LambdaExtensions.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\\NHibernate.Validator.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\\NHibernate.Validator.Specific.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\\NHibernate.XmlSerializers.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin

copy %MTOUTDIR%\%VERSION%\bin\MetraTech.MetraPay.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.BusinessEntity.Core.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Basic.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.BusinessEntity.DataAccess.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.BusinessEntity.Service.ClientProxies.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin

copy %MTOUTDIR%\%VERSION%\bin\*entity* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\*.Interface* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin

copy %MTOUTDIR%\%VERSION%\bin\Core.Common.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin

copy %RMPDIR%\Extensions\PageNav\bin\MetraTech.PageNav.ClientProxies.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.DomainModel.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Core.Services.ClientProxies.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %RMPDIR%\Extensions\Account\bin\MetraTech.Account.ClientProxies.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.CreditNotes.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.UsageServer.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Reports.CrystalEnterprise.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin


copy %MTOUTDIR%\%VERSION%\bin\MetraTech.UI.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Events* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Security* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MTAuditEvents* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Debug.Diagnostics* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin

copy %MTOUTDIR%\%VERSION%\bin\COMMeter.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\COMSecureStore.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\comticketagent.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.OnlineBill.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.OnlineBill.pdb %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Common.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Common.pdb %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.DataAccess.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.DataAccess.pdb %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.ActivityServices.Common.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.ActivityServices.Common.pdb %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Pipeline.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Pipeline.Messages.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Pipeline.Messages.pdb %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Pipeline.pdb %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Xml.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Xml.pdb %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTime.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MTAuth.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MTEnumConfig.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MTPipelineLib.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MTProductCatalog.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MTProductViewExec.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MTServerAccess.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\NameID.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\Oracle.DataAccess.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\PipelineControl.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\PipelineInterop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\PipelineInterop.pdb %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\PipelineTransaction.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\QueryAdapter.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\RCD.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\Rowset.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\SysContext.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MTYAAC.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Accounts.Type.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\IMTAccountType.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\GenericCollection.interop.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Statistics.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Auth.Capabilities.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\RsaKmc.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\kmclient.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
copy %MTOUTDIR%\%VERSION%\bin\MetraTech.Performance.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin

IF NOT EXIST %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin\de MKDIR %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin\de
IF NOT EXIST %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin\en MKDIR %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin\en
IF NOT EXIST %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin\fr MKDIR %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin\fr
IF NOT EXIST %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin\it MKDIR %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin\it
IF NOT EXIST %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin\ja MKDIR %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin\ja

copy %MTOUTDIR%\%VERSION%\bin\de\MetraTech.DomainModel.BaseTypes.Resources.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin\de
copy %MTOUTDIR%\%VERSION%\bin\en\MetraTech.DomainModel.BaseTypes.Resources.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin\en
copy %MTOUTDIR%\%VERSION%\bin\fr\MetraTech.DomainModel.BaseTypes.Resources.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin\fr
copy %MTOUTDIR%\%VERSION%\bin\it\MetraTech.DomainModel.BaseTypes.Resources.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin\it
copy %MTOUTDIR%\%VERSION%\bin\ja\MetraTech.DomainModel.BaseTypes.Resources.dll %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin\ja

REM copy %MTOUTDIR%\%VERSION%\bin\Ajax* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin
REM copy %MTOUTDIR%\%VERSION%\bin\Microsoft.* %RMPDIR%\Extensions\MetraView\Sites\MetraView\bin

REM Pause
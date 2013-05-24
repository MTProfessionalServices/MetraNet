#pragma warning disable 1591  // Disable XML Doc warning for now.
using System;
using System.Collections.Generic;
using System.Text;
using System.ServiceModel;
using System.ServiceModel.Dispatcher;
using System.ServiceModel.Channels;
using System.ServiceModel.Description;

using MetraTech.ActivityServices.Services.Common;
using MetraTech.DataAccess;
using MetraTech.Interop.MTAuth;
using MetraTech.ActivityServices.Common;
using System.Configuration;
using MetraTech.Interop.RCD;
using System.IO;
using System.Diagnostics;
using System.Reflection;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.Interop.COMDBObjects;
using System.Xml.Schema;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.BaseTypes;

namespace MetraTech.ActivityServices.Services.Common
{
    public class CMASServiceBase : IServiceBehavior, IErrorHandler
    {
        #region Private Members
        private static Logger m_Logger;

        private static IMTSessionContext m_SessionContext = null;

        private static Dictionary<LanguageCode, ICOMLocaleTranslator> mLocaleTranslators = new Dictionary<LanguageCode,ICOMLocaleTranslator>();

        public delegate void ServiceStartingEventHandler();
        public static event ServiceStartingEventHandler ServiceStarting;

        public delegate void ServiceStartedEventHandler();
        public static event ServiceStartedEventHandler ServiceStarted;

        public delegate void ServiceStoppedEventHandler();
        public static event ServiceStoppedEventHandler ServiceStopped;

        #endregion

        public XmlSchemaSet Schemas { get; set; }

        static CMASServiceBase()
        {
            m_Logger = new Logger("Logging\\ActivityServices", "[MASErrorHandler]");
        }

        #region IErrorHandler Members

        public bool HandleError(Exception error)
        {
            return false;
        }

        public void ProvideFault(Exception error, System.ServiceModel.Channels.MessageVersion version, ref System.ServiceModel.Channels.Message fault)
        {
            if (error is MASBaseException)
            {
                FaultException fe = ((MASBaseException)error).CreateFaultDetail();
                MessageFault messageFault = fe.CreateMessageFault();
                fault = Message.CreateMessage(version, messageFault, fe.Action);
            }
            else
            {
                m_Logger.LogException("Unhandled exception in ActivityServices service", error);

                MASBasicFaultDetail faultDetail = new MASBasicFaultDetail("An unexpected error occurred in MetraNet Activity Services.");

                FaultException<MASBasicFaultDetail> fe = new FaultException<MASBasicFaultDetail>(faultDetail, "Unhandled Exception in MetraNet Activity Services");
                MessageFault messageFault = fe.CreateMessageFault();
                fault = Message.CreateMessage(version, messageFault, fe.Action);
            }
        }

        #endregion

        #region IServiceBehavior Members

        public void AddBindingParameters(ServiceDescription serviceDescription, ServiceHostBase serviceHostBase, System.Collections.ObjectModel.Collection<ServiceEndpoint> endpoints, BindingParameterCollection bindingParameters)
        {
        }

        public void ApplyDispatchBehavior(ServiceDescription serviceDescription, ServiceHostBase serviceHostBase)
        {
            WsdlExporter wsdlExporter = new WsdlExporter();
            foreach (ServiceEndpoint endpoint in serviceDescription.Endpoints)
            {
                wsdlExporter.ExportContract(endpoint.Contract);
            }

            foreach (ChannelDispatcher disp in serviceHostBase.ChannelDispatchers)
            {
                disp.ErrorHandlers.Add(this);

                foreach (EndpointDispatcher endDisp in disp.Endpoints)
                {
                    endDisp.DispatchRuntime.MessageInspectors.Add(new MASMessageInspector(serviceDescription.Name, wsdlExporter.GeneratedXmlSchemas));
                    //SECURITY-213: Implement protection from SQL and XSS injections in Activity Services
                    //Adding ParameterInspector to validate parameters
                    foreach (DispatchOperation op in endDisp.DispatchRuntime.Operations)
                        op.ParameterInspectors.Add(new ParameterValidationInspector());
                }
            }
        }

        public void Validate(ServiceDescription serviceDescription, ServiceHostBase serviceHostBase)
        {
        }

        #endregion

        #region Security Methods
        protected IMTSessionContext GetSessionContext()
        {
            IMTSessionContext retval = null;

            if (m_SessionContext == null)
            {
            CMASClientIdentity identity = null;
            try
            {
                identity = (CMASClientIdentity)ServiceSecurityContext.Current.PrimaryIdentity;

                retval = identity.SessionContext;
            }
            catch (Exception e)
            {
                m_Logger.LogException("Exception getting identity in GetSubscriptions", e);

                throw new MASBasicException("Service security identity is of improper type");
            }
            }
            else
            {
                retval = m_SessionContext;
            }

            return retval;
        }

        public void InitializeSecurity(string login, string nameSpace, string password)
        {
            IMTLoginContext loginContext = new MTLoginContextClass();

            m_SessionContext = loginContext.Login(login, nameSpace, password);
        }
        #endregion

        #region Service Start/Stop Event Methods
        protected static void OnServiceStarting()
        {
            if (ServiceStarting != null)
            {
                ServiceStarting.Invoke();
            }
        }

        protected static void OnServiceStarted()
        {
            if (ServiceStarted != null)
            {
                ServiceStarted.Invoke();
            }
        }

        protected static void OnServiceStopped()
        {
            if (ServiceStopped != null)
            {
                ServiceStopped.Invoke();
            }
        }

        public static void StartService()
        {
            OnServiceStarting();
        }

        public static void NotifyServiceStarted()
        {
            OnServiceStarted();
        }

        public static void StopService()
        {
            OnServiceStopped();
        }
        #endregion

        #region MTList Helpers
        protected void ApplyFilterSortCriteria<T>(IMTBaseFilterSortStatement statement, MTList<T> mtList)
        {
            MTListFilterSort.ApplyFilterSortCriteria<T>(statement, mtList, null, null);
        }

        protected void ApplyFilterSortCriteria<T>(IMTBaseFilterSortStatement statement, MTList<T> mtList, FilterColumnResolver resolver, object helper)
        {
            MTListFilterSort.ApplyFilterSortCriteria(statement, mtList, resolver, helper);
        }

        //protected delegate string FilterColumnResolver(string propName, ref object propValue, object helper);

        //private BaseFilterElement ConvertMTFilterElement(MTBaseFilterElement filterElement, FilterColumnResolver resolver, object helper)
        //{
        //    BaseFilterElement bfe = null;

        //    if (filterElement.GetType() == typeof(MTBinaryFilterOperator))
        //    {
        //        MTBinaryFilterOperator bfo = filterElement as MTBinaryFilterOperator;

        //        bfe = new BinaryFilterElement(
        //                    ConvertMTFilterElement(bfo.LeftHandElement, resolver, helper), 
        //                    (BinaryFilterElement.BinaryOperatorType)((int)bfo.OperatorType), 
        //                    ConvertMTFilterElement(bfo.RightHandElement, resolver, helper));
        //    }
        //    else if (filterElement.GetType() == typeof(MTFilterElement))
        //    {
        //        MTFilterElement fe = filterElement as MTFilterElement;
        //        object filterValue = fe.Value;
        //        string filterColumn = fe.PropertyName;

        //        if (resolver != null)
        //        {
        //            filterColumn = resolver(fe.PropertyName, ref filterValue, helper);
        //        }

        //        bfe = new FilterElement(filterColumn,
        //          (FilterElement.OperationType)((int)fe.Operation),
        //          filterValue);
        //    }
        //    else
        //    {
        //        throw new MASBasicException("Unexpected MTBaseFilterElement type");
        //    }

        //    return bfe;
        //}
        #endregion

        #region Protected Methods

        protected ProdCatTimeSpan.MTPCDateType GetEndDateType(int endDate)
        {
          switch (endDate)
          {
            /*      NoDate = 0, Absolute = 1, SubscriptionRelative = 2, NextBillingPeriod = 3,Null = 4,  */
            case 0:
              return ProdCatTimeSpan.MTPCDateType.NoDate;              
            case 1:
              return ProdCatTimeSpan.MTPCDateType.Absolute;              
            case 2:
              return ProdCatTimeSpan.MTPCDateType.SubscriptionRelative;
            case 3:
              return ProdCatTimeSpan.MTPCDateType.NextBillingPeriod;
            case 4:
              return ProdCatTimeSpan.MTPCDateType.Null;
            default:
              throw new MASBasicException("Unrecognized Date type");
          }
        }

        protected ProdCatTimeSpan GetEffectiveDate(IMTDataReader dataReader, string prefix)
        {
          ProdCatTimeSpan effectiveDate = new ProdCatTimeSpan();
          effectiveDate.TimeSpanId = dataReader.GetInt32(prefix + "_Id");
          effectiveDate.StartDateType = GetEndDateType(dataReader.GetInt32(prefix + "_BeginType"));
          if (effectiveDate.StartDateType == ProdCatTimeSpan.MTPCDateType.NoDate)
            effectiveDate.StartDate = null;
          else
          {
            if (!dataReader.IsDBNull(prefix + "_StartDate"))
              effectiveDate.StartDate = dataReader.GetDateTime(prefix + "_StartDate");
            else
              effectiveDate.StartDate = null;
          }

          effectiveDate.StartDateOffset = dataReader.GetInt32(prefix + "_BeginOffset");
          effectiveDate.EndDateType = GetEndDateType(dataReader.GetInt32(prefix + "_EndType"));

          // handle nulls
          if (effectiveDate.EndDateType == ProdCatTimeSpan.MTPCDateType.Null)
            effectiveDate.EndDate = null;
          else
          {
            if (!dataReader.IsDBNull(prefix + "_EndDate"))
              effectiveDate.EndDate = dataReader.GetDateTime(prefix + "_EndDate");
            else
              effectiveDate.EndDate = null;
          }

          effectiveDate.EndDateOffset = dataReader.GetInt32(prefix + "_EndOffSet");

          return effectiveDate;
        }

        protected T GetStubResponse<T>(string fileName) where T : class
        {

            MetraTech.Interop.RCD.IMTRcd rcd = new MetraTech.Interop.RCD.MTRcd();

            string filePath = Path.Combine(rcd.ExtensionDir, @"core\config\ActivityServices\Stubs\" + fileName);

            m_Logger.LogInfo("filepath : " + filePath);

            if (!File.Exists(filePath))
            {
                m_Logger.LogError("Stub file not found");
                throw new MASBasicException("stub file not found");
            }


            DataContractSerializer ds = new DataContractSerializer(typeof(T));

            //string path = @"config\ActivityServices\Stubs\" + fileName;
            FileInfo finfo = new FileInfo(filePath);
            T a;
            using (FileStream fs = finfo.Open(FileMode.Open, FileAccess.Read, FileShare.Write))
            {
                a = ds.ReadObject(fs) as T;
                fs.Close();
            }

            return a;
        }

        protected T GetStubResponse<T>() where T : class
        {
            string fileName = GetCallingMethodName();
            return GetStubResponse<T>(fileName);
        }

        protected void WriteStubObjectToXml(object objectToWrite)
        {
            string fileName = GetCallingMethodName();
            WriteStubObjectToXml(fileName, objectToWrite);
        }

        protected void WriteStubObjectToXml(string fileName, object objectToWrite)
        {
            MetraTech.Interop.RCD.IMTRcd rcd = new MetraTech.Interop.RCD.MTRcd();

            string filePath = Path.Combine(rcd.ExtensionDir, @"core\config\ActivityServices\Stubs\" + fileName);


            DataContractSerializer ds = new DataContractSerializer(objectToWrite.GetType());

            if (!File.Exists(filePath))
            {
                if (!Directory.Exists(Path.Combine(rcd.ExtensionDir, @"core\config\ActivityServices\Stubs")))
                {
                    Directory.CreateDirectory(Path.Combine(rcd.ExtensionDir, @"core\config\ActivityServices\Stubs"));
                }

                FileStream fc = File.Create(filePath);
                fc.Close();
            }


            FileInfo finfo = new FileInfo(filePath);
            using (FileStream fs = finfo.Open(FileMode.Truncate, FileAccess.ReadWrite, FileShare.Write))
            {
                ds.WriteObject(fs, objectToWrite);
                fs.Close();
            }
        }		

        protected string GetCallingMethodName()
        {
            StackTrace stackTrace = new StackTrace();
            StackFrame stackFrame = stackTrace.GetFrame(2);
            MethodBase methodBase = stackFrame.GetMethod();
            return string.Format("{0}.{1}.xml", methodBase.DeclaringType.Name, methodBase.Name);
        }

        protected bool HasManageAccHeirarchyAccess(int id_acc, AccessLevel accessLevel, MTHierarchyPathWildCard pathWildCard)
        {
            bool retval = false;

            string path = null;
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement("select tx_path from t_account_ancestor where id_descendent = ? and ? between vt_start and vt_end order by num_generations desc"))
                {
                    stmt.AddParam(MTParameterType.Integer, id_acc);
                    stmt.AddParam(MTParameterType.DateTime, MetraTime.Now);

                    using (IMTDataReader rdr = stmt.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            path = rdr.GetString(0);
                        }
                    }
                }
            }

            if (path != null)
            {
                IMTSecurity security = new MTSecurityClass();
                IMTCompositeCapability manageAH = security.GetCapabilityTypeByName("Manage Account Hierarchies").CreateInstance();
                IMTEnumTypeCapability enumCap = manageAH.GetAtomicEnumCapability();
                enumCap.SetParameter(accessLevel.ToString());

                IMTPathCapability pathCap = manageAH.GetAtomicPathCapability();
                pathCap.SetParameter(path, pathWildCard);
              
                if (GetSessionContext().SecurityContext.HasAccess(manageAH))
                {
                    retval = true;
                }
            }
            else
            {
                throw new MASBasicException("Unable to locate account in hierarchy");
            }

            return retval;
        }

        protected bool CanImpersonateAccount(int accountId, int impersonatorId)
        {
          bool retval = false;

          int owner = -1;
          string nameSpace = "";
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement("select nm_space, id_manager from t_account_mapper map left outer join t_bill_manager i on map.id_acc = i.id_manager where  i.id_acc = ? and i.id_manager = ?"))
            {
              stmt.AddParam(MTParameterType.Integer, accountId);
              stmt.AddParam(MTParameterType.Integer, impersonatorId);
              using (IMTDataReader rdr = stmt.ExecuteReader())
              {
                if (rdr.Read())
                {
                  nameSpace = rdr.GetString(0).ToLower();
                  if (nameSpace.Equals("system_user"))
                  {
                    return true;
                  }
                  owner = rdr.GetInt32(1);
                }
              }
            }
          }

          if (owner == impersonatorId)
          {            
              retval = true;
          }
          else
          {
            throw new MASBasicException(String.Format("The selected account cannot be impersonated by account {0} .", impersonatorId));
          }

          return retval;
        }

        protected string FormatValueForDB(object value)
        {
            string retval = null;

            if (value == null)
            {
                retval = "NULL";
            }
            else if (value is DateTime)
            {
                retval = DBUtil.ToDBString(((DateTime)value));
            }
            else if (value is string || value is String)
            {
                retval = string.Format("'{0}'", DBUtil.ToDBString(((string)value)));
            }
            else if (value.GetType().IsEnum)
            {
                if (value is RateEntryOperators)
                {
                    switch ((RateEntryOperators)value)
                    {
                        case RateEntryOperators.Equal:
                            retval = "'='";
                            break;
                        case RateEntryOperators.Greater:
                            retval = "'>'";
                            break;
                        case RateEntryOperators.GreaterEqual:
                            retval = "'>='";
                            break;
                        case RateEntryOperators.Less:
                            retval = "'<'";
                            break;
                        case RateEntryOperators.LessEqual:
                            retval = "'<='";
                            break;
                        case RateEntryOperators.NotEqual:
                            retval = "'!='";
                            break;
                    }
                }
                else
                {
                    retval = string.Format("{0}", EnumHelper.GetDbValueByEnum(value));
                }
            }
            else if (value is bool)
            {
                retval = ((bool)value ? "1" : "0");
            }
            else
            {
                retval = string.Format("{0}", value);
            }

            return retval;
        }

        #endregion

        protected static System.Configuration.Configuration LoadConfigurationFile(string configFile)
        {
            IMTRcd rcd = new MTRcd();
            //rcd.Init();

            string configPath = configFile;

            if (!Path.IsPathRooted(configPath))
            {
                MTRcdFileList fileList = rcd.RunQueryInAlternateFolder(configPath, true, rcd.ConfigDir);

                if (fileList.Count > 0)
                {
                    configPath = (string)fileList[0];
                }
                else
                {
                    throw new ArgumentException(string.Format("Configuration file {0} could not be located", configPath), "configFile");
                }
            }

            ExeConfigurationFileMap map = new ExeConfigurationFileMap();
            map.ExeConfigFilename = configPath;
            System.Configuration.Configuration config = ConfigurationManager.OpenMappedExeConfiguration(map, ConfigurationUserLevel.None);

            return config;
        }

        protected static ICOMLocaleTranslator GetLocaleTranslator(LanguageCode languageID)
        {
            lock (mLocaleTranslators)
            {
                ICOMLocaleTranslator translator = null;

                if (!mLocaleTranslators.TryGetValue(languageID, out translator))
                {
                    translator = new COMLocaleTranslator();
                    translator.Init(Enum.GetName(typeof(LanguageCode), languageID));
                    mLocaleTranslators.Add(languageID, translator);
                }

                return translator;
            }
        }

        protected string ResolveEnums(string propName, ref object filterVal, object helper)
        {
            if (filterVal is Enum)
            {
                filterVal = EnumHelper.GetDbValueByEnum(filterVal);
            }
            return propName;
        }

    }
}

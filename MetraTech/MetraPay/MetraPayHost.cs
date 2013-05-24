using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.ServiceModel;
using RCD = MetraTech.Interop.RCD;
using System.Configuration;
using System.IO;
using MetraTech.Interop.NameID;
using MetraTech.Interop.Rowset;
using System.Reflection;
using System.ServiceModel.Configuration;
using System.ServiceModel.Description;
using System.ServiceModel.Security;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.ActivityServices.Common;

namespace MetraTech.MetraPay
{
  class CMetraPayHost
  {
    #region Members
    private static System.Configuration.Configuration m_Configuration;
    private static CMetraPayConfig m_HostConfig;

    private Dictionary<string, ServiceHost> m_SvcHosts = new Dictionary<string, ServiceHost>();

    private Thread m_HostThread;
    private AutoResetEvent m_TerminateEvent = new AutoResetEvent(false);

    private Logger m_Logger;

    private bool m_bThreadStarted = false;

    // Cache Objects
    MTNameID m_NameID;
    MTSQLRowset m_SQLRowset;
    MetraTech.Interop.MTEnumConfig.EnumConfig m_EnumConfig;
    private static TypeExtensionsConfig m_TypeExtensions;
    #endregion

    #region Constructors
    static CMetraPayHost()
    {
      RCD.IMTRcd rcd = new RCD.MTRcd();
      ExeConfigurationFileMap map = new ExeConfigurationFileMap();
      map.ExeConfigFilename = Path.Combine(rcd.ConfigDir, @"MetraPay\MetraPayHost.xml");
      m_Configuration = ConfigurationManager.OpenMappedExeConfiguration(map, ConfigurationUserLevel.None);
      try
      {
        m_HostConfig = (CMetraPayConfig)m_Configuration.GetSection("MetraPayConfig");
      }
      catch (Exception e)
      {
        string s = e.Message;
      }

      m_TypeExtensions = TypeExtensionsConfig.GetInstance();
    }

    public CMetraPayHost()
    {
      m_Logger = new Logger("Logging\\MetraPay", "[MetraPayHost]");
    }
    #endregion

    #region Public Methods
    public bool StartHost()
    {
      bool retval = false;
      if (CreateServiceHosts())
      {
        m_HostThread = new Thread(new ThreadStart(HostEntryPoint));
        m_HostThread.Start();

        while (m_HostThread.IsAlive && !m_bThreadStarted) ;

        if (m_bThreadStarted)
        {
          retval = true;
        }
      }

      return retval;
    }

    public void StopHost()
    {
      m_TerminateEvent.Set();

      while (m_HostThread.IsAlive) ;
    }
    #endregion

    #region Public Static Methods
    public static Assembly LoadAssembly(string assemblyName)
    {
      Assembly retval = null;

      string searchName = assemblyName.Substring(0, (assemblyName.IndexOf(',') == -1 ? assemblyName.Length : assemblyName.IndexOf(','))).ToUpper();

      if (!searchName.Contains(".DLL"))
      {
        searchName += ".DLL";
      }

      try
      {
        AssemblyName nm = AssemblyName.GetAssemblyName(searchName);
        retval = Assembly.Load(nm);
      }
      catch (Exception)
      {
        try
        {
          retval = Assembly.LoadFile(Path.Combine(Path.GetDirectoryName(Assembly.GetEntryAssembly().Location), searchName));
        }
        catch (Exception)
        {
          RCD.IMTRcd rcd = new RCD.MTRcd();
          RCD.IMTRcdFileList fileList = rcd.RunQuery(string.Format("Bin\\{0}", searchName), false);

          if (fileList.Count > 0)
          {
            AssemblyName nm2 = AssemblyName.GetAssemblyName(((string)fileList[0]));
            retval = Assembly.Load(nm2);
          }
        }
      }

      return retval;
    }
    #endregion

    #region Thread Entry Point
    private void HostEntryPoint()
    {
      try
      {
        InitializeSingletons();

        m_Logger.LogDebug("Start WCF Service Host Instances");
        foreach (ServiceHost host in m_SvcHosts.Values)
        {
          host.Open();
        }

        bool bContinue = true;
        while (bContinue)
        {
          bContinue = false;
          foreach (ServiceHost host in m_SvcHosts.Values)
          {
            if (host.State != CommunicationState.Opened)
            {
              bContinue = true;
            }
          }
        }

        m_bThreadStarted = true;

        m_Logger.LogDebug("MetraPay Host Running");
        m_TerminateEvent.WaitOne();

        m_Logger.LogDebug("Stop WCF Service Host Instances");
        foreach (ServiceHost host in m_SvcHosts.Values)
        {
          host.Close();
        }
      }
      catch (Exception e)
      {
        m_Logger.LogException("Exception in CMetraPayHost::HostEntryPoint", e);

        Thread.Sleep(500);
      }
      finally
      {
        m_bThreadStarted = false;
      }
    }
    #endregion

    #region Private Methods
    private bool CreateServiceHosts()
    {
      AppDomain.CurrentDomain.AssemblyResolve += new ResolveEventHandler(CurrentDomain_AssemblyResolve);

      foreach (CMetraPayServiceInstance svcInst in m_HostConfig.ServiceInstances)
      {
          #region Add Payment Instrument Mgmt Svc
        //ServiceHost host = new ServiceHost(typeof(PaymentInstrumentMgmtSvc));
        MPServiceHost<PaymentInstrumentMgmtSvc> host = new MPServiceHost<PaymentInstrumentMgmtSvc>(svcInst.Name, svcInst.ProcessorType, svcInst.ConfigFile, svcInst.Timeout);

        NetTcpBinding binding = new NetTcpBinding(SecurityMode.TransportWithMessageCredential, false);
        binding.Security.Message.AlgorithmSuite = SecurityAlgorithmSuite.TripleDesRsa15;
        binding.Security.Message.ClientCredentialType = MessageCredentialType.Certificate;
        binding.Security.Transport.ClientCredentialType = TcpClientCredentialType.Certificate;
        binding.Security.Transport.ProtectionLevel = System.Net.Security.ProtectionLevel.EncryptAndSign;
        binding.TransactionFlow = true;

        host.AddServiceEndpoint("MetraTech.MetraPay.IPaymentInstrumentMgmtSvc", binding, string.Format("net.tcp://localhost:51515/{0}/PaymentInstrumentMgmtSvc", svcInst.Name));

        ServiceThrottlingBehavior throttle;
        throttle = new ServiceThrottlingBehavior();
        throttle.MaxConcurrentCalls = m_HostConfig.ServiceThrottling.MaxConcurrentCalls;
        throttle.MaxConcurrentInstances = m_HostConfig.ServiceThrottling.MaxConcurrentInstances;
        throttle.MaxConcurrentSessions = m_HostConfig.ServiceThrottling.MaxConcurrentSessions;
        host.Description.Behaviors.Add(throttle);

		// SECENG: Fixing problem with multiple active certificates with the same subject.		
		//host.Credentials.ServiceCertificate.SetCertificate(
		//                m_HostConfig.ServiceCertificate.StoreLocation,
		//                m_HostConfig.ServiceCertificate.StoreName,
		//                m_HostConfig.ServiceCertificate.X509FindType,
		//                m_HostConfig.ServiceCertificate.FindValue);

		host.Credentials.ServiceCertificate.Certificate = CertificateHelper.FindCertificate(
			m_HostConfig.ServiceCertificate.StoreName,
			m_HostConfig.ServiceCertificate.StoreLocation,
			m_HostConfig.ServiceCertificate.X509FindType,
			m_HostConfig.ServiceCertificate.FindValue);

        host.CloseTimeout = TimeSpan.FromSeconds(1);

        AddExtendedTypes(host);

        m_SvcHosts.Add(string.Format("{0}\\PaymentInstrumentMgmtSvc", svcInst.Name), host);
          #endregion

        #region Add Transaction Processing Service
        //host = new ServiceHost(typeof(PaymentInstrumentMgmtSvc));
        host = new MPServiceHost<PaymentInstrumentMgmtSvc>(svcInst.Name, svcInst.ProcessorType, svcInst.ConfigFile, svcInst.Timeout);

        binding = new NetTcpBinding(SecurityMode.TransportWithMessageCredential, false);
        binding.Security.Message.AlgorithmSuite = SecurityAlgorithmSuite.TripleDesRsa15;
        binding.Security.Message.ClientCredentialType = MessageCredentialType.Certificate;
        binding.Security.Transport.ClientCredentialType = TcpClientCredentialType.Certificate;
        binding.Security.Transport.ProtectionLevel = System.Net.Security.ProtectionLevel.EncryptAndSign;
        binding.TransactionFlow = true;

        host.AddServiceEndpoint("MetraTech.MetraPay.ITransactionProcessingService", binding, string.Format("net.tcp://localhost:51515/{0}/TransactionProcessingSvc", svcInst.Name));

        throttle = new ServiceThrottlingBehavior();
        throttle.MaxConcurrentCalls = m_HostConfig.ServiceThrottling.MaxConcurrentCalls;
        throttle.MaxConcurrentInstances = m_HostConfig.ServiceThrottling.MaxConcurrentInstances;
        throttle.MaxConcurrentSessions = m_HostConfig.ServiceThrottling.MaxConcurrentSessions;
        host.Description.Behaviors.Add(throttle);

		// SECENG: Fixing problem with multiple active certificates with the same subject.		
		//host.Credentials.ServiceCertificate.SetCertificate(
		//                m_HostConfig.ServiceCertificate.StoreLocation,
		//                m_HostConfig.ServiceCertificate.StoreName,
		//                m_HostConfig.ServiceCertificate.X509FindType,
		//                m_HostConfig.ServiceCertificate.FindValue);

		host.Credentials.ServiceCertificate.Certificate = CertificateHelper.FindCertificate(
			m_HostConfig.ServiceCertificate.StoreName,
			m_HostConfig.ServiceCertificate.StoreLocation,
			m_HostConfig.ServiceCertificate.X509FindType,
			m_HostConfig.ServiceCertificate.FindValue);

        host.CloseTimeout = TimeSpan.FromSeconds(1);

        AddExtendedTypes(host);

        m_SvcHosts.Add(string.Format("{0}\\TransactionProcessingSvc", svcInst.Name), host);
        #endregion

        #region Add Batch Update Service
        host = new MPServiceHost<PaymentInstrumentMgmtSvc>(svcInst.Name, svcInst.ProcessorType, svcInst.ConfigFile, svcInst.Timeout);

        binding = new NetTcpBinding(SecurityMode.TransportWithMessageCredential, false);
        binding.Security.Message.AlgorithmSuite = SecurityAlgorithmSuite.TripleDesRsa15;
        binding.Security.Message.ClientCredentialType = MessageCredentialType.Certificate;
        binding.Security.Transport.ClientCredentialType = TcpClientCredentialType.Certificate;
        binding.Security.Transport.ProtectionLevel = System.Net.Security.ProtectionLevel.EncryptAndSign;
        // increasing default values to avoid errors when passing more than 1000 credit cards
        binding.MaxBufferPoolSize = 9999999;
        binding.MaxBufferSize = 9999999;
        binding.MaxReceivedMessageSize = 9999999;
        binding.ReaderQuotas.MaxDepth = 32;
        binding.ReaderQuotas.MaxStringContentLength = 99999;
        binding.ReaderQuotas.MaxArrayLength = 16384;
        binding.ReaderQuotas.MaxBytesPerRead = 4096;
        binding.ReaderQuotas.MaxNameTableCharCount = 16384; 
        binding.TransactionFlow = true;

        host.AddServiceEndpoint("MetraTech.MetraPay.IBatchUpdateService", binding, string.Format("net.tcp://localhost:51515/{0}/BatchUpdateService", svcInst.Name));

        throttle = new ServiceThrottlingBehavior();
        throttle.MaxConcurrentCalls = m_HostConfig.ServiceThrottling.MaxConcurrentCalls;
        throttle.MaxConcurrentInstances = m_HostConfig.ServiceThrottling.MaxConcurrentInstances;
        throttle.MaxConcurrentSessions = m_HostConfig.ServiceThrottling.MaxConcurrentSessions;
        host.Description.Behaviors.Add(throttle);

        // SECENG: Fixing problem with multiple active certificates with the same subject.		
        //host.Credentials.ServiceCertificate.SetCertificate(
        //                m_HostConfig.ServiceCertificate.StoreLocation,
        //                m_HostConfig.ServiceCertificate.StoreName,
        //                m_HostConfig.ServiceCertificate.X509FindType,
        //                m_HostConfig.ServiceCertificate.FindValue);

          host.Credentials.ServiceCertificate.Certificate = CertificateHelper.FindCertificate(
                        m_HostConfig.ServiceCertificate.StoreName,
                        m_HostConfig.ServiceCertificate.StoreLocation,
                        m_HostConfig.ServiceCertificate.X509FindType,
                        m_HostConfig.ServiceCertificate.FindValue
                );

        host.CloseTimeout = TimeSpan.FromSeconds(1);

        AddExtendedTypes(host);

        m_SvcHosts.Add(string.Format("{0}\\BatchUpdateService", svcInst.Name), host);
        #endregion
      }

      return true;
    }

    private void AddExtendedTypes(ServiceHost host)
    {
      List<string> customizedTypes;

      foreach (ServiceEndpoint se in host.Description.Endpoints)
      {
        foreach (OperationDescription od in se.Contract.Operations)
        {
          foreach (ParameterInfo pi in od.SyncMethod.GetParameters())
          {
            customizedTypes = m_TypeExtensions.GetCustomizedTypes(pi.ParameterType);

            if (customizedTypes != null)
            {
              foreach (string customizedType in customizedTypes)
              {
                od.KnownTypes.Add(Type.GetType(customizedType, true, true));
              }
            }
          }
        }
      }
    }

    private Assembly CurrentDomain_AssemblyResolve(object sender, ResolveEventArgs args)
    {
      return CMetraPayHost.LoadAssembly(args.Name);
    }

    /// <summary>
    /// This method creates instances of some of our objects that utilizing caching. 
    /// This is done for performance reasons so that config reads and DB hits don't
    /// need to be repeated.
    /// </summary>
    private void InitializeSingletons()
    {
      m_NameID = new MTNameIDClass();

      // TODO: this works around the COM+ 15 second delay issue.
      // we need a cleaner fix!
      m_SQLRowset = new MetraTech.Interop.Rowset.MTSQLRowsetClass();
      m_SQLRowset.Init("queries\\ProductCatalog");

      m_EnumConfig = new MetraTech.Interop.MTEnumConfig.EnumConfigClass();
    }
    #endregion
  }
}

using System;
using System.Collections.Generic;
using System.Configuration;
using System.IdentityModel.Policy;
using System.IO;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Security;
using System.Security.Cryptography.X509Certificates;
using System.ServiceModel;
using System.ServiceModel.Description;
using System.ServiceModel.Dispatcher;
using System.ServiceModel.Channels;
using System.ServiceModel.Configuration;
using System.Text;
using System.Threading;

using Microsoft.ServiceBus;
using Microsoft.ServiceBus.Messaging;

using MetraTech.ActivityServices.Configuration;
using RCD = MetraTech.Interop.RCD;
using MetraTech.Interop.NameID;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.Rowset;
using System.ServiceModel.Security;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using System.Xml.Schema;
using System.Xml;
using MetraTech.SecurityFramework;
using MetraTech.Interop.RCD;
using MetraTech.Interop.MTServerAccess;
using System.Messaging;


#region Assembly Attribute
[assembly: InternalsVisibleTo("MetraTech.ActivityServices.Generated, PublicKey=" +
						"00240000048000009400000006020000002400005253413100040000010001009993f9ecb650f0" +
						"bf59efed30ebc31bd85224c1b5905a43f1eb8907b85adea02a4a94e3fd66bb594b04066fa4f836" +
						"e2c09f88bf3ca9ef98ee58cc2a8ece11c804f48306f053932fe4d711c3250b94c769d141bb76a4" +
						"66732466908441d4c27d9d5279758e548b0c038de1f664130e1232c2df09a53c35d1746de7966b" +
						"df27e798")]

#endregion

namespace MetraTech.ActivityServices.Runtime
{
    using Microsoft.ServiceBus;
    using Microsoft.ServiceBus.Messaging;

	public class CMASHost
	{
		#region Members
		public const string GENERATED_CODE_NAMESPACE = "MetraTech.ActivityServices.Generated";

		private static System.Configuration.Configuration m_Configuration;
		private static CMASHostConfig m_HostConfig;

		private static Assembly m_GeneratedClasses = null;

		private Dictionary<string, ServiceHost> m_SvcHosts = new Dictionary<string, ServiceHost>();

		private static Thread m_HostThread;
		private static AutoResetEvent m_TerminateEvent = new AutoResetEvent(false);
		private static readonly AutoResetEvent StartingServAutoEvent = new AutoResetEvent(false);
		private static readonly AutoResetEvent StoppingServAutoEvent = new AutoResetEvent(false);
		private static string m_AbortReason = null;

		private Logger m_Logger;

		private bool m_bStartProceduralProcessing = false;
		private bool m_bStartEventProcessing = false;

		private bool m_bThreadStarted = false;

        private static IMTServerAccessData AzureServiceBusServerAccessData = null;

		// Cache Objects
		MTNameID m_NameID;
		MTSQLRowset m_SQLRowset;
		MetraTech.Interop.MTEnumConfig.EnumConfig m_EnumConfig;
		MTSecurity m_Security;
		MTLoginContext m_LoginContext;
		private static TypeExtensionsConfig m_TypeExtensions;
		#endregion

		#region Constructors
		static CMASHost()
		{
			RCD.IMTRcd rcd = new RCD.MTRcd();
			ExeConfigurationFileMap map = new ExeConfigurationFileMap();
			map.ExeConfigFilename = Path.Combine(rcd.ConfigDir, @"ActivityServices\ActivityServicesHost.xml");
			m_Configuration = ConfigurationManager.OpenMappedExeConfiguration(map, ConfigurationUserLevel.None);
			m_HostConfig = (CMASHostConfig)m_Configuration.GetSection("MASHostConfig");

			m_TypeExtensions = TypeExtensionsConfig.GetInstance();
		}

		public CMASHost()
		{
			m_Logger = new Logger("Logging\\ActivityServices", "[MASHost]");

			m_Logger.LogDebug("ActivityServices Host Initializing");
		}

		public CMASHost(bool forCodeGeneration)
		{
			m_Logger = new Logger("Logging\\ActivityServices", "[MASHost]");

			m_Logger.LogDebug("ActivityServices Host Initializing");

			if (forCodeGeneration)
			{
				CreateServiceHosts(true, false);
			}
		}

		#endregion

		#region Properties
		public static System.Configuration.Configuration ConfigurationFile
		{
			get { return m_Configuration; }
		}

		public static CMASHostConfig HostConfig
		{
			get { return m_HostConfig; }
		}

		public Dictionary<string, ServiceHost> ServiceHosts
		{
			get { return m_SvcHosts; }
		}

		public static TypeExtensionsConfig TypeExtensions
		{
			get { return m_TypeExtensions; }
		}
		#endregion

		#region Public Methods
		public bool StartMASHost()
		{
			bool retval = false;
			try
			{
				CreateServiceHosts(false, true);

				//DumpMetadata();

				if (m_bStartEventProcessing || m_bStartProceduralProcessing)
				{
					m_HostThread = new Thread(new ThreadStart(HostEntryPoint));
					m_HostThread.Start();

					// Wait for signal about the successful MAS start...
					StartingServAutoEvent.WaitOne();

					if (m_bThreadStarted)
					{
						retval = true;
					}
				}
				else
				{
					throw new ApplicationException("No ActivityServices interfaces are defined.  Nothing to host.");
				}
			}
			catch (Exception e)
			{
				m_Logger.LogException("Exception starting ActivityServices host", e);
			}

			return retval;
		}

		//private void DumpMetadata()
		//{

		//    foreach (KeyValuePair<string, ServiceHost> svcHost in m_SvcHosts)
		//    {
		//        WsdlExporter wsdlExporter = new WsdlExporter();
		//        foreach (ServiceEndpoint endpoint in svcHost.Value.Description.Endpoints)
		//        {
		//            wsdlExporter.ExportContract(endpoint.Contract);
		//        }

		//        using (StreamWriter xmlWriter = new StreamWriter(string.Format(@"o:\debug\bin\MASCodeGen\{0}.xsd", svcHost.Key), true, Encoding.UTF8))
		//        {
		//            foreach (XmlSchema xsd in wsdlExporter.GeneratedXmlSchemas.Schemas("http://tempuri.org/"))
		//            {
		//                xsd.Write(xmlWriter);
		//            }
		//        }
		//    }

		//}

		public void StopMASHost()
		{
			m_TerminateEvent.Set();

			StoppingServAutoEvent.WaitOne();
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

			if (searchName == "METRATECH.ACTIVITYSERVICES.GENERATED.DLL")
			{
				retval = m_GeneratedClasses;
			}
			else
			{
				try
				{
					retval = Assembly.LoadFile(Path.Combine(Path.GetDirectoryName(Assembly.GetEntryAssembly().Location), searchName));
				}
				catch (Exception)
				{
					try
					{
						AssemblyName nm = AssemblyName.GetAssemblyName(searchName);
						retval = Assembly.Load(nm);
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
			}

			return retval;
		}

		public static Type GetGeneratedType(string className)
		{
			Type requestedType = m_GeneratedClasses.GetType(string.Format("{0}.{1}", CMASHost.GENERATED_CODE_NAMESPACE, className));

			return requestedType;
		}

		public static void TerminateHost(string reason)
		{
			m_AbortReason = reason;

			m_TerminateEvent.Set();
		}
		#endregion

		#region Thread Entry Point
		private void HostEntryPoint()
		{
			try
			{
				InitializeSingletons();

				if (m_bStartEventProcessing || m_bStartProceduralProcessing)
				{
					m_Logger.LogDebug("Start Processor static runtime");
					CMASProcessorBase.StartWorkflowRuntime();
				}

				m_Logger.LogDebug("Start WCF Service Host Instances");
				CMASServiceBase.StartService();

				foreach (var host in m_SvcHosts.Values)
				{
					host.Open();
				}

				CMASServiceBase.NotifyServiceStarted();

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
				StartingServAutoEvent.Set();

				m_Logger.LogDebug("ActivityServices Host Running");
				m_TerminateEvent.WaitOne();

				m_Logger.LogDebug("Stop WCF Service Host Instances");
				foreach (ServiceHost host in m_SvcHosts.Values)
				{
					host.Close();
				}

				CMASServiceBase.StopService();

				if (m_bStartProceduralProcessing || m_bStartEventProcessing)
				{
					m_Logger.LogDebug("Stop Processor static runtime");
					CMASProcessorBase.StopWorkflowRuntime();
				}
			}
			catch (Exception e)
			{
				m_Logger.LogException("Exception in CMASHost::HostEntryPoint", e);
			}
			finally
			{
				TearDownSingletons();
				m_bThreadStarted = false;
				StoppingServAutoEvent.Set();
				StartingServAutoEvent.Set();
			}

			if (!string.IsNullOrEmpty(m_AbortReason))
			{
				m_Logger.LogError("The MAS Host has been signaled to terminate abnormally with the following reason: {0}", m_AbortReason);

				throw new ApplicationException(m_AbortReason);
			}
		}
		#endregion

		#region Private Methods
		internal void CreateServiceHosts(bool bInMemoryOnly, bool bUseAuthMgr)
		{
			Dictionary<string, List<CMASEndPoint>> classNames = new Dictionary<string, List<CMASEndPoint>>();
			Dictionary<string, List<string>> supportedChildTypes = new Dictionary<string, List<string>>();
			Dictionary<string, CMASCodeService> codeServices = new Dictionary<string, CMASCodeService>();
			ServiceMetadataBehavior behavior;
			Uri baseUri;

			m_Logger.LogDebug("Generate Code from Configuration");
			GenerateCode(out m_GeneratedClasses, ref classNames, ref supportedChildTypes, ref codeServices, bInMemoryOnly);

			AppDomain.CurrentDomain.AssemblyResolve += new ResolveEventHandler(CurrentDomain_AssemblyResolve);

			string baseAddress = m_HostConfig.BaseAddress;

			if (m_HostConfig.BaseAddress.ToUpper().Contains("//LOCALHOST"))
			{
				baseAddress = m_HostConfig.BaseAddress.ToUpper().Replace("//LOCALHOST", string.Format("//{0}", System.Net.Dns.GetHostName()));
			}

            #region Add Code Generated Services
			m_Logger.LogDebug("Generate ServiceHost instances using generated code");
			if (m_GeneratedClasses != null)
			{
				foreach (KeyValuePair<string, List<CMASEndPoint>> classDef in classNames)
				{
					m_Logger.LogDebug("Adding Generated Service {0}", classDef.Key);

					baseUri = new Uri(new Uri(baseAddress), classDef.Key);

					Type genType = m_GeneratedClasses.GetType(string.Format("{0}.{1}", GENERATED_CODE_NAMESPACE, classDef.Key), true);
					ServiceHost host = new ServiceHost(genType, baseUri);

					host.Description.Behaviors.Remove(typeof(ServiceCredentials));
					host.Description.Behaviors.Add(new CMASServiceCredential());

					host.Credentials.UserNameAuthentication.UserNamePasswordValidationMode = System.ServiceModel.Security.UserNamePasswordValidationMode.Custom;
					host.Credentials.UserNameAuthentication.CustomUserNamePasswordValidator = new CMASUserNameValidator();

					//host.Credentials.ClientCertificate.Authentication.CertificateValidationMode = X509CertificateValidationMode.Custom;
					//host.Credentials.ClientCertificate.Authentication.CustomCertificateValidator = new CMASX509Validator();

                    // SECENG: Fixing problem with multiple active certificates with the same subject.
                    // host.Credentials.ServiceCertificate.SetCertificate(
                    //                  m_HostConfig.ServiceCertificate.StoreLocation,
                    //                  m_HostConfig.ServiceCertificate.StoreName,
                    //                  m_HostConfig.ServiceCertificate.X509FindType,
                    //                  m_HostConfig.ServiceCertificate.FindValue);

                    SetHostCertificate(host);
                    
                    behavior = new ServiceMetadataBehavior();
					behavior.HttpGetEnabled = true;
					behavior.HttpGetUrl = baseUri;
					host.Description.Behaviors.Add(behavior);

					ServiceThrottlingBehavior throttle;
					throttle = host.Description.Behaviors.Find<ServiceThrottlingBehavior>();

					if (throttle == null)
					{
						throttle = new ServiceThrottlingBehavior();
						throttle.MaxConcurrentCalls = m_HostConfig.DefaultServiceThrottling.MaxConcurrentCalls;
						throttle.MaxConcurrentInstances = m_HostConfig.DefaultServiceThrottling.MaxConcurrentInstances;
						throttle.MaxConcurrentSessions = m_HostConfig.DefaultServiceThrottling.MaxConcurrentSessions;
						host.Description.Behaviors.Add(throttle);
						host.CloseTimeout = TimeSpan.FromSeconds(1);
					}

					if (m_HostConfig.ClientCertificateValidation != null)
					{
						host.Credentials.ClientCertificate.Authentication.CertificateValidationMode = m_HostConfig.ClientCertificateValidation.CertificateValidationMode;
						host.Credentials.ClientCertificate.Authentication.RevocationMode = m_HostConfig.ClientCertificateValidation.RevocationMode;
						host.Credentials.ClientCertificate.Authentication.TrustedStoreLocation = m_HostConfig.ClientCertificateValidation.TrustedStoreLocation;
					}

					Type intfType = m_GeneratedClasses.GetType(string.Format("{0}.I{1}", GENERATED_CODE_NAMESPACE, classDef.Key), true);

					AddBindings(host, classDef.Key, intfType, classDef.Value);

					if (bUseAuthMgr)
					{
						host.Authorization.ServiceAuthorizationManager = new CMASServiceAuthorizationMgr(genType);
					}

					m_SvcHosts.Add(classDef.Key, host);
				}
			}
			#endregion

			#region Add Core Services
			m_Logger.LogDebug("Generate ServiceHost instances for Code Services");
			foreach (CMASCodeService codeSvc in codeServices.Values)
			{
				m_Logger.LogDebug("Adding Code Service {0}", codeSvc.ServiceType);

				Type svcType = Type.GetType(codeSvc.ServiceType);

				if (svcType != null)
				{
					baseUri = new Uri(new Uri(baseAddress), svcType.Name);

					ServiceHost host = new ServiceHost(svcType, baseUri);

					host.Description.Behaviors.Remove(typeof(ServiceCredentials));
					host.Description.Behaviors.Add(new CMASServiceCredential());

					host.Credentials.UserNameAuthentication.UserNamePasswordValidationMode = System.ServiceModel.Security.UserNamePasswordValidationMode.Custom;
					host.Credentials.UserNameAuthentication.CustomUserNamePasswordValidator = new CMASUserNameValidator();

					//host.Credentials.ClientCertificate.Authentication.CertificateValidationMode = X509CertificateValidationMode.Custom;
					//host.Credentials.ClientCertificate.Authentication.CustomCertificateValidator = new CMASX509Validator();

                    // SECENG: Fixing problem with multiple active certificates with the same subject.
                    //host.Credentials.ServiceCertificate.SetCertificate(
                    //                  m_HostConfig.ServiceCertificate.StoreLocation,
                    //                  m_HostConfig.ServiceCertificate.StoreName,
                    //                  m_HostConfig.ServiceCertificate.X509FindType,
                    //                  m_HostConfig.ServiceCertificate.FindValue);

                    SetHostCertificate(host);

					behavior = new ServiceMetadataBehavior();
					behavior.HttpGetEnabled = true;
					behavior.HttpGetUrl = baseUri;
					host.Description.Behaviors.Add(behavior);

					ServiceThrottlingBehavior throttle;
					throttle = host.Description.Behaviors.Find<ServiceThrottlingBehavior>();

					if (throttle == null)
					{
						throttle = new ServiceThrottlingBehavior();
						throttle.MaxConcurrentCalls = m_HostConfig.DefaultServiceThrottling.MaxConcurrentCalls;
						throttle.MaxConcurrentInstances = m_HostConfig.DefaultServiceThrottling.MaxConcurrentInstances;
						throttle.MaxConcurrentSessions = m_HostConfig.DefaultServiceThrottling.MaxConcurrentSessions;
						host.Description.Behaviors.Add(throttle);
						host.CloseTimeout = TimeSpan.FromSeconds(1);
					}

					if (m_HostConfig.ClientCertificateValidation != null)
					{
						host.Credentials.ClientCertificate.Authentication.CertificateValidationMode = m_HostConfig.ClientCertificateValidation.CertificateValidationMode;
						host.Credentials.ClientCertificate.Authentication.RevocationMode = m_HostConfig.ClientCertificateValidation.RevocationMode;
						host.Credentials.ClientCertificate.Authentication.TrustedStoreLocation = m_HostConfig.ClientCertificateValidation.TrustedStoreLocation;
					}

					foreach (CMASCodeInterface codeInterface in codeSvc.Interfaces)
					{
						Type intfType = Type.GetType(codeInterface.ContractType);

						AddBindings(host, codeInterface.InterfaceName, intfType, codeInterface.WCFEndPoints);
					}

					if (bUseAuthMgr)
					{
						host.Authorization.ServiceAuthorizationManager = new CMASServiceAuthorizationMgr(svcType);
					}

					AddExtendedTypes(host);

					m_SvcHosts.Add(svcType.FullName, host);
				}
				else if (bUseAuthMgr)
				{
					throw new InvalidOperationException(string.Format("Unable to load service type {0}", codeSvc.ServiceType));
				}
			}
            #endregion
		}

		private void AddBindings(ServiceHost host, string serviceName, Type interfaceType, List<CMASEndPoint> endpoints)
		{
			if (endpoints != null && endpoints.Count > 0)
			{
				#region Add Interface Specific Bindings
				foreach (CMASEndPoint wcfBinding in endpoints)
				{
					AddBinding(host, serviceName, interfaceType, wcfBinding.BindingType, wcfBinding.BindingName, wcfBinding.Port);
				}
				#endregion
			}
			else
			{
				#region Add Default Bindings
				foreach (CMASWCFBindingElement wcfBinding in m_HostConfig.DefaultEndpoints)
				{
					AddBinding(host, serviceName, interfaceType, wcfBinding.Type, wcfBinding.BindingName, wcfBinding.Port);
				}
				#endregion
			}

		}

		private void AddBinding(ServiceHost host, string serviceName, Type interfaceType, string wcfBindingType, string wcfBindingName, int wcfPort)
		{
            BindingsSection bindings = m_Configuration.GetSection("system.serviceModel/bindings") as BindingsSection;

			if (String.Compare(wcfBindingType, "WSHttpBinding", true) != 0 &&
					String.Compare(wcfBindingType, "NetTcpBinding", true) != 0 &&
					String.Compare(wcfBindingType, "NetMsmqBinding", true) != 0 &&
					String.Compare(wcfBindingType, "WebHttpBinding", true) != 0 &&
					String.Compare(wcfBindingType, "BasicHttpBinding", true) != 0 &&
                    String.Compare(wcfBindingType, "NetTcpRelayBinding", true) != 0)
			{
				throw new SecurityException(string.Format("Unsupported binding type specified ({0}).  Only BasicHttpBinding, WSHttpBinding, NetTcpBinding, NetMsmqBinding and NetTcpRelayBinding are supported.", wcfBindingType));
			}

			Binding binding = null;
			Uri endpointAddress = null;
			BindingCollectionElement bc = bindings[wcfBindingType];

			foreach (IBindingConfigurationElement bce in bc.ConfiguredBindings)
			{
				if (string.Compare(bce.Name, wcfBindingName, true) == 0)
				{
					binding = Activator.CreateInstance(bc.BindingType) as Binding;

					bce.ApplyConfiguration(binding);

					SetBindingSecurity(wcfBindingType, ref binding);
					endpointAddress = ConstructUri(serviceName, wcfBindingType, wcfPort, binding);
					break;
				}
			}

			if (binding != null)
			{
				m_Logger.LogDebug("Adding Generated Service endpoint for {0}:{1} at {2}", wcfBindingType, wcfBindingName, endpointAddress.AbsoluteUri);

				ServiceEndpoint endpoint = host.AddServiceEndpoint(interfaceType, binding, endpointAddress);

                if (binding is NetTcpRelayBinding)
                {
                    CMASHost.GetAzureServiceServerAccessData();

                    var transportClientEndpointBehavior = new TransportClientEndpointBehavior();
                    
                    transportClientEndpointBehavior.TokenProvider = 
                        TokenProvider.CreateSharedSecretTokenProvider(
                            CMASHost.AzureServiceBusServerAccessData.UserName, 
                            CMASHost.AzureServiceBusServerAccessData.Password);
                    
                    endpoint.Behaviors.Add(transportClientEndpointBehavior);
                }
			}
		}

        // SECENG: Fixing problem with multiple active certificates with the same subject.
        private static void SetHostCertificate(ServiceHost host)
        {
            host.Credentials.ServiceCertificate.Certificate = CertificateHelper.FindCertificate(
                m_HostConfig.ServiceCertificate.StoreName,
                m_HostConfig.ServiceCertificate.StoreLocation,
                m_HostConfig.ServiceCertificate.X509FindType,
                m_HostConfig.ServiceCertificate.FindValue);
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

		private Uri ConstructUri(string serviceName, string bindingType, int port, Binding binding)
		{
			string protocol = "";
			string portStr = "";

			switch (bindingType.ToUpper())
			{
				case "BASICHTTPBINDING":
					BasicHttpBinding basicBinding = binding as BasicHttpBinding;

					if (basicBinding != null)
					{
						if (basicBinding.Security.Mode == BasicHttpSecurityMode.Transport ||
								basicBinding.Security.Mode == BasicHttpSecurityMode.TransportCredentialOnly ||
								basicBinding.Security.Mode == BasicHttpSecurityMode.TransportWithMessageCredential)
						{
							protocol = "https";
						}
						else
						{
							protocol = "http";
						}
					}

					portStr = string.Format(":{0}", port);

					break;
				case "WSHTTPBINDING":
					WSHttpBinding wsBinding = binding as WSHttpBinding;

					if (wsBinding != null)
					{
						if (wsBinding.Security.Mode == SecurityMode.Transport || wsBinding.Security.Mode == SecurityMode.TransportWithMessageCredential)
						{
							protocol = "https";
						}
						else
						{
							protocol = "http";
						}
					}

					portStr = string.Format(":{0}", port);

					break;
				case "NETTCPBINDING":
					protocol = "net.tcp";

					portStr = string.Format(":{0}", port);
					break;
				case "NETMSMQBINDING":
					protocol = "net.msmq";

					NetMsmqBinding msmqBinding = binding as NetMsmqBinding;

					if (msmqBinding != null)
					{
						string queueName = "";

						if (!msmqBinding.UseActiveDirectory)
						{
							portStr = "/private";

							queueName = string.Format(@"{0}\private$\{1}", System.Net.Dns.GetHostName(), serviceName);
						}
						else
						{
							queueName = string.Format(@"{0}\{1}", System.Net.Dns.GetHostName(), serviceName);
						}

						if (!MessageQueue.Exists(queueName))
						{
							var mq = MessageQueue.Create(queueName, true);
							mq.DefaultPropertiesToSend.Recoverable = true;
							mq.UseJournalQueue = false;
							mq.MaximumQueueSize = MessageQueue.InfiniteQueueSize;
							mq.SetPermissions("SYSTEM", MessageQueueAccessRights.FullControl);
							mq.SetPermissions("Administrators", MessageQueueAccessRights.FullControl);
						}
					}

					break;
                case "NETTCPRELAYBINDING":
                    {
                        protocol = "sb";
                    }
                    break;
				default:
					throw new SecurityException(string.Format("Unsupported binding type specified ({0}).  Only BasicHttpBinding, WSHttpBinding, NetTcpBinding and NetMsmqBinding are supported.", bindingType));
			};

            if (bindingType.Equals("NetTcpRelayBinding", StringComparison.InvariantCultureIgnoreCase))
            {
                CMASHost.GetAzureServiceServerAccessData();
                var uri = ServiceBusEnvironment.CreateServiceUri(protocol, CMASHost.AzureServiceBusServerAccessData.ServerName, "I" + serviceName);
                m_Logger.LogDebug("Azure ServiceBus Uri = " + uri.AbsoluteUri);
                return uri;
            }

			return new Uri(string.Format("{0}://{1}{2}/{3}", protocol, System.Net.Dns.GetHostName(), portStr, serviceName));
		}

        private static void GetAzureServiceServerAccessData()
        {
            // Get AzureServiceBus Credential Information
            if (CMASHost.AzureServiceBusServerAccessData == null)
            {
                IMTServerAccessDataSet sads = new MTServerAccessDataSet();
                sads.Initialize();
                CMASHost.AzureServiceBusServerAccessData = sads.FindAndReturnObject("AzureServiceBus");
            }
        }

		private void GenerateCode(out Assembly generatedClasses, ref Dictionary<string, List<CMASEndPoint>> classNames, ref Dictionary<string, List<string>> supportedChildTypes, ref Dictionary<string, CMASCodeService> codeServices, bool bInMemoryOnly)
		{
			RCD.IMTRcd rcd = new RCD.MTRcd();
			RCD.IMTRcdFileList fileList = null;

			fileList = rcd.RunQuery(@"config\ActivityServices\*.xml", false);

			CMASInterfaceGenerator generator = new CMASInterfaceGenerator(GENERATED_CODE_NAMESPACE);
			CMASConfiguration interfaceConfig;

			foreach (string fileName in fileList)
			{
				interfaceConfig = new CMASConfiguration(fileName);

				foreach (CMASEventService interfaceDef in interfaceConfig.EventServiceDefs.Values)
				{
					generator.AddMASEventInterface(interfaceDef.InterfaceName, interfaceDef);

					classNames.Add(interfaceDef.InterfaceName, interfaceDef.WCFEndPoints);
					supportedChildTypes.Add(interfaceDef.InterfaceName, interfaceDef.SupportedChildTypes);

					m_bStartEventProcessing = true;
				}

				foreach (CMASProceduralService interfaceDef in interfaceConfig.ProceduralServiceDefs.Values)
				{
					generator.AddMASProceduralInterface(interfaceDef.InterfaceName, interfaceDef);

					classNames.Add(interfaceDef.InterfaceName, interfaceDef.WCFEndPoints);
					supportedChildTypes.Add(interfaceDef.InterfaceName, interfaceDef.SupportedChildTypes);

					m_bStartProceduralProcessing = true;
				}

				foreach (KeyValuePair<string, CMASCodeService> kvp in interfaceConfig.CodeServiceDefs)
				{
					codeServices.Add(kvp.Key, kvp.Value);
				}

				CMASProcessorBase.AddExchangeServices(interfaceConfig.AdditionalExchangeServices);
			}

			generatedClasses = generator.BuildAssembly(GENERATED_CODE_NAMESPACE, bInMemoryOnly);

			generator.Dispose();
		}

		private void SetBindingSecurity(string bindingType, ref Binding binding)
		{
			switch (bindingType)
			{
				case "basicHttpBinding":
					BasicHttpBinding basicBinding = binding as BasicHttpBinding;

					if (basicBinding.Security.Mode == BasicHttpSecurityMode.None ||
							basicBinding.Security.Mode == BasicHttpSecurityMode.TransportCredentialOnly)
					{
						throw new SecurityException("Security mode for BasicHttpBinding is set to None or TransportCredentialOnly.  Must be Message, Transport or TransportWithMessageCredential");
					}
					else if (basicBinding.Security.Mode == BasicHttpSecurityMode.Transport &&
								basicBinding.Security.Transport.ClientCredentialType != HttpClientCredentialType.Basic &&
							basicBinding.Security.Transport.ClientCredentialType != HttpClientCredentialType.Certificate)
					{
						throw new SecurityException("Security mode for BasicHttpBinding is set to use Transport credentials and credential type is not Basic or Certificate");
					}
					else if (basicBinding.Security.Mode == BasicHttpSecurityMode.Message &&
										basicBinding.Security.Message.ClientCredentialType != BasicHttpMessageCredentialType.Certificate)
					{
						throw new SecurityException("Security mode for BasicHttpBinding is set to use Message credentials and credential type is not Certificate");
					}
					else if (basicBinding.Security.Mode == BasicHttpSecurityMode.TransportWithMessageCredential &&
							basicBinding.Security.Message.ClientCredentialType != BasicHttpMessageCredentialType.Certificate &&
							basicBinding.Security.Message.ClientCredentialType != BasicHttpMessageCredentialType.UserName)
					{
						throw new SecurityException("Security mode for BasicHttpBinding is set to use Transport with Message credentials and credential type is not UserName or Certificate");
					}
					break;
				case "wsHttpBinding":
					WSHttpBinding wsBinding = binding as WSHttpBinding;

					if (wsBinding.Security.Mode == SecurityMode.None)
					{
						throw new SecurityException("Security mode for WSHttpBinding is set to None.  Must be Message, Transport or TransportWithMessageCredential");
					}
					else if (wsBinding.Security.Mode == SecurityMode.Transport &&
										wsBinding.Security.Transport.ClientCredentialType != HttpClientCredentialType.Basic &&
										wsBinding.Security.Transport.ClientCredentialType != HttpClientCredentialType.Certificate)
					{
						throw new SecurityException("Security mode for WSHttpBinding is set to use Transport credentials and credential type is not Basic or Certificate");
					}
					else if ((wsBinding.Security.Mode == SecurityMode.Message || wsBinding.Security.Mode == SecurityMode.TransportWithMessageCredential) &&
											wsBinding.Security.Message.ClientCredentialType != MessageCredentialType.UserName &&
											wsBinding.Security.Message.ClientCredentialType != MessageCredentialType.Certificate)
					{
						throw new SecurityException("Security mode for WSHttpBinding is set to use Message credentials and credential type is not UserName or Certificate");
					}

					break;
				case "netTcpBinding":
					NetTcpBinding tcpBinding = binding as NetTcpBinding;

					tcpBinding.Security.Mode = SecurityMode.TransportWithMessageCredential;
					tcpBinding.Security.Transport.ProtectionLevel = System.Net.Security.ProtectionLevel.EncryptAndSign;

					if (tcpBinding.Security.Message.ClientCredentialType != MessageCredentialType.UserName &&
							tcpBinding.Security.Message.ClientCredentialType != MessageCredentialType.Certificate)
					{
						throw new SecurityException("Client credential type for netTCPBinding is not UserName or Certificate");
					}

					break;
				case "netMsmqBinding":
					NetMsmqBinding msmqBinding = binding as NetMsmqBinding;

					msmqBinding.Security.Mode = NetMsmqSecurityMode.Message;
					msmqBinding.Security.Transport.MsmqProtectionLevel = System.Net.Security.ProtectionLevel.EncryptAndSign;

					break;

                case "netTcpRelayBinding":
                    {
                        var netTcpRelayBinding = binding as NetTcpRelayBinding;

                        if (netTcpRelayBinding.Security.Mode != EndToEndSecurityMode.TransportWithMessageCredential)
                        {
                            throw new SecurityException("Security mode for NetTcpRelayBinding is not set to TransportWithMessageCredential.  Must be TransportWithMessageCredential");
                        }

                        if (netTcpRelayBinding.Security.Message.ClientCredentialType != MessageCredentialType.Certificate)
                        {
                            throw new SecurityException("Message ClientCredentialType for NetTcpRelayBinding is not set to Certificate.  Must be Certificate");
                        }

                        if (netTcpRelayBinding.Security.RelayClientAuthenticationType != RelayClientAuthenticationType.RelayAccessToken)
                        {
                            throw new SecurityException("Message RelayClientAuthenticationType for NetTcpRelayBinding is not set to RelayAccessToken.  Must be RelayAccessToken");
                        }

                        netTcpRelayBinding.Security.Transport.ProtectionLevel = System.Net.Security.ProtectionLevel.EncryptAndSign;
                    }
                    break;
			};
		}

		private Assembly CurrentDomain_AssemblyResolve(object sender, ResolveEventArgs args)
		{
			return CMASHost.LoadAssembly(args.Name);
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

			m_Security = new MTSecurityClass();

			m_LoginContext = new MTLoginContextClass();

			using (MTComSmartPtr<IMTRcd> rcd = new MTComSmartPtr<IMTRcd>())
			{
				rcd.Item = new MTRcdClass();
				rcd.Item.Init();

				//SECENG: Change SecurityFramework version
        string path = Path.Combine(rcd.Item.ConfigDir, @"Security\Validation\MtSfConfigurationLoader.xml");
				//string path = Path.Combine(rcd.Item.ConfigDir, @"Security\Validation\MtSecurityFramework.properties");
				m_Logger.LogDebug("CMASHost Security framework path: {0}", path);
				SecurityKernel.Initialize(path);
				SecurityKernel.Start();
			}
		}

		private void TearDownSingletons()
		{
			SecurityKernel.Stop();
			SecurityKernel.Shutdown();

			m_NameID = null;

			m_SQLRowset = null;

			m_EnumConfig = null;

			m_Security = null;

			m_LoginContext = null;
		}
		#endregion
	}
}
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.Interop.MTAuth;
using System.Security.Cryptography.X509Certificates;
using System.ServiceModel.Description;

namespace MetraTech.Core.Client
{
    using EndpointCache = Dictionary<string, ServiceEndpointCollection>;
    using EndpointEntry = KeyValuePair<string, ServiceEndpointCollection>;
    using System.ServiceModel;
    using System.ServiceModel.Channels;
    using MetraTech.Interop.MTServerAccess;
    using MetraTech.Debug.Diagnostics;

    public enum HostLocation
    {
        Local,
        Remote
    }

    public class CoreClientConnector
    {
        #region Private Static Members
        private static Logger m_Logger = new Logger("[CoreClientConnector]");

        private static EndpointCache m_LocalEndpoints = new EndpointCache();
        private static EndpointCache m_RemoteEndpoints = new EndpointCache();
        #endregion

        #region Public Static Methods
        public static C CreateMASClient<C, I, B>(
            HostLocation location,
            string serviceName,
            string userName,
            string password)
            where C : System.ServiceModel.ClientBase<I>, I
            where I : class
            where B : Binding
        {
            C retval = null;

            using (HighResolutionTimer timer = new HighResolutionTimer("InternalCreateClient call", 15000))
            {
                retval = InternalCreateClient<C, I, B>(location, serviceName, MessageCredentialType.UserName);
            }

            retval.ClientCredentials.UserName.UserName = userName;
            retval.ClientCredentials.UserName.Password = password;

            try
            {
                using (HighResolutionTimer timer = new HighResolutionTimer("Open", 10000))
                {
                    retval.Open();
                }
            }
            catch (CommunicationException e)
            {
                m_Logger.LogException("Exception opening connection", e);

                retval.Abort();

                RemoveEndpoints(location, serviceName);

                retval = InternalCreateClient<C, I, B>(location, serviceName, MessageCredentialType.UserName);

                retval.ClientCredentials.UserName.UserName = userName;
                retval.ClientCredentials.UserName.Password = password;
             
                retval.Open();
            }

            return retval;
        }

        public static C CreateMASClient<C, I, B>(
            HostLocation location, 
            string serviceName, 
            string userName, 
            IMTSessionContext sessionContext) 
                where C : System.ServiceModel.ClientBase<I>, I
                where I : class
                where B : Binding
        {
            C retval = null;

            retval = InternalCreateClient<C, I, B>(location, serviceName, MessageCredentialType.UserName);

            retval.ClientCredentials.UserName.UserName = userName;
            retval.ClientCredentials.UserName.Password = string.Format("{0}{1}", ((char)8).ToString(), sessionContext.ToXML());

            try
            {
                retval.Open();
            }
            catch (Exception)
            {
                retval.Abort();

                RemoveEndpoints(location, serviceName);

                retval = InternalCreateClient<C, I, B>(location, serviceName, MessageCredentialType.UserName);

                retval.ClientCredentials.UserName.UserName = userName;
                retval.ClientCredentials.UserName.Password = string.Format("{0}{1}", ((char)8).ToString(), sessionContext.ToXML());

                retval.Open();
            }
            
            return retval;
        }

        public static C CreateMASClient<C, I, B>(
            HostLocation location, 
            string serviceName, 
            X509Certificate2 certificate) 
                where C : System.ServiceModel.ClientBase<I>, I
                where I : class
                where B : Binding
        {
            C retval = null;

            retval = InternalCreateClient<C, I, B>(location, serviceName, MessageCredentialType.Certificate);

            retval.ClientCredentials.ClientCertificate.Certificate = certificate;

            try
            {
                retval.Open();
            }
            catch (Exception)
            {
                retval.Abort();

                RemoveEndpoints(location, serviceName);

                retval = InternalCreateClient<C, I, B>(location, serviceName, MessageCredentialType.Certificate);

                retval.ClientCredentials.ClientCertificate.Certificate = certificate;

                retval.Open();
            }

            return retval;
        }
        #endregion

        #region Private Static Methods
        private static C InternalCreateClient<C, I, B>(
            HostLocation location, 
            string serviceName, 
            MessageCredentialType authenticationType)
                where C : System.ServiceModel.ClientBase<I>, I
                where I : class
                where B : Binding
        {
            C retval = null;

            ServiceEndpointCollection endpoints = null;
            using (HighResolutionTimer timer = new HighResolutionTimer("RetreiveEndpoints", 10000))
            {
                endpoints = RetrieveEndpoints<I>(location, serviceName);
            }

            ServiceEndpoint endpoint = null;
            using (HighResolutionTimer timer = new HighResolutionTimer("DetermineEndpoints", 10000))
            {
                endpoint = DetermineEndpoint<B>(endpoints, authenticationType);
            }

            if (endpoint != null)
            {
                using (HighResolutionTimer timer = new HighResolutionTimer("Create instance", 10000))
                {
                    retval = Activator.CreateInstance(typeof(C), endpoint.Binding, endpoint.Address) as C;
                }
            }
            else
            {
                throw new ArgumentNullException("endpoint");
            }

            return retval;
        }

        private static ServiceEndpoint DetermineEndpoint<B>(
            ServiceEndpointCollection endpoints, 
            MessageCredentialType authenticationType)
                where B : Binding
        {
            ServiceEndpoint endpoint = null;

            foreach (ServiceEndpoint point in endpoints)
            {
                if (point.Binding is B)
                {
                    if (point.Binding is NetTcpBinding)
                    {
                        NetTcpBinding b = point.Binding as NetTcpBinding;
                        if (b.Security.Message.ClientCredentialType == authenticationType)
                        {
                            endpoint = point;
                            break;
                        }
                    }
                    else if (point.Binding is WSHttpBinding)
                    {
                        WSHttpBinding b = point.Binding as WSHttpBinding;
                        if (b.Security.Message.ClientCredentialType == authenticationType)
                        {
                            endpoint = point;
                            break;
                        }
                    }
                    else if (point.Binding is NetMsmqBinding)
                    {
                        NetMsmqBinding b = point.Binding as NetMsmqBinding;
                        if (b.Security.Message.ClientCredentialType == authenticationType)
                        {
                            endpoint = point;
                            break;
                        }
                    }
                    else
                    {
                        throw new ArgumentException("Unsupported binding type specified");
                    }
                }
            }

            return endpoint;
        }

        private static ServiceEndpointCollection RetrieveEndpoints<I>(HostLocation location, string serviceName)
            where I : class
        {
            EndpointCache cache = EndpointCollection(location);
            ServiceEndpointCollection endpoints = null;

            lock (cache)
            {
                if (cache.ContainsKey(serviceName))
                {
                    endpoints = cache[serviceName];
                }
            }

            if (endpoints == null)
            {
                endpoints = DownloadEndpoints<I>(location, serviceName);

                if (endpoints != null)
                {
                    lock (cache)
                    {
                        if (!cache.ContainsKey(serviceName))
                        {
                            cache.Add(serviceName, endpoints);
                        }
                    }
                }
                else
                {
                    throw new InvalidOperationException(
                        string.Format(
                            "Unable to locate endpoints for {0} using the {1} host location",
                            serviceName,
                            location.ToString()));

                }
            }

            return endpoints;
        }

        private static void RemoveEndpoints(HostLocation location, string serviceName)
        {
            EndpointCache cache = EndpointCollection(location);

            lock (cache)
            {
                if (cache.ContainsKey(serviceName))
                {
                    cache.Remove(serviceName);
                }
            }
        }

        private static ServiceEndpointCollection DownloadEndpoints<I>(HostLocation location, string serviceName)
            where I : class
        {
            ServiceEndpointCollection endpoints = null;
            List<ContractDescription> contracts = new List<ContractDescription>();
            MetadataExchangeClient mexClient = null;

            using (HighResolutionTimer timer = new HighResolutionTimer("Set up download", 10000))
            {

                WSHttpBinding binding = null;
                using (HighResolutionTimer timer2 = new HighResolutionTimer("Creating binding", 10000))
                {
                    binding = new WSHttpBinding(SecurityMode.None);
                    binding.MaxReceivedMessageSize = 50000000;
                }

                using (HighResolutionTimer t3 = new HighResolutionTimer("Create MEX client", 10000))
                {
                    mexClient = new MetadataExchangeClient(binding);
                    mexClient.MaximumResolvedReferences = 100;
                }

                using (HighResolutionTimer t4 = new HighResolutionTimer("Add contract", 10000))
                {
                    contracts.Add(ContractDescription.GetContract(typeof(I)));
                }
            }

            using (HighResolutionTimer timer = new HighResolutionTimer("Resolve", 10000))
            {
                endpoints = MetadataResolver.Resolve(
                    contracts,
                    GetMEXEndpoint(location, serviceName),
                    MetadataExchangeClientMode.HttpGet,
                    mexClient);
            }

            return endpoints;
        }

        private static Uri GetMEXEndpoint(HostLocation location, string serviceName)
        {
            Uri retval = null;
            string serverType;
            
            if(location == HostLocation.Local)
            {
                serverType = "LocalMEXEndpoint";
            }
            else
            {
                serverType = "RemoteMEXEndpoint";
            }

            IMTServerAccessDataSet dataSet = new MTServerAccessDataSetClass();
            dataSet.Initialize();
            IMTServerAccessData data = dataSet.FindAndReturnObject(serverType);

            retval = new Uri(string.Format("http://{0}:{1}/{2}?wsdl", data.ServerName, data.PortNumber, serviceName));

            return retval;
        }

        private static EndpointCache EndpointCollection(HostLocation location)
        {
            if (location == HostLocation.Local)
            {
                return m_LocalEndpoints;
            }
            else
            {
                return m_RemoteEndpoints;
            }
        }
        #endregion

    }
}

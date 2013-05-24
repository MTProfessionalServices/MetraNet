using System;
using System.Collections.Generic;
using System.Text;
using System.ServiceModel.Configuration;
using System.Configuration;
using System.IO;
using System.ServiceModel;
using System.ServiceModel.Description;
using System.Security.Cryptography.X509Certificates;
using System.ServiceModel.Channels;
using System.Reflection;

namespace MetraTech.ActivityServices.Common
{
    public class MASClientClassFactory
    {
        public static T CreateClient<T>(string wcfConfigFile, string endPointName) 
        {
            T client = default(T);

            Configuration configFile;
            ExeConfigurationFileMap map = new ExeConfigurationFileMap();
            map.ExeConfigFilename = wcfConfigFile;

            configFile = ConfigurationManager.OpenMappedExeConfiguration(map, ConfigurationUserLevel.None);

            ClientSection clients = configFile.GetSection("system.serviceModel/client") as ClientSection;

            EndpointAddress addr;
            ChannelEndpointElement selectedEndpoint = null;

            foreach (ChannelEndpointElement endpoint in clients.Endpoints)
            {
                if (endpoint.Name == endPointName)
                {
                    selectedEndpoint = endpoint;

                    break;
                }
            }

            if (selectedEndpoint != null)
            {
                EndpointIdentity endpointIdentity = GetIdentity(selectedEndpoint.Identity);
                addr = new EndpointAddress(selectedEndpoint.Address, endpointIdentity);

                ServiceModelSectionGroup svcModelGrp = ServiceModelSectionGroup.GetSectionGroup(configFile);

                Binding binding = CreateBinding(selectedEndpoint, svcModelGrp);

                Type clientType = typeof(T);
                ConstructorInfo i = clientType.GetConstructor(new Type[] { typeof(Binding), typeof(EndpointAddress) });

                if (i != null)
                {
                    client = (T)i.Invoke(new object[] { binding, addr });

                    PropertyInfo p = clientType.GetProperty("ChannelFactory");
                    object channelFactory = p.GetValue(client, null);

                    PropertyInfo e = channelFactory.GetType().GetProperty("Endpoint");

                    ServiceEndpoint ep = e.GetValue(channelFactory, null) as ServiceEndpoint;

                    if (!string.IsNullOrEmpty(selectedEndpoint.BehaviorConfiguration))
                    {
                        AddBehaviors(selectedEndpoint.BehaviorConfiguration, ref ep, svcModelGrp);
                    }
                }
            }
            else
            {
                throw new ApplicationException(string.Format("Unable to load specified endpoint {0}", endPointName));
            }

            return client;
        }

        public static object CreateClient(string clientProxyType, string endPointName)
        {
          return CreateClient(clientProxyType, endPointName, string.Empty);
        }

        public static object CreateClient(string clientProxyType, string endPointName, string wcfConfigFile)
        {
            Type clientType = Type.GetType(clientProxyType, true, true);

            object client = null;

            Configuration configFile;

            if (string.IsNullOrWhiteSpace(wcfConfigFile))
            {
              configFile = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            }
            else
            {
              ExeConfigurationFileMap map = new ExeConfigurationFileMap();
              map.ExeConfigFilename = wcfConfigFile;
              configFile = ConfigurationManager.OpenMappedExeConfiguration(map, ConfigurationUserLevel.None);
            }
            
            ClientSection clients = configFile.GetSection("system.serviceModel/client") as ClientSection;

            EndpointAddress addr;
            ChannelEndpointElement selectedEndpoint = null;

            foreach (ChannelEndpointElement endpoint in clients.Endpoints)
            {
                if (endpoint.Name == endPointName)
                {
                    selectedEndpoint = endpoint;

                    break;
                }
            }

            if (selectedEndpoint != null)
            {
                EndpointIdentity endpointIdentity = GetIdentity(selectedEndpoint.Identity);
                addr = new EndpointAddress(selectedEndpoint.Address, endpointIdentity);

                ServiceModelSectionGroup svcModelGrp = ServiceModelSectionGroup.GetSectionGroup(configFile);

                Binding binding = CreateBinding(selectedEndpoint, svcModelGrp);

                ConstructorInfo i = clientType.GetConstructor(new Type[] { typeof(Binding), typeof(EndpointAddress) });

                if (i != null)
                {
                    client = i.Invoke(new object[] { binding, addr });

                    PropertyInfo p = clientType.GetProperty("ChannelFactory");
                    object channelFactory = p.GetValue(client, null);

                    PropertyInfo e = channelFactory.GetType().GetProperty("Endpoint");

                    ServiceEndpoint ep = e.GetValue(channelFactory, null) as ServiceEndpoint;

                    if (!string.IsNullOrEmpty(selectedEndpoint.BehaviorConfiguration))
                    {
                        AddBehaviors(selectedEndpoint.BehaviorConfiguration, ref ep, svcModelGrp);
                    }
                }
            }
            else
            {
                throw new ApplicationException(string.Format("Unable to load specified endpoint {0}", endPointName));
            }

            return client;
        }
        /// <summary>
        /// Configures the binding for the selected endpoint
        /// </summary>
        /// <param name="endpoint"></param>
        /// <param name="group"></param>
        /// <returns></returns>
        private static Binding CreateBinding(ChannelEndpointElement endpoint, ServiceModelSectionGroup group)
        {
            BindingCollectionElement bindingElementCollection = group.Bindings[endpoint.Binding];
            if (bindingElementCollection.ConfiguredBindings.Count > 0)
            {
                foreach (IBindingConfigurationElement be in bindingElementCollection.ConfiguredBindings)
                {
                    if (be.Name == endpoint.BindingConfiguration)
                    {
                        Binding binding = GetBinding(be);
                        if (be != null)
                        {
                            be.ApplyConfiguration(binding);
                        }

                        return binding;
                    }
                }
            }

            return null;
        }

        /// <summary>
        /// Adds the configured behavior to the selected endpoint
        /// </summary>
        /// <param name="behaviorConfiguration"></param>
        /// <param name="serviceEndpoint"></param>
        /// <param name="group"></param>
        private static void AddBehaviors(string behaviorConfiguration, ref ServiceEndpoint serviceEndpoint, ServiceModelSectionGroup group)
        {
            EndpointBehaviorElement behaviorElement = group.Behaviors.EndpointBehaviors[behaviorConfiguration];
            for (int i = 0; i < behaviorElement.Count; i++)
            {
                BehaviorExtensionElement behaviorExtension = behaviorElement[i];
                object extension = behaviorExtension.GetType().InvokeMember("CreateBehavior",
                BindingFlags.InvokeMethod | BindingFlags.NonPublic | BindingFlags.Instance,
                null, behaviorExtension, null);
                if (extension != null)
                {
                    if(serviceEndpoint.Behaviors.Contains(extension.GetType()))
                    {
                        serviceEndpoint.Behaviors.Remove(extension.GetType());
                    }

                    serviceEndpoint.Behaviors.Add((IEndpointBehavior)extension);
                }
            }
        }

        /// <summary>
        /// Gets the endpoint identity from the configuration file
        /// </summary>
        /// <param name="element"></param>
        /// <returns></returns>
        private static EndpointIdentity GetIdentity(IdentityElement element)
        {
            EndpointIdentity identity = null;
            PropertyInformationCollection properties = element.ElementInformation.Properties;
            if (properties["userPrincipalName"].ValueOrigin != PropertyValueOrigin.Default)
            {
                return EndpointIdentity.CreateUpnIdentity(element.UserPrincipalName.Value);
            }
            if (properties["servicePrincipalName"].ValueOrigin != PropertyValueOrigin.Default)
            {
                return EndpointIdentity.CreateSpnIdentity(element.ServicePrincipalName.Value);
            }
            if (properties["dns"].ValueOrigin != PropertyValueOrigin.Default)
            {
                return EndpointIdentity.CreateDnsIdentity(element.Dns.Value);
            }
            if (properties["rsa"].ValueOrigin != PropertyValueOrigin.Default)
            {
                return EndpointIdentity.CreateRsaIdentity(element.Rsa.Value);
            }
            if (properties["certificate"].ValueOrigin != PropertyValueOrigin.Default)
            {
                X509Certificate2Collection supportingCertificates = new X509Certificate2Collection();
                supportingCertificates.Import(Convert.FromBase64String(element.Certificate.EncodedValue));
                if (supportingCertificates.Count == 0)
                {
                    throw new InvalidOperationException("UnableToLoadCertificateIdentity");
                }
                X509Certificate2 primaryCertificate = supportingCertificates[0];
                supportingCertificates.RemoveAt(0);
                return EndpointIdentity.CreateX509CertificateIdentity(primaryCertificate, supportingCertificates);
            }

            return identity;
        }

        /// <summary>
        /// Helper method to create the right binding depending on the configuration element
        /// </summary>
        /// <param name="configurationElement"></param>
        /// <returns></returns>
        private static Binding GetBinding(IBindingConfigurationElement configurationElement)
        {
            if (configurationElement is CustomBindingElement)
                return new CustomBinding();
            else if (configurationElement is BasicHttpBindingElement)
                return new BasicHttpBinding();
            else if (configurationElement is NetMsmqBindingElement)
                return new NetMsmqBinding();
            else if (configurationElement is NetNamedPipeBindingElement)
                return new NetNamedPipeBinding();
            else if (configurationElement is NetPeerTcpBindingElement)
                return new NetPeerTcpBinding();
            else if (configurationElement is NetTcpBindingElement)
                return new NetTcpBinding();
            else if (configurationElement is WSDualHttpBindingElement)
                return new WSDualHttpBinding();
            else if (configurationElement is WSHttpBindingElement)
                return new WSHttpBinding();
            else if (configurationElement is WSFederationHttpBindingElement)
                return new WSFederationHttpBinding();

            return null;
        }

    }
}

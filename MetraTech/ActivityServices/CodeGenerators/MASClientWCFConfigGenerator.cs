using System;
using System.Collections.Generic;
using System.Text;
using MetraTech.ActivityServices.Runtime;
using System.IO;
using System.Configuration;
using System.ServiceModel.Configuration;
using System.ServiceModel;
using System.ServiceModel.Description;
using System.Security.Cryptography.X509Certificates;
using System.Reflection;

namespace MetraTech.ActivityServices.ClientCodeGenerators
{
  public class CMASClientWCFConfigGenerator
  {
    #region Members
    private string m_ExtensionName;

    private CMASHost m_MASHost;

    private System.Configuration.Configuration m_NewConfigFile = null;

    Logger m_Logger;

    private static string m_NameSpaceBase = "MetraTech.";
    private static string m_BasePathFormatString;
    #endregion

    #region Constructors
    public CMASClientWCFConfigGenerator(string extensionName)
    {
      try
      {
        m_Logger = new Logger("Logging\\ActivityServices", "[MASClientWCFConfigGenerator]");

        m_ExtensionName = extensionName;

        m_MASHost = new CMASHost(true);
      }
      catch (Exception e)
      {
        m_Logger.LogException("Exception constructing proxy generator", e);

        throw e;
      }
    }
    #endregion

    #region Properties
    public static string NameSpaceBase
    {
      get { return m_NameSpaceBase; }
      set { m_NameSpaceBase = value; }
    }

    public static string BasePathFormatString
    {
      get { return m_BasePathFormatString; }
      set { m_BasePathFormatString = value; }
    }

    private string NameSpaceName
    {
      get { return string.Format("{0}{1}.ClientProxies", NameSpaceBase, m_ExtensionName); }
    }
    #endregion

    #region Public Methods
    public void AddServiceWCFConfig(string serviceName)
    {
      if (m_NewConfigFile == null)
      {
        string path = Path.Combine(string.Format(BasePathFormatString, m_ExtensionName), string.Format("{0}{1}.config", NameSpaceBase, m_ExtensionName));

        if (File.Exists(path))
        {
          File.Delete(path);
        }

        ExeConfigurationFileMap map = new ExeConfigurationFileMap();
        map.ExeConfigFilename = path;

        m_NewConfigFile = ConfigurationManager.OpenMappedExeConfiguration(map, ConfigurationUserLevel.None);
      }

      ServiceModelSectionGroup newGrp = ServiceModelSectionGroup.GetSectionGroup(m_NewConfigFile);
      BindingsSection newBindings = BindingsSection.GetSection(m_NewConfigFile);

      ServiceHost svcHost;
      string bindingName;

      if (m_MASHost.ServiceHosts.ContainsKey(serviceName))
      {
        svcHost = m_MASHost.ServiceHosts[serviceName];

        ServiceDescription desc = svcHost.Description;
        EndpointIdentity certIdentity = EndpointIdentity.CreateX509CertificateIdentity(svcHost.Credentials.ServiceCertificate.Certificate);
        EndpointIdentity dnsIdentity = EndpointIdentity.CreateDnsIdentity(svcHost.Credentials.ServiceCertificate.Certificate.GetNameInfo(X509NameType.DnsName, false));

        foreach (ServiceEndpoint endpoint in desc.Endpoints)
        {
            #region Add Binding Info
          object bindingElement = null;
          if (endpoint.Binding.GetType().ToString().Equals("Microsoft.ServiceBus.NetTcpRelayBinding", StringComparison.InvariantCultureIgnoreCase))
          {
            continue;
          }
          else
          {
              bindingElement = endpoint.GetType().Assembly.CreateInstance(string.Format("System.ServiceModel.Configuration.{0}Element", endpoint.Binding.Name));
          }
          MethodInfo method = bindingElement.GetType().GetMethod("InitializeFrom", BindingFlags.NonPublic | BindingFlags.Instance);

          method.Invoke(bindingElement, new object[] { endpoint.Binding });

          bindingName = string.Format("{0}_I{1}", endpoint.Binding.Name, serviceName);
          int i = 0;

          foreach (BindingCollectionElement collElem in newBindings.BindingCollections)
          {
            foreach (IBindingConfigurationElement elem in collElem.ConfiguredBindings)
            {
              if (elem.Name.Contains(bindingName))
              {
                i++;
              }
            }
          }

          if (i != 0)
          {
            bindingName = string.Format("{0}{1}", bindingName, i);
          }

          bindingElement.GetType().GetProperty("Name").SetValue(bindingElement, bindingName, null);

          object bindingProperty = newBindings.GetType().GetProperty(endpoint.Binding.Name).GetValue(newBindings, null);
          object bindingCol = bindingProperty.GetType().GetProperty("Bindings").GetValue(bindingProperty, null);

          MethodInfo addMethod = bindingCol.GetType().GetMethod("Add");

          addMethod.Invoke(bindingCol, new object[] { bindingElement });
          #endregion

          #region Add Endpoint Info
          ChannelEndpointElement cee = new ChannelEndpointElement(endpoint.Address, endpoint.Contract.Name);
          char[] binding = endpoint.Binding.Name.ToCharArray();
          binding[0] = binding[0].ToString().ToLower()[0];
          binding[1] = binding[1].ToString().ToLower()[0];
          cee.Binding = new string(binding);
          cee.BindingConfiguration = bindingName;
          cee.Name = bindingName;

          cee.Identity.InitializeFrom(dnsIdentity);

          newGrp.Client.Endpoints.Add(cee);
          #endregion
        }
      }
    }

    public void SaveConfig()
    {
      if (m_NewConfigFile != null)
      {
        m_NewConfigFile.Save(ConfigurationSaveMode.Modified, false);
      }
    }
    #endregion
  }
}
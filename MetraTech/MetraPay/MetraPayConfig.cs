using System;
using System.Collections.Generic;
using System.Text;
using System.Configuration;
using System.ServiceModel.Configuration;

namespace MetraTech.MetraPay
{
  class CMetraPayConfig : ConfigurationSection
  {
    public int HostPort
    {
      get { return MetraPayHostConfig.HostPort; }
    }

    [ConfigurationProperty("MetraPayHost")]
    public CMetraPayHostConfig MetraPayHostConfig
    {
      get { return (CMetraPayHostConfig)this["MetraPayHost"]; }
    }

    [ConfigurationProperty("ServiceCertificate")]
    public CertificateReferenceElement ServiceCertificate
    {
      get { return (CertificateReferenceElement)this["ServiceCertificate"]; }
    }

    [ConfigurationProperty("ServiceThrottling")]
    public ServiceThrottlingElement ServiceThrottling
    {
      get
      {
        ServiceThrottlingElement elem = this["ServiceThrottling"] as ServiceThrottlingElement;

        if (elem == null)
        {
          elem = new ServiceThrottlingElement();
          elem.MaxConcurrentCalls = 1000;
          elem.MaxConcurrentInstances = 1000;
          elem.MaxConcurrentSessions = 1000;
        }

        return elem;
      }
    }

    [ConfigurationProperty("ServiceInstances")]
    public CMetraPayServiceInstances ServiceInstances
    {
      get { return (CMetraPayServiceInstances)this["ServiceInstances"]; }
    }
  }


  public sealed class CMetraPayHostConfig : ConfigurationElement
  {
    public CMetraPayHostConfig()
    {
    }

    [ConfigurationProperty("Port", IsRequired = true, DefaultValue = 51515)]
    public int HostPort
    {
      get { return (int)this["Port"]; }
      set { this["Port"] = value; }
    }
  }

  public sealed class CMetraPayServiceInstances : ConfigurationElementCollection
  {
    protected override ConfigurationElement CreateNewElement()
    {
      return new CMetraPayServiceInstance();
    }

    protected override object GetElementKey(ConfigurationElement element)
    {
      return ((CMetraPayServiceInstance)element).Name;
    }

    public override ConfigurationElementCollectionType CollectionType
    {
      get
      {
        return ConfigurationElementCollectionType.BasicMap;
      }
    }

    protected override string ElementName
    {
      get
      {
        return "ServiceInstance";
      }
    }
  }

  public sealed class CMetraPayServiceInstance : ConfigurationElement
  {
    public CMetraPayServiceInstance()
    {
    }

    [ConfigurationProperty("Name")]
    public string Name
    {
      get { return (string)this["Name"]; }
      set { this["Name"] = value; }
    }

    [ConfigurationProperty("ProcessorType")]
    public string ProcessorType
    {
      get { return (string)this["ProcessorType"]; }
      set { this["ProcessorType"] = value; }
    }

    [ConfigurationProperty("ConfigFile")]
    public string ConfigFile
    {
      get { return (string)this["ConfigFile"]; }
      set { this["ConfigFile"] = value; }
    }

    [ConfigurationProperty("Timeout")]
    public double Timeout
    {
        get { return (double)this["Timeout"]; }
        set { this["Timeout"] = value; }
    }
}
}

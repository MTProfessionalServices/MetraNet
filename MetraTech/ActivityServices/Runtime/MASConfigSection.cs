using System;
using System.Collections.Generic;
using System.Text;
using System.Configuration;
using System.ServiceModel.Configuration;
using System.ServiceModel.Security;
using System.Security.Cryptography.X509Certificates;

namespace MetraTech.ActivityServices.Runtime
{
  public sealed class CMASHostConfig : ConfigurationSection
  {
    public CMASHostConfig()
    {
    }

    #region Values
    public string BaseAddress
    {
      get { return BaseWSDLAddressElement.BaseAddress; }
    }

    public bool PreserveCode
    {
      get { return PreserveCodeElement.PreserveCode; }
    }
    #endregion

    #region Configuration Properties
    [ConfigurationProperty("BaseWSDLAddress")]
    public CMASBaseWSDLAddressElement BaseWSDLAddressElement
    {
      get { return ((CMASBaseWSDLAddressElement)this["BaseWSDLAddress"]); }
    }

    [ConfigurationProperty("PreserveCode", IsRequired = false)]
    public CMASPreserveCodeElement PreserveCodeElement
    {
      get { return ((CMASPreserveCodeElement)this["PreserveCode"]); }
    }

    [ConfigurationProperty("DefaultEndpoints", IsDefaultCollection = true)]
    public CMASWCFBindingsCollection DefaultEndpoints
    {
      get { return (CMASWCFBindingsCollection)this["DefaultEndpoints"]; }
    }

    [ConfigurationProperty("ServiceCertificate")]
    public CertificateReferenceElement ServiceCertificate
    {
      get { return (CertificateReferenceElement)this["ServiceCertificate"]; }
    }

    [ConfigurationProperty("DefaultServiceThrottling")]
    public ServiceThrottlingElement DefaultServiceThrottling
    {
      get
      {
        ServiceThrottlingElement elem = this["DefaultServiceThrottling"] as ServiceThrottlingElement;

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

    [ConfigurationProperty("ClientCertificateValidation")]
    public X509ClientCertificateAuthenticationElement ClientCertificateValidation
    {
      get
      {
        X509ClientCertificateAuthenticationElement elem = this["ClientCertificateValidation"] as X509ClientCertificateAuthenticationElement;

        return elem;
      }
    }
    #endregion
  }

  public sealed class CMASWCFBindingsCollection : ConfigurationElementCollection
  {
    protected override ConfigurationElement CreateNewElement()
    {
      return new CMASWCFBindingElement();
    }

    protected override object GetElementKey(ConfigurationElement element)
    {
      return ((CMASWCFBindingElement)element).Type + "_" + ((CMASWCFBindingElement)element).BindingName;
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
        return "WCFEndpoint";
      }
    }
  }

  public sealed class CMASWCFBindingElement : ConfigurationElement
  {
    public CMASWCFBindingElement()
    {
    }

    [ConfigurationProperty("Type")]
    public string Type
    {
      get { return (string)this["Type"]; }
      set { this["Type"] = value; }
    }

    [ConfigurationProperty("BindingName")]
    public string BindingName
    {
      get { return (string)this["BindingName"]; }
      set { this["BindingName"] = value; }
    }

    [ConfigurationProperty("Port")]
    public int Port
    {
      get { return (int)this["Port"]; }
      set { this["Port"] = value; }
    }
  }

  public sealed class CMASBaseWSDLAddressElement : ConfigurationElement
  {
    public CMASBaseWSDLAddressElement()
    {
    }

    [ConfigurationProperty("Value", IsRequired = true, DefaultValue = "http://localhost:8000")]
    public string BaseAddress
    {
      get { return (string)this["Value"]; }
      set { this["Value"] = value; }
    }

  }

  public sealed class CMASPreserveCodeElement : ConfigurationElement
  {
    public CMASPreserveCodeElement()
    {
    }

    [ConfigurationProperty("Value", IsRequired = true, DefaultValue = false)]
    public bool PreserveCode
    {
      get { return (bool)this["Value"]; }
      set { this["Value"] = value; }
    }
  }
}

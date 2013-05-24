#pragma warning disable 1591  // Disable XML Doc warning for now.
using System;
using System.Collections.Generic;
using System.Text;

namespace MetraTech.ActivityServices.Services.Common
{
  [AttributeUsage(AttributeTargets.Method,AllowMultiple=true)]
  public class OperationCapabilityAttribute : Attribute
  {
    private string m_CapabilityName;

    public OperationCapabilityAttribute(string capabilityName)
    {
      m_CapabilityName = capabilityName;
    }

    public string CapabilityName
    {
      get { return m_CapabilityName; }
    }
  }
}

using System;
using System.Collections.Generic;
using System.Text;
using System.ServiceModel.Description;
using System.ServiceModel;

namespace MetraTech.MetraPay
{
  class MPServiceHost<T> : ServiceHost
  {
    private string m_ProcessorType;
    private string m_ConfigFile;
    private string m_ServiceName;
    private double m_Timeout;

    public MPServiceHost(string serviceName, string processorType, string configFile, double timeout)
      : base(typeof(T))
    {
      m_ServiceName = serviceName;
      m_ProcessorType = processorType;
      m_ConfigFile = configFile;
      m_Timeout = timeout;
    }

    public string ProcessorType
    {
      get { return m_ProcessorType; }
    }

    public string ConfigFile
    {
      get { return m_ConfigFile; }
    }

    public string ServiceName
    {
      get { return m_ServiceName; }
    }

      public double Timeout
      {
          get { return m_Timeout; }
      }
}
}

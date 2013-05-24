using System;
using System.Collections.Generic;
using System.Text;

namespace MetraTech.UI.Common
{
  /// <summary>
  ///   Contains data required for metering.
  /// </summary>
  [Serializable]
  public class MeterData
  {
    #region Input Properties
    // ServiceDefinitionName
    private string serviceDefinitionName;
    public string ServiceDefinitionName
    {
      get { return serviceDefinitionName; }
      set { serviceDefinitionName = value; }
    }

    // Synchronous
    private bool synchronous;
    public bool Synchronous
    {
      get { return synchronous; }
      set { synchronous = value; }
    }

    // PropertyDS
    private PropertyDS propertyDS;
    public PropertyDS PropertyDS
    {
      get { return propertyDS; }
      set { propertyDS = value; }
    }

    // MeteringServerName
    private string listenerMachineName;
    public string ListenerMachineName
    {
      get { return listenerMachineName; }
      set { listenerMachineName = value; }
    }
	

    // SessionContext
    [NonSerialized]
    private MetraTech.Interop.MTAuth.IMTSessionContext sessionContext;
    public MetraTech.Interop.MTAuth.IMTSessionContext SessionContext
    {
      get { return sessionContext; }
      set { sessionContext = value; }
    }

    // Transaction Id
    private string transactionId;
    public string TransactionId
    {
      get { return transactionId; }
      set { transactionId = value; }
    }
	
    #endregion

    // OutputPropertyNames
    private List<string> outputPropertyNames;
    public List<string> OutputPropertyNames
    {
      get { return outputPropertyNames; }
      set { outputPropertyNames = value; }
    }

    // HasOutputProperties
    public bool HasOutputProperties
    {
      get
      {
        bool hasOutputProperties = false;
        if (outputPropertyNames != null && outputPropertyNames.Count > 0)
        {
          hasOutputProperties = true;
        }
        return hasOutputProperties;
      }
    }
  }
}

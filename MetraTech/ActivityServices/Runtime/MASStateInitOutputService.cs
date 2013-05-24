using System;
using System.Collections.Generic;
using System.Text;

using MetraTech.ActivityServices.Activities;

namespace MetraTech.ActivityServices.Runtime
{
  using EventOutputDict = Dictionary<string, object>;

  class CStateInitOutputService : IMASStateInitOutput
  {
    #region Members
    private Dictionary<Guid, Dictionary<string,object>> m_StateInitOutputs = new Dictionary<Guid, Dictionary<string,object>>();
    #endregion

    #region Constructor
    public CStateInitOutputService()
    {
    }
    #endregion

    #region Public Methods
    public void ClearStateInitOutput(Guid workflowId)
    {
      lock (m_StateInitOutputs)
      {
        if (m_StateInitOutputs.ContainsKey(workflowId))
        {
          m_StateInitOutputs.Remove(workflowId);
        }
      }
    }

    public Dictionary<string,object> GetStateInitOutputs(Guid workflowId)
    {
      Dictionary<string,object> retval = null;

      lock (m_StateInitOutputs)
      {
        if (m_StateInitOutputs.ContainsKey(workflowId))
        {
          retval = m_StateInitOutputs[workflowId];
          m_StateInitOutputs.Remove(workflowId);
        }
      }

      return retval;
    }
    #endregion

    #region IMASStateInitOutput Members
    public void PostOutputs(Guid workflowId, Dictionary<string,object> outputData)
    {
      lock (m_StateInitOutputs)
      {
        if (m_StateInitOutputs.ContainsKey(workflowId))
        {
          m_StateInitOutputs[workflowId] = outputData;
        }
        else
        {
          m_StateInitOutputs.Add(workflowId, outputData);
        }
      }
    }

    #endregion
  }
}

using System;
using System.Collections.Generic;
using System.Text;

using MetraTech.ActivityServices.Activities;

namespace MetraTech.ActivityServices.Runtime
{
  using EventOutputDict = Dictionary<string, object>;

  class CEventOutputService : IMASEventOutput
  {
    #region Helper Struct
    internal struct EventResultsData
    {
      public EventOutputDict OutputArgs;
    }

    #endregion

    #region Members
    private Dictionary<Guid, EventResultsData> m_EventOutputs = new Dictionary<Guid, EventResultsData>();
    #endregion

    #region Constructor
    public CEventOutputService()
    {
    }
    #endregion

    #region Public Methods
    public void ClearEventResults(Guid workflowId)
    {
      lock (m_EventOutputs)
      {
        if (m_EventOutputs.ContainsKey(workflowId))
        {
          m_EventOutputs.Remove(workflowId);
        }
      }
    }

    public void GetEventResults(Guid workflowId, out EventOutputDict outputs)
    {
      outputs = null;

      lock (m_EventOutputs)
      {
        if (m_EventOutputs.ContainsKey(workflowId))
        {
          EventResultsData resultData = m_EventOutputs[workflowId];
          m_EventOutputs.Remove(workflowId);

          outputs = resultData.OutputArgs;
        }
      }
    }
    #endregion

    #region IMASEventOutput Members
    public void ReportResults(Guid workflowId, Dictionary<string, object> outputs)
    {
      EventResultsData resultData = new EventResultsData();
      
      resultData.OutputArgs = outputs;

      lock (m_EventOutputs)
      {
        if (m_EventOutputs.ContainsKey(workflowId))
        {
          m_EventOutputs[workflowId] = resultData;
        }
        else
        {
          m_EventOutputs.Add(workflowId, resultData);
        }
      }
    }
    #endregion
  }
}

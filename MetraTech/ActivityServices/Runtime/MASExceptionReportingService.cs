using System;
using System.Collections.Generic;
using System.Text;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.ActivityServices.Activities;

namespace MetraTech.ActivityServices.Runtime
{
  public class CMASExceptionReportingService : IMASExceptionReportingService
  {
    #region Members
    private Dictionary<Guid, Exception> m_Exceptions = new Dictionary<Guid, Exception>();
    #endregion

    #region Constructor
    public CMASExceptionReportingService()
    {
    }
    #endregion

    #region Public Methods
    public void ClearExceptions(Guid workflowId)
    {
      lock (m_Exceptions)
      {
        if (m_Exceptions.ContainsKey(workflowId))
        {
          m_Exceptions.Remove(workflowId);
        }
      }
    }

    public void GetException(Guid workflowId, out Exception error)
    {
      error = null;

      lock (m_Exceptions)
      {
        if (m_Exceptions.ContainsKey(workflowId))
        {
          error = m_Exceptions[workflowId];
          m_Exceptions.Remove(workflowId);
        }
      }
    }
    #endregion

    #region IMASExceptionReportingService Members

    public void ReportException(Guid workflowId, Exception error)
    {
      lock (m_Exceptions)
      {
        if (m_Exceptions.ContainsKey(workflowId))
        {
          m_Exceptions[workflowId] = error;
        }
        else
        {
          m_Exceptions.Add(workflowId, error);
        }
      }
    }

    #endregion
  }
}

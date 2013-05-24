using System;
using System.Collections.Generic;
using System.Text;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.ActivityServices.Activities;

namespace MetraTech.ActivityServices.Runtime
{
  internal class CMASWorkflowLoggingService : IMASLoggingService
  {
    #region Members
    private Logger m_Logger;
    #endregion

    #region Constructor
    public CMASWorkflowLoggingService()
    {
      m_Logger = new Logger("Logging\\ActivityServices", "[MASWorkflowLoggingService]");
    }
    #endregion

    #region IMASLoggingService Members

    public void LogFatal(string format, params object[] args)
    {
      m_Logger.LogFatal(format, args);
    }

    public void LogFatal(string str)
    {
      m_Logger.LogFatal(str);
    }

    public void LogError(string format, params object[] args)
    {
      m_Logger.LogError(format, args);
    }

    public void LogError(string str)
    {
      m_Logger.LogError(str);
    }

    public void LogWarning(string format, params object[] args)
    {
      m_Logger.LogWarning(format, args);
    }

    public void LogWarning(string str)
    {
      m_Logger.LogWarning(str);
    }

    public void LogInfo(string format, params object[] args)
    {
      m_Logger.LogInfo(format, args);
    }

    public void LogInfo(string str)
    {
      m_Logger.LogInfo(str);
    }

    public bool WillLogDebug
    {
      get { return m_Logger.WillLogDebug; }
    }

    public void LogDebug(string format, params object[] args)
    {
      m_Logger.LogDebug(format, args);
    }

    public void LogDebug(string str)
    {
      m_Logger.LogDebug(str);
    }

    public void LogException(string str, Exception e)
    {
      m_Logger.LogException(str, e);
    }

    #endregion
  }
}

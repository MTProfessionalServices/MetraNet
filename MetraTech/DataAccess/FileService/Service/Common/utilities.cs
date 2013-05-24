namespace MetraTech.FileService
{
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Assemblies
  ////////////////////////////////////////////////////////////////////////////////////// 
  using System;
  using System.Collections.Generic;
  using System.Diagnostics;
  using System.Threading;
  using MetraTech.Basic;


  ////////////////////////////////////////////////////////////////////////////////////// 
  // Interfaces
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Delegates
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Enumerations
  ////////////////////////////////////////////////////////////////////////////////////// 
  // Classes
  ////////////////////////////////////////////////////////////////////////////////////// 
  #region CODE and Debug Helpers

  public class TLog
  {
    private ILog m_log = null;

    public TLog(string logIdentifier)
    {
      m_log = LogManager.GetLogger(logIdentifier);
    }

    public void Debug(string message)
    {
      m_log.Debug("Thread " + Thread.CurrentThread.ManagedThreadId + ": " + message);
    }

    public void Error(string message)
    {
      m_log.Error("Thread " + Thread.CurrentThread.ManagedThreadId + ": " + message);
    }

    public void Error(string message, System.Exception e)
    {
      m_log.Error("Thread " + Thread.CurrentThread.ManagedThreadId + ": " + message, e);
    }

    public void Info(string message)
    {
      m_log.Info("Thread " + Thread.CurrentThread.ManagedThreadId + ": " + message);
    }

    public void Warn(string message)
    {
      m_log.Warn("Thread " + Thread.CurrentThread.ManagedThreadId + ": " + message);
    }
  }

  /// <summary>
  /// These are helper methods for debugging purposes to
  /// allow logging of line, function info
  /// </summary>
  class CODE
  {
    public string Name = "CODE";
    public static string __FILE__
    {
      get
      {
        System.Diagnostics.StackFrame sf = new
        System.Diagnostics.StackFrame(1);
        return sf.GetFileName().ToString();
      }
    }
    public static string __LINE__
    {
      get
      {
        System.Diagnostics.StackFrame sf = new
        System.Diagnostics.StackFrame(1);
        return sf.GetFileLineNumber().ToString();
      }
    }
    public static string __FUNCTION__
    {
      get
      {
        System.Diagnostics.StackFrame sf = new
        System.Diagnostics.StackFrame(1);
        return sf.GetMethod().Name;
      }
    }
    public static string __POSITION__
    {
      get
      {
        System.Diagnostics.StackFrame sf = new
        System.Diagnostics.StackFrame(1);
        return sf.GetFileColumnNumber().ToString();
      }
    }
    public static void __BREAKPOINT__()
    {
#if DEBUG
//      System.Diagnostics.Debugger.Break();
#endif
    }
  } 
  #endregion
}

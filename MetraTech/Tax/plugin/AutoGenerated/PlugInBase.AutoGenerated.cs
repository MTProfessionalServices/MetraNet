//////////////////////////////////////////////////////////////////////////////
// This file was automatically generated using ICE.
// Avoid making changes to this file.
///////////////////////////////////////////////////////////////////////////////

#region

using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using MetraTech.Interop.SysContext;
using MetraTech.Pipeline;
using MetraTech.Pipeline.PlugIns;
using IMTConfigPropSet = MetraTech.Interop.MTPipelineLib.IMTConfigPropSet;

#endregion

namespace MetraTech.Tax.Plugins.BillSoft
{
  public abstract class PlugInBase : PipelinePlugIn
  {
    #region Delegates

    public delegate string LogDelegate(LogLevel level, string message);

    #endregion

    #region Constants

    protected const int MARK_AS_FAILED_CODE_FAILED = -1;

    #endregion

    #region Variables

    private int? m_currentSessionID;
    private GeneralConfig m_generalConfig;
    private MTLog m_logger;
    private Properties m_prototype;

    #endregion

    #region LogLevel enum

    public enum LogLevel
    {
      Info,
      Warning,
      Error,
      Debug,
      Fatal,
      Off
    } ;

    #endregion

    /// <summary>
    /// Plug-in ProcessorInfo
    /// </summary>
    public override int ProcessorInfo
    {
      get
      {
        Log(LogLevel.Debug, "Start");
        return Constants.E_NOTIMPL;
      }
    }

    /// <summary>
    /// General configuration variables
    /// </summary>
    public GeneralConfig GeneralConfig
    {
      get { return m_generalConfig; }
    }

    #region Logging

    /// <summary>
    /// Writes an exception to the log
    /// </summary>
    internal string Log(string prefix, Exception ex)
    {
      string message;
      if (m_currentSessionID.HasValue)
        message = string.Format("{0} SessionID: {1}, Source: {2}, Message: {3}", prefix, m_currentSessionID.Value,
                                ex.Source, ex.Message);
      else
        message = string.Format("{0} Source: {1}, Message: {2}", prefix, ex.Source, ex.Message);

      m_logger.LogString(PlugInLogLevel.PLUGIN_LOG_ERROR, message);

      return message;
    }

    /// <summary>
    /// Writes a message to the log.
    /// </summary>
    /// <param name="level">The severity of this log entry</param>
    /// <param name="message"></param>
    public string Log(LogLevel level, string message)
    {
      //-- NOTE: Do NOT call this method from an overload as it will throw off 
      //-- the FrameCount and make it unable to get the name of the calling method/type.

      //determine the sys context plugin log level
      PlugInLogLevel? plLevel = null;
      switch (level)
      {
        case LogLevel.Info:
          plLevel = PlugInLogLevel.PLUGIN_LOG_INFO;
          break;
        case LogLevel.Warning:
          plLevel = PlugInLogLevel.PLUGIN_LOG_WARNING;
          break;
        case LogLevel.Error:
          plLevel = PlugInLogLevel.PLUGIN_LOG_ERROR;
          break;
        case LogLevel.Fatal:
          plLevel = PlugInLogLevel.PLUGIN_LOG_FATAL;
          break;
        case LogLevel.Off:
          plLevel = PlugInLogLevel.PLUGIN_LOG_OFF;
          break;
        case LogLevel.Debug:
          plLevel = PlugInLogLevel.PLUGIN_LOG_DEBUG;
          break;
      }

      if (!plLevel.HasValue)
        return string.Empty;

      //find out the name of the calling method
      string method = Utility.GetFQMethodName();

      string _message = null;
      _message = m_currentSessionID.HasValue ? string.Format("{0}: SessionID: {1}, {2}", method, m_currentSessionID.Value, message) : string.Format("{0}: {1}", method, message);

      m_logger.LogString(plLevel.Value, _message);

      return _message;
    }

    #endregion

    protected void SetCurrentSession(ISession session)
    {
      m_currentSessionID = session.InternalID;
    }

    public override void Configure(object systemContext, IMTConfigPropSet propSet)
    {
      try
      {
        //Init the logger
        m_logger = ((IMTSystemContext) systemContext).GetLog();

        Log(LogLevel.Debug, "Start");

        //create the properties prototype
        m_prototype = Properties.CreatePrototype(Log, (IMTSystemContext) systemContext, propSet);

        //create the general config
        m_generalConfig = new GeneralConfig((IMTSystemContext) systemContext, propSet);

        //call startup for any custom startup code
        StartUp((IMTSystemContext) systemContext, propSet);
      }
      catch (Exception ex)
      {
        Log("Configuration failed", ex);
        throw new COMException("Configuration failed " + ex.Message, ex);
      }
    }

    public override void ProcessSessions(ISessionSet sessions)
    {
      Log(LogLevel.Debug, "Start");

      //add the sessions to a list
      var sessionList = sessions.Cast<ISession>().ToList();

      //create the PropertiesCollection
      var propsCol =
        new PropertiesCollection(m_prototype,
                                 new System.Collections.ObjectModel.ReadOnlyCollection<ISession>(sessionList));

      //call the user's code to do the processing
      ProcessAllSessions(propsCol);
    }

    protected abstract void ProcessAllSessions(PropertiesCollection propsCol);

    protected virtual void StartUp(IMTSystemContext systemContext, IMTConfigPropSet propSet)
    {
    }

    protected abstract void ProcessSession(Properties props);

    public override void Shutdown()
    {
    }
  }
}
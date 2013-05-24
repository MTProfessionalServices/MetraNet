using System;
using System.Collections.Generic;
using System.IO;
using System.Diagnostics;

using log4net;
using log4net.Appender;
using log4net.Config;
using log4net.Layout;

using MetraTech.Basic.Exception;

namespace MetraTech.Basic.Config
{
  public static class Log4NetConfig
  {
    /// <summary>
    ///   Configure Log4Net. The configuration file is log4net.xml and it is located in RMP\config\BusinessEntity.
    /// </summary>
    /// <returns></returns>
    public static void Configure(string logFileWithPath, LogLevel logLevel)
    {
      if (!initialized)
      {
        lock (lockObject)
        {
          try
          {
            if (!initialized)
            {
              string configFile = SystemConfig.GetLog4NetConfigFile();
              if (!File.Exists(configFile))
              {
                string message = String.Format("Cannot file log4net config file '{0}'", configFile);
                throw new BasicException(message, SystemConfig.CallerInfo);
              }

              XmlConfigurator.Configure(new FileInfo(configFile));

              // Configure the root logger.
              // http://geekswithblogs.net/rakker/archive/2007/08/22/114900.aspx
              log4net.Repository.Hierarchy.Hierarchy h = (log4net.Repository.Hierarchy.Hierarchy)log4net.LogManager.GetRepository();
              log4net.Repository.Hierarchy.Logger rootLogger = h.Root;
              rootLogger.Level = h.LevelMap[logLevel.ToString().ToUpper()];


              #region Update file path in log4net config using the specified logFileWithPath
              IAppender appender = FindAppender("RollingFileAppender");
              if (appender == null)
              {
                string message = String.Format("Cannot file <appender> element with name 'RollingFileAppender' in config file '{0}'", configFile);
                throw new BasicException(message, SystemConfig.CallerInfo);
              }

              var fileAppender = appender as RollingFileAppender;
              if (fileAppender == null)
              {
                string message = String.Format("The <appender> element with name 'RollingFileAppender' in config file '{0}' is not of type log4net.Appender.RollingFileAppender", configFile);
                throw new BasicException(message, SystemConfig.CallerInfo);
              }

              fileAppender.File = logFileWithPath;              
              fileAppender.ActivateOptions();
              #endregion

              // Stuff [machine name - process name], used in the config file as %property{process}
              log4net.GlobalContext.Properties["process"] = 
                "[" + 
                Environment.MachineName + "-" + 
                // Process.GetCurrentProcess().StartTime.ToUniversalTime().ToString("s") + "-" +
                Process.GetCurrentProcess().ProcessName + 
                "]";

              initialized = true;

              LogManager.GetLogger("Log4NetConfig").Debug(String.Format("Initialized log4net using config file '{0}'", configFile));
            }
          }
          catch (System.Exception e)
          {
            throw new BasicException("Cannot initialize log4net", e, SystemConfig.CallerInfo);
          }
        }
      }
    }

    #region Utility functions to edit log4net config programmatically
    // Set the level for a named logger
    public static void SetLevel(string loggerName, string levelName)
    {
      log4net.ILog log = log4net.LogManager.GetLogger(loggerName);
      log4net.Repository.Hierarchy.Logger l = (log4net.Repository.Hierarchy.Logger)log.Logger;
      l.Level = l.Hierarchy.LevelMap[levelName];
    }

    // Add an appender to a logger
    public static void AddAppender(string loggerName, log4net.Appender.IAppender appender)
    {
      log4net.ILog log = log4net.LogManager.GetLogger(loggerName);
      log4net.Repository.Hierarchy.Logger l = (log4net.Repository.Hierarchy.Logger)log.Logger;
      l.AddAppender(appender);
    }

    // Find a named appender already attached to a logger
    public static IAppender FindAppender(string appenderName)
    {
      foreach (IAppender appender in log4net.LogManager.GetRepository().GetAppenders())
      {
        if (appender.Name == appenderName)
        {
          return appender;
        }
      }
      return null;
    }

    #endregion

    #region Data

    private static bool initialized = false;

    /// <summary>
    /// Private, static object used only for synchronization
    /// </summary>
    private static object lockObject = new object();

    
    #endregion
  }

  public class MTLogFileAppender : log4net.Appender.FileAppender
  {
    public override string File 
    {
      get
      {
        return SystemConfig.GetLogFile();
      }
      set
      {
        base.File = SystemConfig.GetLogFile();
      }
    }
  }

  public static class Log4NetExtension
  {
    /// <summary>
    ///    Extension method must
    ///    (1) Be in a static class.
    ///    (2) Have atleast one parameter prefixed with 'this'. Cannot be out/ref.
    /// </summary>
    /// <param name="logger"></param>
    /// <param name="errorObjects"></param>
    /// <returns></returns>
    public static void LogErrorObjects(this ILog logger, List<ErrorObject> errorObjects)
    {
      if (errorObjects == null)
      {
        return;
      }

      foreach(ErrorObject errorObject in errorObjects)
      {
        logger.Error(errorObject.Message);
      }
    }
  }
}

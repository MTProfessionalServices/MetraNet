using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


namespace MetraTech.Basic
{
  #region LogManager
  public static class LogManager
  {
    public static ILog GetLogger(string tag)
    {
      ILog logger;

      if (loggerType == LoggerType.MetraNet)
      {
        logger = new MTLogger(tag);
      }
      else
      {
        logger = new Log4NetLogger(tag);
      }

      return logger;
    }

    private static LoggerType loggerType = LoggerType.MetraNet;
  }
  #endregion

  #region ILog
  public interface ILog
  {
    void Info(string message);
    void Debug(string message);
    void Warn(string message);
    void Error(string message);
    void Error(string message, System.Exception e);

    LogLevel LogLevel { get; }
  }
  #endregion

  #region MTLogger
  public class MTLogger : ILog
  {
    public MTLogger(string tag)
    {
      logger = new Logger("[" + tag + "]");
    }

    public void Info(string message)
    {
      logger.LogInfo(message);
    }

    public void Debug(string message)
    {
      logger.LogDebug(message);
    }

    public void Warn(string message)
    {
      logger.LogWarning(message);
    }

    public void Error(string message)
    {
      logger.LogError(message);
    }

    public void Error(string message, System.Exception e)
    {
      logger.LogException(message, e);
    }

    public LogLevel LogLevel
    {
      get
      {
        var logLevel = LogLevel.Off;
        if (logger.WillLogDebug)
        {
          logLevel = LogLevel.Debug;
        }
        else if (logger.WillLogError)
        {
          logLevel = LogLevel.Error;
        }
        else if (logger.WillLogFatal)
        {
          logLevel = LogLevel.Fatal;
        }
        else if (logger.WillLogWarning)
        {
          logLevel = LogLevel.Warn;
        }
        else if (logger.WillLogInfo)
        {
          logLevel = LogLevel.Info;
        }

        return logLevel;
      }
    }

    private Logger logger;
  }
  #endregion

  #region Log4NetLogger
  public class Log4NetLogger : ILog
  {
    public Log4NetLogger(string tag)
    {
      logger = log4net.LogManager.GetLogger(tag);
    }

    public void Info(string message)
    {
      logger.Info(message);
    }

    public void Debug(string message)
    {
      logger.Debug(message);
    }

    public void Warn(string message)
    {
      logger.Warn(message);
    }

    public void Error(string message)
    {
      logger.Error(message);
    }

    public void Error(string message, System.Exception e)
    {
      logger.Error(message, e);
    }

    public LogLevel LogLevel
    {
      get
      {
        var logLevel = LogLevel.Off;
        if (logger.IsDebugEnabled)
        {
          logLevel = LogLevel.Debug;
        }
        else if (logger.IsErrorEnabled)
        {
          logLevel = LogLevel.Error;
        }
        else if (logger.IsFatalEnabled)
        {
          logLevel = LogLevel.Fatal;
        }
        else if (logger.IsWarnEnabled)
        {
          logLevel = LogLevel.Warn;
        }
        else if (logger.IsInfoEnabled)
        {
          logLevel = LogLevel.Info;
        }

        return logLevel;
      }
    }

    private log4net.ILog logger;
  }
  #endregion

  enum LoggerType
  {
    Log4Net,
    MetraNet
  }

  public enum LogLevel
  {
    Off,
    Info,
    Debug,
    Warn,
    Error,
    Fatal
  }
}

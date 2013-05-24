#region

using System;
using System.Runtime.InteropServices;

#endregion

namespace MetraTech.Tax.Framework
{
  /// <summary>
    /// The base class of all tax exceptions
  /// </summary>
  [ComVisible(false)]
  public class TaxException : ApplicationException
  {
        // Logger
    protected Logger mLogger;

        /// <summary>
        /// Constructor.  Logs the given exception message
        /// as an error.
        /// </summary>
        /// <param name="message">message associated with the exception</param>
    public TaxException(string message)
      : base(message)
    {
      mLogger = new Logger("[Tax]");
      mLogger.LogError(message);
    }

        /// <summary>
        /// Constructor.  Logs the given message according to the
        /// given log level.
        /// </summary>
        /// <param name="message"></param>
        /// <param name="logLevel"></param>
    public TaxException(string message, LogLevel logLevel)
      : base(message)
    {
      mLogger = new Logger("[Tax]");
      switch (logLevel)
      {
        case LogLevel.Fatal:
          {
            mLogger.LogFatal(message);
            break;
          }
        case LogLevel.Error:
          {
            mLogger.LogError(message);
            break;
          }
        case LogLevel.Warning:
          {
            mLogger.LogWarning(message);
            break;
          }
        case LogLevel.Info:
          {
            mLogger.LogInfo(message);
            break;
          }
        case LogLevel.Debug:
          {
            mLogger.LogDebug(message);
            break;
          }
        default:
          {
            throw new TaxException("Invalid log level specified: " + logLevel);
          }
      }
    }

        /// <summary>
        /// Constructor.  Logs the given message as an error.
        /// If logStackTrace is true, also logs a stack trace.
        /// </summary>
        /// <param name="message">exception message</param>
        /// <param name="logStackTrace">if true will log trace.</param>
    public TaxException(string message, bool logStackTrace)
      : base(message)
    {
      mLogger = new Logger("[Tax]");
      mLogger.LogError(message);

      // the stack trace is set in an exception just before it is thrown
      // since this is construction time, the exception's stack trace is null.
      // because of this, the environment stack trace is used which will have a
      // couple of extra layers on it (i.e., this ctor)
      if (logStackTrace)
        mLogger.LogError(Environment.StackTrace);
    }

        /// <summary>
        /// Constructor.  
        /// </summary>
        /// <param name="message"></param>
        /// <param name="source"></param>
    public TaxException(string message, TaxException source)
      : base(message, source)
    {
      mLogger = new Logger("[Tax]");
      mLogger.LogError(message);
    }

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="message"></param>
        /// <param name="source"></param>
    public TaxException(string message, Exception source)
      : base(message, source)
    {
      mLogger = new Logger("[Tax]");
      mLogger.LogError(message);
      mLogger.LogError(source.ToString());
    }
  }

  /// <summary>
  ///   Enum for log levels
  /// </summary>
  [ComVisible(false)]
  public enum LogLevel
  {
    Fatal = 1,
    Error = 2,
    Warning = 3,
    Info = 4,
    Debug = 5
  }

  /// <summary>
  /// An exception thrown when an invalid configuration is attempted
  /// (occurring either in Tax.xml or recurring_events.xml)
  /// This is a general exception used when no specific exception exists
  /// for configuration related exceptions.
  /// </summary>
  [ComVisible(false)]
  public class InvalidConfigurationException : TaxException
  {
    public InvalidConfigurationException(string message)
      : base(message)
    {
    }

    public InvalidConfigurationException(string message, Exception e)
      : base(message, e)
    {
    }
  }

  /// <summary>
    /// An exception thrown when a requests has been made to generate a unique
    /// tax run ID for an eop/schedule adapter context, but there already is
    /// a unique tax run ID associated with the adapter.
  /// </summary>
  [ComVisible(false)]
  public class DuplicatedContextException : TaxException
  {
    public DuplicatedContextException(string message)
      : base(message)
    {
    }

    public DuplicatedContextException(string message, Exception e)
      : base(message, e)
    {
    }
  }

  /// <summary>
    /// An exception is thrown there is an incorrectly configured tax vendor 
    /// parameter (a row in t_tax_vendor_params).
  /// </summary>
  [ComVisible(false)]
    public class InvalidTaxVendorParamException : TaxException
  {
        public InvalidTaxVendorParamException(string message)
            : base(message)
    {
    }

        public InvalidTaxVendorParamException(string message, Exception e)
            : base(message, e)
    {
    }
  }
}
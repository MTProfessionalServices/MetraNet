/**************************************************************************
* Copyright 1997-2010 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Authors: 
*
* Anatoliy Lokshin <alokshin@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using MetraTech.SecurityFramework.Common.Configuration;
using MetraTech.SecurityFramework.Core.Common.Configuration;
using MetraTech.SecurityFramework.Core.Common.Logging.Configuration;

namespace MetraTech.SecurityFramework.Core.Common.Logging
{
	/// <summary>
	/// Provides an access to the error logger specified in the security framework configuration.
	/// </summary>
	/// <remarks>Static public methods are thread-safe.</remarks>
	public static class LoggingHelper
	{
		private const string LoggerConfigurationNotFound = "Logger type is not specified.";
		private const string LoggerNotInitialized = "Can not initialize the logger instance. Please review the configuration.";
		private const string MessageKeyName = "SFMessage";

		private static readonly object _syncRoot = new object();
		private static IErrorLogger _logger;

		public static LoggerClassConfiguration LoggerConfiguration
		{
			get;
			set;
		}

		/// <summary>
		/// Writes info about the exception to the log.
		/// </summary>
		/// <param name="ex">The data to be written.</param>
		/// <returns>true if the exception was handled successfully and false otherwise.</returns>
    public static bool Log(Exception ex)
    {
      bool result = false;

      if (ex != null && !(ex is ThreadAbortException))
      {
        if (ex.Data != null && !ex.Data.Contains(MessageKeyName))
        {
          ex.Data[MessageKeyName] = FormatMessage(ex).Replace(Environment.NewLine, " ");
        }

        try
        {
          if (LoggerInitialized())
            result = _logger.Log(ex);
        }
        catch (Exception)
        {
          // Hide any exception from a logger.
        }
      }

      return result;
    }

		/// <summary>
		/// Writes Debug message to the log.
		/// </summary>
		/// <param name="tag">String describing WHERE the log called.
		/// For example Subsystem and Method names</param>
		/// <param name="msg">The data to be written.</param>
    public static void LogDebug(string tag, string msg)
    {
      if (string.IsNullOrEmpty(msg))
        return;

      try
      {
        //_logger.LogDebug(tag, FormatDebugMessage(msg));
        if (LoggerInitialized() && _logger.CanLogDebug())
          _logger.LogDebug(tag, msg);
      }
      catch (Exception)
      {
        //throw;
      }
    }

		/// <summary>
		/// Writes Info message to the log.
		/// </summary>
		/// <param name="tag">String describing WHERE the log called.
		/// For example Subsystem and Method names</param>
		/// <param name="msg">The data to be written.</param>
    public static void LogInfo(string tag, string msg)
    {
      if (string.IsNullOrEmpty(msg))
        return;

      try
      {
        if (LoggerInitialized() && _logger.CanLogInfo())
          _logger.LogInfo(tag, msg);
      }
      catch (Exception)
      {
        //throw;
      }
    }

		/// <summary>
		/// Writes Warning message to the log.
		/// </summary>
		/// <param name="tag">String describing WHERE the log called.
		/// For example Subsystem and Method names</param>
		/// <param name="msg">The data to be written.</param>
    public static void LogWarning(string tag, string msg)
    {
      if (string.IsNullOrEmpty(msg))
        return;

      try
      {
        if (LoggerInitialized() && _logger.CanLogWarning())
          _logger.LogWarning(tag, msg);
      }
      catch (Exception)
      {
        //throw;
      }
    }

		/// <summary>
		/// Writes Error message to the log.
		/// </summary>
		/// <param name="tag">String describing WHERE the log called.
		/// For example Subsystem and Method names</param>
		/// <param name="msg">The data to be written.</param>
    public static void LogError(string tag, string msg)
    {
      if (string.IsNullOrEmpty(msg))
        return;

      try
      {
        if (LoggerInitialized() && _logger.CanLogError())
          _logger.LogError(tag, msg);
      }
      catch (Exception)
      {
        //throw;
      }
    }

    /// <summary>
    /// Makes sure that the logger instance is created.
    /// </summary>
    /// <returns>true if the instance created and false otherwise.</returns>
    private static bool LoggerInitialized()
    {
      if (_logger == null)
      {
        lock (_syncRoot)
        {
          if (_logger == null)
          {
            InitLoggingHelper();
          }
        }
      }

      return _logger != null;
    }

		/// <summary>
		/// Formats error messages from linked exceptions.
		/// </summary>
		/// <param name="ex">A top level exception.</param>
		/// <returns></returns>
		private static string FormatMessage(Exception ex)
		{
			string result = "#" + ex.Message;
			if (ex.InnerException != null)
			{
				result += " " + FormatMessage(ex.InnerException);
			}

			return result;
		}


		/// <summary>
		/// Formats Debug messages
		/// </summary>
		/// <param name="msg">Message to format</param>
		/// <returns></returns>
		private static string FormatDebugMessage(string msg)
		{
			return "DEBUG " + msg;
		}

		/// <summary>
		/// Initialises the logger.
		/// </summary>
		/// <returns>true if the loader is initialized and false otherwise.</returns>
		/// <exception cref="ConfigurationException">
		/// If the class specified to handle log does not implement <see cref="IErrorLogger"/> interface.
		/// </exception>
		/// <remarks>Allows to skip logging when the loader is disabled.</remarks>
		private static bool InitLoggingHelper()
		{
			bool result = true;
			
			if (LoggerConfiguration != null)
			{
				Type loggerType = Type.GetType(LoggerConfiguration.TypeName);

				if (loggerType != null)
				{
					_logger = Activator.CreateInstance(loggerType) as IErrorLogger;
				}

				if (_logger != null)
				{
          try
          {
              _logger.Initialize(LoggerConfiguration.Configuration);

              result = true;
          }
          catch (Exception)
          {
              result = false;
          }
				}
				else
				{
					throw new ConfigurationException(LoggerNotInitialized);
				}
			}
			else // Errors logger is not loaded yet or is disabled or not configured at all.
			{
				result = false;
			}

			return result;
		}
	}
}

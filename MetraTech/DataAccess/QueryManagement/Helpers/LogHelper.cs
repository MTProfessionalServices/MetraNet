//=============================================================================
// Copyright 2012 by MetraTech
// All rights reserved.
//
// THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
// REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
// example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
// WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
// OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
// INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
// RIGHTS.
//
// Title to copyright in this software and any associated
// documentation shall at all times remain with MetraTech, and USER
// agrees to preserve the same.
//
//-----------------------------------------------------------------------------
//
// MODULE: LogHelper.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.Helpers
{
    using System;
    using System.Globalization;
    using System.Runtime.InteropServices;
    using System.Threading;

    using Constants;
    using EnumeratedTypes;
    
    /// <summary>
    /// Simple wrapper to the MT Logger object.
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("E89E21F4-ACAE-45EC-83EF-590B48076C2B")]
    public static class LogHelper
    {
        /// <summary>
        /// Calls the the MT Logger object passed in to write a message to the MT log
        /// </summary>
        /// <param name="message">The message to write to the log</param>
        /// <param name="logLevelEnum">The log level of the message to log.</param>
        /// <param name="logger">The MT logger that will write the log message.</param>
        /// <param name="exception">The exception that occurred and will have log messages written to the MT log by the logger object passed in</param>
        public static void WriteLog(string message, LogLevelEnum logLevelEnum, ILogger logger, Exception exception)
        {
            if (string.IsNullOrEmpty(message))
            {
                throw new ArgumentException(string.Format(CultureInfo.CurrentCulture, MessageConstants.ParameterIsNullOrEmpty, "message"));
            }

            if (logger == null)
            {
                throw new ArgumentException(string.Format(CultureInfo.CurrentCulture, MessageConstants.ParameterIsNull, "logger"));
            }

            string messageWithThreadId = string.Concat("[Thread Id=", Thread.CurrentThread.ManagedThreadId, "]", message );
            
            switch (logLevelEnum)
            {
                case LogLevelEnum.Debug:
                    {
                        logger.LogDebug(messageWithThreadId);
                    }
                    break;

                case LogLevelEnum.Error:
                    {
                        logger.LogError(messageWithThreadId, exception);
                    }
                    break;

                case LogLevelEnum.Exception:
                    {
                        if (exception == null)
                        {
                            throw new ArgumentException(string.Format(CultureInfo.CurrentCulture, MessageConstants.ParameterIsNull, "exception"));
                        }

                        if (string.IsNullOrEmpty(exception.Message))
                        {
                            throw new ArgumentException(string.Format(CultureInfo.CurrentCulture, MessageConstants.ParameterIsNullOrEmpty, "exception.message"));
                        }

                        logger.LogException(messageWithThreadId, exception);
                    }
                    break;

                case LogLevelEnum.Fatal:
                    {
                        logger.LogFatal(messageWithThreadId);
                    }
                    break;

                case LogLevelEnum.Info:
                    {
                        logger.LogInfo(messageWithThreadId);
                    }
                    break;

                case LogLevelEnum.Trace:
                    {
                        logger.LogTrace(messageWithThreadId);
                    }
                    break;
                case LogLevelEnum.Warning:
                    {
                        logger.LogWarning(messageWithThreadId);
                    }
                    break;
            }
        }
    }
}
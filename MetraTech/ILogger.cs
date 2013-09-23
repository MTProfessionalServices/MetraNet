// -----------------------------------------------------------------------
// <copyright file="ILogger.cs" company="MetraTech">
// **************************************************************************
// Copyright 2011 by MetraTech
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
//
// $Header$
// 
// ***************************************************************************/
// </copyright>
// -----------------------------------------------------------------------

using System;

namespace MetraTech
{
    public delegate string MessageFormaterDelegate(string message, params object[] args);

    /// <summary>
    /// Interface for logging fucntionality
    /// </summary>
    public interface ILogger
    {
        //
        // FATAL
        // 
        void LogFatal(string format, params object[] args);
        void LogFatal(string str);

        //
        // ERROR
        //
        void LogError(string format, params object[] args);
        void LogError(string str);

        //
        // WARNING
        //
        void LogWarning(string format, params object[] args);
        void LogWarning(string str);

        //
        // INFO
        //
        void LogInfo(string format, params object[] args);
        void LogInfo(string str);

        //
        // DEBUG
        //
        bool WillLogDebug
        { get; }
        bool WillLogError
        { get; }
        bool WillLogWarning
        { get; }
        bool WillLogInfo
        { get; }
        bool WillLogFatal
        { get; }
        bool WillLogTrace
        { get; }

        void LogDebug(string format, params object[] args);
        void LogDebug(string str);

        void LogTrace(string format, params object[] args);
        void LogTrace(string str);

        void LogException(string str, Exception e);

		/// <summary>
        /// Allows set format for output logging
        /// </summary>
        /// <param name="formater"></param>
        void SetFormatter(MessageFormaterDelegate formater);

        /// <summary>
        /// Sets default formater for output logging
        /// </summary>
        void ClearFormatter();
    }
}

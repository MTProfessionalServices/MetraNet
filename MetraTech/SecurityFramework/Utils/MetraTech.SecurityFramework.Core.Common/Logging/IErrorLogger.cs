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
using MetraTech.SecurityFramework.Core.Common.Logging.Configuration;

namespace MetraTech.SecurityFramework.Core.Common.Logging
{
	/// <summary>
	/// Provides an interface fot the error loggers.
	/// </summary>
	public interface IErrorLogger
	{
		/// <summary>
		/// Reads the logger configuration.
		/// </summary>
		/// <param name="configuration">A configuration to be read.</param>
		void Initialize(LoggingConfiguration configuration);

		/// <summary>
		/// Writes info about the exception to the log.
		/// </summary>
		/// <param name="ex">The data to be written.</param>
		/// <returns>true if the exception was handled successfully and false otherwise.</returns>
		bool Log(Exception ex);

		/// <summary>
		/// Writes Debug message to the log.
		/// </summary>
		/// <param name="msg">The data to be written.</param>
		void LogDebug(string msg);

		/// <summary>
		/// Writes Debug message to the log.
		/// </summary>
		/// <param name="tag">String describing WHERE the log called.
		/// For example Subsystem and Method names</param>
		/// <param name="msg">The data to be written.</param>
		void LogDebug(string tag, string msg);

		/// <summary>
		/// Writes Info message to the log.
		/// </summary>
		/// <param name="msg">The data to be written.</param>
		void LogInfo(string msg);

		/// <summary>
		/// Writes Info message to the log.
		/// </summary>
		/// <param name="tag">String describing WHERE the log called.
		/// For example Subsystem and Method names</param>
		/// <param name="msg">The data to be written.</param>
		void LogInfo(string tag, string msg);

		/// <summary>
		/// Writes Info message to the log.
		/// </summary>
		/// <param name="msg">The data to be written.</param>
		void LogWarning(string msg);

		/// <summary>
		/// Writes Info message to the log.
		/// </summary>
		/// <param name="tag">String describing WHERE the log called.
		/// For example Subsystem and Method names</param>
		/// <param name="msg">The data to be written.</param>
		void LogWarning(string tag, string msg);

		/// <summary>
		/// Writes Error message to the log.
		/// </summary>
		/// <param name="tag">String describing WHERE the log called.
		/// For example Subsystem and Method names</param>
		/// <param name="msg">The data to be written.</param>
		void LogError(string tag, string msg);

		/// <summary>
		/// Determines if there is any listener esteblished to log DEBUG messages.
		/// </summary>
		/// <returns>true if the logging is enabled and false otherwise</returns>
		bool CanLogDebug();

		/// <summary>
		/// Determines if there is any listener esteblished to log INFO messages.
		/// </summary>
		/// <returns>true if the logging is enabled and false otherwise</returns>
		bool CanLogInfo();

		/// <summary>
		/// Determines if there is any listener esteblished to log WARNING messages.
		/// </summary>
		/// <returns>true if the logging is enabled and false otherwise</returns>
		bool CanLogWarning();

		/// <summary>
		/// Determines if there is any listener esteblished to log ERROR messages.
		/// </summary>
		/// <returns>true if the logging is enabled and false otherwise</returns>
		bool CanLogError();
	}
}

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
using System.Diagnostics;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Common;
using Microsoft.Practices.EnterpriseLibrary.Logging;

namespace MetraTech.SecurityFramework.MTLogging
{
	/// <summary>
	/// Provides recording trace data to the MetraNet log.
	/// </summary>
	internal sealed class MetraTechLogTraceListener : TraceListener
	{
		private const string DefaultTagName = "[MetraTech.SecurityFramework]";
		private const string TagFormat = "[{0}:{1}]";

		/// <summary>
		///  Writes trace information, a data object and event information to the listener specific output.
		/// </summary>
		/// <param name="eventCache">
		/// A System.Diagnostics.TraceEventCache object that contains the current process ID, thread ID, and stack trace information.
		/// </param>
		/// <param name="source">
		/// A name used to identify the output, typically the name of the application that generated the trace event.
		/// </param>
		/// <param name="eventType">
		/// One of the System.Diagnostics.TraceEventType values specifying the type of event that has caused the trace.
		/// </param>
		/// <param name="id">A numeric identifier for the event.</param>
		/// <param name="data">The trace data to emit.</param>
		public override void TraceData(TraceEventCache eventCache, string source, TraceEventType eventType, int id, object data)
		{
			LogEntry entry = data as LogEntry;
			if (entry != null && Filter != null && Filter.ShouldTrace(eventCache, source, eventType, id, entry.ErrorMessages, null, data, null))
			{
				object subsystemName;
				object categoryName;
				string tagName;

				if (entry.ExtendedProperties != null &&
					entry.ExtendedProperties.TryGetValue(Constants.Logging.SubsystemKeyName, out subsystemName) &&
					entry.ExtendedProperties.TryGetValue(Constants.Logging.CategoryKeyName, out categoryName))
				{
					tagName = string.Format(TagFormat, subsystemName, categoryName);
				}
				else
				{
					tagName = DefaultTagName;
				}

				Logger logger = new Logger(tagName);

				object message;
				string messageStr = entry.ExtendedProperties.TryGetValue(Constants.Logging.MessageKeyName, out message) ? Convert.ToString(message) : entry.Message;

				switch (eventType)
				{
					case TraceEventType.Error:
						logger.LogError(messageStr);
						break;
					case TraceEventType.Critical:
						logger.LogFatal(messageStr);
						break;
					case TraceEventType.Information:
						logger.LogInfo(messageStr);
						break;
					case TraceEventType.Warning:
						logger.LogWarning(messageStr);
						break;
					default:
						logger.LogDebug(messageStr);
						break;
				}
			}
			else
			{
				base.TraceData(eventCache, source, eventType, id, data);
			}
		}

		/// <summary>
		/// Writes a specified message to the MetraNet log.
		/// </summary>
		/// <param name="message">A data to be logged.</param>
		public override void Write(string message)
		{
			try
			{
				Logger logger = new Logger(DefaultTagName);
				logger.LogDebug(message);
			}
			catch
			{
				// Hide any exception including unmanagaed one.
			}
		}

		/// <summary>
		/// Writes a specified message to the MetraNet log.
		/// </summary>
		/// <param name="message">A data to be logged.</param>
		public override void WriteLine(string message)
		{
			Write(message);
		}
	}
}

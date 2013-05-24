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
* Kyle C. Quest <kquest@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using MetraTech.SecurityFramework.Common;
using MetraTech.SecurityFramework.Core.Common.Configuration;
using MetraTech.SecurityFramework.Core.Common.Logging;


namespace MetraTech.SecurityFramework
{
	/// <summary>
	/// Provides a base for exceptions caused by a potentially danger data.
	/// </summary>
	[Serializable]
	public class BadInputDataException : SecurityFrameworkException
	{
		#region Constants

		private const string DecreasedMessageFormat = "\n(Decreased. Original length={0})";
		private const int MaxLengthInputValueForException = 255;

		#endregion

		#region Properties

		/// <summary>
		/// Security problem Id
		/// </summary>
		public int Id
		{
			get;
			private set;
		}


		/// <summary>
		/// Gets or internally sets a type of the event that caused the exception.
		/// </summary>
		public SecurityEventType EventType
		{
			get;
			private set;
		}

		/// <summary>
		/// Gets or internally sets a name of the subsystem a source engine belongs to.
		/// </summary>
		public string SubsystemName
		{
			get;
			private set;
		}

		/// <summary>
		/// Gets or internally sets a name of the category a source engine belongs to.
		/// </summary>
		public string CategoryName
		{
			get;
			private set;
		}

		/// <summary>
		/// Gets or internally sets a input data whith processed by an engine.
		/// </summary>
		public string InputData
		{
			get;
			private set;
		}

		/// <summary>
		/// Gets or internally sets a reason of the current exception. 
		/// </summary>
		/// <example>It maybe a pattern expression whith detected a XSS attack.</example>
		public string Reason
		{
			get;
			private set;
		}

		/// <summary>
		/// Gets or sets whether the exception was handled by the Security Monitor.
		/// </summary>
		public bool IsReported
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or internally sets an input initial data size.
		/// </summary>
		public long InputDataSize
		{
			get;
			private set;
		}

		#endregion

		#region Constructors

		/// <summary>
		/// Creates an instance of the <see cref="BadInputDataException"/> class.
		/// </summary>
		/// <param name="id">Security problem Id</param>  
		/// <param name="subsystemName">Specifies a name of the subsystem a source engine belongs to.</param>
		/// <param name="categoryName">Specifies a name of the category a source engine belongs to.</param>
		/// <param name="message">A message describing the exception.</param>
		/// <param name="eventType">Specifies a type of the event that caused the exception.</param>
		public BadInputDataException(int id, string subsystemName, string categoryName, string message, SecurityEventType eventType)
			: base(TruncateInputDataForException(message))
		{
			this.Id = id;
			this.SubsystemName = subsystemName;
			this.CategoryName = categoryName;
			this.EventType = eventType;

			AutoReport();
		}

		/// <summary>
		/// Creates an instance of the <see cref="BadInputDataException"/> class.
		/// </summary>
		/// <param name="id">Security problem Id</param>  
		/// <param name="subsystemName">Specifies a name of the subsystem a source engine belongs to.</param>
		/// <param name="categoryName">Specifies a name of the category a source engine belongs to.</param>
		/// <param name="message">A message describing the exception.</param>
		/// <param name="eventType">Specifies a type of the event that caused the exception.</param>
		/// <param name="inner">An exception that initailly caused the exception.</param>
		public BadInputDataException(int id, string subsystemName, string categoryName, string message, SecurityEventType eventType, Exception inner)
			: base(message, inner)
		{
			this.Id = id;
			this.SubsystemName = subsystemName;
			this.CategoryName = categoryName;
			this.EventType = eventType;

			AutoReport();
		}

		/// <summary>
		/// Creates an instance of the <see cref="BadInputDataException"/> class.
		/// </summary>
		/// <param name="id">Security problem Id</param> 
		/// <param name="subsystemName">Specifies a name of the subsystem a source engine belongs to.</param>
		/// <param name="categoryName">Specifies a name of the category a source engine belongs to.</param>
		/// <param name="message">A message describing the exception.</param>
		/// <param name="eventType">Specifies a type of the event that caused the exception.</param>
		/// <param name="inputData">Specifies a input data whith processed an engine.</param>
		/// <param name="reason">Specifies a reason of the current exception.</param>
		public BadInputDataException(int id, string subsystemName, string categoryName, string message, SecurityEventType eventType, string inputData, string reason)
			: this(id, subsystemName, categoryName, message, eventType, inputData, reason, null)
		{ }

		/// <summary>
		/// Creates an instance of the <see cref="BadInputDataException"/> class.
		/// </summary>
		/// <param name="id">Security problem Id</param> 
		/// <param name="subsystemName">Specifies a name of the subsystem a source engine belongs to.</param>
		/// <param name="categoryName">Specifies a name of the category a source engine belongs to.</param>
		/// <param name="message">A message describing the exception.</param>
		/// <param name="eventType">Specifies a type of the event that caused the exception.</param>
		/// <param name="inputData">Specifies a input data whith processed an engine.</param>
		/// <param name="reason">Specifies a reason of the current exception.</param>
		/// <param name="inner">Inner exception</param>
		public BadInputDataException(
			int id,
			string subsystemName,
			string categoryName,
			string message,
			SecurityEventType eventType,
			string inputData,
			string reason,
			Exception inner)
			: base(message, inner)
		{
			this.Id = id;
			this.SubsystemName = subsystemName;
			this.CategoryName = categoryName;
			this.EventType = eventType;
			this.InputData = TruncateInputDataForException(inputData);
			this.InputDataSize = inputData != null ? inputData.Length : 0;
			this.Reason = reason;

			AutoReport();
		}

		/// <summary>
		/// Serialization constructor.
		/// </summary>
		/// <param name="info"></param>
		/// <param name="context"></param>
		protected BadInputDataException(SerializationInfo info, StreamingContext context)
			: base(info, context)
		{
		}
	
		#endregion

		#region Private methods

		private static string TruncateInputDataForException(string inputData)
		{
			string result = inputData;
			if (inputData != null && inputData.Length > MaxLengthInputValueForException)
			{
				string decreasedMessage = String.Format(DecreasedMessageFormat, inputData.Length);
				result = inputData.Substring(0, MaxLengthInputValueForException - decreasedMessage.Length) + decreasedMessage;
			}

			return result;
		}

		private void AutoReport()
		{
			try
			{
				Data[Constants.Logging.MessageKeyName] = Message;
				Data[Constants.Logging.SubsystemKeyName] = SubsystemName;
				Data[Constants.Logging.CategoryKeyName] = CategoryName;

				// Check whether auto-logging is enabled.
				if (SecurityFrameworkSettings.Current.AutoMonitorExceptions)
				{
					// Report a problem.
					this.Report();
				}
			}
			catch (ConfigurationException ex)
			{
				// Just hide and log any configuration errors.
				LoggingHelper.Log(ex);
			}
		}

		#endregion
	}
}
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

namespace MetraTech.SecurityFramework.Common
{
	/// <summary>
	/// Contains constants used through out the Security Framework.
	/// </summary>
	public static class Constants
	{
		/// <summary>
		/// Contains method argument names.
		/// </summary>
		public static class Arguments
		{
			public const string From = "from";
			public const string To = "to";
			public const string Data = "data";
			public const string Template = "template";
			public const string Configuration = "configuration";
			public const string Filter = "filter";
			public const string Writer = "writer";
			public const string Properties = "properties";
			public const string SecurityEvent = "securityEvent";
			public const string Actions = "actions";
			public const string HandlerId = "handlerId";
			public const string Handler = "handler";
			public const string EventData = "eventData";
			public const string ActionsData = "actionsData";
		}

		/// <summary>
		/// Contains class's property names.
		/// </summary>
		public static class Properties
		{
			public const string Template = "Template";
			public const string FileName = "FileName";
			public const string Filter = "Filter";
			public const string Formatter = "Formatter";
			public const string IndentLevel = "IndentLevel";
			public const string IndentSize = "IndentSize";
			public const string NeedIndent = "NeedIndent";
			public const string TraceOutputOptions = "TraceOutputOptions";
			public const string EventType = "EventType";
			public const string SubsystemName = "SubsystemName";
			public const string CategoryName = "CategoryName";
			public const string ProblemId = "ProblemId";
			public const string InputData = "InputData";
			public const string Reason = "Reason";
			public const string TimeStamp = "TimeStamp";
			public const string Path = "Path";
			public const string HostName = "HostName";
			public const string Message = "Message";
			public const string ClientAddress = "ClientAddress";
			public const string UserIdentity = "UserIdentity";
			public const string SessionId = "SessionId";
			public const string ClientInfo = "ClientInfo";
			public const string StackTrace = "StackTrace";
			public const string InputDataSize = "InputDataSize";
			public const string SecurityPolicyActionTypeId = "SecurityPolicyActionTypeId";
			public const string BlockingPeriod = "BlockingPeriod";
			public const string SessionParameterName = "SessionParameterName";
			public const string SessionParameterValue = "SessionParameterValue";
			public const string AdminEmailAddress = "AdminEmailAddress";
			public const string DestinationPath = "DestinationPath";
		}

		/// <summary>
		/// Contains constants for formatting.
		/// </summary>
		public static class Formatting
		{
			public const string ISO8601DateFormat = "yyyy-MM-dd HH:mm:ss.fff";
			public const string SortableDateFormat = "yyyyMMdd";
			public const string EnumToStringFormat = "G";
			public const string Comma = ",";
			public const string QuotationFormat = "\"{0}\"";
		}

		/// <summary>
		/// Contains constants to wrk with regular expressions.
		/// </summary>
		public static class RegEx
		{
			public const string HexCodeGroupName = "hexCode";
			public const string NamedEntityGroupName = "namedEntity";
			public const string DecimalCodeGroupName = "decimalCode";
			public const string Or = "|";
		}

		/// <summary>
		/// Contains database query parameters.
		/// </summary>
		public static class DbParameters
		{
			public const string SecurityEventTypeId = "@SecurityEventTypeID";
			public const string SubsystemCategoryId = "@SubsystemCategoryID";
			public const string CategoryName = "@CategoryName";
			public const string SubsystemName = "@SubsystemName";
			public const string ProblemId = "@ProblemId";
			public const string InputData = "@InputData";
			public const string Reason = "@Reason";
			public const string TimeStamp = "@TimeStamp";
			public const string Path = "@Path";
			public const string HostName = "@HostName";
			public const string Message = "@Message";
			public const string ClientAddress = "@ClientAddress";
			public const string UserIdentity = "@UserIdentity";
			public const string ClientInfo = "@ClientInfo";
			//public const string StackTrace = "@StackTrace";
			public const string SessionId = "@SessionID";
			public const string SecurityEventId = "@SecurityEventId";
			public const string SecurityPolicyActionTypeId = "@SecurityPolicyActionTypeId";
			public const string BlockingPeriod = "@BlockingPeriod";
			public const string SessionParameterName = "@SessionParameterName";
			public const string SessionParameterValue = "@SessionParameterValue";
			public const string AdminEmailAddress = "@AdminEmailAddress";
			public const string DestinationPath = "@DestinationPath";
			public const string CurrentAddress = "@CurrentAddress";
			public const string InputDataSize = "@InputDataSize";
		}

		/// <summary>
		/// Contains database table column names.
		/// </summary>
		public static class DbColumns
		{
			public const string Id = "ID";
			public const string Name = "Name";
			public const string SubsystemName = "SubsystemName";
		}

		/// <summary>
		/// Contains constants used in validators.
		/// </summary>
		public static class Validation
		{
			public const string HexNumberPrefix1 = "0x";
			public const string HexNumberPrefix2 = "\\x";
			public const string OctalNumberPrefix = "\\0";
		}

		/// <summary>
		/// Contains constants used by the logging system.
		/// </summary>
		public static class Logging
		{
			public const string MessageKeyName = "SFMessage";
			public const string SubsystemKeyName = "SFSubsystem";
			public const string CategoryKeyName = "SFCategory";
			public const string DefaultTagKey = "[MetraTech.SecurityFramework]";
		}
	}
}

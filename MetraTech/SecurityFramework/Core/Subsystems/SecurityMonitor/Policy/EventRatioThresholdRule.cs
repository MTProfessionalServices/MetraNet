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
using MetraTech.SecurityFramework.Common;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Core.SecurityMonitor.Policy
{
	/// <summary>
	/// Checks if the ration of secority events from one source to events from another source in the specified time frame does not exceed a specified limit.
	/// </summary>
	[Serializable]
	public class EventRatioThresholdRule : IPolicyRule
	{
		/// <summary>
		/// Gets or sets a value indicating a time frame to count security events within. 
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
		public TimeSpan TimeThreshold
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets a ratio limit.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
		public double RatioLimit
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets a subsystem name of the first source.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
		public string SourceSubsystem1
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets a category name of the first source.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
		public string SourceCategory1
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets a subsystem name of the second source.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
		public string SourceSubsystem2
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets a category name of the second source.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
		public string SourceCategory2
		{
			get;
			set;
		}

		/// <summary>
		/// Calculates a ration between number of events from different sources and determines does it fit with the specified limt.
		/// </summary>
		/// <param name="securityEvent">A security event to be evaluated.</param>
		/// <returns>true if the event matched the security policy rule and false otherwise.</returns>
		/// <exception cref="ArgumentNullException">If <paramref name="securityEvent"/> is null.</exception>
		public bool Evaluate(ISecurityEvent securityEvent)
		{
			if (securityEvent == null)
			{
				throw new ArgumentNullException(Constants.Arguments.SecurityEvent);
			}

			DateTime fromTime = DateTime.Now - TimeThreshold;
			// Get number of events in the specified time frame.
			int source1Events = LogAnalizerFactory.Analyzer.GetEventsNumberInTimespan(fromTime, SourceSubsystem1, SourceCategory1);
			int source2Events = LogAnalizerFactory.Analyzer.GetEventsNumberInTimespan(fromTime, SourceSubsystem2, SourceCategory2);

			// Check if the current event source falls into source 1 and/or source 2.
			if (string.Compare(SourceSubsystem1, securityEvent.SubsystemName, StringComparison.InvariantCultureIgnoreCase) == 0 &&
				string.Compare(SourceCategory1, securityEvent.CategoryName, StringComparison.InvariantCultureIgnoreCase) == 0)
			{
				source1Events++;
			}

			if (string.Compare(SourceSubsystem2, securityEvent.SubsystemName, StringComparison.InvariantCultureIgnoreCase) == 0 &&
				string.Compare(SourceCategory2, securityEvent.CategoryName, StringComparison.InvariantCultureIgnoreCase) == 0)
			{
				source2Events++;
			}

			double ration = source1Events == 0 ? 0 : (source2Events == 0 ? double.PositiveInfinity : (double)source1Events / (double)source2Events);
			bool result = ration > RatioLimit;

			return result;
		}
	}
}

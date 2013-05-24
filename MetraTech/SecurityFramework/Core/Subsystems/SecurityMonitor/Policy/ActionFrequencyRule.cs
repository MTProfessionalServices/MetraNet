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
	/// Checks if the action of the same type was recommended in the specified time frame.
	/// </summary>
	[Serializable]
	public class ActionFrequencyRule : IPolicyRule
	{
		/// <summary>
		/// Gets or sets a policy action type to look for.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
		public SecurityPolicyActionType PolicyActionType
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets a value indicating a time frame to count policy actions within. 
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
		public TimeSpan TimeThreshold
		{
			get;
			set;
		}

		/// <summary>
		/// Checks if a policy action of the specified type was generated in the specified time frame.
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

			DateTime point = DateTime.Now - TimeThreshold;
			DateTime lastActionTime = LogAnalizerFactory.Analyzer.GetLastActionTimeStamp((int)PolicyActionType);
			bool result = lastActionTime < point;

			return result;
		}
	}
}

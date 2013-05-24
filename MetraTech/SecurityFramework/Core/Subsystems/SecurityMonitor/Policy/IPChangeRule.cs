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
	/// Checks if client's IP address has been changes within a session.
	/// </summary>
	[Serializable]
	public class IPChangeRule : IPolicyRule
	{
		/// <summary>
		/// Gets or sets a number of addresses allowed in the session.
		/// </summary>
		/// <remarks>Default value is 1.</remarks>
		[SerializePropertyAttribute]
		public int NumberThreshold
		{
			get;
			set;
		}

		/// <summary>
		/// Creates an instance of the <see cref="IPChangeRule"/>.
		/// Initializes RepeatThreshold.
		/// </summary>
		public IPChangeRule()
		{
			NumberThreshold = 1;
		}

		/// <summary>
		/// Checks if client's IP address has been changes within a session specified in the <paramref name="securityEvent"/>.
		/// </summary>
		/// <param name="securityEvent">A security event to be evaluated.</param>
		/// <returns>true if the event matched the security policy rule and false otherwise.</returns>
		public bool Evaluate(ISecurityEvent securityEvent)
		{
			if (securityEvent == null)
			{
				throw new ArgumentNullException(Constants.Arguments.SecurityEvent);
			}

			int addressesNumber =
				LogAnalizerFactory.Analyzer.GetSessionIPAddressesNumber(securityEvent.SessionId, securityEvent.ClientAddress.ToString());

			bool result = (addressesNumber + 1) > NumberThreshold;

			return result;
		}
	}
}

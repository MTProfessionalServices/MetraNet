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
    /// Checks if the event of the same type happened some number of times in the current user session.
    /// </summary>
    [Serializable]
    public class EventRepeatThresholdRule : IPolicyRule
    {
        /// <summary>
        /// Gets or sets a number of times the event can occurs in the session.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
        public int RepeatThreshold
        {
            get;
            set;
        }

        /// <summary>
        /// Evaluates if the event matches the policy rule.
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

            int repeats = LogAnalizerFactory.Analyzer.GetEventsNumberInSession(
                securityEvent.SessionId,
                securityEvent.SubsystemName,
                securityEvent.CategoryName);

            return repeats >= RepeatThreshold;
        }
    }
}

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
    /// Checks if the event has the specified Security Event Type.
    /// </summary>
    [Serializable]
    public class EventTypeRule : IPolicyRule
    {
        /// <summary>
        /// Gets or sets an event type to check event for.
        /// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
        public SecurityEventType EventType
        {
            get;
            set;
        }

        /// <summary>
        /// Evaluates if the event has the same Event type that is defined in the rule.
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

            return EventType == securityEvent.EventType;
        }
    }
}

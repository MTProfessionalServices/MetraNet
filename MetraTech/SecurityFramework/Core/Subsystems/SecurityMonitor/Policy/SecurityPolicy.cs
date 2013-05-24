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
    /// Contains a policy rule set and definitions of actions those have to be performed
    /// if the processed event matches the rules.
    /// Unlike the event filters the policy rules are combined with AND operation
    /// (i.e., an event has to match all rules to be a subject of the policy).
    /// </summary>
    public class SecurityPolicy
    {
        /// <summary>
        /// Gets or sets an identifier of the security policy.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
        public string Id
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a list of policy actions to be performed if a security event matches all policy pules.
		/// </summary>
		[SerializeCollectionAttribute(IsRequired = true)]
        public PolicyAction[] Actions
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a list of policy rules to be applied to a security event.
		/// </summary>
		[SerializeCollectionAttribute(IsRequired = true)]
        public IPolicyRule[] Rules
        {
            get;
            set;
        }

        /// <summary>
        /// Evaluates if the event matches the policy rules
        /// and returns a list of actions to be performed in the response to the event if it does.
        /// </summary>
        /// <param name="securityEvent">A security event to be evaluated.</param>
        /// <param name="actions">A list of actions to be performed by an app in response to the event.</param>
        /// <returns>true if the event matched the security policy rule and false otherwise.</returns>
        /// <exception cref="ArgumentNullException">If any argument is null.</exception>
        /// <exception cref="InvalidOperationException">If either Actions or Rules property is null.</exception>
        public bool Evaluate(ISecurityEvent securityEvent, List<PolicyAction> actions)
        {
            if (securityEvent == null)
            {
                throw new ArgumentNullException(Constants.Arguments.SecurityEvent);
            }

            if (actions == null)
            {
                throw new ArgumentNullException(Constants.Arguments.Actions);
            }

            if (Actions == null)
            {
                throw new InvalidOperationException(
                    string.Format("Actions are not configured for the security policy \"{0}\"", Id));
            }

            if (Rules == null)
            {
                throw new InvalidOperationException(
                    string.Format("Rules are not configured for the security policy '{0}\"", Id));
            }

            bool result = true;
            
            // Evaluate rules.
            for (int i = 0; result && i < Rules.Length; i++)
            {
                result = Rules[i].Evaluate(securityEvent);
            }

            if (result)
            {
                // Add actions if the event matches the policy.
                actions.AddRange(Actions);
            }

            return result;
        }
    }
}

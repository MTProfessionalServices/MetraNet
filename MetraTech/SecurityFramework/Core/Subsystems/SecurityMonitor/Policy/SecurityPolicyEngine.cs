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
using MetraTech.SecurityFramework.Core.Common.Logging;

namespace MetraTech.SecurityFramework.Core.SecurityMonitor.Policy
{
    /// <summary>
    /// Validates a security event against configured security policies.
    /// </summary>
    internal class SecurityPolicyEngine
    {
        /// <summary>
        /// Gets or sets a list of security policies.
        /// </summary>
        public SecurityPolicy[] Policies
        {
            get;
            private set;
        }

        /// <summary>
        /// Creates an instance of the <see cref="SecurityPolicyEngine"/> class.
        /// </summary>
        /// <param name="policies">A list of security policies to be evaliated against events.</param>
        public SecurityPolicyEngine(SecurityPolicy[] policies)
        {
            this.Policies = policies;
        }

        /// <summary>
        /// Processes the specified security event.
        /// </summary>
        /// <param name="securityEvent">An event to be processed.</param>
        /// <param name="actions">
        /// A list of actions to be performed in response to the event.
        /// <remarks>Actions in the list are distinguished, i.e. there are no two the same actions added by different policies.</remarks>
        /// </param>
        /// <returns>true if the event matches some of the security policies.</returns>
        /// <exception cref="ArgumentNullException">If any argument is null.</exception>
        /// <exception cref="InvalidOperationException">If Policies properti is null.</exception>
        public bool ProcessEvent(ISecurityEvent securityEvent, List<PolicyAction> actions)
        {
            if (securityEvent == null)
            {
                throw new ArgumentNullException(Constants.Arguments.SecurityEvent);
            }

            if (actions == null)
            {
                throw new ArgumentNullException(Constants.Arguments.Actions);
            }

            if (Policies == null)
            {
                throw new InvalidOperationException("Security policies are not configured for the security policy engine.");
            }

            actions.Clear();

            // Evaluate security policies against the event.
            bool result = false;
            List<PolicyAction> tempActions = new List<PolicyAction>();
            for (int i = 0; i < Policies.Length; i++)
            {
                try
                {
                    result = Policies[i].Evaluate(securityEvent, tempActions) || result;
                }
                catch (Exception ex)
                {
                    // Log an exception and process other policies.
                    LoggingHelper.Log(ex);
                }
            }

            if (result)
            {
                // Distinguish actions and add them to the output list.
                actions.AddRange(tempActions.Distinct());
            }

            return result;
        }
    }
}

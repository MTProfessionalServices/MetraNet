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
    /// Checks if the event became from the specified source (subsystem and subsystem’s category).
    /// </summary>
    [Serializable]
    public class EventSourceRule : IPolicyRule
    {
        /// <summary>
        /// Gets or sets a subsystem name to check event source against.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
        public string SubsystemName
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a subsystem's category name to check event source against.
		/// </summary>
		[SerializePropertyAttribute]
        public string CategoryName
        {
            get;
            set;
        }

        /// <summary>
        /// Determines whether Subsystem name and Category name defined in the rule are equal to event's source
        /// subsystem and category.
        /// If the Category name if not defined for the rule then only Subsystem name equality is required
        /// to match the rule.
        /// All comparisions are case-insensitive.
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

            bool result =
                string.Compare(securityEvent.SubsystemName, SubsystemName, StringComparison.InvariantCultureIgnoreCase) == 0 &&
                (string.IsNullOrEmpty(CategoryName) ||
                string.Compare(securityEvent.CategoryName, CategoryName, StringComparison.InvariantCultureIgnoreCase) == 0);

            return result;
        }
    }
}

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

namespace MetraTech.SecurityFramework.Core.SecurityMonitor
{
    /// <summary>
    /// Represents arguments for CustomFilter event handler.
    /// </summary>
    [Serializable]
    public class CustomFilterEventArgs : EventArgs
    {
        /// <summary>
        /// Gets or internally sets an event to be tested.
        /// </summary>
        public ISecurityEvent SecurityEvent
        {
            get;
            private set;
        }

        /// <summary>
        /// Gets or sets if the event matches conditions.
        /// </summary>
        public bool Matched
        {
            get;
            set;
        }

        /// <summary>
        /// Creates an instance of the <see cref="CustomFilterEventArgs"/> class.
        /// </summary>
        /// <param name="securityEvent">An event to be tested.</param>
        public CustomFilterEventArgs(ISecurityEvent securityEvent)
        {
            this.SecurityEvent = securityEvent;
        }
    }

    public delegate void CustomFilterEventHandler(object sender, CustomFilterEventArgs e);

    /// <summary>
    /// Determines whether the event matches some especial conditions.
    /// </summary>
    public class SecurityEventFilter
    {
        #region Public properties

        /// <summary>
        /// Gets or sets a type of events to match.
        /// </summary>
        /// <remarks>Unknown event type specifies to not filter by this criteria.</remarks>
        public SecurityEventType EventType
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets an event source subsystem name to match.
        /// </summary>
        /// <remarks>null or empty string specifies to not filter by this criteria.</remarks>
        public string SubsystemName
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets an event source engine category name to match.
        /// </summary>
        /// <remarks>null or empty string specifies to not filter by this criteria.</remarks>
        public string SubsystemCategoryName
        {
            get;
            set;
        }

        /// <summary>
        /// Provides a custom filtering functionality.
        /// </summary>
        public event CustomFilterEventHandler CustomFilter;

        #endregion

        #region Public methods

        /// <summary>
        /// Determines whether the event matches the filter's conditions.
        /// </summary>
        /// <param name="securityEvent">The event to be tested</param>
        /// <returns>true if the event matches the condition and false otherwise.</returns>
        /// <remarks>The comparision of the subsystem and category names is case-insensitive.</remarks>
        public bool IsMatched(ISecurityEvent securityEvent)
        {
            bool result;

            // Evaluate event type matching.
            result =
                this.EventType == SecurityEventType.Unknown || this.EventType == securityEvent.EventType;

            // Evaluate source subsystem matching.
            result = result &&
                (string.IsNullOrEmpty(this.SubsystemName) ||
                string.Compare(this.SubsystemName, securityEvent.SubsystemName, StringComparison.InvariantCultureIgnoreCase) == 0);

            // Evaluate source category name.
            result = result &&
                (string.IsNullOrEmpty(this.SubsystemCategoryName) ||
                string.Compare(this.SubsystemCategoryName, securityEvent.CategoryName, StringComparison.InvariantCultureIgnoreCase) == 0);

            // Evaluate custom filter.
            if (result && this.CustomFilter != null)
            {
                CustomFilterEventArgs args = new CustomFilterEventArgs(securityEvent) { Matched = result };
                this.CustomFilter(this, args);

                result = args.Matched;
            }

            return result;
        }

        #endregion
    }
}

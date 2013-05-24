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
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Core.SecurityMonitor
{
    /// <summary>
    /// Represents a configuration for <see cref="SecurityEventFilter"/>.
    /// </summary>
    public class EventFilterProperties
    {
        /// <summary>
        /// Represents a custom event filter event handler setting.
        /// </summary>
        public class CustomFilterProperties
        {
            /// <summary>
            /// Gets or sets a name of the class that contains an event handler.
			/// </summary>
			[SerializePropertyAttribute]
            public string TypeName
            {
                get;
                set;
            }

            /// <summary>
            /// Gets or sets a name of the static method that fit with <see cref="CustomFilterEventHandler"/> delegate.
			/// </summary>
			[SerializePropertyAttribute]
            public string MethodName
            {
                get;
                set;
            }
        }

        #region Properties

        /// <summary>
        /// Gets or sets a type of events to match.
        /// </summary>
		/// <remarks>Unknown event type specifies to not filter by this criteria.</remarks>
		[SerializePropertyAttribute]
        public SecurityEventType EventType
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets an event source subsystem name to match.
        /// </summary>
		/// <remarks>null or empty string specifies to not filter by this criteria.</remarks>
		[SerializePropertyAttribute]
        public string SubsystemName
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets an event source engine category name to match.
        /// </summary>
		/// <remarks>null or empty string specifies to not filter by this criteria.</remarks>
		[SerializePropertyAttribute]
        public string SubsystemCategoryName
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a custom filter handler setting.
		/// </summary>
		[SerializePropertyAttribute]
        public CustomFilterProperties CustomFilter
        {
            get;
            set;
        }

        #endregion
    }
}

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
using System.Diagnostics;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Core.Common.Logging.Configuration
{
    /// <summary>
    /// Represents an exception handler configuration.
    /// </summary>
    public class ExceptionHandlerConfiguration : TypeConfiguration
    {
        /// <summary>
        /// Gets or sets a name of the log category to be handled.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
        public string LogCategory
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets an event ID.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
        public int EventId
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a minimum severity of the event to be handled.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
        public TraceEventType Severity
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets the default title for logged events.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
        public string Title
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets an assebly or fully qualified name of the formatter type.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
        public string FormatterType
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a handler priority.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
        public int Priority
        {
            get;
            set;
        }
    }
}

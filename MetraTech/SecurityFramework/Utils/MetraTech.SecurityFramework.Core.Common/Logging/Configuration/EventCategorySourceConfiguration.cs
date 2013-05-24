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
using System.Diagnostics;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Core.Common.Logging.Configuration
{
    /// <summary>
    /// Represents an event category configuration.
    /// </summary>
    public class EventCategorySourceConfiguration
    {
        /// <summary>
        /// Gets or sets the value of the switch.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
        public SourceLevels SwitchValue
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a source category name.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
        public string CategoryName
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a list of listeners registered for the category.
		/// </summary>
		[SerializeCollectionAttribute]
        public string[] Listeners
        {
            get;
            set;
        }
    }
}

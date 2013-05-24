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

namespace MetraTech.SecurityFramework.Core.Common.Logging.Configuration
{
    /// <summary>
    /// Represents log formatter configuration.
    /// </summary>
    public class LogFormatterConfiguration : TypeConfiguration
    {
        /// <summary>
        /// Gets or sets a formatter template.
		/// </summary>
		[SerializePropertyAttribute]
        public string Template
        {
            get;
            set;
        }
    }
}

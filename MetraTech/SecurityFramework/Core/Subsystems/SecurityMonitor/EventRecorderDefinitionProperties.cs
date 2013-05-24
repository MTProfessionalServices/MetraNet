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
    /// Represents a base configuration class for <see cref="EventRecorderDefinition"/>.
    /// </summary>
    public abstract class EventRecorderDefinitionProperties
    {
        #region Properties

        /// <summary>
        /// Gets or sets an ID of the recorder.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
        public string Id
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a filters configuration.
		/// </summary>
		[SerializeCollectionAttribute]
        public EventFilterProperties[] Filters
        {
            get;
            set;
        }

        #endregion

        #region Methods

        /// <summary>
        /// Creates a writer using current configuration.
        /// </summary>
        /// <returns></returns>
        public abstract SecurityEventWriter CreateWriter();

        #endregion
    }
}

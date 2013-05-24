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
* Kyle C. Quest <kquest@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using System.Xml;
using System.IO;
using MetraTech.SecurityFramework.Core.SecurityMonitor.Policy;
using MetraTech.SecurityFramework.Serialization.Attributes;


namespace MetraTech.SecurityFramework.Core.SecurityMonitor
{
    public sealed class SecurityMonitorProperties : MetraTech.SecurityFramework.Core.SubsystemProperties
    {
        #region Properties

        /// <summary>
        /// Gets or sets a recorders configuration.
		/// </summary>
		[SerializeCollectionAttribute(IsRequired = true)]
        public EventRecorderDefinitionProperties[] Recorders
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a list of Security Monitor policies.
		/// </summary>
		[SerializeCollectionAttribute(IsRequired = true)]
        public SecurityPolicy[] Policies
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a name of the type that implements
        /// <see cref="MetraTech.SecurityFramework.Core.SecurityMonitor.Policy.ILogAnalizerRepository"/> interface
        /// an is used for security events analyses.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
        public ILogAnalizerRepository LogAnalyzer
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a value indication if Input Data should be recorder together with other information.
		/// </summary>
		[SerializePropertyAttribute]
        public bool RecordInputData
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a value indication if security event Reason should be recorder together with other information.
        /// </summary>
		[SerializePropertyAttribute]
        public bool RecordEventReason
        {
            get;
            set;
        }

        #endregion
    }
}

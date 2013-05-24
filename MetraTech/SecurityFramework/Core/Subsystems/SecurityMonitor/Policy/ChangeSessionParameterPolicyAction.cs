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
    /// Represents the data for SendAdminNotification policy action.
    /// </summary>
    [Serializable]
    public class ChangeSessionParameterPolicyAction : PolicyAction
    {
        /// <summary>
        /// Gets or sets a name of the parameter to be changed.
        /// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
        public string ParameterName
        {
            get;
            set;
        }

        /// <summary>
        /// Gets or sets a recommended value to be set to a parameter.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
        public string ParameterValue
        {
            get;
            set;
        }

        /// <summary>
        /// Creates an instance of the <see cref="ChangeSessionParameterPolicyAction"/> class.
        /// </summary>
        public ChangeSessionParameterPolicyAction()
            : base(SecurityPolicyActionType.ChangeSessionParameter)
        {
        }

		/// <summary>
		/// Writes the action data using the specified recorder.
		/// </summary>
		/// <param name="writer">A recorder to be used.</param>
		public override void Record(SecurityEventWriter writer)
		{
			base.Record(writer);

			writer.Write(Constants.Properties.SessionParameterName, ParameterName);
			writer.Write(Constants.Properties.SessionParameterValue, ParameterValue);
		}
    }
}

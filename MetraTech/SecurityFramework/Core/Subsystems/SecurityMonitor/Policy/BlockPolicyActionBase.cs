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
    /// Provides a base class for block action policy definitions.
    /// </summary>
    public abstract class BlockPolicyActionBase : PolicyAction
    {
        /// <summary>
        /// Gets or sets a period the operation should be blocked for.
        /// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
        public TimeSpan BlockingPeriod
        {
            get;
            set;
        }

        /// <summary>
        /// Creates an instance of the <see cref="PolicyAction"/> class.
        /// </summary>
        /// <param name="actionType">Action type supported by the definition.</param>
        protected BlockPolicyActionBase(SecurityPolicyActionType actionType)
            : base(actionType)
        {
        }

		/// <summary>
		/// Writes the action data using the specified recorder.
		/// </summary>
		/// <param name="writer">A recorder to be used.</param>
		public override void Record(SecurityEventWriter writer)
		{
			base.Record(writer);

			writer.Write(Constants.Properties.BlockingPeriod, BlockingPeriod.TotalSeconds);
		}
    }
}

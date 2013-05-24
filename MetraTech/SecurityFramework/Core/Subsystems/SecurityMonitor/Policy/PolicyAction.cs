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
    /// Represents a base class for security policy action definitions.
    /// </summary>
    public abstract class PolicyAction
	{
		#region Properties

		/// <summary>
        /// Gets or internally sets a <see cref="SecurityPolicyActionType"/>.
		/// </summary>
		[SerializePropertyAttribute]
        public SecurityPolicyActionType ActionType
        {
            get;
            private set;
        }

		#endregion

		#region Constructor

		/// <summary>
        /// Creates an instance of the <see cref="PolicyAction"/> class.
        /// </summary>
        /// <param name="actionType">Action type supported by the definition.</param>
        protected PolicyAction(SecurityPolicyActionType actionType)
        {
            this.ActionType = actionType;
        }

		#endregion

		#region Public methods

		/// <summary>
		/// Writes the action data using the specified recorder.
		/// </summary>
		/// <param name="writer">A recorder to be used.</param>
		public virtual void Record(SecurityEventWriter writer)
		{
			if (writer == null)
			{
				throw new ArgumentNullException(Constants.Arguments.Writer);
			}

			writer.Write(Constants.Properties.SecurityPolicyActionTypeId, (int)ActionType);
		}

        /// <summary>
        /// Determines whether two object are equals.
        /// </summary>
        /// <param name="obj">An object to compare.</param>
        /// <returns>true if the objects are equals.</returns>
        public override bool Equals(object obj)
        {
            PolicyAction action = obj as PolicyAction;
            return action != null && action.ActionType == ActionType;
        }

        /// <summary>
        /// Gets a hash code for the object.
        /// </summary>
        /// <returns>An object's hash code.</returns>
        public override int GetHashCode()
        {
            return ActionType.GetHashCode();
		}

		#endregion
	}
}

/**************************************************************************
* Copyright 1997-2010 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech.SecurityFramework MAKES NO REPRESENTATIONS OR
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
* Viktor Grytsay <vgrytsay@MetraTech.SecurityFramework.com>
*
* 
***************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Serialization.Attributes;
using MetraTech.SecurityFramework.Core.Common.Configuration;

namespace MetraTech.SecurityFramework
{
	/// <summary>
	/// Base class for processor rules
	/// </summary>
	public abstract class RuleBase : IRule
	{
		uint _maxExecution;

		#region Protected properties

		/// <summary>
		/// Gets or sets id next rule if data handling throw exception.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
		protected string IdExceptionRule
		{
			get;
			set;
		}
		#endregion

		/// <summary>
		/// Gets or sets maximum execution count for current rule
		/// </summary>
		[SerializePropertyAttribute(IsRequired = false)]
		internal uint MaxExecution
		{
			get
			{
				return _maxExecution;
			}
			set
			{
				if (_maxExecution == 0)
				{
					_maxExecution = value;
				}
			}
		}

		[SerializePropertyAttribute(IsRequired = true)]
		public string Id
		{
			get;
			set;
		}

		public bool IsInitialize
		{
			get;
			protected set;
		}

		/// <summary>
		/// Handling the data in the current rule and return id next rule in chain of processor.
		/// </summary>
		public abstract string Execute(ApiInput input, ref ApiOutput output);

		/// <summary>
		/// Initializing members in current rule.
		/// </summary>
		public virtual void Initialize()
		{
			if (string.IsNullOrEmpty(Id))
			{
				string mes = string.Format("Rule id is null. Check configuration for processor subsystem.", Id);
				throw new ConfigurationException(mes);
			}

			if (string.IsNullOrEmpty(IdExceptionRule))
			{
				string mes = string.Format("IdExceptionRule for rule {0} is null or empty. Check configuration for processor subsystem.", Id);
				throw new ConfigurationException(mes);
			}
		}
	}
}

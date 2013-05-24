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
	/// This rule type uses for declaring end processor chain.
	/// </summary>
	public class StopRule : IRule
	{
		[SerializePropertyAttribute(IsRequired = true)]
		public string Id
		{
			get;
			set;
		}

		public string Execute(ApiInput input, ref ApiOutput output)
		{
			output = new ApiOutput(input);
			return "Stop!";
		}

		public void Initialize()
		{
			if (string.IsNullOrEmpty(Id))
			{
				string mes = string.Format("Rule id is null. Check configuration for processor subsystem.", Id);
				throw new ConfigurationException(mes);
			}
		}
	}
}

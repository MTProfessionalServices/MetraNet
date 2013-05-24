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

namespace MetraTech.SecurityFramework
{
	/// <summary>
	/// This interface contains declaration common properties and methods for all rule type.
	/// </summary>
	public interface IRule
	{
		/// <summary>
		/// Gets or sets id for current rule
		/// </summary>
		string Id
		{
			get;
			set;
		}

		/// <summary>
		/// Handling the data in the current rule and return id next rule in chain of processor.
		/// </summary>
		string Execute(ApiInput input, ref ApiOutput output);

		/// <summary>
		/// Initializing members in current rule.
		/// </summary>
		void Initialize();

	}
}

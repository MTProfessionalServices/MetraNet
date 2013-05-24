/**************************************************************************
* Copyright 1997-2010 by MetraTech.SecurityFramework
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech.SecurityFramework MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech.SecurityFramework MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech.SecurityFramework, and USER
* agrees to preserve the same.
*
* Authors: Viktor Grytsay
*
* <vgrytsay@MetraTech.SecurityFramework.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.SecurityFramework.Common.Configuration.Logger
{
	/// <summary>
	/// This interface is driver for working with repository changes in configuration subsystems.
	/// </summary>
	public interface IConfigurationLogProvider
	{
		/// <summary>
		/// Gets or sets path to repository changes.
		/// </summary>
		string ConnectionString
		{
			get;
			set;
		}

		/// <summary>
		/// Executing actions with the repository.
		/// </summary>
		/// <param name="updateParameters">A collection of configuration changes.</param>
		void Execute(ICollection<ChangedParams> updateParameters);
	}
}

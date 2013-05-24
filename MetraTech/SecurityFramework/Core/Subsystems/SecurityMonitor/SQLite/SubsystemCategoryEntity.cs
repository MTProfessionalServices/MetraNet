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

namespace MetraTech.SecurityFramework.Core.SecurityMonitor.SQLite
{
	/// <summary>
	/// Represents a row from the SubsystemCategory database table.
	/// </summary>
	internal class SubsystemCategoryEntity
	{
		/// <summary>
		/// Gets or sets a row ID.
		/// </summary>
		internal long Id
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets a category's subsystem name.
		/// </summary>
		internal string SubsystemName
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets a category name.
		/// </summary>
		internal string Name
		{
			get;
			set;
		}
	}
}

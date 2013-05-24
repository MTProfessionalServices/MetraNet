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
	/// Contains information about changes in the subsystem configuration.
	/// </summary>
	public class ChangedParams
	{
		/// <summary>
		/// Gets or sets id for changes.
		/// </summary>
		public Guid Id
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets id subsystem in which the changes occurred.
		/// </summary>
		public Guid IdSubsystem
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets date of change.
		/// </summary>
		public DateTime UpdateDate
		{
			get;
			set;
		}

		//TODO: developed the storage format changes
	}
}

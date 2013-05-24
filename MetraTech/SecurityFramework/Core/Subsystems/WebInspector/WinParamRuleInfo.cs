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
using System.Text;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.WebInspector
{
	public class WinParamRuleInfo
	{
		#region Public properties

		[SerializeProperty]
		public string Param
		{
			get;
			set;
		}

		[SerializeProperty]
		public bool Exclude
		{
			get;
			set;
		}

		[SerializeProperty]
		public bool ExcludeAll
		{
			get;
			set;
		}

		[SerializeProperty]
		public WinRuleInfo Rule
		{
			get;
			set;
		}

		#endregion

		#region Constructors

		public WinParamRuleInfo()
		{
			Param = "="; //this means apply to all params in a given resource
			Exclude = false;
			ExcludeAll = false;
		}

		#endregion
	}
}


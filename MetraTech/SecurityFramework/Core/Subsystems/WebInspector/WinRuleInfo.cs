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
    public class WinRuleInfo
		{
			#region Public properties

			[SerializeProperty]
			public string Id
			{
				get;
				set;
			}

			[SerializeProperty]
			public string Subsystem
			{
				get;
				set;
			}

			[SerializeProperty]
			public string Engine
			{
				get;
				set;
			}

			[SerializeCollection]
			public Dictionary<string, string> Params
			{
				get;
				set;
			}


			#endregion

			#region Constructors

			public WinRuleInfo()
			{
				Id = "<missing>";
        Subsystem = "<missing>";
        Engine = "<missing>";
				Params = new Dictionary<string, string>();
			}

			#endregion
    }
}



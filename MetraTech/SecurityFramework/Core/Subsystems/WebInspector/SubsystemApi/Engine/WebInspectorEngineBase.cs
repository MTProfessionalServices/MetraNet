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
using MetraTech.SecurityFramework.WebInspector;

namespace MetraTech.SecurityFramework
{
	public abstract class WebInspectorEngineBase : EngineBase
	{
		[SerializeNested(DefaultType = typeof(WinPropertiesInfo))]
		public WinPropertiesInfo InspectorInfo
		{
			get;
			set;
		}

		protected internal MetraTech.SecurityFramework.WebInspector.WebInspector Inspector
		{
			get;
			set;
		}

		protected override Type SubsystemType
		{
			get
			{
				return typeof(MetraTech.SecurityFramework.WebInspectorSubsystem);
			}
		}

		protected WebInspectorEngineCategory Category { get; private set; }

		public override void Initialize()
		{
            if (InspectorInfo == null)
			{
				throw new ArgumentNullException(string.Format("Configuration for WebInspector {0} is empty.", Id));
			}

			Inspector = new WebInspector.WebInspector();
			Inspector.Initialize(InspectorInfo);

			base.Initialize();
		}

		protected WebInspectorEngineBase(WebInspectorEngineCategory category)
		{
			Category = category;
			this.CategoryName = Convert.ToString(Category);
		}

		protected override ApiOutput ExecuteInternal(ApiInput input)
		{
			if (input == null)
			{
				throw new ArgumentNullException(string.Format("Input parameter in WebInspector {0} is null.", Id));
			}

			return new ApiOutput(input);
		} 
	}
}

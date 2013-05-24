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
using Microsoft.Practices.EnterpriseLibrary.Logging.Configuration;
using System.Diagnostics;
using System.Linq.Expressions;

namespace MetraTech.SecurityFramework.MTLogging.Configuration
{
	/// <summary>
	/// Provides a layer for trace listener factory.
	/// </summary>
	internal sealed class MetraTechLogTraceListenerData : TraceListenerData
	{
		/// <summary>
		/// Creates an instance of the <see cref="MetraTechLogTraceListenerData"/> class.
		/// </summary>
		public MetraTechLogTraceListenerData()
			: base(typeof(MetraTechLogTraceListener))
		{
		}

		/// <summary>
		/// Gets the creation expression used to produce a Microsoft.Practices.EnterpriseLibrary.Common.Configuration.ContainerModel.TypeRegistration
		/// during Microsoft.Practices.EnterpriseLibrary.Logging.Configuration.TraceListenerData.GetRegistrations().
		/// </summary>
		/// <returns>A <see cref="Expression"/> that creates a <see cref="MetraTechLogTraceListener"/>.</returns>
		protected override Expression<Func<TraceListener>> GetCreationExpression()
		{
			return () => new MetraTechLogTraceListener();
		}
	}
}

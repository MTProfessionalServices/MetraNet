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
using System.Diagnostics;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Core.Common.Logging.Configuration
{
	/// <summary>
	/// Represents logging event listener base configuration.
	/// </summary>
	public class TraceListenerConfiguration : TypeConfiguration
	{
		/// <summary>
		/// Gets or sets an assembly or fully qualifiet of the listener's data type name.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
		public string ListenerDataType
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets a source level for <see cref="EventTypeFilter"/>.EventType.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
		public SourceLevels Filter
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets a name of the formatter.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = false)]
		public string Formatter
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets an indent level.
		/// </summary>
		[SerializePropertyAttribute]
		public int IndentLevel
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets an indent size.
		/// </summary>
		[SerializePropertyAttribute]
		public int IndentSize
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets a value indicating whether to indent the output.
		/// </summary>
		[SerializePropertyAttribute]
		public bool NeedIndent
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets a comma-separated list of the trace oprions.
		/// </summary>
		[SerializePropertyAttribute]
		public string TraceOutputOptions
		{
			get;
			set;
		}
	}
}

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
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Core.Common.Configuration
{
	/// <summary>
	/// Contains settings to be used by all framework parts.
	/// </summary>
	internal class SecurityFrameworkSettings
	{
		private const string ConfigurationNotFound = "Framework general configuration type is not specified.";

		private static SecurityFrameworkSettings _configuration;

		/// <summary>
		/// Gets or sets whether auto-monitoring for <see cref="BadInputDataException"/> is enabled.
		/// </summary>
		[SerializePropertyAttribute]
		public bool AutoMonitorExceptions
		{
			get;
			set;
		}

		/// <summary>
		/// Gets or sets a name of the execution context provider type.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
		public string ExecutionContextTypeName
		{
			get;
			set;
		}

	    /// <summary>
	    /// Gets or sets a a value indicating to use the performance conters to monitor the SF's performance.
	    /// </summary>
	    [SerializePropertyAttribute(IsRequired = false, DefaultValue = false)]
	    public bool UsePerformanceCounters
	    {
	      get;
	      set;
	    }

		/// <summary>
		/// Gets the current set of the common settings.
		/// </summary>
		public static SecurityFrameworkSettings Current
		{
			get
			{
				if (_configuration == null)
				{
					_configuration = SecurityKernel.GetSubsystem<SecurityFrameworkSettings>();

					if (_configuration == null)
					{
						throw new ConfigurationException(ConfigurationNotFound);
					}
				}

				return _configuration;
			}
		}
	}
}

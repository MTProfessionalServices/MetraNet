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
using MetraTech.SecurityFramework.Core.Common.Configuration;

namespace MetraTech.SecurityFramework
{
	/// <summary>
	/// Contains the properties to determine the next rule.
	/// </summary>
	public class Case
	{
		private IEngine _resultHandler = null;
		private bool _isInitializeHandler = false;

		/// <summary>
		/// Gets or sets engine id for result handlers.
		/// </summary>
		[SerializePropertyAttribute(MappedName = "IdEngine")]
		private string IdEngine
		{ 
			get; 
			set;
		}

		/// <summary>
		/// Gets or sets subsystem name for result handlers engine.
		/// </summary>
		[SerializePropertyAttribute(MappedName = "Subsystem")]
		private string Subsystem 
		{
			get;
			set; 
		}

		/// <summary>
		/// Gets or sets engine for result handlers.
		/// </summary>
		internal IEngine ResultHandler 
		{
			get
			{
				if (!_isInitializeHandler)
				{
					InitializeHandler();
				}
				
				return _resultHandler;
			}
		}

		/// <summary>
		/// Gets or sets regular expression for comparison with the result of data  processing.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
		internal string CompareValue { get; set; }

		/// <summary>
		/// Gets or sets rule id. Works if the malicious code is detected.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
		internal string IdNextRule { get; set; }

		/// <summary>
		/// Gets or sets comparison type.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
		internal OperationType OperationType { get; set; }

		internal void InitializeHandler()
		{
			if (!string.IsNullOrEmpty(IdEngine) && !string.IsNullOrEmpty(Subsystem))
			{
				if (SecurityKernel.IsInitialized() == false)
				{
					string msg = "SecurityKernel.Loader is not initialized. For more information, see the error log";
					throw new ConfigurationException(msg);
				}

				// If subsystem is not specified, then assume that is not specified and the engine.
				if (!String.IsNullOrEmpty(Subsystem))
				{
					SubsystemBase sb = SecurityKernel.GetSubsystem(Subsystem) as SubsystemBase;

					if (sb == null)
						throw new ConfigurationException(String.Format("Subsystem {0} is not declared.", Subsystem));

					if (String.IsNullOrEmpty(IdEngine))
						throw new ConfigurationException("Engine handler id is not declared.");

					_resultHandler = sb.Api.GetEngine(IdEngine);

					if (_resultHandler == null)
						throw new ConfigurationException(string.Format("Engine {0} in subsystem {1} is not declared.",
																		IdEngine, Subsystem));

					_isInitializeHandler = true;
				}
			}
		}
	}
}

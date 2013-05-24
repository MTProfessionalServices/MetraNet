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
	/// This rule combines functional of SwitchRule and SequenceRule.
	/// </summary>
	public class SwitchRuleEx : SwitchRule
	{
		private IEngine _currentEngine;
		private bool _engineIsInitialize = false;

		/// <summary>
		/// Contains current id engine. This engine is handler for input data. 
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true, MappedName = "IdEngine")]
		private string IdEngine
		{
			get;
			set;
		}

		/// <summary>
		/// Contains subsystem name for current engine.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true, MappedName = "Subsystem")]
		private string Subsystem
		{
			get;
			set;
		}

		/// <summary>
		/// Initializing members in current rule.
		/// </summary>
		public override void Initialize()
		{
			base.Initialize();

			if (string.IsNullOrEmpty(Subsystem))
			{
				throw new ConfigurationException(string.Format("Subsystem id for rule {0} is not declared.", Id));
			}

			if (string.IsNullOrEmpty(IdEngine))
			{
				throw new ConfigurationException(string.Format("Engine id for rule {0} is not declared.", Id));
			}

			IsInitialize = true;
		}

		/// <summary>
		/// Handling the data in the current rule and return id next rule in chain of processor.
		/// </summary>
		public override string Execute(ApiInput input, ref ApiOutput output)
		{
			if (!_engineIsInitialize)
			{
				InitializeEngine();
			}

			string idNextRule = this.DefaultIdRule;

			try
			{
				output = _currentEngine.Execute(input);

                idNextRule = base.ExecuteCases(new ApiInputCase(input, output), ref output);
			}
			catch (Exception e)
			{
				idNextRule = this.IdExceptionRule;
				input.Exceptions.Add(e);
				output = new ApiOutput(input);
			}

			return idNextRule;
		}

		private void InitializeEngine()
		{
			if (SecurityKernel.IsInitialized() == false)
			{
				string msg = "SecurityKernel.Loader is not initialized. For more information, see the error log";
				throw new ConfigurationException(msg);
			}

			SubsystemBase sb = SecurityKernel.GetSubsystem(Subsystem) as SubsystemBase;

			if (sb == null)
				throw new ConfigurationException(String.Format("Subsystem {0} is not declared.", Subsystem));

			try
			{
				_currentEngine = sb.Api.GetEngine(IdEngine);
				_engineIsInitialize = true;
			}
			catch (SubsystemInputParamException exc)
			{
				throw new ConfigurationException(string.Format("Engine {0} in subsystem {1} is not declared.", IdEngine, Subsystem), exc);
			}
		}
	}
}

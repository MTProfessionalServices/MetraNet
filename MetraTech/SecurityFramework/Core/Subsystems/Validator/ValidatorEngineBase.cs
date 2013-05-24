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

namespace MetraTech.SecurityFramework.Core.Validator
{
	/// <summary>
	/// Provides a base class for all engines in the Validator subsystem.
	/// </summary>
	public abstract class ValidatorEngineBase : EngineBase
	{
		#region Propertiers

		/// <summary>
		/// Gets a type of the subsystem the engine belongs to.
		/// </summary>
		protected override Type SubsystemType
		{
			get
			{
				return typeof(MetraTech.SecurityFramework.Validator);
			}
		}

		/// <summary>
		/// Validator category enum
		/// </summary>
		protected ValidatorEngineCategory Category
		{
			get;
			private set;
		}

		#endregion

		#region Constructor

		protected ValidatorEngineBase(ValidatorEngineCategory category)
		{
			Category = category;
			this.CategoryName = Convert.ToString(Category);
		}

		#endregion 

		#region Protected methods

		/// <summary>
		/// Performs data processing. Validates for null and empty strings.
		/// </summary>
		/// <param name="input">Data to be processed.</param>
		/// <returns>Processing result.</returns>
		protected override ApiOutput ExecuteInternal(ApiInput input)
		{
			if (input == null || string.IsNullOrEmpty(input.ToString()))
			{
				throw new NullInputDataException(SubsystemName, CategoryName, SecurityEventType.InputDataProcessingEventType);
			}

			return ValidateInternal(input);
		}

		/// <summary>
		/// Validates input data.
		/// </summary>
		/// <param name="inputA data to be validated."></param>
		/// <returns>A validation result.</returns>
		protected abstract ApiOutput ValidateInternal(ApiInput input);

		#endregion
	}
}

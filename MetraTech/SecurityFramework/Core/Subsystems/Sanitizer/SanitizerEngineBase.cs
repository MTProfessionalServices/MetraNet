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
* Maksym Sukhovarov <msukhovarov@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace MetraTech.SecurityFramework.Core.Sanitizer
{
	/// <summary>
	/// Provides a base class for all engines in the Sanitizer subsystem.
	/// </summary>
	public abstract class SanitizerEngineBase : EngineBase
	{
        #region Properties

		/// <summary>
		/// Gets or sets an engine's category.
		/// </summary>
		protected virtual SanitizerEngineCategory Category
		{
			get;
			set;
		}

		/// <summary>
		/// Gets a type of the subsystem the engine belongs to.
		/// </summary>
		protected override Type SubsystemType
		{
			get
			{
				return typeof(MetraTech.SecurityFramework.Sanitizer);
			}
		}

		#endregion

		#region Constructors

		/// <summary>
		/// Creates an instance of the engine for the specified category.
		/// </summary>
		/// <param name="category">An engine's category.</param>
		protected SanitizerEngineBase(SanitizerEngineCategory category)
		{
			Category = category;
			this.CategoryName = Convert.ToString(Category);
		}

		#endregion

        #region Protected methods

        /// <summary>
		/// Checks an input value for null and empty string and performs a sanitizer.
		/// </summary>
		/// <param name="input">An input value.</param>
		/// <returns>A decoded value.</returns>
		protected override ApiOutput ExecuteInternal(ApiInput input)
		{
			if (input == null)
			{
				throw new NullInputDataException(SubsystemName, CategoryName, SecurityEventType.InputDataProcessingEventType);
			}

			return SanitizeInternal(input);
		}

		/// <summary>
		/// Performs a sanitizing.
		/// </summary>
		/// <param name="input">An input value.</param>
		/// <returns>A sanitized value.</returns>
		protected abstract ApiOutput SanitizeInternal(ApiInput input);

		#endregion
	}
}


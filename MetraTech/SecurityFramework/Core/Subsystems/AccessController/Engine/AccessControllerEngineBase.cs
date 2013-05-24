/**************************************************************************
* Copyright 1997-2011 by MetraTech.SecurityFramework
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech.SecurityFramework MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech.SecurityFramework MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech.SecurityFramework, and USER
* agrees to preserve the same.
*
* Authors: Viktor Grytsay
*
* <vgrytsay@MetraTech.SecurityFramework.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using MetraTech.SecurityFramework.Core.Common.Configuration;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework
{
	/// <summary>
	/// Provides a base class for all engines in the AccessController subsystem.
	/// </summary>
	public abstract class AccessControllerEngineBase : EngineBase
	{
		#region Properties

		/// <summary>
		/// Gets a type of the subsystem the engine belongs to.
		/// </summary>
		protected override Type SubsystemType
		{
			get
			{
				return typeof(MetraTech.SecurityFramework.AccessController);
			}
		}

		/// <summary>
		/// AccessController category enum
		/// </summary>
		protected AccessControllerEngineCategory Category
		{
			get;
			private set;
		}

		#endregion

		#region Constructors
		
		public AccessControllerEngineBase(AccessControllerEngineCategory category)
		{
			Category = category;
			this.CategoryName = Convert.ToString(Category);
		}

		#endregion

		#region Public methods
		
		/// <summary>
		/// Initializing members in current object.
		/// </summary>
		public override void Initialize()
		{
			base.Initialize();
		}

		#endregion

		#region Protected methods

		/// <summary>
		/// Performs data processing. Validates for null and empty strings.
		/// </summary>
		/// <param name="input">Data to be processed.</param>
		/// <returns>A access  description to resource.</returns>
		protected override ApiOutput ExecuteInternal(ApiInput input)
		{
			if (input == null || string.IsNullOrEmpty(input.ToString()))
			{
				throw new NullInputDataException(SubsystemName, CategoryName, SecurityEventType.InputDataProcessingEventType);
			}

			return AccesControllerExecuteInternal(input);
		}

		/// <summary>
		/// Validates input data.
		/// </summary>
		/// <param name="inputA data to be validated."></param>
		/// <returns>A validation result.</returns>
		protected abstract ApiOutput AccesControllerExecuteInternal(ApiInput input);

		#endregion
	}
}

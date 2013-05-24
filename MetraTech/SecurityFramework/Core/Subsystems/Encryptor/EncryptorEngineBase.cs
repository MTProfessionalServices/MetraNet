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

namespace MetraTech.SecurityFramework.Core.Encryptor
{
	/// <summary>
	/// Provides a base class for Encryptor subsystem engine classes.
	/// </summary>
	public abstract class EncryptorEngineBase : EngineBase
	{
		#region Properties

		/// <summary>
		/// Gets or sets an engine's category.
		/// </summary>
		protected virtual EncryptorEngineCategory Category
		{
			get;
			set;
		}

		/// <summary>
		/// Gets a type of the subsystem the engine belongs to.
		/// </summary>
		/// <remarks>Always returns <see cref="MetraTech.SecurityFramework.Encryptor"/>.</remarks>
		protected override Type SubsystemType
		{
			get
			{
				return typeof(MetraTech.SecurityFramework.Encryptor);
			}
		}

		#endregion

		#region Constructor

		/// <summary>
		/// Creates an instance of the <see cref="EncryptorEngineBase"/> with the specified category.
		/// </summary>
		/// <param name="category">An engin's category.</param>
		public EncryptorEngineBase(EncryptorEngineCategory category)
		{
			Category = category;
			this.CategoryName = Convert.ToString(Category);
		}

		#endregion
	}
}

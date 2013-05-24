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
using System.Text.RegularExpressions;
using MetraTech.SecurityFramework.Core.Common;

namespace MetraTech.SecurityFramework.Core.Validator
{
	/// <summary>
	/// Provides validation for hexadecimal numbers.
	/// </summary>
	internal sealed class HexStringValidatorEngine : ValidatorEngineBase
	{
		#region Constants

		private const string HexNumberInvalid = "Input string contains invalid character(s)";

		#endregion

		#region Private fields

		private static readonly Regex _hexMatcher = new Regex("^[0-9a-fA-F]+$", RegexOptions.Compiled);

		#endregion

		#region Properties

		/// <summary>
		/// Gets a type of output value.
		/// </summary>
		/// <remarks>Always returns <see cref="String"/>.</remarks>
		public Type ResultType
		{
			get
			{
				return typeof(string);
			}
		}

		#endregion

		#region Constructor

		/// <summary>
		/// Creates an instance of the <see cref="HexStringValidatorEngine"/> class.
		/// </summary>
		public HexStringValidatorEngine()
			: base(ValidatorEngineCategory.HexString)
		{
		}

		#endregion

		#region Protected methods

		/// <summary>
		/// Performs the validation of input value.
		/// </summary>
		/// <param name="input">A data to be validated.</param>
		/// <returns>Validation result.</returns>
		/// <exception cref="ValidatorInputDataException">When any validation problem found.</exception>
		protected override ApiOutput ValidateInternal(ApiInput input)
		{
			// An input value passed the validation for null to this point.
			string inputStr = input.ToString();

			if (!_hexMatcher.IsMatch(inputStr))
			{
				throw new ValidatorInputDataException(ExceptionId.Validator.HexNumberInvalid, Category, HexNumberInvalid, inputStr, HexNumberInvalid);
			}

			return new ApiOutput(inputStr);
		}

		#endregion
	}
}

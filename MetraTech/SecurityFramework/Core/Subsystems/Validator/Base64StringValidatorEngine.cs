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
using MetraTech.SecurityFramework.Serialization.Attributes;
using MetraTech.SecurityFramework.Core.Common;

namespace MetraTech.SecurityFramework.Core.Validator
{
	/// <summary>
	/// Provides validation for BASE 64 encoded data.
	/// </summary>
	internal sealed class Base64StringValidatorEngine : ValidatorEngineBase
	{
		#region Constants

		private const string Bas64StringInvalid = "BASE 64 encoded data has invalid format.";
		private const string SpacesNotAllowed = "Spaces are disallowed for BASE 64 encoded data.";
		private const string InvalidLength = "BASE 64 encoded data has invalid invalid length";
		private const string InvalidCharacter = "Invalid character(s) found";

		private static readonly Regex _b64Chars = new Regex("^[0-9a-zA-Z+/]+(\\={0,2})$", RegexOptions.Compiled);

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

		/// <summary>
		/// If this property is true, input value is decoded from Base64
		/// </summary>
		[SerializePropertyAttribute(IsRequired = false, DefaultValue = false)]
		private bool DoDecode
		{
			get;
			set;
		}

		#endregion

		#region Constructor

		/// <summary>
		/// Creates an instance of the <see cref="Base64StringValidatorEngine"/> class.
		/// </summary>
		public Base64StringValidatorEngine()
			: base(ValidatorEngineCategory.Base64String)
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
			string inputStr = input.ToString().Trim();

			if (string.IsNullOrEmpty(inputStr))
			{
				throw new ValidatorInputDataException(
					ExceptionId.Validator.Base64StringInvalid, ValidatorEngineCategory.Base64String, Bas64StringInvalid, input.ToString(), SpacesNotAllowed);
			}

			int inputLen = inputStr.Length;
			int left = inputLen % 4;
			if (left != 0)
			{
				throw new ValidatorInputDataException(
					ExceptionId.Validator.Base64StringInvalid, ValidatorEngineCategory.Base64String, Bas64StringInvalid, input.ToString(), InvalidLength);
			}

			if (!_b64Chars.IsMatch(inputStr))
			{
				throw new ValidatorInputDataException(
					ExceptionId.Validator.Base64StringInvalid, ValidatorEngineCategory.Base64String, Bas64StringInvalid, input.ToString(), InvalidCharacter);
			}

			string result = DoDecode ? 
							SecurityKernel.Decoder.Api.ExecuteDefaultByCategory(DecoderEngineCategory.Base64.ToString(), inputStr) :
							inputStr;

			return new ApiOutput(result);
		}

		#endregion
	}
}

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
* Kyle C. Quest <kquest@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
using MetraTech.SecurityFramework.Core.Common;

namespace MetraTech.SecurityFramework.Core.Validator
{
	/// <summary>
	/// Provides validation for credit card numbers.
	/// </summary>
	internal sealed class CcnStringValidatorEngine : ValidatorEngineBase
	{
		#region Constants

		private const string CcnLengthInvalid = "Credit card number length invalid";
		private const string CcnContainIllegalCharacter = "Illegal character in credit card number";
		private const string CcnValidationFailed = "Credit card number is invalid";

		#endregion

		#region Private fields

		private static Regex _ccnMatcher = new Regex("^(?:\\d[ -]*?){13,30}$", RegexOptions.Compiled);

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
		/// Creates an instance of the <see cref="CcnStringValidatorEngine"/> class.
		/// </summary>
		public CcnStringValidatorEngine()
			: base(ValidatorEngineCategory.CreditCardString)
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
			string inputStr = input.ToString().Trim();

			int inputLen = inputStr.Length;
			if (inputLen < 13)
			{
				throw new ValidatorInputDataException(
					ExceptionId.Validator.CcnLengthInvalid, Category, CcnLengthInvalid, inputStr, CcnLengthInvalid);
			}

			StringBuilder ccn = new StringBuilder();
			for (int i = 0; i < inputLen; i++)
			{
				switch (inputStr[i])
				{
					case '-':
					case ' ':
						break;
					default:
						ccn.Append(inputStr[i]);
						break;
				}
			}

			string ccnStr = ccn.ToString();

			if (ccnStr.Length < 13 || ccnStr.Length > 16)
			{
				throw new ValidatorInputDataException(ExceptionId.Validator.CcnLengthInvalid, Category, CcnLengthInvalid, inputStr, CcnLengthInvalid);
			}

			if (!_ccnMatcher.IsMatch(ccnStr))
			{
				throw new ValidatorInputDataException(ExceptionId.Validator.CcnIllegalCharacter, Category, CcnContainIllegalCharacter, inputStr, CcnContainIllegalCharacter);
			}

			if (!IsValidCcnCheckSum(ccnStr))
			{
				throw new ValidatorInputDataException(ExceptionId.Validator.CcnInvalidNumber, Category, CcnValidationFailed, inputStr, CcnValidationFailed);
			}

			return new ApiOutput(ccnStr);
		}

		#endregion

		#region Private methods

		private bool IsValidCcnCheckSum(string input)
		{
			int sum = 0;
			int digit = 0;
			bool timesTwo = false;
			for (int i = input.Length - 1; i >= 0; i--)
			{
				digit = Convert.ToByte(input.Substring(i, 1), CultureInfo.InvariantCulture);
				if (timesTwo)
				{
					int addend = digit * 2;
					if (addend > 9)
					{
						addend -= 9;
					}

					sum += addend;
				}
				else
				{
					sum += digit;
				}

				timesTwo = !timesTwo;
			}

			return (sum % 10) == 0;
		}

		#endregion
	}
}

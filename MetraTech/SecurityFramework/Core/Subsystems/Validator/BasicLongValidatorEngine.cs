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
using MetraTech.SecurityFramework.Common;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Core.Validator
{
	/// <summary>
	/// Provides a basic validation for 64 bits integer numbers.
	/// </summary>
	internal sealed class BasicLongValidatorEngine : ValidatorEngineBase
	{
		#region Constants

		private const string InputNonIntegerValue = "Input string does not represent a long integer.";
		private const string UnableConvertInputValue = "Unable to convert an input value to long integer number.";

		private const string InputNotInRange = "Input integer is not in range.";
		private const string NotInRangeReasonFormat = " minValue = {0}, maxValue = {1}; {0} < inputValue < {1}";

		#endregion

		#region Private fields

		private static Type _type = typeof(long);

		#endregion

		#region Properties

		/// <summary>
		/// Gets or sets a min allowed value.
		/// </summary>
		[SerializePropertyAttribute]
		public long Min
		{
			get;
			private set;
		}

		/// <summary>
		/// Gets or sets a max allowed value.
		/// </summary>
		[SerializePropertyAttribute]
		public long Max
		{
			get;
			private set;
		}

		/// <summary>
		/// Gets or sets a value indicating that the validator has to try to recognize input data format.
		/// </summary>
		/// <remarks>Default value is true.</remarks>
		[SerializePropertyAttribute]
		public bool DoFormatAutoDetect
		{
			get;
			private set;
		}

		/// <summary>
		/// Gets or sets a value indicating the validator expects for input data in hexadecimal format.
		/// </summary>
		[SerializePropertyAttribute]
		public bool ExpectHexFormat
		{
			get;
			private set;
		}

		/// <summary>
		/// Gets a type of output value.
		/// </summary>
		/// <remarks>Always returns <see cref="Int64"/>.</remarks>
		public Type ResultType
		{
			get
			{
				return _type;
			}
		}

		#endregion

		#region Constructor

		/// <summary>
		/// Creates an instance of the <see cref="BasicLongValidatorEngine"/> class.
		/// </summary>
		public BasicLongValidatorEngine()
			: base(ValidatorEngineCategory.BasicLongint)
		{
			DoFormatAutoDetect = true;
			Min = long.MinValue;
			Max = long.MaxValue;
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

			long var = ConvertToLong(inputStr);

			if (var < Min || var > Max)
			{
				throw new ValidatorInputDataException(
						Common.ExceptionId.Validator.InputIntegerNotInRange,
						Category,
						InputNotInRange,
						inputStr,
						string.Format(NotInRangeReasonFormat, Min, Max));
			}

			ApiOutput result = new ApiOutput(var);

			return result;
		}

		#endregion

		#region Private methods

		private long ConvertToLong(string inputStr)
		{
			if (inputStr.StartsWith("+") || inputStr.StartsWith("-0"))
			{
				throw new ValidatorInputDataException(
					Common.ExceptionId.Validator.InputValueIsNotInteger, Category, InputNonIntegerValue, inputStr, UnableConvertInputValue);
			}

			long var;
			if (ExpectHexFormat)
			{
				try
				{
					if (inputStr.Length >= 2 &&
						(inputStr.StartsWith(Constants.Validation.HexNumberPrefix1) || inputStr.StartsWith(Constants.Validation.HexNumberPrefix2)))
					{
						inputStr = inputStr.Substring(2);
					}

					var = Convert.ToInt64(inputStr, 16);
				}
				catch (Exception ex)
				{
					throw new ValidatorInputDataException(
						Common.ExceptionId.Validator.InputValueIsNotInteger, Category, InputNonIntegerValue, inputStr, UnableConvertInputValue, ex);
				}
			}
			else if (DoFormatAutoDetect)
			{
				try
				{
					if (inputStr.Length >= 2 &&
						(inputStr.StartsWith(Constants.Validation.HexNumberPrefix1) || inputStr.StartsWith(Constants.Validation.HexNumberPrefix2)))
					{
						inputStr = inputStr.Substring(2);
						var = Convert.ToInt64(inputStr, 16);
					}
					else if (inputStr.Length >= 2 && inputStr.StartsWith(Constants.Validation.OctalNumberPrefix))
					{
						inputStr = inputStr.Substring(2);
						var = Convert.ToInt64(inputStr, 8);
					}
					else
					{
						var = Convert.ToInt64(inputStr, 10);
					}
				}
				catch (Exception ex)
				{
					throw new ValidatorInputDataException(
						Common.ExceptionId.Validator.InputValueIsNotInteger, Category, InputNonIntegerValue, inputStr, UnableConvertInputValue, ex);
				}
			}
			else if (!long.TryParse(inputStr, out var))
			{
				throw new ValidatorInputDataException(
					Common.ExceptionId.Validator.InputValueIsNotInteger, Category, InputNonIntegerValue, inputStr, UnableConvertInputValue);
			}

			return var;
		}

		#endregion
	}
}

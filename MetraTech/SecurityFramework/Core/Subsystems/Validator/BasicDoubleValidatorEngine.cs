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
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Core.Validator
{
	/// <summary>
	/// Provides a basic validation for double precision floating poit numbers.
	/// </summary>
	internal sealed class BasicDoubleValidatorEngine : ValidatorEngineBase
	{
		#region Constants

		private const string InputNonDoubleValue = "Input string does not represent a double.";
		private const string UnableConvertInputValue = "Unable to convert an input value to double precision number.";

		private const string InputNotInRange = "Input double is not in range.";
		private const string NotInRangeReasonFormat = " minValue = {0}, maxValue = {1}; {0} < inputValue < {1}";

		#endregion

		#region Properties

		/// <summary>
		/// Gets or sets a max allowed value.
		/// </summary>
		[SerializePropertyAttribute]
		public double Max
		{
			get;
			private set;
		}

		/// <summary>
		/// Gets or sets a min allowed value.
		/// </summary>
		[SerializePropertyAttribute]
		public double Min
		{
			get;
			private set;
		}

		/// <summary>
		/// Gets a type of output value.
		/// </summary>
		/// <remarks>Always returns <see cref="Double"/>.</remarks>
		public Type ResultType
		{
			get
			{
				return typeof(double);
			}
		}

		#endregion

		#region Constructor

		/// <summary>
		/// Creates an instance of the <see cref="BasicDoubleValidatorEngine"/> class.
		/// </summary>
		public BasicDoubleValidatorEngine()
			: base(ValidatorEngineCategory.BasicDouble)
		{
			Max = double.MaxValue;
			Min = double.MinValue;
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

			if (inputStr.StartsWith("+") || inputStr.Equals("-0"))
			{
				throw new ValidatorInputDataException(
						Common.ExceptionId.Validator.InputValueIsNotDouble, Category, InputNonDoubleValue, inputStr, UnableConvertInputValue);
			}

			double var;
			if (!double.TryParse(inputStr, out var))
			{
				throw new ValidatorInputDataException(Common.ExceptionId.Validator.InputValueIsNotDouble, Category, InputNonDoubleValue, inputStr, UnableConvertInputValue);
			}

			if (var < Min || var > Max)
			{
				throw new ValidatorInputDataException(
						Common.ExceptionId.Validator.InputDoubleNotInRange, Category, InputNotInRange, inputStr, string.Format(NotInRangeReasonFormat, Min, Max));
			}

			ApiOutput result = new ApiOutput(var);

			return result;
		}

		#endregion
	}
}

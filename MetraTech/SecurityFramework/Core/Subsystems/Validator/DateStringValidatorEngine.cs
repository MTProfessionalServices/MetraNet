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
using System.Globalization;
using MetraTech.SecurityFramework.Core.Common;

namespace MetraTech.SecurityFramework.Core.Validator
{
	/// <summary>
	/// Provides validation for date and time string.
	/// </summary>
	internal sealed class DateStringValidatorEngine : ValidatorEngineBase
	{
		#region Constants

		private const string DateStringFormatInvalid = "Invalid date/time format";

		#endregion

		#region Properties

		/// <summary>
		/// Gets a type of output value.
		/// </summary>
		/// <remarks>Always returns <see cref="DateTime"/>.</remarks>
		public Type ResultType
		{
			get
			{
				return typeof(DateTime);
			}
		}

		#endregion

		#region Constructor

		/// <summary>
		/// Creates an instance of the <see cref="DateStringValidatorEngine"/> class.
		/// </summary>
		public DateStringValidatorEngine()
			: base(ValidatorEngineCategory.DateString)
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
			string inputStr = input.ToString();

			DateTime result;
			if (!DateTime.TryParse(inputStr, CultureInfo.CurrentCulture, DateTimeStyles.AllowWhiteSpaces, out result))
			{
				throw new ValidatorInputDataException(
					ExceptionId.Validator.DateTimeStringInvalid, Category, DateStringFormatInvalid, inputStr, DateStringFormatInvalid);
			}

			return new ApiOutput(result);
		}

		#endregion
	}
}

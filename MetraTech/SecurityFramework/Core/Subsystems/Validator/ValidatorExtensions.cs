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
namespace MetraTech.SecurityFramework
{
    public static class ValidatorExtensions
    {
		/// <summary>
		/// Checks an input data with the specified validator.
		/// </summary>
		/// <param name="str">A data to be validated.</param>
		/// <param name="engineId">An ID of the engine to be used for validation.</param>
		/// <returns>The validation result.</returns>
		/// <exception cref="NullInputDataException">If an input data is empty string (for some engines).</exception>
		/// <exception cref="ValidatorInputDataException">If input data did not pass the validation.</exception>
		public static object ValidateWithEngine(this string str, string engineId)
        {
            return SecurityKernel.Validator.Api.Execute(engineId, new ApiInput(str)).Value;
        }

		/// <summary>
		/// Check whether input string represents a integer and converts it when yes.
		/// </summary>
		/// <param name="str">A data to be validated.</param>
		/// <returns>Integer value.</returns>
		/// <exception cref="NullInputDataException">If an input data is empty string.</exception>
		/// <exception cref="ValidatorInputDataException">If input data does not represent an integer number.</exception>
		public static int ValidateAsBasicInt(this string str)
        {
            return SecurityKernel.Validator.Api.ExecuteDefaultByCategory(ValidatorEngineCategory.BasicInt.ToString(), str).OfType<int>();
        }

		/// <summary>
		/// Check whether input string represents a long integer and converts it when yes.
		/// </summary>
		/// <param name="str">A data to be validated.</param>
		/// <returns>Long integer value.</returns>
		/// <exception cref="NullInputDataException">If an input data is empty string.</exception>
		/// <exception cref="ValidatorInputDataException">If input data does not represent a long integer number.</exception>
		public static long ValidateAsBasicLong(this string str)
		{
			return SecurityKernel.Validator.Api.ExecuteDefaultByCategory(ValidatorEngineCategory.BasicLongint.ToString(), str).OfType<long>();
		}

		/// <summary>
		/// Checks whether input string represents a double precision number and converts it when yes.
		/// </summary>
		/// <param name="str">A data to be validated.</param>
		/// <returns>Double value.</returns>
		/// <exception cref="NullInputDataException">If an input data is empty string.</exception>
		/// <exception cref="ValidatorInputDataException">If input data does not represent a double precision number.</exception>
		public static double ValidateAsBasicDouble(this string str)
		{
			return SecurityKernel.Validator.Api.ExecuteDefaultByCategory(ValidatorEngineCategory.BasicDouble.ToString(), str).OfType<double>();
		}

		/// <summary>
		/// Checks whether input string fit validation creteria, i.e. length range, black or white list charactrers.
		/// </summary>
		/// <param name="str">A data to be validated.</param>
		/// <returns>Input data itself.</returns>
		/// <exception cref="ValidatorInputDataException">If input data does not fit validation criteria.</exception>
		public static string ValidateAsBasicString(this string str)
        {
            return SecurityKernel.Validator.Api.ExecuteDefaultByCategory(ValidatorEngineCategory.BasicString.ToString(), str);
        }

		/// <summary>
		/// Checks whether input string is a valid Credit card number.
		/// </summary>
		/// <param name="str">A data to be validated.</param>
		/// <returns>A Credit card number if it's valid.</returns>
		/// <exception cref="NullInputDataException">If an input data is empty string.</exception>
		/// <exception cref="ValidatorInputDataException">If input data does not look as a valid credit card number.</exception>
		public static string ValidateAsCreditCardNumber(this string str)
		{
			return SecurityKernel.Validator.Api.ExecuteDefaultByCategory(ValidatorEngineCategory.CreditCardString.ToString(), str);
		}

		/// <summary>
		/// Checks whether input string is a data in the hexadecimal form.
		/// </summary>
		/// <param name="str">A data to be validated.</param>
		/// <returns>An input data itself if it's valid.</returns>
		/// <exception cref="NullInputDataException">If an input data is empty string.</exception>
		/// <exception cref="ValidatorInputDataException">If input data does not represent a hex string.</exception>
		public static string ValidateAsHexString(this string str)
		{
			return SecurityKernel.Validator.Api.ExecuteDefaultByCategory(ValidatorEngineCategory.HexString.ToString(), str);
		}

		/// <summary>
		/// Check whether input string contains only printable ASCII characters.
		/// </summary>
		/// <param name="str">A data to be validated.</param>
		/// <returns>An input data itself if it's valid.</returns>
		/// <exception cref="NullInputDataException">If an input data is empty string.</exception>
		/// <exception cref="ValidatorInputDataException">If input data does not represent printable ASCII string.</exception>
		public static string ValidateAsPrintableString(this string str)
		{
			return SecurityKernel.Validator.Api.ExecuteDefaultByCategory(ValidatorEngineCategory.PrintableString.ToString(), str);
		}

		/// <summary>
		/// Checks whether input string is a valid date/time and convert to it when yes.
		/// </summary>
		/// <param name="str">A data to be validated.</param>
		/// <returns>DateTime value.</returns>
		/// <exception cref="NullInputDataException">If an input data is empty string.</exception>
		/// <exception cref="ValidatorInputDataException">If input data does not represent a date and time.</exception>
		public static DateTime ValidateAsDateString(this string str)
		{
			return SecurityKernel.Validator.Api.ExecuteDefaultByCategory(ValidatorEngineCategory.DateString.ToString(), str).OfType<DateTime>();
		}

		/// <summary>
		/// Checks whether input string is BASE 64 encoded data and decodes it when yes.
		/// </summary>
		/// <param name="str">A data to be validated.</param>
		/// <returns>Decoded string value.</returns>
		/// <exception cref="NullInputDataException">If an input data is empty string.</exception>
		/// <exception cref="ValidatorInputDataException">If input data does not represent a BASE 64 encoded data.</exception>
		public static string ValidateAsBase64String(this string str)
		{
			return SecurityKernel.Validator.Api.ExecuteDefaultByCategory(ValidatorEngineCategory.Base64String.ToString(), str);
		}
    }
}

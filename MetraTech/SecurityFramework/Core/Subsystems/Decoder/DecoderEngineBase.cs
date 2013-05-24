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

namespace MetraTech.SecurityFramework.Core.Decoder
{
	/// <summary>
	/// Provides a base class for all engines in the Decoder subsystem.
	/// </summary>
	public abstract class DecoderEngineBase : EngineBase
	{
        #region Constants
       
        /// <summary>
        /// pattern for hex code detection
        /// </summary>
        private const string RegexPatternGetHexCode = @"(?im:(?<hexCode>(?:\d|[ABCDEF]){2,}))";
        private const string HexCodeGroupName = "hexCode";

        /// <summary>
        /// pattern for decimal sequence detection
        /// </summary>
        private const string RegexPatternGetDecimal = @"(?im:(?<decimal>\d{2,}))";
        private const string DecimalGroupName = "decimal";

        #endregion

        private static readonly Regex RegexGetHexCode = new Regex(RegexPatternGetHexCode, RegexOptions.Compiled);
        private static readonly Regex RegexGetDecimal = new Regex(RegexPatternGetDecimal, RegexOptions.Compiled);

		#region Properties

		/// <summary>
		/// Gets or sets an engine's category.
		/// </summary>
		protected virtual DecoderEngineCategory Category
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
				return typeof(MetraTech.SecurityFramework.Decoder);
			}
		}

		#endregion

		#region Constructors

		/// <summary>
		/// Creates an instance of the engine for the specified category.
		/// </summary>
		/// <param name="category">An engine's category.</param>
		protected DecoderEngineBase(DecoderEngineCategory category)
		{
			Category = category;
			this.CategoryName = Convert.ToString(Category);
		}

		#endregion

        #region Public methods

        /// <summary>
        /// Converts string to hex code 
        /// </summary>
        /// <param name="inputData">An input value</param>
        /// <returns>A converted value</returns>
        public static int GetHexFromString(string inputData)
        {
            string hexCode = RegexGetHexCode.Match(inputData).Groups[HexCodeGroupName].Value;
            if (String.IsNullOrEmpty(hexCode))
                new SubsystemInternalException("Hex code can't be null. Check regex pattern for ASCII.");

            return int.Parse(hexCode, System.Globalization.NumberStyles.HexNumber);
        }

        /// <summary>
        /// Converts string to decimal 
        /// </summary>
        /// <param name="inputData">An input value</param>
        /// <returns>A converted value</returns>
        public static int GetDecimalFromString(string inputData)
        {
            string decimalCode = RegexGetDecimal.Match(inputData).Groups[DecimalGroupName].Value;
            if (String.IsNullOrEmpty(decimalCode))
                new SubsystemInternalException("Hex code can't be null. Check regex pattern for ASCII.");

            return int.Parse(decimalCode, System.Globalization.NumberStyles.Number);
        }

        /// <summary>
        /// Converts hex code to unicode string 
        /// </summary>
        /// <param name="hexCode">An input value</param>
        /// <returns>A converted value</returns>
        public static string GetUnicodeFromCode(int hexCode)
        {
            //return Encoding.UTF32.GetString(BitConverter.GetBytes(hexCode));
            return char.ConvertFromUtf32(hexCode);
        }

	    #endregion

        #region Protected methods

		/// <summary>
		/// Checks an input value for null and empty string and performs a decoding.
		/// </summary>
		/// <param name="input">An input value.</param>
		/// <returns>A decoded value.</returns>
		protected override ApiOutput ExecuteInternal(ApiInput input)
		{
			if (input == null || string.IsNullOrEmpty(input.ToString()))
			{
				throw new NullInputDataException(SubsystemName, CategoryName, SecurityEventType.InputDataProcessingEventType);
			}

			return DecodeInternal(input);
		}

		/// <summary>
		/// Performs a decoding.
		/// </summary>
		/// <param name="input">An input value.</param>
		/// <returns>A decoded value.</returns>
		protected abstract ApiOutput DecodeInternal(ApiInput input);

		#endregion
	}
}

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
using System.Globalization;

namespace MetraTech.SecurityFramework.Core.Decoder
{
	/// <summary>
	/// Provides a base class for decoders using regular expressions to find characters to translate.
	/// </summary>
	public abstract class DecoderTranslatorEngineBase : DecoderEngineBase
	{
		#region Private fields

		private Regex _regularExpression;

		#endregion

		#region Properties

		/// <summary>
		/// Gets a regular expression finding characters to translate.
		/// </summary>
		protected abstract string Expression
		{
			get;
		}

		private Regex RegularExpression
		{
			get
			{
				if (_regularExpression == null)
				{
					_regularExpression = new Regex(Expression, RegexOptions.Compiled);
				}

				return _regularExpression;
			}
		}

		#endregion

		#region Constructors

		/// <summary>
		/// Creates an instance of the engine for the specified category.
		/// </summary>
		/// <param name="category">An engine's category.</param>
		protected DecoderTranslatorEngineBase(DecoderEngineCategory category)
			: base(category)
		{
		}

		#endregion

		#region Protected methods

		/// <summary>
		/// Performs a decoding.
		/// </summary>
		/// <param name="input">An input value.</param>
		/// <returns>A decoded value.</returns>
		protected override ApiOutput DecodeInternal(ApiInput input)
		{
			string result = RegularExpression.Replace(input.ToString(), TranslateToken);

			return new ApiOutput(result);
		}

		/// <summary>
		/// Translates a found token to a corresponding character.
		/// </summary>
		/// <param name="token">A found token.</param>
		/// <returns>A translated character.</returns>
		protected abstract string TranslateToken(Match token);

		/// <summary>
		/// Parses a character specified by its hex code.
		/// </summary>
		/// <param name="charCode">A character code.</param>
		/// <returns>A string containing parsed character.</returns>
		/// <exception cref="ArgumentNullException">charCode is null.</exception>
		/// <exception cref="FormatException">charCode contains other characters besides hexadecimal digits.</exception>
		/// <exception cref="OverflowException">
		/// charCode represents a number less than System.Int32.MinValue or greater than System.Int32.MaxValue or does not represent any character.
		/// </exception>
		protected string ParseHexChar(string charCode)
		{
			return ParseChar(charCode, NumberStyles.AllowHexSpecifier);
		}

		/// <summary>
		/// Parses a character specified by its decimal code.
		/// </summary>
		/// <param name="charCode">A character code.</param>
		/// <returns>A string containing parsed character.</returns>
		/// <exception cref="ArgumentNullException">charCode is null.</exception>
		/// <exception cref="FormatException">charCode contains other characters besides decimal digits.</exception>
		/// <exception cref="OverflowException">
		/// charCode represents a number less than System.Int32.MinValue or greater than System.Int32.MaxValue or does not represent any character.
		/// </exception>
		protected string ParseDecimalChar(string charCode)
		{
			return ParseChar(charCode, NumberStyles.None);
		}

		#endregion

		#region Private methods

		private string ParseChar(string charCode, NumberStyles numberStyle)
		{
			return char.ConvertFromUtf32(int.Parse(charCode, numberStyle, CultureInfo.InvariantCulture)).ToString();
		}

		#endregion
	}
}

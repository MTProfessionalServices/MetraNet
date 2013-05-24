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
	/// Provides translation from CSS encoding.
	/// </summary>
	public class CssDecoderEngine : DecoderTranslatorEngineBase
	{
		#region Constants

		private const string CssRegex = "(?m)\\\\(?<charCode>[0-9a-fA-F]{1,5})(\\u0020|$)|\\\\(?<charCode>[0-9a-fA-F]{6})(\\u0020?)|\\\\(?<charCode>[0-9a-fA-F]{1,5})(?![0-9a-fA-F])";
		private const string CharCodeGroupName = "charCode";

		#endregion

		#region Properties

		/// <summary>
		/// Gets a regular expression finding characters to translate.
		/// </summary>
		protected override string Expression
		{
			get
			{
				return CssRegex;
			}
		}

		#endregion

		#region Constructors

		/// <summary>
		/// Creates an instance of the <see cref="CssDecoderEngine"/> class.
		/// </summary>
		public CssDecoderEngine()
			: base(DecoderEngineCategory.Css)
		{
		}

		#endregion

		#region Protected methods

		/// <summary>
		/// Translates a found token to a corresponding character.
		/// </summary>
		/// <param name="token">A found token.</param>
		/// <returns>A translated character.</returns>
		protected override string TranslateToken(Match token)
		{
			string charCode = token.Groups[CharCodeGroupName].Value;

			string result;
			try
			{
				result = ParseHexChar(charCode);
			}
			catch (OverflowException)
			{
				// Some codes don't correspond to any characters.
				result = token.Value;
			}

			return result;
		}

		#endregion
	}
}

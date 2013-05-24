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
* Maksym Sukhovarov <msukhovarov@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Diagnostics;

namespace MetraTech.SecurityFramework.Core.Decoder
{
	/// <summary>
	/// Provides decoder of vbscript encoding sequence
	/// </summary>
	internal class VbScriptDecoderEngine : DecoderEngineBase
	{
		#region Constants

		#region Regex Pattern for replace chrw? symbols

		/// <summary>
		/// Pattern consist from 3 groups:
		///         1) detect all strings with format ^..." or "...." or "...$
		///         2) chrw?(decimal)
		///         3) chrw?(hexCode)
		/// </summary>
		private const string RegexPatternGetChrSequence = @"(?im:(?<chrSequence>(?:^|(?<amp>\s*&))\s*chrw?\(\s*(?:(?<decimal>\d{2,5})|(?<hexCode>&h(?:\d|[ABCDEF]){2,4}))\s*\)\s*)(?=\s*&|$))";

		private const string ChrSequenceGroupName = "chrSequence";
		private const string DecimalCodeGroupName = "decimal";
		private const string HexCodeGroupName = "hexCode";
		private const string AmpersandGroupName = "amp";

		#endregion Regex Pattern for replace chrw? symbols

		/// <summary>
		/// Concatenate the part strings
		/// </summary>
		private Regex _concatenateStr = new Regex(@"(?m:(?<quote>(?:^|\s*&\s*)""(?<innerText>.*?)"")(?=\s*&|$))", RegexOptions.Compiled);
		private const string QuoteGroupName = "quote";
		private const string QuoteInnerTextGroupName = "innerText";

		/// <summary>
		/// Checks start and stop quotesr. 
		/// </summary>
		private const string PatternContainStartStopQuoters =
			@"(?im:(?<startQuote>^\bchrw?\(\s*(?:\d+|&h(?:\d|[ABCDEF])+)\s*\)|^"").*?(?<stopQuote>\bchrw?\(\s*(?:\d+|&h(?:\d|[ABCDEF])+)\s*\)$|""$))";

		private const string StartQuoterGroupName = "startQuote";
		private const string StopQuoterGroupName = "stopQuote";


		#endregion Constants

		/// <summary>
		/// Concatination string "...._\r\n...."
		/// </summary>
		private readonly Regex _regConcatenationStr = new Regex("_\r?\n", RegexOptions.Compiled);

		/// <summary>
		/// contains chrw?(...) sequence or ....."   &   ".....
		/// </summary>
		private readonly Regex _regexChrOrQuotesContains = new Regex(@"(?im:\bchrw?\(\s*(?:\d+|&h(?:\d|[ABCDEF])+)\s*\)|""\s*&\s*""|^""(?!=>""\s*&\s*"").*?""$)", RegexOptions.Compiled);

		/// <summary>
		///  Checks start and stop quotesr. 
		/// </summary>
		private readonly Regex _regContainStartStopQuotesOrChrw = new Regex(PatternContainStartStopQuoters, RegexOptions.Compiled);

		/// <summary>
		/// Try to find chrw? functions
		/// </summary>
		private readonly Regex _regGetChrw = new Regex(RegexPatternGetChrSequence, RegexOptions.Compiled);

		/// <summary>
		/// Regex for cheks input and output values 
		/// </summary>
		/// <remarks>Last step</remarks>
		private readonly Regex _regEqualInputOutputWithoutQuotes = new Regex("(?m:^\\s*\"(.*?)\"\\s*$)", RegexOptions.Compiled);

		#region Constructors

		/// <summary>
		/// Creates an instance of the <see cref="VbScriptDecoderEngine"/> class.
		/// Sets an engine category to <see cref="DecoderEngineCategory"/>.VbScript
		/// </summary>
		public VbScriptDecoderEngine()
			: base(DecoderEngineCategory.VbScript)
		{ }

		#endregion Constructors

		#region Protected methods

		/// <summary>
		/// Performs a decoding.
		/// </summary>
		/// <param name="input">An input value.</param>
		/// <returns>A decoded value.</returns>
		protected override ApiOutput DecodeInternal(ApiInput input)
		{
			string result;
			string afterDecoding = RemoveLineContinuationChar(input.ToString());

			result =
				IsContainsVbScriptSequence(afterDecoding) ? DecodeVbScriptDecodingStr(afterDecoding) : input.ToString();

			return new ApiOutput(result, input.Exceptions);
		}


		#endregion Protected methods

		#region Private methods

		/// <summary>
		/// Remove '_\n' symbols to nothing
		/// </summary>
		/// <remarks>First step</remarks>
		/// <param name="input">The input VB string</param>
		/// <returns>Concatinated VB's string</returns>
		private string RemoveLineContinuationChar(string input)
		{
			return _regConcatenationStr.Replace(input, string.Empty);
		}

		/// <summary>
		/// Try to search VBScript sequences '"..."  &  "..."' or 'chrw?(...)' functions 
		/// </summary>
		/// <remarks>Second step</remarks>
		/// <param name="input"></param>
		/// <returns></returns>
		private bool IsContainsVbScriptSequence(string input)
		{
			return _regexChrOrQuotesContains.IsMatch(input);
		}

		/// <summary>
		/// Try to decode VBScript input string
		/// </summary>
		/// <remarks>Thrid step</remarks>
		/// <param name="input"></param>
		/// <returns></returns>
		private string DecodeVbScriptDecodingStr(string input)
		{
			string result = input;
			string intermed = input;
			if (!String.IsNullOrEmpty(result))
			{
				intermed = _regGetChrw.Replace(intermed, ReplaceChrwToken).Trim();

				// check input string for start and stop VBSCript symblos('"..."  &  "..."' or 'chrw?(...)' functions)
				intermed = AddStartStopQuotesIfNeed(intermed);

				if (_concatenateStr.IsMatch(intermed))
				{
					// Try to cocatenate VBScript strings ("...."  & "...." & "....")
					result = _concatenateStr.Replace(intermed, ConcatenateStringToken);
				}

				if (IsEqualInputOutputWithoutQuotes(input, result))
					// input value and output value without start and stop qoutes - equal 
					result = input.ToString();
			}

			return result;
		}

		/// <summary>
		/// Translates a found string whith begin and end breaked ", decimal code or hex code to a corresponding character.
		/// </summary>
		/// <remarks>First step in DecodeVbScriptDecodingStr</remarks>
		/// <param name="token">A found entity.</param>
		/// <returns>A translated character.</returns>
		private string ReplaceChrwToken(Match token)
		{
			string result = null;

			try
			{
				Group g = token.Groups[ChrSequenceGroupName];
				if (g.Success)
				{
					if (token.Groups[AmpersandGroupName].Success)
						result = "&";
					string symbol;
					if ((g = token.Groups[DecimalCodeGroupName]).Success)
						symbol = GetUnicodeFromCode(GetDecimalFromString(g.Value));
					else if ((g = token.Groups[HexCodeGroupName]).Success)
						symbol = GetUnicodeFromCode(GetHexFromString(g.Value));
					else
						symbol = String.Empty;

					if (symbol == "\"")
						symbol += "\"";

					result += "\"" + symbol + "\"";
				}

				if (result == null)
				{
					throw new SubsystemInternalException(String.Format(
							"{0} category: Regex pattern was success, but this coincidence was not proccessed. Regex is '{1}' ",
							CategoryName,
							token));
				}

			}
			catch (OverflowException)
			{
				// Some codes don't correspond to any characters.
				result = token.Value;
			}

			return result;
		}

		/// <summary>
		/// Checks start and stop quotesr if it not exest then it would be added. 
		/// </summary>
		/// <remarks>Second step in DecodeVbScriptDecodingStr</remarks>
		/// <param name="result"></param>
		/// <returns></returns>
		private string AddStartStopQuotesIfNeed(string result)
		{
			Match m = _regContainStartStopQuotesOrChrw.Match(result);

			if (!m.Groups[StartQuoterGroupName].Success)
				result = '"' + result;

			if (!m.Groups[StopQuoterGroupName].Success)
				result += '"';

			return result;
		}

		/// <summary>
		/// Regex token for concatenate the parts of strings 
		/// </summary>
		/// <param name="token"></param>
		/// <returns></returns>
		private string ConcatenateStringToken(Match token)
		{
			string result = null;

			try
			{
				Group g = token.Groups[QuoteGroupName];
				if (g.Success)
				{
					result = token.Groups[QuoteInnerTextGroupName].Value.Replace("\"\"", "\"");
				}

				if (result == null)
				{
					throw new Exception(String.Format(
							"{0} category: Regex pattern was success, but this coincidence was not proccessed. Regex is '{1}' ",
							SubsystemName,
							token));
				}

			}
			catch (OverflowException)
			{
				// Some codes don't correspond to any characters.
				result = token.Value;
			}

			return result;
		}

		/// <summary>
		/// Cheks input and output values without start and stop quotes.
		/// </summary>
		/// <remarks>Last step</remarks>
		/// <param name="input"></param>
		/// <param name="output"></param>
		/// <returns>true - if equale</returns>
		private bool IsEqualInputOutputWithoutQuotes(string input, string output)
		{
			Match m = _regEqualInputOutputWithoutQuotes.Match(input);

			return m.Groups[1].Success
				   && m.Groups[1].Value.Equals(output);
		}

		#endregion Private methods
	}
}

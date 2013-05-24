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
using System.Threading;
using MetraTech.SecurityFramework.Core.Common;
using MetraTech.SecurityFramework.Core.Common.Configuration;
using System.Text.RegularExpressions;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Core.Decoder
{
	/// <summary>
	/// Convert input string as Base64 encoding data to <see cref="String"/> 
	/// </summary>
	internal sealed class Base64DecoderToStringEngine : DecoderEngineBase
	{
		#region Consts
		private const string BaseCharForIndex62 = "+";
		private const string BaseCharForIndex63 = "/";

		private const string ExceptionMessCantContainSymbol = "Base64 decoder with id='{0}'used as modified version base64 decoder.\n This version can't contain '{1}' into input sequence";

		private const string ReplasePattern = "(?i:(?<replaceChars>({0})))";
		private const string ReplaceCharsGroup = "replaceChars";
		#endregion Consts

		private Regex _replase62and63CharsRegex = null;

		public Base64DecoderToStringEngine()
			: base(DecoderEngineCategory.Base64)
		{ }

		/// <summary>
		/// TODO: remove this method after new configuration loader implementing.
		/// </summary>
		/// <param name="engineProps"></param>
		public override void Initialize()
		{
			base.Initialize();

			CreateRegexForReplace();
		}

		/// <summary>
		/// Performs a decoding.
		/// </summary>
		/// <param name="input">An input value.</param>
		/// <returns>A decoded value.</returns>
		protected override ApiOutput DecodeInternal(ApiInput input)
		{
			CheckInputData(input);
			try
			{
				UTF8Encoding encoder = new UTF8Encoding();
				System.Text.Decoder utf8Decode = encoder.GetDecoder();

				byte[] toDecodeBytes = Convert.FromBase64String(Replace62and63Chars(input.ToString()));
				char[] decodedChars = new char[utf8Decode.GetCharCount(toDecodeBytes, 0, toDecodeBytes.Length)];
				utf8Decode.GetChars(toDecodeBytes, 0, toDecodeBytes.Length, decodedChars, 0);

				return new ApiOutput(new String(decodedChars), input.Exceptions);
			}
			catch (Exception e)
			{
				throw new DecoderInputDataException(
					ExceptionId.Decoder.General, Category, "Error in Base64 decode.", input.ToString(), String.Format("throw Exception: {0}", e.Message), e.InnerException);
			}
		}

		private void CreateRegexForReplace()
		{
			// add chars for replase
			string replaseChars = String.Empty;
			if (IsModifiedCharForIndex62)
				replaseChars = Regex.Escape(CharForIndex62);

			if (IsModifiedCharForIndex63)
			{
				if (!String.IsNullOrEmpty(replaseChars))
					replaseChars += "|";
				replaseChars += Regex.Escape(CharForIndex63);
			}

			// Create regex
			if (!String.IsNullOrEmpty(replaseChars))
			{
				_replase62and63CharsRegex = new Regex(String.Format(ReplasePattern, replaseChars), RegexOptions.Compiled);
			}
			else
			{
				_replase62and63CharsRegex = null;
			}
		}

		[SerializePropertyAttribute]
		private string CharForIndex62
		{
			get;
			set;
		}

		[SerializePropertyAttribute]
		private string CharForIndex63
		{
			get;
			set;
		}

		private void CheckInputData(ApiInput input)
		{
			if (IsModifiedCharForIndex62 && input.ToString().Contains(BaseCharForIndex62))
				// TODO: Set ID category exception
				throw new DecoderInputDataException(
					ExceptionId.Decoder.General,
					Category,
					"Error in Base64 decode.",
					input.ToString(),
					String.Format(ExceptionMessCantContainSymbol, this.Id, BaseCharForIndex62));


			if (IsModifiedCharForIndex63 && input.ToString().Contains(BaseCharForIndex63))
				// TODO: Set ID category exception
				throw new DecoderInputDataException(
					ExceptionId.Decoder.General,
					Category,
					"Error in Base64 decode.",
					input.ToString(),
					String.Format(ExceptionMessCantContainSymbol, this.Id, BaseCharForIndex63));
		}

		private bool IsModifiedCharForIndex62
		{
			get
			{
				return String.IsNullOrEmpty(CharForIndex62) == false
						  && BaseCharForIndex62.Equals(CharForIndex62) == false;
			}
		}

		private bool IsModifiedCharForIndex63
		{
			get
			{
				return String.IsNullOrEmpty(CharForIndex63) == false
						  && BaseCharForIndex63.Equals(CharForIndex63) == false;
			}
		}

		/// <summary>
		/// Translates a found token to a corresponding character.
		/// </summary>
		/// <param name="token">A found token.</param>
		/// <returns>A translated character.</returns>
		private string TranslateToken(Match token)
		{
			string result = null;

			try
			{
				Group g = token.Groups[ReplaceCharsGroup];
				if (g.Success)
				{
					// replace chars
					if (g.Value.Equals(CharForIndex62))
						result = BaseCharForIndex62;
					if (g.Value.Equals(CharForIndex63))
						result = BaseCharForIndex63;
				}

				if (String.IsNullOrEmpty(result))
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

		private string Replace62and63Chars(string inputData)
		{
			return _replase62and63CharsRegex == null ? inputData : _replase62and63CharsRegex.Replace(inputData, TranslateToken);
		}
	}
}


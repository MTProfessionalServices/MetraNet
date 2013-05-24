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

namespace MetraTech.SecurityFramework
{
	public static class DecoderExtensions
	{
		/// <summary>
		/// Converts an input data using a specified decoder engine.
		/// </summary>
		/// <param name="str">A data to decode.</param>
		/// <param name="engineId">An ID of the engine to decode the data with.</param>
		/// <returns>A decoded value.</returns>
		public static string DecodeWithEngine(this string str, string engineId)
		{
			return SecurityKernel.Decoder.Api.Execute(engineId, str);
		}

		public static string DecodeFromUrl(this string str)
		{
			return SecurityKernel.Decoder.Api.ExecuteDefaultByCategory(DecoderEngineCategory.Url.ToString(), str);
		}

		public static string DecodeFromHtml(this string str)
		{
			return SecurityKernel.Decoder.Api.ExecuteDefaultByCategory(DecoderEngineCategory.Html.ToString(), str);
		}

		/// <summary>
		/// Converts an input from HTML attribute encoding.
		/// </summary>
		/// <param name="str">A data to decode.</param>
		/// <returns>A decoded value</returns>
		/// <remarks>Actually it's the same the <see cref="DecodeFromHtml"/> is.</remarks>
		public static string DecodeFromHtmlAttribute(this string str)
		{
			return DecodeFromHtml(str);
		}

        /// <summary>
        /// Converts an input from JavaScript encoding.
        /// </summary>
        /// <param name="str">A data to decode.</param>
        /// <returns>A decoded value.</returns>
        public static string DecodeFromJavaScript(this string str)
        {
            return SecurityKernel.Decoder.Api.ExecuteDefaultByCategory(DecoderEngineCategory.JavaScript.ToString(), str);
        }

        /// <summary>
        /// Converts an input from VBScript encoding.
        /// </summary>
        /// <param name="str">A data to decode.</param>
        /// <returns>A decoded value.</returns>
        public static string DecodeFromVbScript(this string str)
        {
            return SecurityKernel.Decoder.Api.ExecuteDefaultByCategory(DecoderEngineCategory.VbScript.ToString(), str);
        }

		/// <summary>
		/// Converts an input from XML encoding.
		/// </summary>
		/// <param name="str">A data to decode.</param>
		/// <returns>A decoded value.</returns>
		public static string DecodeFromXml(this string str)
		{
			return SecurityKernel.Decoder.Api.ExecuteDefaultByCategory(DecoderEngineCategory.Xml.ToString(), str);
		}

		/// <summary>
		/// Converts an input from XML attribute encoding.
		/// </summary>
		/// <param name="str">A data to decode.</param>
		/// <returns>A decoded value</returns>
		/// <remarks>Actually it's the same the <see cref="DecodeFromXml"/> is.</remarks>
		public static string DecodeFromXmlAttribute(this string str)
		{
			return DecodeFromXml(str);
		}

		public static string DecodeStringFromBase64(this string str)
		{
			return SecurityKernel.Decoder.Api.ExecuteDefaultByCategory(DecoderEngineCategory.Base64.ToString(), str);
		}

		/// <summary>
		/// Converts an input from CSS encoding.
		/// </summary>
		/// <param name="str">A data to decode.</param>
		/// <returns>A decoded value.</returns>
		public static string DecodeFromCss(this string str)
		{
			return SecurityKernel.Decoder.Api.ExecuteDefaultByCategory(DecoderEngineCategory.Css.ToString(), str);
		}

		/// <summary>
		/// Takes a BASE 64 encoded compressed data and decodes it to an uncompressed array of bytes.
		/// </summary>
		/// <param name="str">A data to decode.</param>
		/// <returns>A decoded value.</returns>
		/// <exception cref="DecoderInputDataException">
		/// A <paramref name="str"/> is not trully BASE 64 encoded or the encoded value is not trully compressed with GZIP algorithm.
		/// </exception>
		public static byte[] DecodeFromGZip(this string str)
		{
			return SecurityKernel.Decoder.Api.ExecuteDefaultByCategory(DecoderEngineCategory.GZip.ToString(), str).Value as byte[];
		}

		/// <summary>
		/// Converts an input from LDAP escaping.
		/// </summary>
		/// <param name="str">A data to decode.</param>
		/// <returns>A decoded value.</returns>
		public static string DecodeFromLdap(this string str)
		{
			return SecurityKernel.Decoder.Api.ExecuteDefaultByCategory(DecoderEngineCategory.Ldap.ToString(), str);
		}

		public static string DecodeAll(this string str)
		{
			return string.Empty;
		}
	}
}

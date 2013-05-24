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
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;

namespace MetraTech.SecurityFramework.Core.Decoder
{
	/// <summary>
	/// Provides uncompression of data compressed with GNU ZIP algorithm.
	/// </summary>
	public class GZipDecoderEngine : DecoderEngineBase
	{
		/// <summary>
		/// Creates an instance of the <see cref="GZipDecoderEngine"/> class.
		/// </summary>
		public GZipDecoderEngine()
			: base(DecoderEngineCategory.GZip)
		{
		}

		/// <summary>
		/// Recognizes an input format and uncopresses the data.
		/// </summary>
		/// <param name="input">An input value.</param>
		/// <returns>A decoded value.</returns>
		/// <remarks>
		/// The method tries to recognize input data from as a BASE 64 encoded string, bytes array or <see cref="Stream"/> object.
		/// It throws an exception if all of recornitions tries failed.
		/// </remarks>
		protected override ApiOutput DecodeInternal(ApiInput input)
		{
			Stream streamInput;
			bool innerStream;
			string base64EncodedInput;
			byte[] arrayInput;

			if ((base64EncodedInput = input.Value as string) != null) // Try to recognize a BASE 64 encoded input.
			{
				try
				{
					streamInput = new MemoryStream(Convert.FromBase64String(base64EncodedInput));
					innerStream = true;
				}
				catch (FormatException ex)
				{
					throw new DecoderInputDataException(Common.ExceptionId.Decoder.Base64InvalidFormat, DecoderEngineCategory.GZip, ex.Message, ex);
				}
			}
			else if ((arrayInput = input.Value as byte[]) != null) // Try to recognize a byte array input.
			{
				streamInput = new MemoryStream(arrayInput);
				innerStream = true;
			}
			else if ((streamInput = input.Value as Stream) != null) // Try to recognize a Stream input.
			{
				innerStream = false;
			}
			else
			{
				throw new SubsystemInputParamException(string.Format("Unsupported input type \"{0}\"", input.Value.GetType()));
			}

			try
			{
				ApiOutput result = new ApiOutput(Decompress(streamInput));
				return result;
			}
			finally
			{
				if (innerStream)
				{
					// A stream was created internally by the method.
					streamInput.Dispose();
				}
			}
		}

		private byte[] Decompress(Stream data)
		{
			try
			{
				using (GZipStream decopressor = new GZipStream(data, CompressionMode.Decompress))
				{
					using (MemoryStream result = new MemoryStream())
					{
						int val;
						while ((val = decopressor.ReadByte()) != -1)
						{
							result.WriteByte((byte)val);
						}

						result.Flush();

						return result.ToArray();
					}
				}
			}
			catch (Exception ex)
			{
				throw new DecoderInputDataException(Common.ExceptionId.Decoder.GZipInvalidFormat, DecoderEngineCategory.GZip, ex.Message, ex);
			}
		}
	}
}

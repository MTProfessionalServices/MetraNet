using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.SecurityFramework.Core.Common
{
    /// <summary>
    /// Id exceptions contain.
    /// </summary>
    /// <remarks>Full information can see in <b>ExceptionsIntervalsID.txt</b> file"/></remarks>
    public static class ExceptionId
    {
        #region General Ids
        /// <summary>
        /// General Id intervals from 0 to 999
        /// </summary>
        public enum General
        {
            /// <summary>
            /// Input data is null
            /// </summary>
            Null = 100
        }

        public static int ToInt(this General en)
        {
            return (int)en;
        }

        #endregion General Ids

        #region Decoder Ids

        /// <summary>
        /// Decoder Id intervals from 1000 to 1999
        /// </summary>
        public enum Decoder
        {
            /// <summary>
            /// General exception
            /// </summary>
            General = 1000,
			Base64InvalidFormat = General + 10,
			GZipInvalidFormat = General + 100
        }

        public static int ToInt(this Decoder en)
        {
            return (int)en;
        }

        #endregion Decoder Ids

        #region Detector Ids

        /// <summary>
        /// Detector Id intervals from 2000 to 2999
        /// </summary>
        public enum Detector
        {
            /// <summary>
            /// General exception
            /// </summary>
            General = 2000,
            DetectXssInjection = General + 10,
            DetectJavaScript = General + 20,
            DetectDomElement = General + 30,
            DetectHtmlTag = General + 40,
            DetectHtmlEvent = General + 50,
            DetectSignElement = General + 60,
            DetectVbScriptElement = General + 70,
            DetectObfuscation = General + 80,
            DetectSqlInjection = General + 200,
            DetectDirectoryTraversal = General + 300
        }

        public static int ToInt(this Detector en)
        {
            return (int)en;
        }

        #endregion Detector Ids

        #region Validator Ids

        /// <summary>
        /// Validator Id intervals from 3000 to 3999
        /// </summary>
        public enum Validator
        {
            /// <summary>
            /// General exception
            /// </summary>
            General = 3000,
            EmptyStringNotAllowed = General + 10,
            InputStringNotRange = General + 20,
            InputValueIsNotInteger = General + 30,
            InputIntegerNotInRange = General + 40,
            BlockedInputString = General + 50,
			InputValueIsNotDouble = General + 60,
			InputDoubleNotInRange = General + 70,
			CcnLengthInvalid = General + 80,
			CcnIllegalCharacter = General + 90,
			CcnInvalidNumber = General + 100,
			HexNumberInvalid = General + 110,
			PrintableStringInvalid = General + 120,
			DateTimeStringInvalid = General + 130,
			Base64StringInvalid = General + 140
        }

        public static int ToInt(this Validator en)
        {
            return (int)en;
        }

        #endregion Validator Ids

        #region Encoder Ids

        /// <summary>
        /// Encoder Id intervals from 4000 to 4999
        /// </summary>
        public enum Encoder
        {
            /// <summary>
            /// General exception
            /// </summary>
            General = 4000
        }

        public static int ToInt(this Encoder en)
        {
            return (int)en;
        }

        #endregion Encoder Ids

        #region Processor Ids

        /// <summary>
        /// Processor Id intervals from 5000 to 5999
        /// </summary>
        public enum Processor
        {
            /// <summary>
            /// General exception
            /// </summary>
            General = 5000,
        }

        public static int ToInt(this Processor en)
        {
            return (int)en;
        }

        #endregion Processor Ids

        #region Sanitizer Ids

        /// <summary>
        /// Sanitizer Id intervals from 6000 to 6999
        /// </summary>
        public enum Sanitizer
        {
            /// <summary>
            /// General exception
            /// </summary>
            General = 6000,            
        }

        public static int ToInt(this Sanitizer en)
        {
            return (int)en;
        }

        #endregion Sanitizer Ids

		#region Encryptor Ids

		/// <summary>
		/// Encryptor Id intervals from 7000 to 7999
		/// </summary>
		public enum Encryptor
		{
			/// <summary>
			/// General exception
			/// </summary>
			General = 7000,

			/// <summary>
			/// Data cannot be decrypted (bad encrypted data)
			/// </summary>
			BadEncryptedData = 7010,

			/// <summary>
			/// Data cannot be decoded (bad encoded data)
			/// </summary>
			BadEncodedData = 7020,
		}

		public static int ToInt(this Encryptor en)
		{
			return (int)en;
		}

		#endregion

		#region AccessController Ids

		/// <summary>
		/// AccessController Id intervals from 8000 to 8999
		/// </summary>
		public enum AccessController
		{
			/// <summary>
			/// General exception
			/// </summary>
			General = 8000
		}

		public static int ToInt(this AccessController en)
		{
 			return (int)en;
		}

		#endregion
	}
}

   

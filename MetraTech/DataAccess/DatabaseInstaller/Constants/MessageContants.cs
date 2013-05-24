//=============================================================================
// Copyright 2012 by MetraTech
// All rights reserved.
//
// THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
// REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
// example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
// WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
// OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
// INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
// RIGHTS.
//
// Title to copyright in this software and any associated
// documentation shall at all times remain with MetraTech, and USER
// agrees to preserve the same.
//
//-----------------------------------------------------------------------------
//
// MODULE: MessageConstants.cs
//
//=============================================================================

namespace MetraTech.DataAccess.DatabaseInstaller.Constants
{
    /// <summary>
    /// Class of message constants
    /// </summary>
    public static class MessageConstants
    {
        /// <summary>
        /// Double Quotes
        /// </summary>
        public const string DoubleQuotes = "\"";

        /// <summary>
        /// Opening Bracket
        /// </summary>
        public const string BracketOpen = "[";

        /// <summary>
        /// Closing Bracket
        /// </summary>
        public const string BracketClose = "]";

        /// <summary>
        /// Elapsed Milliseconds message prefix.
        /// </summary>
        public const string ElapsedMilliseconds = "Elapsed Milliseconds=";

        /// <summary>
        /// Message indicating the Enum parameter with the value of "All" is invalid
        /// </summary>
        public const string EnumParameterAllIsInvalid = "The enum parameter \"All\" is invalid.";

        /// <summary>
        /// Indicates a method has been entered.
        /// </summary>
        public const string MethodEnter = " -- Method Enter";

        /// <summary>
        /// Indicates a method has been exited.
        /// </summary>
        public const string MethodExit = " -- Method Exit";

        /// <summary>
        /// Indicates the value of a parameter to a method is null when it should not be.
        /// </summary>
        public static readonly string ParameterIsEmpty =
            string.Concat("Parameter ", MessageConstants.DoubleQuotes, "{0}", MessageConstants.DoubleQuotes, " is empty, which is not allowed.");

        /// <summary>
        /// Indicates the parameter is invalid.
        /// </summary>
        public static readonly string ParameterIsNotValid =
            string.Concat("Parameter ", MessageConstants.DoubleQuotes, "{0}", MessageConstants.DoubleQuotes, " is not valid.");

        /// <summary>
        /// Indicates the value of a parameter to a method is null when it should not be.
        /// </summary>
        public static readonly string ParameterIsNull =
            string.Concat("Parameter ", MessageConstants.DoubleQuotes, "{0}", MessageConstants.DoubleQuotes, " is null, which is not allowed.");

        /// <summary>
        /// Indicates the value of a parameter to a method is null or empty when it should not be.
        /// </summary>
        public static readonly string ParameterIsNullOrEmpty =
            string.Concat("Parameter ", MessageConstants.DoubleQuotes, "{0}", MessageConstants.DoubleQuotes, " is null or empty, which is not allowed.");

        public static readonly string ExecutingInstallSet = "Executing InstallSet: {0}";
    }
}
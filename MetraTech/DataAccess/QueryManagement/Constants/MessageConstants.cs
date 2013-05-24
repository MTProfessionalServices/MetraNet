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

namespace MetraTech.DataAccess.QueryManagement.Constants
{
    using System.Runtime.InteropServices;

    /// <summary>
    /// Class of message constants
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("71BE2652-95BA-4D74-B0DB-EDA36DACC5B7")]
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
        /// Does not exist message
        /// </summary>
        public const string DoesNotExist = " does not exist ";

        /// <summary>
        /// Elapsed Milliseconds message prefix.
        /// </summary>
        public const string ElapsedMilliseconds = "Elapsed Milliseconds=";

        /// <summary>
        /// Message indicating the Enum parameter with the value of "All" is invalid
        /// </summary>
        public const string EnumParameterAllIsInvalid = "The enum parameter \"All\" is invalid.";

        /// <summary>
        /// Found in folder message
        /// </summary>
        public const string FoundInfolder = " found in the folder ";

        /// <summary>
        /// Message indication the array or collection is empty.
        /// </summary>
        public const string ArrayOrCollectionIsEmpty = "The array or collection is empty.";

        /// <summary>
        /// Message indicating the value of the enumerated type "ValidationResultType" is invalid.
        /// </summary>
        public const string InvalidValidationResultType = "The value of the enumerated type \"ValidationResultType\" is set to \"None\", which is invalid.";

        /// <summary>
        /// Indicates a method has been entered.
        /// </summary>
        public const string MethodEnter = " -- Method Enter";

        /// <summary>
        /// Indicates a method has been exited.
        /// </summary>
        public const string MethodExit = " -- Method Exit";

        /// <summary>
        /// No directories found
        /// </summary>
        public const string NoDirectoriesFound = "No directiories found for one or more types that were searched for.";

        /// <summary>
        /// Indicates no directories of type X were found message prefix.
        /// </summary>
        public const string NoDirectoriesOfType = "No directories of type ";

        /// <summary>
        /// Indicates no files of type X were found message prefix.
        /// </summary>
        public const string NoFilesOfType = "No files of type ";

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

        /// <summary>
        /// The folder message prefix.
        /// </summary>
        public const string TheFolder = "The folder, ";

        /// <summary>
        /// DatabaseTypeEnum Value message prefix
        /// </summary>
        public const string ValuePrefixDatabaseTypeEnum = " databaseTypeEnum=";

        /// <summary>
        /// DataQueryLanguageEnum Value message prefix
        /// </summary>
        public const string ValuePrefixDataQueryLanguageEnum = " dataQueryLanguageEnum=";

        /// <summary>
        /// PerformValidation Value message prefix
        /// </summary>
        public const string ValuePrefixPerformValidation = " performValidation=";

        /// <summary>
        /// QueryFileTypeEnum Value message prefix
        /// </summary>
        public const string ValuePrefixQueryFileTypeEnum = " queryFileTypeEnum=";

        /// <summary>
        /// QueryFolderEnum Value message prefix
        /// </summary>
        public const string ValuePrefixQueryFolderEnum = " queryFolderEnum=";

        /// <summary>
        /// QuerySearchResults.Count Value message prefix
        /// </summary>
        public const string ValuePrefixQuerySearchResultsCount = " querySearchResults.Count=";

        /// <summary>
        /// Search Path value message prefix
        /// </summary>
        public const string ValuePrefixSearchPath = " searchPath=";

        /// <summary>
        /// Search Pattern value message prefix
        /// </summary>
        public const string ValuePrefixSearchPattern = " searchPattern=";

        /// <summary>
        /// Validation Message value message prefix
        /// </summary>
        public const string ValuePrefixValidationMessage = " validationMessage=";

        /// <summary>
        /// Validation Result Type Message value message prefix
        /// </summary>
        public const string ValuePrefixValidationResultType = " validationResultType=";
    }
}
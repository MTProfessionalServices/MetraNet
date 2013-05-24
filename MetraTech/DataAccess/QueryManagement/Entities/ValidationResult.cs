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
// MODULE: ValidationResult.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.Entities
{
    using System;
    using System.Diagnostics;
    using System.Globalization;
    using System.Runtime.InteropServices;

    using Constants;
    using EnumeratedTypes;
    using Helpers;

    /// <summary>
    /// The ValidationResult class det
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("90E6CDC5-4A7E-4712-9810-680D6F8BD681")]
    public class ValidationResult
    {
        /// <summary>
        /// Name of this class.
        /// </summary>
        private const string ClassName = "ValidationResult";

        /// <summary>
        /// The name of the file that was validated
        /// </summary>
        public static string FileOrFolderName
        {
            get;
            private set;
        }

        /// <summary>
        /// The message indicating the result of the validation
        /// </summary>
        public static string ValidationMessage
        {
            get;
            private set;
        }

        /// <summary>
        /// Enumerated type of validation result
        /// </summary>
        public static DirectoryValidationTypeEnum DirectoryValidationType
        {
            get;
            private set;
        }

        /// <summary>
        /// Local logging object
        /// </summary>
        private static ILogger Logger = new Logger(@"Logging\QueryManagement", string.Concat(MessageConstants.BracketOpen, ValidationResult.ClassName, MessageConstants.BracketClose));

        /// <summary>
        /// Prevents a default instance of the ValidationResult class from being instantiated.
        /// </summary>
        private ValidationResult()
        {
        }

        /// <summary>
        /// Creates and initializes an new instance of the ValidationResult class
        /// </summary>
        /// <param name="validationMessage">Validation message describing the validation result.</param>
        /// <param name="directoryValidationType">Enumerated type indicating the validation result.</param>
        /// <param name="fileOrFolderName">The file or foldername of the file/folder that was validated.</param>
        /// <returns>A newly created and initialized instance of a ValicationResult class.</returns>
        public static ValidationResult CreateInstance(string validationMessage, DirectoryValidationTypeEnum directoryValidationType, string fileOrFolderName)
        {
            const string methodName = "[CreateInstance]";
            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (ValidationResult.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, ValidationResult.Logger, null);
            }

            try
            {
                if (string.IsNullOrEmpty(validationMessage))
                {
                    message = string.Concat(methodName, string.Format(CultureInfo.CurrentCulture, MessageConstants.ParameterIsNullOrEmpty, ParameterNameConstants.ValidationMessage));

                    if (ValidationResult.Logger.WillLogFatal)
                    {
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, ValidationResult.Logger, null);
                    }
                    throw new ArgumentException(message);
                }

                if (directoryValidationType == DirectoryValidationTypeEnum.None)
                {
                    message = string.Concat(methodName, string.Format(CultureInfo.CurrentCulture, MessageConstants.InvalidValidationResultType, ParameterNameConstants.DirectoryValidationType));

                    if (ValidationResult.Logger.WillLogFatal)
                    {
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, ValidationResult.Logger, null);
                    }
                    throw new ArgumentException(message);
                }

                // Log parameter values
                if (ValidationResult.Logger.WillLogDebug)
                {
                    message = string.Concat(
                        methodName,
                        MessageConstants.ValuePrefixValidationMessage,
                        validationMessage,
                        MessageConstants.ValuePrefixValidationResultType,
                        directoryValidationType.ToString());

                    LogHelper.WriteLog(message, LogLevelEnum.Debug, ValidationResult.Logger, null);
                }

                DirectoryValidationType = directoryValidationType;
                ValidationMessage = validationMessage;
                FileOrFolderName = fileOrFolderName;
            }
            finally
            {
                // Trace Logging
                if (ValidationResult.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, ValidationResult.Logger, null);
                }
            }

            return new ValidationResult();
        }
    }
}
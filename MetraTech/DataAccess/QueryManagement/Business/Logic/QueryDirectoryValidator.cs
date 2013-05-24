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
// MODULE: QueryDirectoryValidator.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.Business.Logic
{
    using System;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Globalization;
    using System.Linq;
    using System.Runtime.InteropServices;
    using System.Threading.Tasks;

    using Constants;
    using Entities;
    using EnumeratedTypes;
    using Helpers;
    
    /// <summary>
    /// The QueryDirectoryValidator class enforces directory business validation rules pertinent to the QueryManagement Feature
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("58C078FA-9CAE-4804-9763-002B5458CD8A")]
    public class QueryDirectoryValidator : IQueryManagementValidator
    {
        /// <summary>
        /// Name of this class.
        /// </summary>
        private const string ClassName = "QueryDirectoryValidator";

        /// <summary>
        /// Local DirectoryValidationType type object
        /// </summary>
        private static Type DirectoryValidationType = typeof(DirectoryValidationTypeEnum);

        /// <summary>
        /// Array of directory validation types.
        /// </summary>
        private static Array DirectoryValidationTypes = Enum.GetValues(QueryDirectoryValidator.DirectoryValidationType);

        /// <summary>
        /// Local logging object
        /// </summary>
        private static ILogger Logger = new Logger(@"Logging\QueryManagement", string.Concat(MessageConstants.BracketOpen, QueryDirectoryValidator.ClassName, MessageConstants.BracketClose));

        /// <summary>
        /// Initializes a new instance of the QueryDirectoryValidator class.
        /// </summary>
        public QueryDirectoryValidator()
        {
        }

        /// <summary>
        /// Performs directory business validations pertinent to the QueryManagement feature
        /// </summary>
        /// <param name="querySearchResults">Contains the directories to perform the directory validations on.</param>
        /// <returns>A QueryValidationResults class containing the validation results.</returns>
        public ValidationResults Execute(QuerySearchResults querySearchResults)
        {
            const string methodName = "[Execute]";

            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (QueryDirectoryValidator.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryDirectoryValidator.Logger, null);
            }

            try
            {
                if (querySearchResults == null)
                {
                    message = string.Concat(methodName, string.Format(CultureInfo.CurrentCulture, MessageConstants.ParameterIsNull, ParameterNameConstants.QuerySearchResults));

                    if (QueryDirectoryValidator.Logger.WillLogFatal)
                    {
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryDirectoryValidator.Logger, null);
                    }
                    throw new ArgumentException(message);
                }

                if (querySearchResults.Count == 0)
                {
                    message = string.Concat(methodName, string.Format(CultureInfo.CurrentCulture, MessageConstants.ArrayOrCollectionIsEmpty, ParameterNameConstants.QuerySearchResults));

                    if (QueryDirectoryValidator.Logger.WillLogFatal)
                    {
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryDirectoryValidator.Logger, null);
                    }
                    throw new ArgumentException(message);
                }

                // Log parameter values
                if (QueryDirectoryValidator.Logger.WillLogDebug)
                {
                    message = string.Concat(
                        methodName,
                        MessageConstants.ValuePrefixQuerySearchResultsCount,
                        querySearchResults.Count);

                    LogHelper.WriteLog(message, LogLevelEnum.Debug, QueryDirectoryValidator.Logger, null);
                }

                var validationResults = new ValidationResults();

                //// Business Logic
                for (int index = 0; index < querySearchResults.Count; index++)
                {
                    KeyValuePair<string, DataQueryLanguageSearchResults> querySearchResult = querySearchResults.ElementAt(index);

                    foreach (KeyValuePair<DataQueryLanguageEnum, DirectoryTypeNameSearchResults> directoryTypeNameSearchResult in querySearchResult.Value)
                    {
                        foreach (KeyValuePair<DirectorySearchTypeValue, DirectoryListWithFiles> directoryListWithFiles in directoryTypeNameSearchResult.Value)
                        {
                            foreach(DirectoryFiles directoryFiles in directoryListWithFiles.Value)
                            {
                                var validationResult = QueryDirectoryValidator.ValidateDirectory(directoryFiles.BaseFolder, directoryFiles.Files);
                                validationResults.Add(directoryFiles.BaseFolder, validationResult);
                            }
                        }
                    }
                }

                return validationResults;

            }
            finally
            {
                // Trace Logging
                if (QueryDirectoryValidator.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryDirectoryValidator.Logger, null);
                }
            }
        }

        /// <summary>
        /// Performs business validations on the directory and the files contained within it.
        /// </summary>
        /// <param name="directoryName">The name of the directory to perform the business validations on.</param>
        /// <param name="files">The list of files within the directory to perform the business validations on.</param>
        /// <returns>A list of validation results that were created while validating the directory</returns>
        private static List<ValidationResult> ValidateDirectory(string directoryName, Array files)
        {
            const string methodName = "[ValidateDirectory]";
            string message = string.Empty;
            Stopwatch stopwatch = null;

            //// Trace Logging
            if (QueryDirectoryValidator.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryDirectoryValidator.Logger, null);
            }

            try
            {
                // Method Input Parameter Validation
                if (string.IsNullOrEmpty(directoryName))
                {
                    message = string.Concat(methodName, string.Format(CultureInfo.CurrentCulture, MessageConstants.ParameterIsNullOrEmpty, ParameterNameConstants.DirectoryName));

                    if (QueryDirectoryValidator.Logger.WillLogFatal)
                    {
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryDirectoryValidator.Logger, null);
                    }
                    throw new ArgumentException(message);
                }

                if (files == null)
                {
                    message = string.Concat(methodName, string.Format(CultureInfo.CurrentCulture, MessageConstants.ParameterIsNull, ParameterNameConstants.Files));

                    if (QueryDirectoryValidator.Logger.WillLogFatal)
                    {
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryDirectoryValidator.Logger, null);
                    }
                    throw new ArgumentException(message);
                }

                // Log parameter values
                if (QueryDirectoryValidator.Logger.WillLogInfo)
                {
                    message = string.Concat(
                        methodName,
                        "Validating directory:",
                        directoryName);

                    LogHelper.WriteLog(message, LogLevelEnum.Info, QueryDirectoryValidator.Logger, null);
                }

                var listOfValidationResults = new List<ValidationResult>();
                
                foreach (DirectoryValidationTypeEnum directoryValidationTypeEnum in QueryDirectoryValidator.DirectoryValidationTypes)
                {
                    switch (directoryValidationTypeEnum)
                    {
                        case DirectoryValidationTypeEnum.EmptyDirectory:
                            {
                                if (files.Length == 0)
                                {
                                    var validationResult = ValidationResult.CreateInstance(
                                        DirectoryValidationMessageConstants.EmptyDirectory, 
                                        DirectoryValidationTypeEnum.EmptyDirectory, 
                                        directoryName);
                                    listOfValidationResults.Add(validationResult);
                                }
                            }
                            break;
                        case DirectoryValidationTypeEnum.NoQueryInfoFiles:
                            {
                                bool infoFileFound = false;
                                foreach (string fileName in files)
                                {
                                    if (fileName.EndsWith(AllowedFilePostFixes.PostFixes[QueryFileTypeEnum.Info], StringComparison.InvariantCultureIgnoreCase))
                                    {
                                        infoFileFound = true;
                                        break;
                                    }
                                }
                                if (infoFileFound == false)
                                {
                                    var validationResult = 
                                        ValidationResult.CreateInstance(
                                            DirectoryValidationMessageConstants.NoQueryInfoFilesFound, 
                                            DirectoryValidationTypeEnum.NoQueryInfoFiles, 
                                            directoryName);
                                }
                            }
                            break;
                        case DirectoryValidationTypeEnum.DisAllowedFilesFound:
                            {
                                bool databaseAccessFileFound = false;

                                foreach (string fileName in files)
                                {
                                    var matchedAllowedCount = 0;
                                    foreach (KeyValuePair<QueryFileTypeEnum, string> postFix in AllowedFilePostFixes.PostFixes)
                                    {
                                        if (!fileName.EndsWith(postFix.Value, StringComparison.InvariantCultureIgnoreCase))
                                        {
                                            if (postFix.Key == QueryFileTypeEnum.DbAccess)
                                            {
                                                databaseAccessFileFound = true;
                                            }
                                            matchedAllowedCount++;
                                        }
                                    }

                                    if (!databaseAccessFileFound)
                                    {
                                        matchedAllowedCount++;
                                    }

                                    if (matchedAllowedCount > AllowedFilePostFixes.PostFixes.Count)
                                    {
                                        var validationResult = 
                                            ValidationResult.CreateInstance(
                                                DirectoryValidationMessageConstants.DisAllowedFilesFound,
                                                DirectoryValidationTypeEnum.DisAllowedFilesFound, 
                                                directoryName);
                                        listOfValidationResults.Add(validationResult);
                                    }
                                }
                            }
                            break;
                        default:
                            {
                            }
                            break;
                    }
                }

                return listOfValidationResults;
            }
            finally
            {
                //// Trace Logging
                if (QueryDirectoryValidator.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryDirectoryValidator.Logger, null);
                }
            }
        }    
    }
}

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
// MODULE: BatchSequenceHelper.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.Helpers
{
    using System;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Globalization;
    using System.IO;

    using Constants;
    using Entities;
    using EnumeratedTypes;

    /// <summary>
    /// Provides method(s) to help with the Bactch Sequence / Ordered Query Execution
    /// </summary>
    public static class BatchSequenceHelper
    {
        /// <summary>
        /// Name of this class.
        /// </summary>
        private const string ClassName = "BatchSequenceHelper";

        /// <summary>
        /// Local logging object
        /// </summary>
        private static ILogger Logger = new Logger(@"Logging\QueryManagement", string.Concat(MessageConstants.BracketOpen, BatchSequenceHelper.ClassName, MessageConstants.BracketClose));

        /// <summary>
        /// Parses the file specified and returns the list of query names from it.
        /// </summary>
        /// <param name="batchSequenceFileNameAndPath">The file name and file path of the batch sequence file to parse</param>
        /// <returns>A list of query tags sorted in the order the batch sequence file dictates</returns>
        public static List<string> RetrieveBatchQueriesFromBatchSequenceFile(string batchSequenceFileNameAndPath)
        {
            const string methodName = "[RetrieveBatchQueriesFromBatchSequenceFile]";
            string message = null;
            Stopwatch stopwatch = null;

            //// Trace Logging.
            if (BatchSequenceHelper.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, BatchSequenceHelper.Logger, null);
            }
            try
            {
                if (string.IsNullOrEmpty(batchSequenceFileNameAndPath))
                {
                    message = string.Concat(
                        methodName,
                        string.Format(CultureInfo.CurrentCulture,
                        MessageConstants.ParameterIsNullOrEmpty,
                        "batchSequenceFileNameAndPath"));

                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, BatchSequenceHelper.Logger, null);
                    throw new ArgumentException(message);
                }

                //// Parameter Value Debug Logging
                if (BatchSequenceHelper.Logger.WillLogDebug)
                {
                    message =
                        string.Concat(
                            methodName,
                            "batchSequenceFileNameAndPath = ",
                            batchSequenceFileNameAndPath);

                    LogHelper.WriteLog(message, LogLevelEnum.Debug, BatchSequenceHelper.Logger, null);
                }

                if (!File.Exists(batchSequenceFileNameAndPath))
                {
                    message = string.Concat(
                        methodName,
                        string.Format(CultureInfo.CurrentCulture,
                        "The file ",
                        batchSequenceFileNameAndPath,
                        "does not exist"));

                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, BatchSequenceHelper.Logger, null);

                    throw new ArgumentException(message);
                }

                var batchQueriesArray = File.ReadAllLines(batchSequenceFileNameAndPath);
                var batchQueriesList = new List<string>(batchQueriesArray);

                return batchQueriesList;
            }
            finally
            {
                //// Trace logging
                if (BatchSequenceHelper.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, BatchSequenceHelper.Logger, null);
                }
            }
        }

        //public static List<string> MergeBatchQueriesFromCoreAndCustom(

        /// <summary>
        /// Validates the queries in the batch order exist
        /// </summary>
        /// <param name="batchQueryFolderPath">The folder path where the queries and batch query manifest reside</param>
        /// <param name="batchQueryOrder">A list of query names in order according to the batch file</param>
        /// <param name="queryTags">The query tags found on disk.</param>
        public static void ValidateBatchQueries(string batchQueryFolderPath, List<string> batchQueryOrder, List<string> queryTags)
        {
            const string methodName = "[ValidateBatchQueries]";
            string message = null;
            Stopwatch stopwatch = null;

            //// Trace Logging.
            if (BatchSequenceHelper.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, BatchSequenceHelper.Logger, null);
            }
            try
            {
                if (string.IsNullOrEmpty(batchQueryFolderPath))
                {
                    message = string.Concat(
                        methodName,
                        string.Format(CultureInfo.CurrentCulture,
                        MessageConstants.ParameterIsNullOrEmpty,
                        "batchQueryFolderPath"));

                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, BatchSequenceHelper.Logger, null);
                    throw new ArgumentException(message);
                }

                if (batchQueryOrder == null)
                {
                    message = string.Concat(
                        methodName,
                        string.Format(CultureInfo.CurrentCulture,
                        MessageConstants.ParameterIsNull,
                        "batchQueryOrder"));

                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, BatchSequenceHelper.Logger, null);
                    throw new ArgumentException(message);
                }

                if (queryTags == null)
                {
                    message = string.Concat(
                        methodName,
                        string.Format(CultureInfo.CurrentCulture,
                        MessageConstants.ParameterIsNull,
                        "queryTags"));

                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, BatchSequenceHelper.Logger, null);
                    throw new ArgumentException(message);
                }

                if (batchQueryOrder.Count < 1)
                {
                    message = string.Concat(
                        methodName,
                        string.Format(CultureInfo.CurrentCulture,
                        MessageConstants.ParameterIsEmpty,
                        "batchQueryOrder.Count"));

                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, BatchSequenceHelper.Logger, null);
                    throw new ArgumentException(message);
                }

                if (queryTags.Count < 1)
                {
                    message = string.Concat(
                        methodName,
                        string.Format(CultureInfo.CurrentCulture,
                        MessageConstants.ParameterIsEmpty,
                        "queryTags.Count"));

                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, BatchSequenceHelper.Logger, null);
                    throw new ArgumentException(message);
                }

                bool oneOrMoreQueryTagsWereNotFound = false;

                foreach (var queryTagName in queryTags) 
                {
                    bool batchQueryNameWasFound = false;
                    foreach (var batchQueryName in batchQueryOrder)
                    {
                        if (batchQueryName.Equals(queryTagName, StringComparison.InvariantCultureIgnoreCase))
                        {
                            batchQueryNameWasFound = true;
                            break;
                        }
                    }

                    if (!batchQueryNameWasFound)
                    {
                        oneOrMoreQueryTagsWereNotFound = true;

                        message = string.Concat(
                            methodName,
                            "The batch sequenced query tag named ",
                            MessageConstants.DoubleQuotes,
                            queryTagName,
                            MessageConstants.DoubleQuotes,
                            " was not found in the list of batch query tags from the batch query file within the folder path ",
                            MessageConstants.DoubleQuotes,
                            batchQueryFolderPath,
                            MessageConstants.DoubleQuotes);

                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, BatchSequenceHelper.Logger, null);
                    }
                }

                if (oneOrMoreQueryTagsWereNotFound)
                {
                    message = string.Concat(methodName, "One or more query tags were not found.");
                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, BatchSequenceHelper.Logger, null);
                    throw new QueryManagementException(message);
                }
            }
            finally
            {
                //// Trace logging
                if (BatchSequenceHelper.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, BatchSequenceHelper.Logger, null);
                }
            }
        }
    }
}
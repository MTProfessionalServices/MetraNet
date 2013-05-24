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
// MODULE: QuerySearchContext.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.Entities
{
    using System;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Globalization;
    using System.Runtime.InteropServices;

    using Constants;
    using EnumeratedTypes;
    using Helpers;

    /// <summary>
    /// The query search context class is used to provide 
    /// the relevant search criteria to use by the various 
    /// finder classes.
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("DE0FAEB5-6CA6-4453-9E7E-F1FDE66B05CA")]
    public class QuerySearchContext
    {
        /// <summary>
        /// Name of this class
        /// </summary>
        private const string ClassName = "QuerySearchContext";

        /// <summary>
        /// Local logging object
        /// </summary>
        private static ILogger Logger = new Logger(@"Logging\QueryManagement", string.Concat(MessageConstants.BracketOpen, QuerySearchContext.ClassName, MessageConstants.BracketClose));

        /// <summary>
        /// The type of query statements to search for.
        /// </summary>
        public DataQueryLanguageEnum DataQueryLanguageEnum
        {
            get;
            set;
        }

        /// <summary>
        /// The type of database to search for query files for.
        /// </summary>
        public DatabaseTypeEnum DatabaseTypeEnum
        {
            get;
            set;
        }

        /// <summary>
        /// Indicates if validation(s) should be performed while searching
        /// </summary>
        public bool PerformValidation
        {
            get;
            set;
        }

        /// <summary>
        /// Indicates the type of query file being searched for.
        /// </summary>
        public QueryFileTypeEnum QueryFileTypeEnum
        {
            get;
            set;
        }

        /// <summary>
        /// Indicates the query folder being searched in.
        /// </summary>
        public QueryFolderEnum QueryFolderEnum
        {
            get;
            set;
        }

        /// <summary>
        /// The starting directory path to perform the search from
        /// </summary>
        public string SearchPath
        {
            get;
            set;
        }

        /// <summary>
        /// Prevents a default instance of the QuerySearchContext class from being instantiated.
        /// </summary>
        private QuerySearchContext()
        {
        }

        /// <summary>
        /// Creates and initializes and instance of the QuerySearchContext class.
        /// </summary>
        /// <param name="dataQueryLanguageEnum">The dataQueryLanguageEnum for this QuerySearchContext class</param>
        /// <param name="databaseTypeEnum">The databaseTypeEnum for this QuerySearchContext class</param>
        /// <param name="performValidation">The performValidation for this QuerySearchContext class</param>
        /// <param name="queryFileTypeEnum">The queryFileTypeEnum for this QuerySearchContext class</param>
        /// <param name="queryFolderEnum">The queryFolderEnum for this QuerySearchContext class</param>
        /// <param name="searchPath">The searchPath for this QuerySearchContext class</param>
        /// <returns>An initialized instance of the QuerySearchContext class</returns>
        public static QuerySearchContext CreateInstance(
            DataQueryLanguageEnum dataQueryLanguageEnum, 
            DatabaseTypeEnum databaseTypeEnum, 
            bool performValidation,
            QueryFileTypeEnum queryFileTypeEnum,
            QueryFolderEnum queryFolderEnum,
            string searchPath)
        {
            const string methodName = "[CreateInstance]";
            string message = null;

            Stopwatch stopwatch = null;

            if (Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, Logger, null);
            }

            try
            {
                if (string.IsNullOrEmpty(searchPath))
                {
                    message = string.Concat(methodName, string.Format(CultureInfo.CurrentCulture, MessageConstants.ParameterIsNullOrEmpty, "searchPath"));

                    if (Logger.WillLogFatal)
                    {
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, Logger, null);
                    }
                    throw new ArgumentException(message);
                }

                // Perform additional business logic checks here.
                // Such as invalid combinations of search values
                // For example:  Search for ddl files in sqlcore

                if (Logger.WillLogDebug)
                {
                    message = string.Concat(
                        methodName,
                        MessageConstants.ValuePrefixDatabaseTypeEnum,
                        databaseTypeEnum.ToString(),
                        MessageConstants.ValuePrefixDataQueryLanguageEnum,
                        dataQueryLanguageEnum.ToString(),
                        MessageConstants.ValuePrefixPerformValidation,
                        performValidation.ToString(),
                        MessageConstants.ValuePrefixQueryFileTypeEnum,
                        queryFileTypeEnum.ToString(),
                        MessageConstants.ValuePrefixQueryFolderEnum,
                        queryFolderEnum.ToString(),
                        MessageConstants.ValuePrefixSearchPath,
                        searchPath);

                    LogHelper.WriteLog(message, LogLevelEnum.Debug, Logger, null);
                }

                var querySearchContext = new QuerySearchContext();

                querySearchContext.DatabaseTypeEnum = databaseTypeEnum;
                querySearchContext.DataQueryLanguageEnum = dataQueryLanguageEnum;
                querySearchContext.PerformValidation = performValidation;
                querySearchContext.QueryFileTypeEnum = queryFileTypeEnum;
                querySearchContext.QueryFolderEnum = queryFolderEnum;
                querySearchContext.SearchPath = searchPath;

                return querySearchContext;
            }
            finally
            {
                if (Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, Logger, null);
                }
            }
        }
    }
}
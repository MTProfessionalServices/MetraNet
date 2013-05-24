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
// MODULE: QueryFinder.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.Business.Logic
{
    using System;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Globalization;
    using System.IO;
    using System.Linq;
    using System.Runtime.InteropServices;
    using System.Text;
    using System.Threading.Tasks;

    using Constants;
    using Entities;
    using EnumeratedTypes;
    using Helpers;

    /// <summary>
    /// The QueryFinder class is responsible for locating the 
    /// query folders and files within them using the search context specified
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("2529063C-C986-4011-8809-F86295E26E49")]
    public static class QueryFinder
    {
        /// <summary>
        /// Name of the Batch Query Sequence File
        /// </summary>
        private const string BatchQuerySequenceFilName = "___BatchQuerySequence.txt";

        /// <summary>
        /// Name of this class.
        /// </summary>
        private const string ClassName = "QueryFinder";

        /// <summary>
        /// Local Type object representing a DatabaseDefinitionTypeEnum Type
        /// </summary>
        private static readonly Type databaseDefinitionTypeEnumType = typeof(DatabaseDefinitionTypeEnum);

        /// <summary>
        /// Local Type object representing a DatabaseModelingTypeEnum Type
        /// </summary>
        private static readonly Type databaseModelingTypeEnum = typeof(DatabaseModelingTypeEnum);

        /// <summary>
        /// Local logging object
        /// </summary>
        private static ILogger Logger = new Logger(@"Logging\QueryManagement", string.Concat(MessageConstants.BracketOpen, QueryFinder.ClassName, MessageConstants.BracketClose));

        /// <summary>
        /// String array of query file type enum names
        /// </summary>
        private static string[] QueryFileTypeEnumNames = Enum.GetNames(typeof(QueryFileTypeEnum));

        /// <summary>
        /// Locates queries in the folder specified and return them in sorted order.
        /// </summary>
        /// <param name="OrderedQueryPath">The path to search for the query files.</param>
        /// <returns>A sorted list of query tags.</returns>
        public static List<string> Execute(string orderedQueryPath)
        {
            const string methodName = "[Execute]";
            string message = null;
            Stopwatch stopwatch = null;

            //// Trace Logging.
            if (QueryFinder.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryFinder.Logger, null);
            }

            try
            {
                //// Validate parameter OrderdQueryPath
                if (string.IsNullOrEmpty(orderedQueryPath))
                {
                    message = string.Concat(
                        methodName,
                        string.Format(CultureInfo.CurrentCulture,
                        MessageConstants.ParameterIsNullOrEmpty,
                        "orderedQueryPath"));

                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryFinder.Logger, null);

                    throw new ArgumentException(message);
                }

                if (!Directory.Exists(orderedQueryPath))
                {
                    message = string.Concat(
                        methodName,
                        string.Format(CultureInfo.CurrentCulture,
                        MessageConstants.ParameterIsNotValid,
                        "orderedQueryPath"));

                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryFinder.Logger, null);

                    throw new ArgumentException(message);
                }

                //// Parameter Value Debug Logging
                if (QueryFinder.Logger.WillLogDebug)
                {
                    message =
                        string.Concat(
                            methodName,
                            "orderedQueryPath = ",
                            orderedQueryPath);

                    LogHelper.WriteLog(message, LogLevelEnum.Debug, QueryFinder.Logger, null);
                }

                //// Validate the file ___BatchQuerySequence.txt Exists
                var batchQuerySequenceFileNameAndPath = Path.Combine(orderedQueryPath, QueryFinder.BatchQuerySequenceFilName);

                if (!File.Exists(batchQuerySequenceFileNameAndPath))
                {
                    message = string.Concat(
                        methodName,
                        string.Format(CultureInfo.CurrentCulture,
                        "The file ",
                        batchQuerySequenceFileNameAndPath,
                        "does not exist"));

                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryFinder.Logger, null);

                    throw new QueryManagementException(message);
                }

                //// Find and sort both core and custom if both exist, replacing 
                //// core with custom, else return just core or custom.
                bool orderedQueryPathIsCore = false;

                bool coreOrderedQueryPathExists = false;
                bool customOrderedQueryPathExists = false;

                string coreOrderedQueryPath = string.Empty;
                string customOrderedQueryPath = string.Empty;

                List<string> coreBatchQueryOrder = null;
                List<string> customBatchQueryOrder = null;

                List<string> coreQueryTags = null;
                List<string> customQueryTags = null;

                //// Determine if OrderedQueryPath is Core or Custom
                if (orderedQueryPath.IndexOf(QueryFolderEnum.SqlCore.ToString(), 0, StringComparison.InvariantCultureIgnoreCase) > -1)
                {
                    orderedQueryPathIsCore = true;
                    coreOrderedQueryPathExists = true;
                    coreOrderedQueryPath = orderedQueryPath;
                    coreBatchQueryOrder = BatchSequenceHelper.RetrieveBatchQueriesFromBatchSequenceFile(batchQuerySequenceFileNameAndPath);
                    coreQueryTags = QueryFinder.LocateQueryTagsInDirectory(coreOrderedQueryPath);
                }
                else
                {
                    customOrderedQueryPathExists = true;
                    customOrderedQueryPath = orderedQueryPath;
                    customBatchQueryOrder = BatchSequenceHelper.RetrieveBatchQueriesFromBatchSequenceFile(batchQuerySequenceFileNameAndPath);
                    customQueryTags = QueryFinder.LocateQueryTagsInDirectory(customOrderedQueryPath);
                }

                //// Check to see if there is a core or custom folder that matches the 
                //// orderedQueryPath passed in depending on if it is Core or Custom
                if (orderedQueryPathIsCore)
                {
                    customOrderedQueryPath = coreOrderedQueryPath.Replace(QueryFolderEnum.SqlCore.ToString(), QueryFolderEnum.SqlCustom.ToString());
                    if (Directory.Exists(customOrderedQueryPath))
                    {
                        customOrderedQueryPathExists = true;
                        customBatchQueryOrder = BatchSequenceHelper.RetrieveBatchQueriesFromBatchSequenceFile(batchQuerySequenceFileNameAndPath);
                        customQueryTags = QueryFinder.LocateQueryTagsInDirectory(customOrderedQueryPath);
                        BatchSequenceHelper.ValidateBatchQueries(coreOrderedQueryPath, coreBatchQueryOrder, coreQueryTags);
                    }
                }
                else
                {
                    coreOrderedQueryPath = customOrderedQueryPath.Replace(QueryFolderEnum.SqlCustom.ToString(), QueryFolderEnum.SqlCore.ToString());
                    if (Directory.Exists(coreOrderedQueryPath))
                    {
                        customOrderedQueryPathExists = true;
                        coreBatchQueryOrder = BatchSequenceHelper.RetrieveBatchQueriesFromBatchSequenceFile(batchQuerySequenceFileNameAndPath);
                        coreQueryTags = QueryFinder.LocateQueryTagsInDirectory(coreOrderedQueryPath);
                        BatchSequenceHelper.ValidateBatchQueries(customOrderedQueryPath, customBatchQueryOrder, customQueryTags);
                    }
                }

                var orderedQueryTags = new List<string>();

                //// Only core batch queries exist for this folder.
                if (coreOrderedQueryPathExists && !customOrderedQueryPathExists)
                {
                    foreach (var queryTagName in coreBatchQueryOrder) 
                    {
                        foreach (var batchQueryName in coreQueryTags)
                        {
                            if (batchQueryName.Equals(queryTagName, StringComparison.InvariantCultureIgnoreCase))
                            {   
                                orderedQueryTags.Add(batchQueryName);
                                break;
                            }
                        }
                    }
                }
                else
                {
                    foreach (var queryTagName in customBatchQueryOrder)
                    {
                        foreach (var batchQueryName in customQueryTags)
                        {
                            if (batchQueryName.Equals(queryTagName, StringComparison.InvariantCultureIgnoreCase))
                            {
                                orderedQueryTags.Add(batchQueryName);
                                break;
                            }
                        }
                    }
                }

                return orderedQueryTags;
            }
            finally
            {
                //// Trace logging
                if (QueryFinder.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryFinder.Logger, null);
                }
            }
        }

        /// <summary>
        /// Finds all the folders and files using the search criteria provided by the querySearchContext
        /// </summary>
        /// <param name="querySearchContext">The search context containing the search criteria to perform the search with.</param>
        /// <returns>Dictionary containing folder type as an object with an enumerated list of strings representing the directories found from the search.</returns>
        public static QuerySearchResults Execute(QuerySearchContext querySearchContext)
        {
            const string methodName = "[Execute]";
            string message = null;
            Stopwatch stopwatch = null;
            
            //// Trace Logging.
            if (QueryFinder.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryFinder.Logger, null);
            }

            try
            {
                //// Validate parameter querySearchContext
                if (querySearchContext == null)
                {
                    message = string.Concat(
                        methodName,
                        string.Format(CultureInfo.CurrentCulture,
                        MessageConstants.ParameterIsNull,
                        ParameterNameConstants.QuerySearchContext));

                    if (QueryFinder.Logger.WillLogFatal)
                    {
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryFinder.Logger, null);
                    }
                    throw new ArgumentException(message);
                }

                //// Validate parameter querySearchContext.SearchPath
                if (string.IsNullOrEmpty(querySearchContext.SearchPath))
                {
                    message = string.Concat(
                        methodName, 
                        string.Format(CultureInfo.CurrentCulture, 
                        MessageConstants.ParameterIsNullOrEmpty,
                        ParameterNameConstants.SearchPath));

                    if (QueryFinder.Logger.WillLogFatal)
                    {
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryFinder.Logger, null);
                    }
                    throw new ArgumentException(message);
                }

                //// Validate SearchPath directory to search from exists
                if (Directory.Exists(querySearchContext.SearchPath) == false)
                {
                    message = string.Concat(
                        methodName, 
                        MessageConstants.TheFolder, 
                        MessageConstants.DoubleQuotes,
                        querySearchContext.SearchPath, 
                        MessageConstants.DoubleQuotes, 
                        MessageConstants.DoesNotExist);

                    if (QueryFinder.Logger.WillLogFatal)
                    {
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryFinder.Logger, null);
                    }
                    throw new ArgumentException(message);
                }

                //// Parameter Value Debug Logging
                if (QueryFinder.Logger.WillLogDebug)
                {
                    message =
                        string.Concat(
                            methodName,
                            MessageConstants.ValuePrefixDatabaseTypeEnum,
                            querySearchContext.DatabaseTypeEnum.ToString(),
                            MessageConstants.ValuePrefixDataQueryLanguageEnum,
                            querySearchContext.DataQueryLanguageEnum.ToString(),
                            MessageConstants.ValuePrefixPerformValidation,
                            querySearchContext.PerformValidation.ToString(),
                            MessageConstants.ValuePrefixQueryFileTypeEnum,
                            querySearchContext.QueryFileTypeEnum.ToString(),
                            MessageConstants.ValuePrefixQueryFolderEnum,
                            querySearchContext.QueryFolderEnum.ToString(),
                            MessageConstants.ValuePrefixSearchPath,
                            querySearchContext.SearchPath);

                    LogHelper.WriteLog(message, LogLevelEnum.Debug, QueryFinder.Logger, null);
                }

                //// Business Logic
                var baseDirectories = QueryFinder.FindSqlBaseDirectories(querySearchContext.SearchPath);
                var querySearchResults = new QuerySearchResults();
              
                for (int index = 0; index < baseDirectories.Count(); index++)
                {
                    KeyValuePair<QueryFolderEnum, Array> kvp = baseDirectories.ElementAt(index);
                    foreach (string folder in kvp.Value)
                    {
                        string installFolder = string.Concat(folder, QuerySearchConstants.Install);
                        string queriesFolder = string.Concat(folder, QuerySearchConstants.Queries);

                        var directoryDataLanguageSearchResults = new DataQueryLanguageSearchResults();

                        switch (querySearchContext.DataQueryLanguageEnum)
                        {
                            case DataQueryLanguageEnum.All:
                                {
                                    if (Directory.Exists(installFolder))
                                    {
                                        var results = QueryFinder.FindDirectories(DataQueryLanguageEnum.DataDefinitionLanguage, installFolder);
                                        directoryDataLanguageSearchResults.Add(DataQueryLanguageEnum.DataDefinitionLanguage, results);
                                        querySearchResults.Add(installFolder, directoryDataLanguageSearchResults);
                                    }

                                    if (Directory.Exists(queriesFolder))
                                    {
                                        var results = QueryFinder.FindDirectories(DataQueryLanguageEnum.DataModelingLanguage, queriesFolder);
                                        directoryDataLanguageSearchResults = new DataQueryLanguageSearchResults();
                                        directoryDataLanguageSearchResults.Add(DataQueryLanguageEnum.DataModelingLanguage, results);
                                        querySearchResults.Add(queriesFolder, directoryDataLanguageSearchResults);
                                    }
                                }
                                break;
                            case DataQueryLanguageEnum.DataDefinitionLanguage:
                                {
                                    if (Directory.Exists(installFolder))
                                    {
                                        var results = QueryFinder.FindDirectories(DataQueryLanguageEnum.DataDefinitionLanguage, installFolder);
                                        directoryDataLanguageSearchResults.Add(DataQueryLanguageEnum.DataDefinitionLanguage, results);
                                        querySearchResults.Add(installFolder, directoryDataLanguageSearchResults);
                                    }
                                }
                                break;
                            case DataQueryLanguageEnum.DataModelingLanguage:
                                {
                                    if (Directory.Exists(queriesFolder))
                                    {
                                        var results = QueryFinder.FindDirectories(DataQueryLanguageEnum.DataModelingLanguage, queriesFolder);
                                        directoryDataLanguageSearchResults.Add(DataQueryLanguageEnum.DataModelingLanguage, results);
                                        querySearchResults.Add(queriesFolder, directoryDataLanguageSearchResults);
                                    }
                                }
                                break;
                        }
                    }
                }

                return querySearchResults;
            }
            finally
            {
                //// Trace logging
                if (QueryFinder.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName, 
                        MessageConstants.BracketOpen, 
                        MessageConstants.ElapsedMilliseconds, 
                        stopwatch.ElapsedMilliseconds, 
                        MessageConstants.BracketClose, 
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryFinder.Logger, null);
                }
            }
        }

        /// <summary>
        /// Finds the directories according that match the DataQueryLanguageEnum specified within the search path specified.
        /// </summary>
        /// <param name="dataQueryLanguageEnum">The type of directories to locate.</param>
        /// <param name="searchPath">The path to search for the type of directories to locate.</param>
        /// <returns>An initialized instance of a DirectoryTypeNameSearchResults class containing the directories searched for.</returns>
        private static DirectoryTypeNameSearchResults FindDirectories(DataQueryLanguageEnum dataQueryLanguageEnum, string searchPath)
        {
            const string methodName = "[FindDirectories]";
            string message = null;
            Stopwatch stopwatch = null;

            //// Trace Logging
            if (QueryFinder.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryFinder.Logger, null);
            }

            try
            {
                //// Validate parameter searchPath
                if (string.IsNullOrEmpty(searchPath))
                {
                    message = string.Concat(
                            methodName, 
                                string.Format(CultureInfo.CurrentCulture, 
                                MessageConstants.ParameterIsNullOrEmpty, 
                                ParameterNameConstants.SearchPath));

                    if (QueryFinder.Logger.WillLogFatal)
                    {
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryFinder.Logger, null);
                    }
                    throw new ArgumentException(message);
                }

                //// Validate parameter dataQueryLanguageEnum
                if (dataQueryLanguageEnum == DataQueryLanguageEnum.All)
                {
                    message = string.Concat(
                        methodName,  
                            MessageConstants.EnumParameterAllIsInvalid, 
                            ParameterNameConstants.DataQueryLanguageEnum);

                    if (QueryFinder.Logger.WillLogFatal)
                    {
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryFinder.Logger, null);
                    }
                    throw new ArgumentException(message);
                }

                //// Business Logic
                string[] directoryEnumNames = null;
                Type type = null;
                
                switch (dataQueryLanguageEnum)
                {
                    case DataQueryLanguageEnum.DataDefinitionLanguage:
                        {
                            directoryEnumNames = Enum.GetNames(databaseDefinitionTypeEnumType);
                            type = databaseDefinitionTypeEnumType;
                        }
                        break;
                    case DataQueryLanguageEnum.DataModelingLanguage:
                        {
                            directoryEnumNames = new string[] { QuerySearchConstants.Wildcard };  // Currrently the dml is not stored in "named" folders.
                            type = databaseModelingTypeEnum;
                        }
                        break;
                }

                var directoryTypeNameSearchResults = new DirectoryTypeNameSearchResults();

                for (int index = 0; index < directoryEnumNames.Length; index++)
                {
                    var directories = Directory.GetDirectories(searchPath, directoryEnumNames[index], SearchOption.AllDirectories);
                    if (directories.Count() > 0)
                    {
                        var directorySearchTypeValue = DirectorySearchTypeValue.CreateInstance(type, index);
                        var directoryListWithFiles = QueryFinder.FindFiles(directories);

                        directoryTypeNameSearchResults.Add(directorySearchTypeValue, directoryListWithFiles);
                    }
                }

                //// Post Validations ?

                return directoryTypeNameSearchResults;
            }
            finally
            {
                //// Trace Logging
                if (QueryFinder.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryFinder.Logger, null);
                }
            }
        }

        /// <summary>
        /// Finds all files within each directory contained in the Array of directories specified.
        /// </summary>
        /// <param name="directories">An array of directory names to find files within.</param>
        /// <returns>An initialized DirectoryListWithFiles object</returns>
        private static DirectoryListWithFiles FindFiles(Array directories)
        {
            const string methodName = "[FindFiles]";
            string message = null;
            Stopwatch stopwatch = null;

            //// Trace Logging.
            if (QueryFinder.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryFinder.Logger, null);
            }

            try
            {
                //// Validate parameter directories
                if (directories == null)
                {
                    message = string.Concat(methodName, string.Format(CultureInfo.CurrentCulture, MessageConstants.ParameterIsNull, ParameterNameConstants.Directories));

                    if (QueryFinder.Logger.WillLogInfo)
                    {
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryFinder.Logger, null);
                    }
                    throw new ArgumentException(message);
                }

                //// Validate parameter directories.Length
                if (directories.Length == 0)
                {
                    message = string.Concat(methodName, string.Format(CultureInfo.CurrentCulture, MessageConstants.ParameterIsEmpty, ParameterNameConstants.Directories));

                    if (QueryFinder.Logger.WillLogInfo)
                    {
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryFinder.Logger, null);
                    }
                    throw new ArgumentException(message);
                }

                //// Business Logic
                var directoryListWithFiles = new DirectoryListWithFiles();

                foreach (string directoryName in directories)
                {
                    var filenames = Directory.GetFiles(directoryName, QuerySearchConstants.Wildcard, SearchOption.TopDirectoryOnly);
                    var directoryFiles = DirectoryFiles.CreateInstance(directoryName, filenames);
                    directoryListWithFiles.Add(directoryFiles);
                }

                return directoryListWithFiles;
            }
            finally
            {
                //// Trace Logging
                if (QueryFinder.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryFinder.Logger, null);
                }
            }
        }

        /// <summary>
        /// Finds all the QueryFolderEnum type folders below the searchPath specified
        /// </summary>
        /// <param name="searchPath">The folder to start searching from.</param>
        /// <returns>a dictionary containing all the folders found keyed by the QueryFolderEnum value</returns>
        private static Dictionary<QueryFolderEnum, Array> FindSqlBaseDirectories(string searchPath)
        {
            const string methodName = "[FindSqlBaseDirectories]";
            string message = null;

            Stopwatch stopwatch = null;

            //// Trace Logging
            if (QueryFinder.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryFinder.Logger, null);
            }

            try
            {
                //// Validate Parameter searchPath
                if (string.IsNullOrEmpty(searchPath))
                {
                    message = string.Concat(methodName, string.Format(CultureInfo.CurrentCulture, MessageConstants.ParameterIsNullOrEmpty, ParameterNameConstants.SearchPath));

                    if (QueryFinder.Logger.WillLogInfo)
                    {
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryFinder.Logger, null);
                    }
                    throw new ArgumentException(message);
                }

                //// Parameter Value Debug Logging
                if (QueryFinder.Logger.WillLogDebug)
                {
                    message =
                        string.Concat(
                            methodName,
                            MessageConstants.ValuePrefixSearchPath,
                            searchPath);

                    LogHelper.WriteLog(message, LogLevelEnum.Debug, QueryFinder.Logger, null);
                }

                //// Business Logic
                string[] directoryEnumNames = Enum.GetNames(typeof(QueryFolderEnum));
                Array directoryEnumValues = Enum.GetValues(typeof(QueryFolderEnum));

                var dictionary = new Dictionary<QueryFolderEnum, Array>();

                for (int index = 0; index < directoryEnumNames.Count(); index++)
                {
                    if (directoryEnumNames[index].Equals("All", StringComparison.CurrentCultureIgnoreCase))
                    {
                        continue;
                    }

                    var results = Directory.GetDirectories(searchPath, directoryEnumNames[index], SearchOption.AllDirectories);
                    QueryFolderEnum queryFolderEnum = (QueryFolderEnum)directoryEnumValues.GetValue(index);

                    if (queryFolderEnum == QueryFolderEnum.SqlCore && results.Count() == 0)
                    {
                        message = string.Concat(methodName, MessageConstants.NoDirectoriesFound);

                        if (QueryFinder.Logger.WillLogFatal)
                        {
                            LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryFinder.Logger, null);
                        }
                        throw new QueryManagementException(message);
                    }

                    dictionary.Add(queryFolderEnum, results);
                }

                return dictionary;
            }
            finally
            {
                //// Trace Logging
                if (QueryFinder.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryFinder.Logger, null);
                }
            }
        }

        /// <summary>
        /// Locates the queryTags in a specified directory
        /// </summary>
        /// <param name="queryPath">The folder path containging the queryTags</param>
        /// <returns>A list containging strings that represent the queryTags</returns>
        private static List<string> LocateQueryTagsInDirectory(string queryPath)
        {
            const string methodName = "[LocateQueryTagsInDirectory]";
            string message = null;
            Stopwatch stopwatch = null;

            //// Trace Logging.
            if (QueryFinder.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryFinder.Logger, null);
            }

            try
            {
                //// Validate parameter queryPath
                if (string.IsNullOrEmpty(queryPath))
                {
                    message = string.Concat(
                        methodName,
                        string.Format(CultureInfo.CurrentCulture,
                        MessageConstants.ParameterIsNullOrEmpty,
                        "queryPath"));

                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryFinder.Logger, null);

                    throw new ArgumentException(message);
                }

                if (!Directory.Exists(queryPath))
                {
                    message = string.Concat(
                        methodName,
                        string.Format(CultureInfo.CurrentCulture,
                        "The directory ",
                        queryPath,
                        " does not exist"));

                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryFinder.Logger, null);

                    throw new ArgumentException(message);
                }

                //// Parameter Value Debug Logging
                if (QueryFinder.Logger.WillLogDebug)
                {
                    message =
                        string.Concat(
                            methodName,
                            "queryPath = ",
                            queryPath);

                    LogHelper.WriteLog(message, LogLevelEnum.Debug, QueryFinder.Logger, null);
                }

                //// Business Logic
                var databaseType = QueryManagementConfiguration.Configuration.PlatformDatabase.ToString();
                var files = Directory.GetFiles(queryPath);
                var queryTags = new Dictionary<string, QueryTagProperties>();

                var infoSearch = QuerySearchConstants.Info.Replace(QuerySearchConstants.Wildcard, string.Empty);
                QueryTagProperties queryTagProperties;

                var all = QueryFileTypeEnum.All.ToString();
                var common = QueryFileTypeEnum.Common.ToString();
                var dbaccess = QueryFileTypeEnum.DbAccess.ToString();

                // Determine all tags first
                foreach (string filenameWithPath in files)
                {
                    string fileNameWithoutExtension = Path.GetFileNameWithoutExtension(filenameWithPath);
                    string fileExtension = Path.GetExtension(filenameWithPath);
                    string queryTag;

                    if (filenameWithPath.EndsWith("DbAccess.xml", StringComparison.InvariantCultureIgnoreCase))
                    {
                        continue;
                    }

                    int firstPeriodIndex = fileNameWithoutExtension.IndexOf(".");

                    if (firstPeriodIndex > -1)
                    {
                        queryTag = fileNameWithoutExtension.Substring(0, firstPeriodIndex);
                    }
                    else
                    {
                        continue;
                    }

                    string filetype = fileNameWithoutExtension.Substring(queryTag.Length + 1).ToLower();

                    if (queryTags.ContainsKey(queryTag))
                    {
                        queryTagProperties = queryTags[queryTag];
                    }
                    else
                    {
                        queryTagProperties = new QueryTagProperties();
                        queryTagProperties.DbAccessFileName = "DbAccess.xml";
                        queryTagProperties.DbAccessFilePath = Path.Combine(QueryManagementConfiguration.MetraNetInstallDirectory, @"Config\SqlCore\Queries\Database");
                        queryTagProperties.QueryTag = queryTag;
                        queryTags.Add(queryTag, queryTagProperties);
                    }

                    // Determine File Type
                    for (int index = 0; index < QueryFinder.QueryFileTypeEnumNames.Length; index++)
                    {
                        if (QueryFinder.QueryFileTypeEnumNames[index].Equals(common, StringComparison.InvariantCultureIgnoreCase) &&
                          filetype.Equals(QueryFileTypeEnum.Common.ToString(), StringComparison.InvariantCultureIgnoreCase))
                        {
                            queryTagProperties.QueryFilePath = queryPath;
                            queryTagProperties.QueryFileName = string.Concat(fileNameWithoutExtension, fileExtension);
                            break;
                        }

                        if (QueryFinder.QueryFileTypeEnumNames[index].Equals(databaseType, StringComparison.InvariantCultureIgnoreCase) &&
                          filetype.Equals(databaseType, StringComparison.InvariantCultureIgnoreCase))
                        {
                            if (string.IsNullOrEmpty(queryTagProperties.QueryFilePath))
                            {
                                queryTagProperties.QueryFilePath = queryPath;
                                queryTagProperties.QueryFileName = string.Concat(fileNameWithoutExtension, fileExtension);
                            }
                            break;
                        }
                    }

                    queryTags[queryTag] = queryTagProperties;
                }

                var queryTags2 = new Dictionary<string, QueryTagProperties>();
                foreach (var qp in queryTags)
                {
                    if (!string.IsNullOrEmpty(qp.Value.QueryFileName))
                    {
                        queryTags2.Add(qp.Key, qp.Value);
                    }
                }

                var list = new List<string>();
                foreach (KeyValuePair<string, QueryTagProperties> kvp in queryTags2)
                {
                    list.Add(kvp.Key);
                }

                return list;
            }
            finally
            {
                //// Trace logging
                if (QueryFinder.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryFinder.Logger, null);
                }
            }
        }
    }

    /// <summary>
    /// Used because the structure chosen doesn't support modification like a class.
    /// </summary>
    internal class StringComparer : IEqualityComparer<string>
    {
      /// <summary>
      /// Compares string a to string with case insensitivity.
      /// </summary>
      /// <param name="a">The first string to compare</param>
      /// <param name="b">The second string to compare</param>
      /// <returns></returns>
      public bool Equals(string a, string b)
      {
        if (a.Equals(b, StringComparison.InvariantCultureIgnoreCase))
        {
          return true;
        }

        return false;
      }

      public int GetHashCode(string s)
      {
        return -1;
      }
    }
}
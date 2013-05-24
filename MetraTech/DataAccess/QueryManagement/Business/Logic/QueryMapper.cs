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
// MODULE: QueryMapper.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.Business.Logic
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Globalization;
    using System.IO;
    using System.Linq;
    using System.Runtime.InteropServices;
    using System.Text.RegularExpressions;
    
    using Constants;
    using Entities;
    using EnumeratedTypes;
    using Helpers;

    /// <summary>
    /// Provides access into the MetraNet query and file structures
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("224F6FD8-0AE7-4BBA-94B0-73512C9EFEAC")]
    public class QueryMapper : IQueryMapper
    {
        /// <summary>
        /// Name of this class.
        /// </summary>
        private const string ClassName = "QueryMapper";

        /// <summary>
        /// Local logging object
        /// </summary>
        private static ILogger Logger = new Logger(@"Logging\QueryManagement", string.Concat(MessageConstants.BracketOpen, QueryMapper.ClassName, MessageConstants.BracketClose));

        /// <summary>
        /// 
        /// </summary>
        private static string [] QueryFileTypeEnumNames = Enum.GetNames(typeof(QueryFileTypeEnum));

        /// <summary>
        /// 
        /// </summary>
        private Array QueryFileTypeEnuValues = Enum.GetValues(typeof(QueryFileTypeEnum));

        /// <summary>
        /// Indicates if the Query Management Feature set is enabled.
        /// </summary>
        public bool Enabled
        {
            get
            {
                return QueryManagementConfiguration.Configuration.Enabled;
            }
        }

        /// <summary>
        /// Allows the directory to search for query files to be overridden
        /// </summary>
        public static string SearchDirectoryOverride
        {
            get;
            set;
        }

        /// <summary>
        /// Creates a new instance of the QueryMapper class.
        /// </summary>
        public QueryMapper()
        {
        }

        /// <summary>
        /// Applies one querytag per query "file" logic to SqlCore/SqlCustom folders
        /// </summary>
        /// <param name="querySearchResults">The QuerySearchResults containing the query directories and files per their location within the MetraNet system.</param>
        /// <returns></returns>
        private static QueryTags CalculateQueryTags(QuerySearchContext querySearchContext, QuerySearchResults querySearchResults)
        {
            const string methodName = "[CalculateQueryTags]";
            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (QueryMapper.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryMapper.Logger, null);
            }

            try
            {
                var allQueryTags = new QueryTags();

                for (int index = 0; index < querySearchResults.Count; index++)
                {
                    KeyValuePair<string, DataQueryLanguageSearchResults> querySearchResult = querySearchResults.ElementAt(index);

                    foreach (KeyValuePair<DataQueryLanguageEnum, DirectoryTypeNameSearchResults> directoryTypeNameSearchResult in querySearchResult.Value)
                    {
                        foreach (KeyValuePair<DirectorySearchTypeValue, DirectoryListWithFiles> directoryListWithFiles in directoryTypeNameSearchResult.Value)
                        {
                            foreach (DirectoryFiles directoryFiles in directoryListWithFiles.Value)
                            {
                                CalculateQueryTagsInDirectory(allQueryTags, querySearchContext, directoryListWithFiles.Key, directoryFiles);
                            }
                        }
                    }
                }

                var finalQueryTags = new QueryTags();
                foreach (KeyValuePair<string, QueryTagProperties> kvp in allQueryTags)
                {
                    if (!string.IsNullOrEmpty(kvp.Value.QueryFileName))
                    {
                        finalQueryTags.Add(kvp.Key, kvp.Value);
                    }
                }

                return finalQueryTags;
            }
            catch (Exception exception)
            {
                message =
                    string.Concat(
                        methodName,
                        "Exception caught: ",
                        exception.Message);

                LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryMapper.Logger, null);
                throw;
            }
            finally
            {
                // Trace Logging
                if (QueryMapper.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryMapper.Logger, null);
                }
            }
        }

        /// <summary>
        /// Determines QueryTagProperties list from a given directory
        /// </summary>
        /// <param name="querySearchContext">The query search context that located the query files.</param>
        /// <param name="directorySearchTypeValue">The type of enum that represents the folder the query files are located.</param>
        /// <param name="directoryFiles">A dictionary keyed by a string representing the folder the query files reside in
        /// and valued by a list that represents the files found within the directory.</param>
        /// <returns>A list of effective querytagproperties for the directory</returns>
        private static void CalculateQueryTagsInDirectory(QueryTags queryTags,
            QuerySearchContext querySearchContext, DirectorySearchTypeValue directorySearchTypeValue, DirectoryFiles directoryFiles)
        {
            const string methodName = "[CalculateQueryTagsInDirectory]";
            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (QueryMapper.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryMapper.Logger, null);
            }
            try
            {
                var databaseType = querySearchContext.DatabaseTypeEnum.ToString().ToLower();

                var infoSearch = QuerySearchConstants.Info.Replace(QuerySearchConstants.Wildcard, string.Empty);
                QueryTagProperties queryTagProperties;

                var all = QueryFileTypeEnum.All.ToString();
                var common = QueryFileTypeEnum.Common.ToString();
                var dbaccess = QueryFileTypeEnum.DbAccess.ToString();

                var sqlCore = QueryFolderEnum.SqlCore.ToString();
                var sqlCustom = QueryFolderEnum.SqlCustom.ToString();

                string queryConfigurationDirectory = null;

                int coreSqlIndex = directoryFiles.BaseFolder.LastIndexOf(sqlCore);
                if (coreSqlIndex < 0)
                {   
                    coreSqlIndex = directoryFiles.BaseFolder.LastIndexOf(sqlCustom);
                    if (coreSqlIndex < 0)
                    {
                            message = string.Concat(
                            methodName,
                            "Unable to parse configuration directory from ",
                            directoryFiles.BaseFolder);

                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryMapper.Logger, null);
                
                        throw new QueryManagementException(message);
                    }
                    else
                    {
                        coreSqlIndex += sqlCustom.Length;
                    }
                }
                else
                {
                    coreSqlIndex += sqlCore.Length;
                }

                queryConfigurationDirectory = directoryFiles.BaseFolder.Substring(coreSqlIndex + 1);

                string overrideDbaccessFilePath = Path.Combine(QueryManagementConfiguration.MetraNetInstallDirectory, @"Config\SqlCore\Queries\Database");

                var stringComparer = new StringComparer();
                if (directoryFiles.Files.Contains<string>(Path.Combine(directoryFiles.BaseFolder, "DbAccess.xml"), stringComparer))
                {
                    overrideDbaccessFilePath = directoryFiles.BaseFolder;
                }

                // Determine all tags first
                foreach (string filenameWithPath in directoryFiles.Files)
                {
                    string fileNameWithoutExtension = Path.GetFileNameWithoutExtension(filenameWithPath);
                    string fileExtension = Path.GetExtension(filenameWithPath);
                    string queryTag;

                    if(filenameWithPath.EndsWith(QueryFileTypeEnum.DbAccess.ToString(), StringComparison.InvariantCultureIgnoreCase))
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
                        queryTagProperties = new QueryTagProperties
                                                 {
                                                     ConfigurationDirectory = queryConfigurationDirectory,
                                                     DbAccessFileName = "DbAccess.xml",
                                                     DbAccessFilePath = overrideDbaccessFilePath
                                                 };
                        if (overrideDbaccessFilePath.Equals(Path.Combine(QueryManagementConfiguration.MetraNetInstallDirectory, @"Config\SqlCore\Queries\Database"), StringComparison.InvariantCultureIgnoreCase))
                        {
                            queryTagProperties.DefaultDbAccessFile = true;
                        }
                        else
                        {
                            queryTagProperties.DefaultDbAccessFile = false;
                        }
                        queryTagProperties.QueryTag = queryTag;
                        queryTagProperties.QueryTypeEnumName = directorySearchTypeValue.EnumType.ToString();
                        queryTagProperties.QueryTypeEnumValue = directorySearchTypeValue.TypeValue;
                        queryTags.Add(queryTag, queryTagProperties);
                    }

                    // Determine File Type
                    for (int index = 0; index < QueryMapper.QueryFileTypeEnumNames.Length; index++ )
                    {
                        if (QueryMapper.QueryFileTypeEnumNames[index].Equals(common, StringComparison.InvariantCultureIgnoreCase) &&
                          filetype.Equals(QueryFileTypeEnum.Common.ToString(), StringComparison.InvariantCultureIgnoreCase))
                        {
                            queryTagProperties.QueryFilePath = directoryFiles.BaseFolder;
                            queryTagProperties.QueryFileName = string.Concat(fileNameWithoutExtension, fileExtension);
                            break;
                        }

                        if (QueryMapper.QueryFileTypeEnumNames[index].Equals(databaseType, StringComparison.InvariantCultureIgnoreCase) &&
                          filetype.Equals(databaseType, StringComparison.InvariantCultureIgnoreCase))
                        {
                            queryTagProperties.QueryFilePath = directoryFiles.BaseFolder;
                            queryTagProperties.QueryFileName = string.Concat(fileNameWithoutExtension, fileExtension);
                            break;
                        }
                    }

                    queryTags[queryTag] = queryTagProperties;
                }

                // If we have gotten to here and there are no tags, 
                // double check if we have only a DBAccess.xml
                if (1 == directoryFiles.Files.Count() && directoryFiles.Files.Contains<string>(Path.Combine(directoryFiles.BaseFolder, "DbAccess.xml"), stringComparer))
                {
                    string newTagName = directoryFiles.BaseFolder.ToUpperInvariant().Replace(@"\", "_");
                    queryTagProperties = new QueryTagProperties
                                             {
                                                 ConfigurationDirectory = queryConfigurationDirectory,
                                                 DbAccessFileName = "DbAccess.xml",
                                                 DbAccessFilePath = directoryFiles.BaseFolder,
                                                 DbAccessFileInfoOnly = true,
                                                 DefaultDbAccessFile = false,
                                                 QueryFileName = "DbAccess.xml",
                                                 QueryFilePath = directoryFiles.BaseFolder,
                                                 QueryTag = newTagName,
                                                 QueryTypeEnumName = directorySearchTypeValue.EnumType.ToString()
                                             };
                    if (queryTags.ContainsKey(newTagName))
                    {
                        LogHelper.WriteLog(String.Concat("Can't add duplicate tag ", newTagName), LogLevelEnum.Error, QueryMapper.Logger, null);
                    }
                    else
                    {
                        queryTags.Add(newTagName,queryTagProperties);                        
                    }
                }
            }
            catch (Exception exception)
            {
                message =
                    string.Concat(
                        methodName,
                        "Exception caught: ",
                        exception.Message);

                LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryMapper.Logger, null);
                throw;
            }
            finally
            {
                // Trace Logging
                if (QueryMapper.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryMapper.Logger, null);
                }
            }
        }

        /// <summary>
        /// Finds and calculates the database definition queries within the platform.
        /// </summary>
        /// <returns>A dictionary of querytags.</returns>
        public QueryTags DatabaseDefinitionLanguageQueryTags(string databaseType)
        {
            const string methodName = "[DatabaseDefinitionLanguageQueryTags]";
            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (QueryMapper.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryMapper.Logger, null);
            }

            try
            {
                DatabaseTypeEnum databaseTypeEnum = DatabaseTypeEnum.All;

                if (string.IsNullOrEmpty(databaseType))
                {
                    databaseTypeEnum = QueryManagementConfiguration.Configuration.PlatformDatabase;
                }
                else
                {
                    var names = Enum.GetNames(typeof(DatabaseTypeEnum));

                    for (int index = 0; index < names.Length; index++)
                    {
                        if (names[index].Equals(databaseType, StringComparison.InvariantCultureIgnoreCase))
                        {
                            databaseTypeEnum = (DatabaseTypeEnum)index;
                            break;
                        }
                    }
                }

                if (databaseTypeEnum == DatabaseTypeEnum.All && !string.IsNullOrEmpty(databaseType))
                {
                    message = string.Concat(
                        methodName,
                        string.Format(CultureInfo.CurrentCulture,
                        MessageConstants.ParameterIsNotValid,
                        ParameterNameConstants.DatabaseType));

                    if (QueryMapper.Logger.WillLogFatal)
                    {
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryMapper.Logger, null);
                    }
                    throw new ArgumentException(message);
                }

                string querySearchDirectory = string.IsNullOrEmpty(QueryMapper.SearchDirectoryOverride) ? QueryManagementConfiguration.MetraNetInstallDirectory : QueryMapper.SearchDirectoryOverride;

                var querySearchContext =
                    QuerySearchContext.CreateInstance(
                        DataQueryLanguageEnum.DataDefinitionLanguage,
                        databaseTypeEnum,
                        false,
                        QueryFileTypeEnum.All,
                        QueryFolderEnum.All,
                        querySearchDirectory);

                return this.Execute(querySearchContext);
            }
            finally
            {
                // Trace Logging
                if (QueryMapper.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryMapper.Logger, null);
                }
            }
        }

        /// <summary>
        /// Performs the search for "query" files based on the search context
        /// and if one or more validations are configured performs the validations.
        /// </summary>
        /// <param name="querySearchContext">The QuerySearchContext to construct the QuerySearchResults from.</param>
        /// <returns>A QueryTags object containing the query tags with their appropriate </returns>
        public QueryTags Execute(QuerySearchContext querySearchContext)
        {
            const string methodName = "[Execute]";
            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (QueryMapper.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryMapper.Logger, null);
            }

            try
            {
                if (querySearchContext == null)
                {
                    //// Return all QueryTags -- need to look at servers.xml and determine database implementation then set DatabaseTypeEnum appropriately
                    querySearchContext = 
                        QuerySearchContext.CreateInstance(
                            DataQueryLanguageEnum.All, 
                            DatabaseTypeEnum.All, 
                            false, 
                            QueryFileTypeEnum.All, 
                            QueryFolderEnum.All, 
                            QueryManagementConfiguration.MetraNetInstallDirectory);
                }

                if (QueryMapper.Logger.WillLogInfo)
                {
                    message =
                    string.Concat(
                        methodName,
                        "Mapping query tags.");

                    LogHelper.WriteLog(message, LogLevelEnum.Info, QueryMapper.Logger, null);
                }

                var querySearchResults = QueryFinder.Execute(querySearchContext);
                IQueryManagementValidator queryDirectoryValidator = new QueryDirectoryValidator();
                var validationResults = queryDirectoryValidator.Execute(querySearchResults);

                return QueryMapper.CalculateQueryTags(querySearchContext, querySearchResults);
            }
            finally
            {
                // Trace Logging
                if (QueryMapper.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryMapper.Logger, null);
                }
            }
        }

        /// <summary>
        /// MTQueryCache Interface - returns the effective set of queries to be used by the cache
        /// </summary>
        /// <param name="queryTagProperties">Array of QueryTagProperties</param>
        public void QueryCache(out IEnumerator queryTagProperties)
        {
            const string methodName = "[QueryCache]";
            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (QueryMapper.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryMapper.Logger, null);
            }

            try
            {
                string querySearchDirectory = string.IsNullOrEmpty(QueryMapper.SearchDirectoryOverride) ? QueryManagementConfiguration.MetraNetInstallDirectory : QueryMapper.SearchDirectoryOverride;

                var querySearchContext =
                    QuerySearchContext.CreateInstance(
                        DataQueryLanguageEnum.All,
                        QueryManagementConfiguration.Configuration.PlatformDatabase,
                        false,
                        QueryFileTypeEnum.All,
                        QueryFolderEnum.All,
                        querySearchDirectory);

                var queryTags = this.Execute(querySearchContext);
                var al = new ArrayList();
                foreach(var tag in queryTags)
                {
                    IntPtr tbuf = Marshal.AllocHGlobal(Marshal.SizeOf(tag.Value));
                    Marshal.StructureToPtr(tag.Value, tbuf, false);
                    al.Add(tbuf);
                }
                queryTagProperties = al.GetEnumerator();
            }
            finally
            {
                // Trace Logging
                if (QueryMapper.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryMapper.Logger, null);
                }
            }
        }
    }
}
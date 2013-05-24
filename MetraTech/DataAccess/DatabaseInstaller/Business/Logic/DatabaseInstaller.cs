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
// MODULE: DatabaseInstaller.cs
//
//=============================================================================

namespace MetraTech.DataAccess.DatabaseInstaller.Business.Logic
{
    using System;
    using System.Collections.Generic;
    using System.Data;
    using System.Diagnostics;
    using System.IO;
    using System.Linq;
    using System.Xml;
    using System.Text;

    using Constants;
    using Entities;

    using MetraTech.DataAccess;
    using MetraTech.DataAccess.QueryManagement;
    using MetraTech.DataAccess.QueryManagement.Business.Logic;
    using MetraTech.DataAccess.QueryManagement.Entities;
    using MetraTech.DataAccess.QueryManagement.EnumeratedTypes;
    using MetraTech.DataAccess.QueryManagement.Helpers;

    /// <summary>
    /// 
    /// </summary>
    public class DatabaseInstaller
    {
        /// <summary>
        /// Name of this class.
        /// </summary>
        private const string ClassName = "DatabaseInstaller";

        /// <summary>
        /// Local logging object
        /// </summary>
        private static ILogger mtLogLogger =
            new Logger(
                string.Concat(
                    MessageConstants.BracketOpen,
                    DatabaseInstaller.ClassName,
                    MessageConstants.BracketClose));

        /// <summary>
        /// Local logging object
        /// </summary>
        private static ILogger Logger = 
            new Logger(
                @"Logging\QueryManagement",
                string.Concat(
                    MessageConstants.BracketOpen, 
                    DatabaseInstaller.ClassName, 
                    MessageConstants.BracketClose));

        /// <summary>
        /// Array of DatabaseDefinitionTypeEnum names.
        /// </summary>
        private static Array ddlNames;     

        /// <summary>
        /// The queries to be installed.
        /// </summary>
        private InstallOrder installOrder = null;

        /// <summary>
        /// Local instance of the parsed arguments passed to this instance of the program
        /// </summary>
        private ProgramArguments Arguments = null;

        /// <summary>
        /// Dictionary of Query Install Parameters
        /// </summary>
        private QueryInstallParameters QueryInstallParameters = null;

        /// <summary>
        /// Prevents a default instance of the DatabaseInstaller class from being instantiated.
        /// </summary>
        private DatabaseInstaller()
        {
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="programArguments"></param>
        /// <param name="queryInstallParameters"></param>
        /// <returns></returns>
        public static DatabaseInstaller CreateInstance(ProgramArguments programArguments, QueryInstallParameters queryInstallParameters)
        {
            const string methodName = "[CreateInstance]";
            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (DatabaseInstaller.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, DatabaseInstaller.Logger, null);
            }
            try
            {
                var databaseInstaller = new DatabaseInstaller();
                databaseInstaller.Arguments = programArguments;
                databaseInstaller.QueryInstallParameters = queryInstallParameters;
                databaseInstaller.Initialize();
                return databaseInstaller;
            }
            finally
            {
                // Trace Logging
                if (DatabaseInstaller.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, DatabaseInstaller.Logger, null);
                }
            }
        }

        /// <summary>
        /// Creates and initializes a new instance of the database installer class.
        /// </summary>
        private void Initialize()
        {
            const string methodName = "[Initialize]";
            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (DatabaseInstaller.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, DatabaseInstaller.Logger, null);
            }

            try
            {
                DatabaseInstaller.ddlNames = Enum.GetNames(typeof(DatabaseDefinitionTypeEnum));
                var queryTags = this.LoadQueryTags();
                installOrder = InstallOrder.CreateInstance(this.Arguments, queryTags);
            }
            finally
            {
                // Trace Logging
                if (DatabaseInstaller.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, DatabaseInstaller.Logger, null);
                }
            }
        }

        /// <summary>
        /// Installs the MetraNet database.
        /// </summary>
        public void Execute()
        {
            const string methodName = "[Execute]";
            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (DatabaseInstaller.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, DatabaseInstaller.Logger, null);
            }

            try
            {
                DatabaseDefinitionTypeEnum minIndex = this.Arguments.MinInstallSet;
                DatabaseDefinitionTypeEnum maxIndex = this.Arguments.MaxInstallSet;

                int currentErrorCount = 0;
                var nextInstallSets = new InstallSet[this.installOrder.InStallSets.Count()];
                // First Pass
                for (int index = 0; index < this.installOrder.InStallSets.Count(); index++)
                {
                    if (this.installOrder.InStallSets[index].InstallType < minIndex || this.installOrder.InStallSets[index].InstallType > maxIndex)
                    {
                        continue;
                    }
                    if (this.installOrder.InStallSets[index].Queries.Count > 0)
                    {
                        nextInstallSets[index] = this.ExecuteQueries(this.installOrder.InStallSets[index]);
                        currentErrorCount += nextInstallSets[index].Queries.Count;
                    }
                }

                // Repetitive Pass
                int lastErrorCount = currentErrorCount;

                while (lastErrorCount > 0)
                {
                    LogHelper.WriteLog(string.Concat(methodName, "Starting next query installation execution pass."), LogLevelEnum.Info, DatabaseInstaller.mtLogLogger, null);
                    var currentInstallSets = nextInstallSets;
                    nextInstallSets = new InstallSet[this.installOrder.InStallSets.Count()];
                    currentErrorCount = 0;
                    for (int index = 0; index < currentInstallSets.Count(); index++)
                    {
                        if (currentInstallSets[index] != null)
                        {
                            if (currentInstallSets[index].InstallType < minIndex || currentInstallSets[index].InstallType > maxIndex)
                            {
                                continue;
                            }
                            if (currentInstallSets[index].Queries.Count > 0)
                            {
                                nextInstallSets[index] = this.ExecuteQueries(currentInstallSets[index]);
                                currentErrorCount += nextInstallSets[index].Queries.Count;
                            }
                        }
                    }
                    LogHelper.WriteLog(string.Concat(methodName, "Finished query installation execution pass."), LogLevelEnum.Info, DatabaseInstaller.Logger, null);

                    if (lastErrorCount == currentErrorCount)
                    {
                        message = string.Concat(methodName, "The same number of errors, ", currentErrorCount, ", occurred during successive installation executions.  The errors that occurred are as follows in the mtlog.");
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, DatabaseInstaller.Logger, null);

                        for (int index = 0; index < nextInstallSets.Count(); index++)
                        {
                            if (nextInstallSets[index] != null && nextInstallSets[index].Errors.Count > 0)
                            {
                                foreach(string error in nextInstallSets[index].Errors)
                                {
                                    LogHelper.WriteLog(string.Concat(methodName, error), LogLevelEnum.Fatal, DatabaseInstaller.mtLogLogger, null);
                                }
                            }
                        }

                        throw new QueryManagementException(message);
                    }
                    lastErrorCount = currentErrorCount;
                }
            }
            finally
            {
                // Trace Logging
                if (DatabaseInstaller.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, DatabaseInstaller.Logger, null);
                }
            }
        }

        /// <summary>
        /// Installs a query installation set.
        /// </summary>
        /// <param name="queries">The list of queries to install.</param>
        public void ExecuteQuery()
        {
            const string methodName = "[ExecuteQuery]";
            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (DatabaseInstaller.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, DatabaseInstaller.Logger, null);
            }

            try
            {
                var connectionInfo = this.DetermineConnectionInfo(DatabaseDefinitionTypeEnum.Data);
                try
                {
                    using (IMTConnection connection = ConnectionManager.CreateConnection(connectionInfo))
                    {
                        using (IMTAdapterStatement statement = connection.CreateAdapterStatement(@"Queries\Database", this.Arguments.QueryTag))
                        {
                            foreach (KeyValuePair<string, string> parameter in this.QueryInstallParameters)
                            {
                                statement.AddParamIfFound(parameter.Key, parameter.Value);
                            }

                            statement.ExecuteNonQuery();
                        }
                    }
                }
                catch (Exception exception)
                {
                    message =
                        string.Concat(
                            methodName,
                            "Exception caught while executing query with tag = \"",
                            this.Arguments.QueryTag,
                            "\":",
                            exception.Message,
                            exception.StackTrace);

                    LogHelper.WriteLog(message, LogLevelEnum.Error, DatabaseInstaller.mtLogLogger, null);
                }
            }
            finally
            {
                // Trace Logging
                if (DatabaseInstaller.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, DatabaseInstaller.Logger, null);
                }
            }
        }

        /// <summary>
        /// Installs a query installation set.
        /// </summary>
        /// <param name="installSet">The list of queries to install.</param>
        public InstallSet ExecuteQueries(InstallSet installSet)
        {
            const string methodName = "[ExecuteQueries]";
            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (DatabaseInstaller.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, DatabaseInstaller.Logger, null);
            }

            try
            {
                if (installSet == null)
                {
                    message = string.Concat(methodName, string.Format(MessageConstants.ParameterIsNull, "installSet"));
                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, DatabaseInstaller.Logger, null);
                    throw new ArgumentException(message);
                }

                if (installSet.Queries == null)
                {
                    message = string.Concat(methodName, string.Format(MessageConstants.ParameterIsNull, "installSet.Queries"));
                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, DatabaseInstaller.Logger, null);
                    throw new ArgumentException(message);
                }

                message = string.Format(MessageConstants.ExecutingInstallSet, installSet.InstallType);
                LogHelper.WriteLog(message, LogLevelEnum.Debug, DatabaseInstaller.mtLogLogger, null);
                var connectionInfo = this.DetermineConnectionInfo(installSet.InstallType);
                var errors = new List<QueryTagProperties>();
                using (IMTConnection connection = ConnectionManager.CreateConnection(connectionInfo))
                {
                    installSet.Errors.Clear();
                    foreach (QueryTagProperties queryTagProperties in installSet.Queries)
                    {
                        try
                        {
                            using (IMTAdapterStatement statement = connection.CreateAdapterStatement(@"Queries\Database", queryTagProperties.QueryTag))
                            {
                                foreach (KeyValuePair<string, string> parameter in this.QueryInstallParameters)
                                {
                                    statement.AddParamIfFound(parameter.Key, parameter.Value);
                                }

                                statement.ExecuteNonQuery();
                            }
                        }
                        catch (Exception exception)
                        {
                            errors.Add(queryTagProperties);
                            message = 
                                string.Concat(
                                    methodName, 
                                    "Exception caught while executing query with tag = \"", 
                                    queryTagProperties.QueryTag, 
                                    "\":", 
                                    exception.Message, 
                                    exception.StackTrace);
                            installSet.Errors.Add(message);
                        }
                    }
                }

                return InstallSet.CreateInstance(installSet, errors);
            }
            finally
            {
                // Trace Logging
                if (DatabaseInstaller.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, DatabaseInstaller.Logger, null);
                }
            }
        }

        /// <summary>
        /// Retrieves the queries to be installed for the system.
        /// </summary>
        private QueryTags LoadQueryTags()
        {
            const string methodName = "[LoadQueryTags]";
            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (DatabaseInstaller.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, DatabaseInstaller.Logger, null);
            }

            try
            {
                const string infoFileExtension = "._Info.xml";
                var queryMap = new QueryMapper(); 
                var queryTags = queryMap.DatabaseDefinitionLanguageQueryTags(null);
                var effectiveQueryTags = new QueryTags();
                bool oneOrMoreErrorsOccurred = false;

                // Filter tags based on Pre/Post Sync operation and schema type
                foreach (var kvp in queryTags)
                {
                    var queryTagProperties = kvp.Value;
                    var infoFilename = Path.Combine(queryTagProperties.QueryFilePath, string.Concat(queryTagProperties.QueryTag, infoFileExtension));

                    var xmlDocument = new XmlDocument();
                    xmlDocument.Load(infoFilename);
                    var installTimeXmlNode = xmlDocument.SelectSingleNode("//InstallTime");

                    if (installTimeXmlNode == null)
                    {
                        Console.WriteLine(string.Concat("InstallTime xml node was not found for file ", infoFilename));
                        oneOrMoreErrorsOccurred = true;
                        continue;
                    }

                    if (string.IsNullOrEmpty(installTimeXmlNode.InnerText))
                    {
                        Console.WriteLine(string.Concat("InstallTime xml node value/inner text is null or empty for file " + infoFilename));
                        oneOrMoreErrorsOccurred = true;
                        continue;
                    }

                    if (!this.Arguments.InstallTime.ToString().Equals(installTimeXmlNode.InnerText, StringComparison.InvariantCultureIgnoreCase))
                    {
                        continue;
                    }

                    // Determines if the query should be installed in the database schema specified by this program's command line arguments
                    var schemasNode = xmlDocument.SelectSingleNode("//Schemas");

                    bool bFoundSchema = false;
                    if (schemasNode != null && schemasNode.ChildNodes.Count > 0)
                    {
                        foreach (XmlNode schemaNode in schemasNode.ChildNodes)
                        {
                            if (schemaNode.Name.Equals("Schema", StringComparison.InvariantCultureIgnoreCase) && !string.IsNullOrEmpty(schemaNode.InnerText))
                            {
                                if (!this.Arguments.IsStaging && schemaNode.InnerText.IndexOf(DatabaseContextEnum.NetMeter.ToString(), 0, StringComparison.InvariantCultureIgnoreCase) > -1)
                                {
                                    bFoundSchema = true;
                                    break;
                                }

                                if (this.Arguments.IsStaging && schemaNode.InnerText.IndexOf(DatabaseContextEnum.Staging.ToString(), 0, StringComparison.InvariantCultureIgnoreCase) > -1)
                                {
                                    bFoundSchema = true;
                                    break;
                                }
                            }
                        }
                    }

                    if (bFoundSchema)
                    {
                        effectiveQueryTags.Add(kvp.Key, kvp.Value);
                    }
                }

                if (oneOrMoreErrorsOccurred)
                {
                    throw new QueryManagementException("One or more errors occurred validating QueryManagement Info files.");
                }

                return effectiveQueryTags;
            }
            finally
            {
                // Trace Logging
                if (DatabaseInstaller.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, DatabaseInstaller.Logger, null);
                }
            }
        }

        private ConnectionInfo DetermineConnectionInfo(DatabaseDefinitionTypeEnum databaseDefinitionTypeEnum)
        {
            var connectionInfo = new ConnectionInfo((this.Arguments.IsStaging) ? "NetMeterStage" : "NetMeter")
                                     {
                                         UserName = this.Arguments.SeverAdminLogon,
                                         Password = this.Arguments.SeverAdminPassword,
                                         Timeout = Convert.ToInt32(this.Arguments.TimeoutValue)
                                     };

            switch(this.Arguments.DatabaseType.ToLower())
            {
                case "oracle":
                    {
                        //connectionInfo.DataSource = this.Arguments.DataSource;
                        //connectionInfo.Catalog = string.Empty;
                        switch (databaseDefinitionTypeEnum)
                            {
                            case DatabaseDefinitionTypeEnum.DropTable:
                            case DatabaseDefinitionTypeEnum.DropDatabase:
                            case DatabaseDefinitionTypeEnum.DropDataDevice:
                            case DatabaseDefinitionTypeEnum.DropLogDevice:
                            case DatabaseDefinitionTypeEnum.DropLogin:
                            case DatabaseDefinitionTypeEnum.CreateDatabase:
                            case DatabaseDefinitionTypeEnum.AlterDatabase:
                            case DatabaseDefinitionTypeEnum.CreateLogin:
                            case DatabaseDefinitionTypeEnum.Schemas:
                                {
                                    connectionInfo.UserName = this.Arguments.SeverAdminLogon;
                                    connectionInfo.Password = this.Arguments.SeverAdminPassword;
                                }
                                break;
                            case DatabaseDefinitionTypeEnum.Grants:
                                {
                                    connectionInfo.UserName = "sys";
                                    connectionInfo.Password = this.Arguments.SeverAdminPassword + "; DBA Privilege=SYSDBA";
                                }
                                break;
                            default:
                                {
                                    connectionInfo.UserName = this.Arguments.DboLogon;
                                    connectionInfo.Password = this.Arguments.DboPassword;
                                }
                                break;
                        }
                    }
                    break;
                case "sqlserver":
                    {
                        connectionInfo.Server = this.Arguments.ServerName;
                        switch (databaseDefinitionTypeEnum)
                        {
                            case DatabaseDefinitionTypeEnum.DropTable:
                            case DatabaseDefinitionTypeEnum.DropDatabase:
                            case DatabaseDefinitionTypeEnum.DropDataDevice:
                            case DatabaseDefinitionTypeEnum.DropLogDevice:
                            case DatabaseDefinitionTypeEnum.DropLogin:
                            case DatabaseDefinitionTypeEnum.CreateDatabase:
                            case DatabaseDefinitionTypeEnum.AlterDatabase:
                            case DatabaseDefinitionTypeEnum.CreateLogin:
                                {
                                    connectionInfo.Catalog = "master";
                                }
                                break;
                            default:
                                break;
                        }
                    }
                    break;
            }
            
            return connectionInfo;
        }
    }
}

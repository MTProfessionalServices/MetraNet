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
// MODULE: InstallSet.cs
//
//=============================================================================

namespace MetraTech.DataAccess.DatabaseInstaller.Entities
{
    using System;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Globalization;

    using Constants;

    using QueryManagement.Entities;
    using QueryManagement.EnumeratedTypes;
    using QueryManagement.Helpers;

    /// <summary>
    /// 
    /// </summary>
    public class InstallSet
    {
        /// <summary>
        /// Name of this class.
        /// </summary>
        private const string ClassName = "DatabaseInstaller";

        /// <summary>
        /// Local logging object
        /// </summary>
        private static ILogger Logger =
            new Logger(
                @"Logging\QueryManagement",
                string.Concat(
                    MessageConstants.BracketOpen,
                    InstallSet.ClassName,
                    MessageConstants.BracketClose));

        /// <summary>
        /// The type of database definition query type represented by this InstallSet instance
        /// </summary>
        public DatabaseDefinitionTypeEnum InstallType
        {
            get;
            private set;
        }

        /// <summary>
        /// The list of queries to install the database objects from
        /// </summary>
        public List<QueryTagProperties> Queries
        {
            get;
            set;
        }

        /// <summary>
        /// The list of queries to install the database objects from
        /// </summary>
        public List<string> Errors
        {
            get;
            set;
        }

        /// <summary>
        /// Prevents a default instance of the InstallSet class from being instantiated.
        /// </summary>
        private InstallSet()
        {
        }

        /// <summary>
        /// Creates an instance of the InstallSet class
        /// </summary>
        /// <param name="installSet">Existing installSet to create this installSet from.</param>
        /// <param name="queries">A list of queries</param>
        /// <returns>An initialized instance of the InstallSet class.</returns>
        public static InstallSet CreateInstance(InstallSet installSet, List<QueryTagProperties> queries)
        {
            var newInstallSet = InstallSet.CreateInstance(installSet.InstallType, queries);
            if (installSet.Errors.Count > 0)
            {
                newInstallSet.Errors = installSet.Errors;
            }
            return newInstallSet;
        }

        /// <summary>
        /// Creates an instance of the InstallSet class
        /// </summary>
        /// <param name="installType">The type of database installation queries this installation set contains.</param>
        /// <param name="queries">A list of queries</param>
        /// <returns>An initialized instance of the InstallSet class.</returns>
        public static InstallSet CreateInstance(DatabaseDefinitionTypeEnum installType, List<QueryTagProperties> queries)
        {
            const string methodName = "[CreateInstance]";
            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (InstallSet.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, InstallSet.Logger, null);
            }

            if (queries == null)
            {
                message = string.Concat(
                    methodName,
                    string.Format(CultureInfo.CurrentCulture,
                    MessageConstants.ParameterIsNull,
                    "queries"));

                if (InstallSet.Logger.WillLogFatal)
                {
                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, InstallSet.Logger, null);
                }
                throw new ArgumentException(message);
            }

            if (queries.Count == 0)
            {
                if (InstallSet.Logger.WillLogInfo)
                {
                    message = string.Concat(methodName, "The query list contains no queries.");
                    LogHelper.WriteLog(message, LogLevelEnum.Info, InstallSet.Logger, null);
                }
            }
            try
            {
                var installSet = new InstallSet();
                installSet.InstallType = installType;
                installSet.Queries = queries;
                installSet.Errors = new List<string>();
                return installSet;
            }
            finally
            {
                // Trace Logging
                if (InstallSet.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, InstallSet.Logger, null);
                }
            }
        }
    }
}
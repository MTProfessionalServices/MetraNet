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
// MODULE: InstallOrder.cs
//
//=============================================================================

namespace MetraTech.DataAccess.DatabaseInstaller.Entities
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Globalization;
    using System.IO;
    using System.Linq;
    using System.Text;
    using System.Text.RegularExpressions;
    using System.Threading;
    using System.Threading.Tasks;
    using System.Xml;

    using Constants;

    using QueryManagement.Entities;
    using QueryManagement.EnumeratedTypes;
    using QueryManagement.Helpers;

    /// <summary>
    /// Class containing ordered array of query installation sets.
    /// </summary>
    public class InstallOrder
    {
        /// <summary>
        /// Name of this class.
        /// </summary>
        private const string ClassName = "InstallOrder";

        /// <summary>
        /// Local logging object
        /// </summary>
        private static ILogger Logger =
            new Logger(
                @"Logging\QueryManagement",
                string.Concat(
                    MessageConstants.BracketOpen,
                    InstallOrder.ClassName,
                    MessageConstants.BracketClose));

        /// <summary>
        /// Array of names from the Enumerated Type InstallTime 
        /// </summary>
        private static string[] enumNames = Enum.GetNames(typeof(InstallTime));

        /// <summary>
        /// Ordered array of query installation sets.
        /// </summary>
        private static InstallSet[] installSets;

        /// <summary>
        /// InstallSets property
        /// </summary>
        public InstallSet[] InStallSets
        {
            get
            {
                return installSets;
            }
        }


        /// <summary>
        /// Prevents a default instance of the InstallSet class from being created.
        /// </summary>
        private InstallOrder()
        {
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="programArguments"></param>
        /// <param name="queryTags"></param>
        /// <returns></returns>
        public static InstallOrder CreateInstance(ProgramArguments programArguments, QueryTags queryTags)
        {
            const string methodName = "[CreateInstance]";
            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (InstallOrder.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, InstallOrder.Logger, null);
            }

            if (queryTags == null)
            {
                message = string.Concat(
                    methodName,
                    string.Format(CultureInfo.CurrentCulture,
                    MessageConstants.ParameterIsNull,
                    "queryTags"));

                if (InstallOrder.Logger.WillLogFatal)
                {
                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, InstallOrder.Logger, null);
                }
                throw new ArgumentException(message);
            }

            if (queryTags.Count == 0)
            {
                message = string.Concat(methodName, "The variable queryTags does not contain any items.");

                if (InstallOrder.Logger.WillLogFatal)
                {
                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, InstallOrder.Logger, null);
                }

                throw new ArgumentException(message);
            }

            try
            {
                var installOrder = new InstallOrder();
                var names = Enum.GetNames(typeof(DatabaseDefinitionTypeEnum));
                
                if (programArguments.UnInstallOnly)
                {
                  names = names.Where(name => Regex.IsMatch(name, "^Drop", RegexOptions.IgnoreCase)).ToArray();
                }
                  
                InstallOrder.installSets = new InstallSet[names.Length];

                for (int index = 0; index < names.Length; index++)
                {
                    InstallOrder.installSets[index] = InstallSet.CreateInstance((DatabaseDefinitionTypeEnum)index, new List<QueryTagProperties>());
                }

                foreach (KeyValuePair<string, QueryTagProperties> kvp in queryTags)
                //Parallel.ForEach<KeyValuePair<string, QueryTagProperties>>(queryTags, kvp =>
                {
                  if (kvp.Value.QueryTypeEnumValue < names.Length)
                    {
                      var queryTagProperties = kvp.Value;
                      var xmlDocument = new XmlDocument();
                      string filename =  Path.Combine(queryTagProperties.QueryFilePath, string.Concat(queryTagProperties.QueryTag, @"._Info.xml"));
                      LogHelper.WriteLog(string.Concat("Parsing \"InstallTime\" xml node from ", filename), LogLevelEnum.Trace, InstallOrder.Logger, null);
                      xmlDocument.Load(filename);
                      var syncNode = xmlDocument.SelectSingleNode("//InstallTime");
                      if (syncNode == null || string.IsNullOrEmpty(syncNode.InnerText))
                      {
                          LogHelper.WriteLog(string.Concat("Unable to parse \"InstallTime\" xml node from ", filename), LogLevelEnum.Fatal, InstallOrder.Logger, null);
                          throw new QueryManagementException(message);
                      }
                      if (syncNode.InnerText.Equals(programArguments.InstallTime.ToString(), StringComparison.InvariantCultureIgnoreCase)) 
                      {
                          InstallOrder.installSets[kvp.Value.QueryTypeEnumValue].Queries.Add(kvp.Value);
                      }
                    }

                } //);

                return installOrder;
            }
            finally
            {
                // Trace Logging
                if (InstallOrder.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, InstallOrder.Logger, null);
                }
            }
        }
    }
}

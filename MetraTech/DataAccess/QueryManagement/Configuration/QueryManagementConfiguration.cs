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
// MODULE: QueryManagementConfiguration.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement
{
    using System;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Globalization;
    using System.IO;
    using System.Runtime.InteropServices;
    using System.Security;
    using System.Xml;
    using System.Xml.XPath;

    using MetraTech.Interop.MTServerAccess;

    using Microsoft.Win32;

    using Constants;
    using Entities;
    using EnumeratedTypes;
    using Helpers;
    
    /// <summary>
    /// Provides access to the QueryManagement configuration file.
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("3103E58D-7852-4E49-9038-E44375731907")]
    public class QueryManagementConfiguration
    {
        /// <summary>
        /// Name of this class.
        /// </summary>
        private const string ClassName = "QueryManagementConfiguration";

        /// <summary>
        /// List of configuration errors.
        /// </summary>
        private static List<string> configurationErrorList = new List<string>();

        /// <summary>
        /// XmlDocument which loads the QueryManagement configuration file into memory.
        /// </summary>
        private XmlDocument configurationFile = new XmlDocument();

        /// <summary>
        /// The path and name of the configuration file containing the configuration settings for QueryManagement.
        /// </summary>
        private string configurationFileName = null;

        /// <summary>
        /// Indicates if the QueyManagement configuration is enabled.
        /// </summary>
        private bool enabled;

        /// <summary>
        /// Local logging object
        /// </summary>
        private static ILogger Logger =
            new Logger(@"Logging\QueryManagement", string.Concat(MessageConstants.BracketOpen, QueryManagementConfiguration.ClassName, MessageConstants.BracketClose));

        /// <summary>
        /// MetraNet Installation directory
        /// </summary>
        private static string metraNetInstallDirectory = null;

        /// <summary>
        /// MetraNet Installation Registry Key Name
        /// </summary>
        private const string metraNetInstallDirRegistryKeyName = @"InstallDir";

        /// <summary>
        /// MetraNet Registry Key Name
        /// </summary>
        private const string metraNetRegistryKeyName = @"SOFTWARE\MetraTech\MetraNet\";

        /// <summary>
        /// The type of database the platform is currently running against.
        /// </summary>
        private DatabaseTypeEnum platformDatabase = DatabaseTypeEnum.All;

        /// <summary>
        /// Singleton instance of the QueryManagementConfiguration class.
        /// </summary>
        private static QueryManagementConfiguration queryManagementConfiguration = null;

        /// <summary>
        /// Used to provide synchronized access to this class.
        /// </summary>
        private static object SyncObject = new object();

        /// <summary>
        /// Dictionary of Validator types that are to be enforced.
        /// </summary>
        private Dictionary<Type, List<int>> validators = new Dictionary<Type, List<int>>();

        /// <summary>
        /// Gets the singleton instance of the AllowedFilePostFixes class
        /// </summary>
        public static QueryManagementConfiguration Configuration
        {
            get
            {
                if (QueryManagementConfiguration.queryManagementConfiguration == null)
                {
                    QueryManagementConfiguration.Initialize();
                }

                return QueryManagementConfiguration.queryManagementConfiguration;
            }
        }

        /// <summary>
        /// Gets or sets the QueryManagement configuration filename
        /// </summary>
        public string ConfigurationFileName
        {
            get
            {
                if (QueryManagementConfiguration.queryManagementConfiguration == null)
                {
                    QueryManagementConfiguration.Initialize();
                }
                return queryManagementConfiguration.configurationFileName;
            }
            private set
            {
                queryManagementConfiguration.configurationFileName = value;
            }
        }

        /// <summary>
        /// Gets or sets the type of database the platform is running against
        /// </summary>
        public DatabaseTypeEnum PlatformDatabase
        {
            get
            {
                if (QueryManagementConfiguration.queryManagementConfiguration == null)
                {
                    QueryManagementConfiguration.Initialize();
                }
                return queryManagementConfiguration.platformDatabase;
            }
            private set
            {
                queryManagementConfiguration.platformDatabase = value;
            }
        }

        /// <summary>
        /// Gets or sets the boolean valud which indicates if the QueryManagement configuration is enabled.
        /// </summary>
        public bool Enabled
        {
            get
            {
                if (QueryManagementConfiguration.queryManagementConfiguration == null)
                {
                    QueryManagementConfiguration.Initialize();
                }
                return queryManagementConfiguration.enabled;
            }
            private set
            {
                queryManagementConfiguration.enabled = value;
            }
        }

        /// <summary>
        /// Gets or sets the MetraNet Installation Directory
        /// </summary>
        public static string MetraNetInstallDirectory
        {
            get
            {
                if (QueryManagementConfiguration.queryManagementConfiguration == null)
                {
                    QueryManagementConfiguration.Initialize();
                }
                return QueryManagementConfiguration.metraNetInstallDirectory;
            }
            private set
            {
                QueryManagementConfiguration.metraNetInstallDirectory = value;
            }
        }

        /// <summary>
        /// Dictionary of Validator types that are to be enforced.
        /// </summary>
        public Dictionary<Type, List<int>> Validators
        {
            get
            {
                if (QueryManagementConfiguration.queryManagementConfiguration == null)
                {
                    QueryManagementConfiguration.Initialize();
                }
                return queryManagementConfiguration.validators;
            }
            private set
            {
                queryManagementConfiguration.validators = value;
            }
        }

        /// <summary>
        /// Prevents a default instance of the QueryManagementConfiguration class from being instantiated.
        /// </summary>
        private QueryManagementConfiguration()
        {
        }

        /// <summary>
        /// Determines where MetraNet is installed from the registry
        /// </summary>
        /// <returns>A string which represents the folder path where MetraNet is installed.</returns>
        private static void DetermineMetranetInstallationDirectory()
        {
            const string methodName = "[DetermineMetranetInstallationDirectory]";
            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (QueryManagementConfiguration.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryManagementConfiguration.Logger, null);
            }

            RegistryKey localMachineRegistryKey = null;
            RegistryKey metraNetRegistryKey = null;

            try
            {
                localMachineRegistryKey = RegistryKey.OpenBaseKey(RegistryHive.LocalMachine, RegistryView.Registry32);
                metraNetRegistryKey = localMachineRegistryKey.OpenSubKey(QueryManagementConfiguration.metraNetRegistryKeyName);
                QueryManagementConfiguration.metraNetInstallDirectory = (string)metraNetRegistryKey.GetValue(QueryManagementConfiguration.metraNetInstallDirRegistryKeyName);

                if (string.IsNullOrEmpty(QueryManagementConfiguration.metraNetInstallDirectory))
                {
                    throw new QueryManagementException("The MetraNet Installation Directory value is null or empty.");
                }
                if (!Directory.Exists(QueryManagementConfiguration.metraNetInstallDirectory))
                {
                    throw new QueryManagementException("The MetraNet Installation Directory does not exist.");
                }
            }
            catch (ArgumentException argumentException)
            {
                message = string.Concat(
                    methodName,
                    "ArgumentException caught while determining MetraNet Installation location:  ",
                    argumentException.Message);

                LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryManagementConfiguration.Logger, null);
                throw new QueryManagementException(message, argumentException);
            }
            catch (QueryManagementException queryManagementException)
            {
                message = string.Concat(
                    methodName,
                    "QueryManagementException caught while determining MetraNet Installation location:  ",
                    queryManagementException.Message);

                LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryManagementConfiguration.Logger, null);
                throw;
            }
            catch (SecurityException securityException)
            {
                message = string.Concat(
                    methodName,
                    "SecurityException caught while determining MetraNet Installation location:  ",
                    securityException.Message);

                LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryManagementConfiguration.Logger, null);
            }
            catch (UnauthorizedAccessException unauthorizedAccessException)
            {
                message = string.Concat(
                    methodName,
                    "UnauthorizedAccessException caught while determining MetraNet Installation location:  ",
                    unauthorizedAccessException.Message);

                LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryManagementConfiguration.Logger, null);
                throw new QueryManagementException(message, unauthorizedAccessException);
            }
            catch (Exception exception)
            {
                message = string.Concat(
                    methodName,
                    "Exception caught while determining MetraNet Installation location:  ",
                    exception.Message);

                LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryManagementConfiguration.Logger, null);
                throw new QueryManagementException(message, exception);
            }
            finally
            {
                if (localMachineRegistryKey != null)
                {
                    localMachineRegistryKey.Close();
                }
                if (metraNetRegistryKey != null)
                {
                    metraNetRegistryKey.Close();
                }

                // Trace Logging
                if (QueryManagementConfiguration.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryManagementConfiguration.Logger, null);
                }
            }
        }
        
        /// <summary>
        /// 
        /// </summary>
        private static void DeterminePlatformDatabase()
        {
            const string methodName = "[DeterminePlatformDatabase]";
            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (QueryManagementConfiguration.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryManagementConfiguration.Logger, null);
            }
            try
            {
                var serverAccessDataSet = new MTServerAccessDataSet();
                serverAccessDataSet.Initialize();
                var serverAccessData = serverAccessDataSet.FindAndReturnObject("NetMeter");

                switch (serverAccessData.DatabaseType.ToUpper())
                {
                    case "{SQL SERVER}":
                        {
                            QueryManagementConfiguration.queryManagementConfiguration.PlatformDatabase = DatabaseTypeEnum.SqlServer;
                        }
                        break;
                    case "{ORACLE}":
                        {
                            QueryManagementConfiguration.queryManagementConfiguration.PlatformDatabase = DatabaseTypeEnum.Oracle;
                        }
                        break;
                    default:
                        {
                            throw new QueryManagementException("Unknown database type \"" + serverAccessData.DatabaseType + "\" found for the \"NetMeter\" server in \"rmp\\config\\serveraccess\\servers.xml\".");
                        }
                }
            }
            finally
            {
                // Trace Logging
                if (QueryManagementConfiguration.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryManagementConfiguration.Logger, null);
                }
            }
        }
        
        /// <summary>
        /// Searches for the xml node specified by the parameter "xmlNodeName"
        /// validating it exists, and optionally if it contains innerText.
        /// Saves errors encountered in local error list.
        /// </summary>
        /// <param name="xmlDocument">The xml document containing the xml node to search for.</param>
        /// <param name="xmlNode">The xml parent node containing the xml node to search for.</param>
        /// <param name="xmlNodeName">The name of the xml node to search for.</param>
        /// <param name="containsInnerText">Boolean value indicating if the xml node searched for contains innerText.</param>
        /// <returns></returns>
        private static XmlNode FindAndParseXmlNodeOrSaveError(XmlDocument xmlDocument, XmlNode xmlNode, string xmlNodeName, bool containsInnerText)
        {
            const string methodName = "[FindAndParseXmlNodeOrSaveError]";

            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (QueryManagementConfiguration.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryManagementConfiguration.Logger, null);
            }

            try
            {
                if (xmlDocument == null && xmlNode == null)
                {
                    message = string.Concat(methodName, "Either the XmlDocument or the XmlNode parameter must be specified.");
                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryManagementConfiguration.Logger, null);
                    throw new ArgumentException(message);
                }

                if (string.IsNullOrEmpty(xmlNodeName))
                {
                    message = string.Concat(methodName, MessageConstants.ParameterIsNullOrEmpty, "xmlNodeName");
                    LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryManagementConfiguration.Logger, null);
                    throw new ArgumentException(message);
                }

                XmlNode xmlTestNode = null;

                if (xmlNodeName.Equals("root", StringComparison.InvariantCultureIgnoreCase))
                {
                    xmlTestNode = QueryManagementConfiguration.queryManagementConfiguration.configurationFile.DocumentElement;
                }
                else
                {
                    xmlTestNode = xmlNode.SelectSingleNode(xmlNodeName);
                }

                if (xmlTestNode == null)
                {
                    message =
                        string.Concat(
                            methodName,
                            "The \"",
                            xmlNodeName,
                            "\" element is missing in the file \"",
                            QueryManagementConfiguration.queryManagementConfiguration.configurationFileName,
                            "\".");

                    QueryManagementConfiguration.configurationErrorList.Add(message);
                }

                if (containsInnerText)
                {
                    if (string.IsNullOrEmpty(xmlTestNode.InnerText))
                    {
                        message =
                            string.Concat(
                                methodName,
                                "The \"",
                                xmlNodeName,
                                "\" element's value/InnerText is missing in the file \"",
                                QueryManagementConfiguration.queryManagementConfiguration.configurationFileName,
                                "\".");

                        QueryManagementConfiguration.configurationErrorList.Add(message);
                    }
                }

                return xmlTestNode;
            }
            finally
            {
                // Trace Logging
                if (QueryManagementConfiguration.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryManagementConfiguration.Logger, null);
                }
            }
        }

        /// <summary>
        /// Initializes the singleton instance of the QueryManagementConfiguration class.
        /// </summary>
        private static void Initialize()
        {
            const string methodName = "[Initialize]";
            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (QueryManagementConfiguration.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryManagementConfiguration.Logger, null);
            }

            try
            {
                if (QueryManagementConfiguration.queryManagementConfiguration == null)
                {
                    lock (QueryManagementConfiguration.SyncObject)
                    {
                        if (QueryManagementConfiguration.queryManagementConfiguration == null)
                        {
                            QueryManagementConfiguration.queryManagementConfiguration = new QueryManagementConfiguration();
                            QueryManagementConfiguration.DetermineMetranetInstallationDirectory();
                            QueryManagementConfiguration.queryManagementConfiguration.configurationFileName =
                                string.Concat(QueryManagementConfiguration.metraNetInstallDirectory, @"\Config\QueryManagement\QueryManagement.xml");
                            QueryManagementConfiguration.queryManagementConfiguration.configurationFile.Load(QueryManagementConfiguration.queryManagementConfiguration.configurationFileName);
                            QueryManagementConfiguration.ParseConfigurationFile();
                            QueryManagementConfiguration.DeterminePlatformDatabase();

                            if (QueryManagementConfiguration.configurationErrorList.Count > 0)
                            {
                                foreach (string s in QueryManagementConfiguration.configurationErrorList)
                                {
                                    LogHelper.WriteLog(s, LogLevelEnum.Fatal, QueryManagementConfiguration.Logger, null);
                                }
                                throw new QueryManagementException("One or more configuration errors encountered.");
                            }
                        }
                    }
                }
            }
            finally
            {
                // Trace Logging
                if (QueryManagementConfiguration.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryManagementConfiguration.Logger, null);
                }
            }
        }

        /// <summary>
        /// Reads, validates and sets local variables from the QueryManagement configuration file.
        /// </summary>
        private static void ParseConfigurationFile()
        {
            const string methodName = "[ParseConfigurationFile]";

            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (QueryManagementConfiguration.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryManagementConfiguration.Logger, null);
            }

            try
            {
                if (QueryManagementConfiguration.Logger.WillLogInfo)
                {
                    message = string.Concat(methodName, "Parsing configuration file, \"", QueryManagementConfiguration.queryManagementConfiguration.configurationFileName, "\"");
                    LogHelper.WriteLog(message, LogLevelEnum.Info, QueryManagementConfiguration.Logger, null);
                }

                var rootXmlNode = QueryManagementConfiguration.FindAndParseXmlNodeOrSaveError(QueryManagementConfiguration.queryManagementConfiguration.configurationFile, null, "root", false);
                var enabledXmlNode = QueryManagementConfiguration.FindAndParseXmlNodeOrSaveError(null, rootXmlNode, "enabled", true);
                QueryManagementConfiguration.queryManagementConfiguration.enabled = enabledXmlNode.InnerText.Equals("true", StringComparison.InvariantCultureIgnoreCase) ? true : false;

                var validatorsXmlNode = QueryManagementConfiguration.FindAndParseXmlNodeOrSaveError(null, rootXmlNode, "validators", true);
                QueryManagementConfiguration.ParseValidatorXmlNodes(validatorsXmlNode, typeof(DirectoryValidationTypeEnum));
                QueryManagementConfiguration.ParseValidatorXmlNodes(validatorsXmlNode, typeof(InfoFileValidationTypeEnum));
            }
            finally
            {
                // Trace Logging
                if (QueryManagementConfiguration.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryManagementConfiguration.Logger, null);
                }
            }
        }

        /// <summary>
        /// Parses the validator xml nodes from the QueryManagement configuration file, validating their value/InnerText
        /// and adding them to the dictionary of validations to perform if their value/InnerText is set to "true"
        /// </summary>
        /// <param name="validatorsXmlNode">The validators xml node from the QueryManagement configuration file.</param>
        /// <param name="enumType">The enumerated type to load, parse and validate mathing xml nodes from.</param>
        private static void ParseValidatorXmlNodes(XmlNode validatorsXmlNode, Type enumType)
        {
            const string methodName = "[ParseValidatorXmlNodes]";

            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (QueryManagementConfiguration.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryManagementConfiguration.Logger, null);
            }

            try
            {
                //// Validate parameter rootXmlNode
                if (validatorsXmlNode == null)
                {
                    message = string.Concat(
                        methodName,
                        string.Format(CultureInfo.CurrentCulture,
                        MessageConstants.ParameterIsNull,
                        "validatorsXmlNode"));

                    if (QueryManagementConfiguration.Logger.WillLogFatal)
                    {
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryManagementConfiguration.Logger, null);
                    }

                    throw new ArgumentException(message);
                }

                if (enumType == null)
                {
                    message = string.Concat(
                        methodName,
                        string.Format(CultureInfo.CurrentCulture,
                        MessageConstants.ParameterIsNull,
                        "enumType"));

                    if (QueryManagementConfiguration.Logger.WillLogFatal)
                    {
                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryManagementConfiguration.Logger, null);
                    }

                    throw new ArgumentException(message);
                }

                string typeName = enumType.ToString();
                string validatorNodeName = null;
                
                switch(typeName)
                {
                    case "MetraTech.DataAccess.QueryManagement.EnumeratedTypes.DirectoryValidationTypeEnum":
                        {
                            validatorNodeName = "directory";
                        }
                        break;
                    case "MetraTech.DataAccess.QueryManagement.EnumeratedTypes.InfoFileValidationTypeEnum":
                        {
                            validatorNodeName = "infofile";
                        }
                        break;
                    default:
                        {
                             message = string.Concat(
                                methodName,
                                string.Format(CultureInfo.CurrentCulture,
                                MessageConstants.ParameterIsNotValid,
                                "enumType"));

                            if (QueryManagementConfiguration.Logger.WillLogFatal)
                            {
                                LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryManagementConfiguration.Logger, null);
                            }

                            throw new ArgumentException(message);
                        }
                }

                string[] names = Enum.GetNames(enumType);
                var validatorNode = QueryManagementConfiguration.FindAndParseXmlNodeOrSaveError(null, validatorsXmlNode, validatorNodeName, false);

                if (validatorNode != null)
                {
                    var validationList = new List<int>();
                    for (int index = 0; index < names.Length; index++)
                    {
                        if (names[index].Equals("None", StringComparison.InvariantCultureIgnoreCase))
                        {
                            continue;
                        }

                        var validatorTypeXmlNode = QueryManagementConfiguration.FindAndParseXmlNodeOrSaveError(null, validatorNode, names[index], false);
                        var validatorEnabledXmlNode = QueryManagementConfiguration.FindAndParseXmlNodeOrSaveError(null, validatorTypeXmlNode, "enabled", true);
                        if (QueryManagementConfiguration.ValidateBooleanXmlNodeInnerText(validatorEnabledXmlNode))
                        {
                            if (validatorEnabledXmlNode.InnerText.Equals("true", StringComparison.InvariantCultureIgnoreCase))
                            {
                                validationList.Add(index);
                            }
                        }
                    }
                    if (validationList.Count > 0)
                    {
                        QueryManagementConfiguration.queryManagementConfiguration.validators.Add(enumType, validationList);
                    }
                }
            }
            finally
            {
                // Trace Logging
                if (QueryManagementConfiguration.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryManagementConfiguration.Logger, null);
                }
            }
        }

        /// <summary>
        /// Validates the value/InnerText of the XmlNode specified is equivalent to a boolean value of true or false.
        /// </summary>
        /// <param name="xmlNode">The xml node to validate contains a boolean value in its InnerText field/property.</param>
        private static bool ValidateBooleanXmlNodeInnerText(XmlNode xmlNode)
        {
            const string methodName = "[ValidateBooleanXmlNodeInnerText]";

            string message = string.Empty;
            Stopwatch stopwatch = null;

            // Trace Logging
            if (QueryManagementConfiguration.Logger.WillLogTrace)
            {
                stopwatch = new Stopwatch();
                stopwatch.Start();
                message = string.Concat(methodName, MessageConstants.MethodEnter);
                LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryManagementConfiguration.Logger, null);
            }

            try
            {
                if (!xmlNode.InnerText.Equals("true", StringComparison.InvariantCultureIgnoreCase) &&
                    !xmlNode.InnerText.Equals("false", StringComparison.InvariantCultureIgnoreCase))
                {
                    if (QueryManagementConfiguration.Logger.WillLogFatal)
                    {
                        message =
                            string.Concat(
                                methodName,
                                "The \"",
                                xmlNode.Name,
                                "\" element's value/InnerText acceptable values are \"true\" or \"false\".  The current value is \"",
                                xmlNode.InnerText,
                                "\" in the file ",
                                QueryManagementConfiguration.queryManagementConfiguration.configurationFileName,
                                "\" for the parent element \"",
                                xmlNode.ParentNode.Name,
                                "\".");

                        LogHelper.WriteLog(message, LogLevelEnum.Fatal, QueryManagementConfiguration.Logger, null);
                    }

                    QueryManagementConfiguration.configurationErrorList.Add(message);
                    return false;
                }
                return true;
            }
            finally
            {
                // Trace Logging
                if (QueryManagementConfiguration.Logger.WillLogTrace)
                {
                    stopwatch.Stop();

                    message = string.Concat(
                        methodName,
                        MessageConstants.BracketOpen,
                        MessageConstants.ElapsedMilliseconds,
                        stopwatch.ElapsedMilliseconds,
                        MessageConstants.BracketClose,
                        MessageConstants.MethodExit);

                    LogHelper.WriteLog(message, LogLevelEnum.Trace, QueryManagementConfiguration.Logger, null);
                }
            }
        }
    }
}
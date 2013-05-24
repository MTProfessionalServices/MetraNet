using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml;

namespace MetraTech.Utils.DbInstallComments
{
    /// <summary>
    /// Contains common settings
    /// </summary>
    /// <remarks>This class is sigletone</remarks>
    internal sealed class CommonSettings
    {
        private const string ArgumentHelp = "/h";
        private const string ArgumentDirPathToTableComments = "/dc";
        private const string QueryAdapterFile = "queryadapter.xml";
        private const string XPathSqlServerFileName = "//sql_server_query_file";
        private const string XPathOraclerFileName = "//oracle_query_file";
        private const string XPathSqlServerForViewFileName = "//sql_server_query_file_for_view";
        private const string XPathOraclerForViewFileName = "//oracle_query_file_for_view";
        
        private readonly string _pathToCommentsDir = String.Empty;
        private readonly string _pathToAdapterFileConfig = String.Empty;
        private static CommonSettings _commonSettings = null;

        private CommonSettings(string commentsDir)
        {
            _pathToCommentsDir = commentsDir;
            _pathToAdapterFileConfig = Path.Combine(commentsDir, QueryAdapterFile);

            if (!File.Exists(_pathToAdapterFileConfig))
                throw new ArgumentException(String.Format(Localization.AdapterFileNotExist, _pathToAdapterFileConfig));

            SqlServerCommentFileName = GetFilePathFromFileAdapter(XPathSqlServerFileName);
            OracleCommentFileName = GetFilePathFromFileAdapter(XPathOraclerFileName);
            SqlServerCommentForViewFileName = GetFilePathFromFileAdapter(XPathSqlServerForViewFileName);
            OracleCommentForViewFileName = GetFilePathFromFileAdapter(XPathOraclerForViewFileName);
        }

        XmlDocument _xmlAdapterDoc = null;
        private string GetFilePathFromFileAdapter(string xpath)
        {
            if (_xmlAdapterDoc == null)
            {
                _xmlAdapterDoc = new XmlDocument();
            using (XmlTextReader xmlReader = new XmlTextReader(_pathToAdapterFileConfig))
            {
                    _xmlAdapterDoc.Load(xmlReader);
                }
            }

            return Path.Combine(_pathToCommentsDir, GetValueFromXml(_xmlAdapterDoc, xpath));
        }

        /// <summary>
        /// Checks args and creates settings
        /// </summary>
        /// <param name="args">Arguments from main method</param>
        /// <param name="message"></param>
        /// <returns>0 - if settings were created, otherwise error code</returns>
        public static int CreateInstance(string[] args, out string message)
        {
            int errorCode = 0;
            message = String.Empty;
            if (ShowHelp(args))
            {
                message = Localization.UsageApp;
                errorCode = 1;
            }
            else if (args.Length != 2)
            {
                message = CreateMsgParamsSetIncorect();
                errorCode = -1;
            }
            else if (args[0].Equals(ArgumentDirPathToTableComments))
            {
                if (Directory.Exists(args[1]))
                {
                    _commonSettings = new CommonSettings(args[1]); 
                }
                else
                {
                    message = String.Format(Localization.DirNotExist, args[1]);
                    errorCode = -3;
                }
                
            }
            else
            {
                message = CreateMsgParamsSetIncorect();
                errorCode = -2;
            }

            return errorCode;
        }

        /// <summary>
        /// Gets instance of CommonSettings singletone
        /// </summary>
        public static CommonSettings Instance
        {
            get
            {
                if (_commonSettings == null)
                    throw new TypeInitializationException(typeof(CommonSettings).ToString(), null);
                return _commonSettings;
            }
        }

        /// <summary>
        /// Path to file which is contained the table/columns comments for MSSQL DB
        /// </summary>
        public string SqlServerCommentFileName 
        {
            get; private set;
        }
        
        /// <summary>
        /// Path to file which is contained the table/columns comments for Oracle DB
        /// </summary>
        public string OracleCommentFileName
        {
            get; private set;
        }

        /// <summary>
        /// Path to file which is contained the view comments for MSSQL DB
        /// </summary>
        public string SqlServerCommentForViewFileName
        {
            get;
            private set;
        }

        /// <summary>
        /// Path to file which is contained the view comments for Oracle DB
        /// </summary>
        public string OracleCommentForViewFileName
        {
            get;
            private set;
        }

        /// <summary>
        /// Name of CORE DB
        /// </summary>
        public readonly string NetMeterDb = "NetMeter";

        /// <summary>
        /// Name of staging DB
        /// </summary>
        public readonly string NetMeterStageDb = "NetMeterStage";

        private string GetValueFromXml(XmlDocument xmlDoc, string xPath)
        {
            XmlNode node = xmlDoc.SelectSingleNode(xPath);
            if (node == null)
                throw new AggregateException(String.Format(Localization.CantFindXmlTagInFileByXPath, xPath, _pathToAdapterFileConfig));

            if (String.IsNullOrEmpty(node.InnerText))
                throw new XmlException(String.Format(Localization.ValueIsNullOrEmptyInXmlFile, node, _pathToAdapterFileConfig));

            return node.InnerText;
        }

        #region Command line argumens

        private static bool ShowHelp(string[] args)
        {
            return args.Length == 1 && (args[0].Equals(ArgumentHelp));
        }

        private static string CreateMsgParamsSetIncorect()
        {
            return String.Format("{0}\n{1}",
                                        Localization.ParamSetIncorrectly,
                                        Localization.UsageApp);
        }

        #endregion Command line argumens

    }
}

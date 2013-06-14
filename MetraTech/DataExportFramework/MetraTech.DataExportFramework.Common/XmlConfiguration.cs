using System;
using System.Configuration;
using System.IO;
using System.Xml;
using MetraTech.DataAccess.QueryManagement.Business.Logic;
using MetraTech.Interop.RCD;

namespace MetraTech.DataExportFramework.Common
{
    /// <summary>
    /// Reads configuration for DataExport Seervice from the xml configuration file.
    /// The configuration describes in <see cref="DataExport\Config\Usage\MetratechReports.xml"/> file
    /// </summary>
    /// <remarks>The class should not be ussed directly
    /// It should be used in <see cref="Configuration"/> class </remarks>
    
    public class XmlConfiguration : IConfiguration
    {
        private const string CurrentExtensionDirName = "DataExport";
        private const string UsageDir = @"Config\Usage";
        private const string DefaultReportConfigurationFileName = "MetratechReports.xml";
        private string _customReportConfigurationFileName = String.Empty;
        private const string PathtypeXmlAttribute = "pathtype";

        private readonly string _extensionDir = null;

        #region getting data from congiguration file

        private XmlDocument _xmlConfig = null;

        private XmlDocument InitXmlDoc()
        {
            if (File.Exists(PathToReportConfigFile) == false)
                throw new FileNotFoundException(Localize.TheConfigFileDoesntExistInSpecifiedPath, PathToReportConfigFile);

            XmlDocument xmlDoc= new XmlDocument();
            xmlDoc.Load(PathToReportConfigFile);

            return xmlDoc;
        }

        private T GetValueFromConfigFile<T>(string xPath)
        {
            if (_xmlConfig == null)
            {
                _xmlConfig = InitXmlDoc();
            }

            XmlNode node = _xmlConfig.SelectSingleNode(xPath);

            if (node == null)
                throw new ConfigurationErrorsException(
                    String.Format(Localize.XPathIsNotSpecifiyedInConfigFile, xPath),
                    PathToReportConfigFile, -1);

            if (String.IsNullOrEmpty(node.InnerText))
                throw new ConfigurationErrorsException(
                    String.Format(
                        Localize.ValueIsNotSpecInTagInConfigFile,
                        xPath),
                    PathToReportConfigFile, -1);

            try
            {
                return (T) Convert.ChangeType(node.InnerText.Trim(), typeof (T));
            }
            catch (Exception ex)
            {
                throw new ConfigurationErrorsException(
                    String.Format(Localize.ValueWasNotAbleToConvertFromTagInConfigFile
                        , node.InnerText.Trim(), typeof(T), xPath, PathToReportConfigFile), ex);
            }
        }

        private pathtype GetPathTypeFromConfilgFile(string xPath)
        {
            pathtype pathType = pathtype.relative;
            if (_xmlConfig == null)
            {
                _xmlConfig = InitXmlDoc();
            }

            XmlNode node = _xmlConfig.SelectSingleNode(xPath);

            if (node == null)
                throw new ConfigurationErrorsException(
                    String.Format(Localize.XPathIsNotSpecifiyedInConfigFile, xPath),
                    PathToReportConfigFile, -1);

            node = node.Attributes.GetNamedItem(PathtypeXmlAttribute);

            if (node != null)
            {
                try
                {
                    pathType = (pathtype)Enum.Parse(typeof(pathtype), node.Value);
                }
                catch (Exception ex)
                {
                    string supportsPathtypeValues = String.Empty;
                    foreach (string enumItem in Enum.GetNames(typeof(pathtype)))
                    {
                       supportsPathtypeValues = String.Format("{0}{1}, ", supportsPathtypeValues, enumItem);
                    }

                    if (supportsPathtypeValues.Length > 2)
                        supportsPathtypeValues.Substring(0, supportsPathtypeValues.Length -2);

                    throw new ConfigurationErrorsException(String.Format(Localize.IlligalValueFromXmlAttribute
                        , node.Value, PathtypeXmlAttribute, supportsPathtypeValues), ex, node);
                }
            }

            return pathType;
        }

        #endregion getting data from congiguration file

        private static IConfiguration _instance = null;
        private readonly FileSystemWatcher _configWathcer = new FileSystemWatcher();

        private XmlConfiguration()
        {
            IMTRcd rcd = new MetraTech.Interop.RCD.MTRcdClass();
            rcd.Init();
            _extensionDir = rcd.ExtensionDir;

            Init();

            // configure file wathcer
            _configWathcer.Path = Path.GetDirectoryName(PathToReportConfigFile);
            _configWathcer.Filter = Path.GetFileName(PathToReportConfigFile);
            _configWathcer.Changed += new FileSystemEventHandler(OnConfigFileChanged);
            _configWathcer.EnableRaisingEvents = true;

        }

        // Define the event handlers. 
        private void OnConfigFileChanged(object source, FileSystemEventArgs e)
        {
            DefLog.MakeLogEntry(Localize.DEFIsGoingToStartReInitilizeConfiguration, "info");

            try
            {
                // re-init class with new paths
                Init();
            }
             
            catch (Exception ex)
            {
                DefLog.MakeLogEntry(String.Format(Localize.FailedToREInitConfigurationForDEF, ex.Message, ex), "error");
                 throw;
            }

            // cleanup QM var
            _qm = null;
            DefLog.MakeLogEntry(Localize.DEFReInitilizeConfigurationIsFinishedSuccessfully, "info");
        }

        private const string XPathToWorkingFolder = "xmlconfig/reports/paths/workingfolder";
        private const string XPathToServiceQueryDir = "xmlconfig/reports/paths/queries/service";
        private const string XPathToCustomQueryDir = "xmlconfig/reports/paths/queries/custom";
        private const string XPathToReportFieldDefDir = "xmlconfig/reports/paths/reportfieldef";

        private readonly object _lockInit = new object();

        private void Init()
        {
            lock (_lockInit)
            {
                _xmlConfig = null;
                DefLog.MakeLogEntry(String.Format(Localize.DEFWillUseConfigFromTheSpecFile, PathToReportConfigFile), "info");

                ScanInterval = GetValueFromConfigFile<int>("xmlconfig/reports/scandataexportservice/scaninterval");
                DefLog.MakeLogEntry(String.Format(Localize.DEFWillUseConfigParameter_withAdditionalInfo, "scaninterval", ScanInterval, "minute(s)"), "info");

                ProcessingServer = GetValueFromConfigFile<string>("xmlconfig/reports/processingserver");
                DefLog.MakeLogEntry(String.Format(Localize.DEFWillUseConfigParameter, "processingserver", ProcessingServer), "info");

                WorkingFolder = GetPathFromConfigFile(XPathToWorkingFolder);
                DefLog.MakeLogEntry(String.Format(Localize.DEFWillUseConfigParameter, "workingfolder", WorkingFolder), "info");

                PathToServiceQueryDir = GetPathFromConfigFile(XPathToServiceQueryDir);
                DefLog.MakeLogEntry(String.Format(Localize.DEFWillUseConfigParameter, "queries/service", PathToServiceQueryDir), "info");

                PathToCustomQueryDir = GetPathFromConfigFile(XPathToCustomQueryDir);
                DefLog.MakeLogEntry(String.Format(Localize.DEFWillUseConfigParameter, "queries/custom", PathToCustomQueryDir), "info");

                PathToReportFieldDefDir = GetPathFromConfigFile(XPathToReportFieldDefDir);
                DefLog.MakeLogEntry(String.Format(Localize.DEFWillUseConfigParameter, "reportfieldef", PathToReportFieldDefDir), "info");
            }
        }

        private string GetPathFromConfigFile(string xPath)
        {
            string pathToFolder = String.Empty; 
            
            switch(GetPathTypeFromConfilgFile(xPath))
            {
                case pathtype.absolute:
                    pathToFolder = GetValueFromConfigFile<string>(xPath);
                    break;
                case pathtype.relative:
                    pathToFolder = Path.GetFullPath(
                                        Path.Combine(Path.GetDirectoryName(
                                                PathToReportConfigFile), GetValueFromConfigFile<string>(xPath)));
                    break;
                default: throw new ConfigurationErrorsException(String.Format(
                    Localize.DevelopersForgotToAddImplementationForTheType, GetPathTypeFromConfilgFile(xPath), PathtypeXmlAttribute));
            }

            IsFolderExist(pathToFolder, xPath);

            return pathToFolder;
        }

        private void IsFolderExist(string folderPath, string xPathToConfigTag)
        {
            if (!Directory.Exists(folderPath))
                throw new ConfigurationErrorsException(
                    String.Format(
                        Localize.SpecifiedFolderDoesNotExistInConfigFile,
                        folderPath,
                        xPathToConfigTag,
                        PathToReportConfigFile));
        }

        private enum pathtype
        {
            relative,
            absolute
        }

        /// <summary>
        /// Gets configuration instance
        /// </summary>
        public static IConfiguration Instance
        {
            get
            {
                if (_instance == null)
                {
                    try
                    {
                        _instance = new XmlConfiguration();
                    }
                    catch (Exception ex)
                    {
                        DefLog.MakeLogEntry(String.Format(Localize.FailedToInitConfigurationForDEF, ex.Message, ex), "error");
                        throw;
                    }
                   
                }
                return _instance;
            }
        }

        /// <summary>
        /// Sets new file configuration and re-init instance
        /// </summary>
        /// <param name="fileConfiguration">just file name</param>
        public void SetNewFileConfiguration(string fileConfiguration)
        {
            if (String.IsNullOrEmpty(fileConfiguration.Trim()))
                throw new ConfigurationErrorsException(Localize.TheConfilgFileWasNotSpec);

            _customReportConfigurationFileName = fileConfiguration.Trim();
            ((XmlConfiguration)_instance).Init(); 
        }

        /// <summary>
        /// Sets default configuration file and re-init instance
        /// </summary>
        public void UseDefaultConfiguration()
        {
            _customReportConfigurationFileName = String.Empty;
            ((XmlConfiguration)_instance).Init();
        }

        public int ScanInterval { get; private set; }
        public string ProcessingServer { get; private set; }
        public string WorkingFolder { get; private set; }
        public string PathToServiceQueryDir { get; private set; }
        public string PathToCustomQueryDir { get; private set; }
        public string PathToReportFieldDefDir { get; private set; }

        public string PathToReportConfigFile
        {
            get { return CombinePathToExtensionDir(Path.Combine(UsageDir, 
                                                    String.IsNullOrEmpty(_customReportConfigurationFileName) 
                                                            ? DefaultReportConfigurationFileName
                                                            : _customReportConfigurationFileName));
            }
        }

        public string PathToExtensionDir
        {
            get { return CombinePathToExtensionDir(String.Empty); }
        }

        private string CombinePathToExtensionDir(string path)
        {
            return Path.Combine(_extensionDir, CurrentExtensionDirName, path);
        }

        private QueryMapper _qm = null;
        public bool IsQueryManagerEnabled
        {
            get
            {
                // Check Query Management Enabled or not? 
                if (_qm == null)
                {
                    _qm = new QueryMapper();
                }
                
                return _qm.Enabled;
            }
        }
    }
}

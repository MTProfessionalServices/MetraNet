using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.DataExportFramework.Common
{
    /// <summary>
    /// Inteface for DEF configuration should be used like Singltone
    /// </summary>
    public interface IConfiguration
    {
        /// <summary>
        /// Gets intervals fro scunning in minutes
        /// </summary>
        int ScanInterval { get; }

        /// <summary>
        /// Gets the server name where the Metratech Data Export Service is running
        /// </summary>
        string ProcessingServer { get; }

        /// <summary>
        /// Gets path to folder were reports are saved
        /// </summary>
        string WorkingFolder { get; }

        /// <summary>
        /// Gets full path to query for Windows Service
        /// </summary>
        /// <value>absolute Dir path</value>
        string PathToServiceQueryDir { get; }

        /// <summary>
        /// Gets full path to query for custom queries which can be used in UI side
        /// </summary>
        /// <value>absolute Dir path</value>
        string PathToCustomQueryDir { get; }

        /// <summary>
        /// Gets dir to field definition (the old name is fieldDef)
        /// </summary>
        /// <value></value>
        string PathToReportFieldDefDir { get; }

        /// <summary>
        /// Gets full path to config faile
        /// </summary>
        /// <value>full file name</value>
        string PathToReportConfigFile { get; }

        /// <summary>
        /// Gets extension dir
        /// </summary>
        /// <value></value>
        string PathToExtensionDir { get; }

        /// <summary>
        /// Sets new file configuration and re-init instance
        /// </summary>
        /// <param name="fileConfiguration">just file name</param>
        void SetNewFileConfiguration(string fileConfiguration);

        /// <summary>
        /// Sets default configuration file and re-init instance
        /// </summary>
        void UseDefaultConfiguration();

        bool IsQueryManagerEnabled { get; }
    }
}

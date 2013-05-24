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
// MODULE: ProgramArguments.cs
//
//=============================================================================

namespace MetraTech.DataAccess.DatabaseInstaller.Entities
{
    using System;
    using System.Linq;
    using MetraTech.DataAccess.QueryManagement.EnumeratedTypes;

    /// <summary>
    /// Class which holds the parsed arguments passed to the program
    /// </summary>
    public class ProgramArguments
    {
        public ProgramArguments()
        {
            MinInstallSet = Enum.GetValues(typeof(DatabaseDefinitionTypeEnum)).Cast<DatabaseDefinitionTypeEnum>().Min();
            MaxInstallSet = Enum.GetValues(typeof(DatabaseDefinitionTypeEnum)).Cast<DatabaseDefinitionTypeEnum>().Max();
        }

        /// <summary>
        /// 
        /// </summary>
        public string Action
        {
            get;
            set;
        }

        /// <summary>
        /// The database name
        /// </summary>
        public string DatabaseName
        {
            get;
            set;
        }

        /// <summary>
        /// The database type
        /// </summary>
        public string DatabaseType
        {
            get;
            set;
        }

        /// <summary>
        /// The database device location
        /// </summary>
        public string DataDeviceLocation
        {
            get;
            set;
        }

        /// <summary>
        /// The database device name
        /// </summary>
        public string DataDeviceName
        {
            get;
            set;
        }

        /// <summary>
        /// The database device ize
        /// </summary>
        public string DataDeviceSize
        {
            get;
            set;
        }

        /// <summary>
        /// The datbase device filename
        /// </summary>
        public string DataDumpDeviceFile
        {
            get;
            set;
        }

        /// <summary>
        /// The datasource
        /// </summary>
        public string DataSource
        {
            get;
            set;
        }

        /// <summary>
        /// The name of the dbo logon
        /// </summary>
        public string DboLogon
        {
            get;
            set;
        }

        /// <summary>
        /// The password for the dbo logon
        /// </summary>
        public string DboPassword
        {
            get;
            set;
        }

        /// <summary>
        /// The InstallTime Pre/Post Synchronization option
        /// </summary>
        public InstallTime InstallTime
        {
            get;
            set;
        }

        /// <summary>
        /// The install without dropping the database option
        /// </summary>
        public bool InstallWithoutDroppingDatabase
        {
            get;
            set;
        }

        /// <summary>
        /// The is it a staging database option
        /// </summary>
        public bool IsStaging
        {
            get;
            set;
        }

        /// <summary>
        /// The log device file location
        /// </summary>
        public string LogDeviceLocation
        {
            get;
            set;
        }

        /// <summary>
        /// The log device filename
        /// </summary>
        public string LogDeviceName
        {
            get;
            set;
        }

        /// <summary>
        /// The size of the log device
        /// </summary>
        public string LogDeviceSize
        {
            get;
            set;
        }

        /// <summary>
        /// The log dump device filename
        /// </summary>
        public string LogDumpDeviceFile
        {
            get;
            set;
        }

        /// <summary>
        /// The Name of the QueryTag to execute
        /// </summary>
        public string QueryTag
        {
            get;
            set;
        }

        /// <summary>
        /// The server admin logon name
        /// </summary>
        public string SeverAdminLogon
        {
            get;
            set;
        }

        /// <summary>
        /// The server admin logon password
        /// </summary>
        public string SeverAdminPassword
        {
            get;
            set;
        }

        /// <summary>
        /// The name of the serever
        /// </summary>
        public string ServerName
        {
            get;
            set;
        }

        /// <summary>
        /// The timeout value
        /// </summary>
        public UInt32 TimeoutValue
        {
            get;
            set;
        }

        /// <summary>
        /// The uninstalling option
        /// </summary>
        public bool UnInstalling
        {
            get;
            set;
        }
        /// <summary>
        /// The uninstall only option
        /// </summary>
        public bool UnInstallOnly
        {
            get;
            set;
        }
        /// <summary>
        /// The min install set
        /// </summary>
        public DatabaseDefinitionTypeEnum MinInstallSet
        {
            get;
            set;
        }

        /// <summary>
        /// The max install set
        /// </summary>
        public DatabaseDefinitionTypeEnum MaxInstallSet
        {
            get;
            set;
        }
    }
}

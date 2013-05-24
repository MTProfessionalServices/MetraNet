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
// MODULE: ProgramArgumentConstants.cs
//
//=============================================================================

namespace MetraTech.DataAccess.DatabaseInstaller.Constants
{
    /// <summary>
    /// Class of Program Argument Constants
    /// </summary>
    public class ProgramArgumentConstants
    {
        /// <summary>
        /// The type of install action to perform program argument
        /// </summary>
        public const string Action = "-action";

        /// <summary>
        /// The database device name program argument
        /// </summary>
        public const string DatabaseDeviceName = "-datadevname";

        /// <summary>
        /// The  program argument
        /// </summary>
        public const string DatabaseDeviceLocation = "-datadevloc";

        /// <summary>
        /// The database device size program argument
        /// </summary>
        public const string DatabaseDeviceSize = "-datadevsize";

        /// <summary>
        /// The  program argument
        /// </summary>
        public const string DatabaseDumpFile = "-datadumpdevfile";

        /// <summary>
        /// The database name program argument
        /// </summary>
        public const string DatabaseName = "-dbname";

        /// <summary>
        /// The datbase type program argument
        /// </summary>
        public const string DatabaseType = "-dbtype";

        /// <summary>
        /// The datasource program argument
        /// </summary>
        public const string DataSource = "-datasource";

        /// <summary>
        /// The  program argument
        /// </summary>
        public const string DboLogon = "-dbologon";

        /// <summary>
        /// The dbo user password program argument
        /// </summary>
        public const string DboPassword = "-dbopassword";

        /// <summary>
        /// Indicates which Pre/Post Synchronization Hook DDL should be executed
        /// </summary>
        public const string InstallTime = "-installtime";

        /// <summary>
        /// The install without dropping database program argument
        /// </summary>
        public const string InstallWithoutDroppingDatabase = "-installwithoutdropdb";

        /// <summary>
        /// The is staging database program argument
        /// </summary>
        public const string IsStagingDatabase = "-isstaging";
        
        /// <summary>
        /// The log device name program argument
        /// </summary>
        public const string LogDeviceName = "-logdevname";
        
        /// <summary>
        /// The log device location program argument
        /// </summary>
        public const string LogDeviceLocation = "-logdevloc";
        
        /// <summary>
        /// The log device size program argument
        /// </summary>
        public const string LogDeviceSize = "-logdevsize";
        
        /// <summary>
        /// The log dump device file program argument
        /// </summary>
        public const string LogDumpDeviceFile = "-logdumpdevfile";

        /// <summary>
        /// The query to execute program argument
        /// </summary>
        public const string QueryTag = "-querytag";

        /// <summary>
        /// The server admin logon program argument
        /// </summary>
        public const string ServerAdminLogon = "-salogon";

        /// <summary>
        /// The server admin passord program argument
        /// </summary>
        public const string ServerAdminPassword = "-sapassword";

        /// <summary>
        /// The server name program argument
        /// </summary>
        public const string ServerName = "-servername";

        /// <summary>
        /// The timeout value program argument
        /// </summary>
        public const string TimeoutValue = "-timeoutvalue";

        /// <summary>
        /// The uninstall program argument
        /// </summary>
        public const string UnInstall = "-uninstall";

        /// <summary>
        /// The uninstall only program argument
        /// </summary>
        public const string UnInstallOnly = "-uninstallonly";

        /// <summary>
        /// The minimum install set
        /// </summary>
        public const string MinInstallSet = "-mininstallset";

        /// <summary>
        /// The maximum install set
        /// </summary>
        public const string MaxInstallSet = "-maxinstallset";
    }
}
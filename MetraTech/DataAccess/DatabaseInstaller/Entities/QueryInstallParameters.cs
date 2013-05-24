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

namespace MetraTech.DataAccess.DatabaseInstaller.Entities
{
    using System.Collections.Generic;

    using Constants;

    /// <summary>
    /// Strongly typed dictionary for readability
    /// </summary>
    public class QueryInstallParameters : Dictionary<string, string>
    {
        /// <summary>
        /// Prevents a default instance of this class from being instantiated.
        /// </summary>
        private QueryInstallParameters()
        {
        }

        /// <summary>
        /// Initializes the QueryInstallParameters class.
        /// </summary>
        public QueryInstallParameters(ProgramArguments programArguments)
        {
            this.Add(QueryInstallParameterConstants.DatabaseName, programArguments.DatabaseName);
            this.Add(QueryInstallParameterConstants.DataDeviceName, programArguments.DataDeviceName);
            this.Add(QueryInstallParameterConstants.DataDeviceLocation, programArguments.DataDeviceLocation);
            this.Add(QueryInstallParameterConstants.DataDeviceSize, programArguments.DataDeviceSize);
            this.Add(QueryInstallParameterConstants.DataDumpDeviceFile, programArguments.DataDumpDeviceFile);
            this.Add(QueryInstallParameterConstants.DboLogon, programArguments.DboLogon);
            this.Add(QueryInstallParameterConstants.DboPassword, programArguments.DboPassword);
            this.Add(QueryInstallParameterConstants.LogDeviceName, programArguments.LogDeviceName);
            this.Add(QueryInstallParameterConstants.LogDeviceLocation, programArguments.LogDeviceLocation);
            this.Add(QueryInstallParameterConstants.LogDeviceSize, programArguments.LogDeviceSize);
            this.Add(QueryInstallParameterConstants.LogDumpDeviceFile, programArguments.LogDumpDeviceFile);
            this.Add(QueryInstallParameterConstants.SaLogon, programArguments.SeverAdminLogon);
            this.Add(QueryInstallParameterConstants.SaPassword, programArguments.SeverAdminPassword);
            this.Add(QueryInstallParameterConstants.ServerName, programArguments.ServerName);
            this.Add(QueryInstallParameterConstants.TimeouValue, programArguments.TimeoutValue.ToString());
        }
    }
}

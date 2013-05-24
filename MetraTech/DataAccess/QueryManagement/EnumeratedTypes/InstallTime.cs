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
// MODULE: InstallTime.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.EnumeratedTypes
{
    /// <summary>
    /// Enumerated type that indicates when the specified DDL query is executed.
    /// </summary>
    public enum InstallTime
    {
        /// <summary>
        /// Indicates the DDL install script is to run before the synchronization hooks.
        /// </summary>
        PreSync,

        /// <summary>
        /// Indicates the DDL install script is to run afte the synchronization hooks.
        /// </summary>
        PostSync,

        /// <summary>
        /// Indicates the DDL install script is to run independedt of the synchronization hooks.
        /// </summary>
        OnDemand
    }
}

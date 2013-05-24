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
// MODULE: QueryFileTypeEnum.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.EnumeratedTypes
{
    using System.Runtime.InteropServices;

    /// <summary>
    /// Enumerated type representing the type of database query file
    /// </summary>
    [ComVisible(true)]
    [Guid("6E5F4320-0A43-4EFB-A997-C442CB0E4E66")]
    public enum QueryFileTypeEnum
    {
        /// <summary>
        /// Used to indicate all query file types are applicable
        /// </summary>
        All,

        /// <summary>
        /// The "Common" query file.
        /// </summary>
        Common,

        /// <summary>
        /// The "DbAccess" query file.
        /// </summary>
        DbAccess,

        /// <summary>
        /// The "Info" query metadata file.
        /// </summary>
        Info,

        /// <summary>
        /// The "SqlServer" query file.
        /// </summary>
        SqlServer,

        /// <summary>
        /// The "Oracle" query file.
        /// </summary>
        Oracle
    }
}
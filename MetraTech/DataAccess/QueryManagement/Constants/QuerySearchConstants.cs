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
// MODULE: QuerySearchConstants.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.Constants
{
    using System.Runtime.InteropServices;

    /// <summary>
    /// Constants used when searching for query files
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("D51695FF-965D-4751-8431-A53233C62F2E")]
    public static class QuerySearchConstants
    {
        /// <summary>
        /// The search value for the "Common" query file.
        /// </summary>
        public const string Common = "*.Common.sql";

        /// <summary>
        /// The search value for the "Info" info metadata file.
        /// </summary>
        public const string Info = "*._Info.xml";

        /// <summary>
        /// The DDL top level folder 
        /// </summary>
        public const string Install = @"\Install";

        /// <summary>
        /// The search value for the "Oracle" query file.
        /// </summary>
        public const string Oracle = "*.Oracle.sql";

        /// <summary>
        /// The DML top level folder 
        /// </summary>
        public const string Queries = @"\Queries";

        /// <summary>
        /// The search value for the "SqlServer" query file.
        /// </summary>
        public const string SqlServer = "*.SqlServer.sql";

        /// <summary>
        /// The "WildCard" search value.
        /// </summary>
        public const string Wildcard = "*";
    }
}

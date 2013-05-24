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
// MODULE: QueryFolderEnum.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.EnumeratedTypes
{
    using System.Runtime.InteropServices;

    /// <summary>
    /// Enumerated type indicating which olders different types of queries reside in
    /// </summary>
    [ComVisible(true)]
    [Guid("42D2D532-F07F-4971-B2B1-82AFBE1CD931")]
    public enum QueryFolderEnum
    {
        /// <summary>
        /// Indicates all Query Folder types.
        /// </summary>
        All,

        /// <summary>
        /// The baseline folder where the core queries reside
        /// </summary>
        SqlCore,

        /// <summary>
        /// The folder where the customer queries reside
        /// </summary>
        SqlCustom
    }
}

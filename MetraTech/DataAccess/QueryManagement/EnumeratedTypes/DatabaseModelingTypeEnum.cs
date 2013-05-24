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
// MODULE: DatabaseModelingTypeEnum.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.EnumeratedTypes
{
    using System.Runtime.InteropServices;

    /// <summary>
    /// Enumerated type that defines the type of DDL query found in the DDL query file
    /// </summary>
    [ComVisible(true)]
    [Guid("3458F16B-2314-4DEB-9922-057C504C9EF0")]
    public enum DatabaseModelingTypeEnum
    {
        /// <summary>
        /// Represents a file containing a query that performs an insert operation
        /// </summary>
        Insert,

        /// <summary>
        /// Represents a file containing a query that performs an update operation
        /// </summary>
        Update,

        /// <summary>
        /// Represents a file containing a query that performs a delete operation
        /// </summary>
        Delete,

        /// <summary>
        /// Represents a file containing a query that performs a select operation
        /// </summary>
        Select,

        /// <summary>
        /// Unknown DML query
        /// We can look at removing this when the data is cleaned up
        /// </summary>
        Unknown
    }
}
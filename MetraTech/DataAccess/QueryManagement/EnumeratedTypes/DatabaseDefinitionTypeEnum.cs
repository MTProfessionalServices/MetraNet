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
// MODULE: DatabaseDefinitionTypeEnum.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.EnumeratedTypes
{
    using System.Runtime.InteropServices;
    
    /// <summary>
    /// Enumerated type that defines the type of DDL query found in the DDL query file
    /// </summary>
    [ComVisible(true)]
    [Guid("B6199825-E826-46F3-A08D-FFB2E1CC91E8")]
    public enum DatabaseDefinitionTypeEnum
    {
        /// <summary>
        /// Drops A Database Table
        /// </summary>
        DropTable,

        /// <summary>
        /// Drop A Database
        /// </summary>
        DropDatabase,

        /// <summary>
        /// Drops A Database Data Device
        /// </summary>
        DropDataDevice,

        /// <summary>
        /// Drops A Database Log Device
        /// </summary>
        DropLogDevice,

        /// <summary>
        /// Drops A Database Login
        /// </summary>
        DropLogin,

        /// <summary>
        /// Represents a file containing a query that creates a database
        /// </summary>
        CreateDatabase,

        /// <summary>
        /// Represents a file containing a query that alters a database
        /// </summary>
        AlterDatabase,

        /// <summary>
        /// Represents a file containing a query that creates a database login
        /// </summary>
        CreateLogin,

        /// <summary>
        /// Represents a file containing a query that creates/drops a schema
        /// </summary>
        Schemas,

        /// <summary>
        /// Represents a file containing a query that creates a grant privilege
        /// </summary>
        Grants,

        /// <summary>
        /// Represents a file containing a query that creates/drops a table
        /// </summary>
        CreateTables,

        /// <summary>
        /// Represents a file containing a query that creates/drops a sequence
        /// </summary>
        CreateSequences,

        /// <summary>
        /// Represents a file containing an "ALTER TABLE" query
        /// </summary>
        AlterTables,
        
        /// <summary>
        /// Represents a file containing a query that creates/drops an index
        /// </summary>
        CreateIndexes,

        /// <summary>
        /// Represents a file containing a query that creates/drops a foreign key
        /// </summary>
        ForeignKeys,

        /// <summary>
        /// Represents a file containing a query that creates/drops a trigger
        /// </summary>
        CreateTriggers,

        /// <summary>
        /// Represents a file containing a query that creates/drops a view
        /// </summary>
        CreateViews,

        /// <summary>
        /// Represents a file containing a query that creates/drops a dblink
        /// </summary>
        Synonyms,

        /// <summary>
        /// Represents a file containing a query that creates/drops a type
        /// </summary>
        Types,

        /// <summary>
        /// Represents a file containing a query which inserts and/or updates data in the database
        /// </summary>
        Data,

        /// <summary>
        /// Represents a file containing a query that creates/drops a dblink
        /// </summary>
        DatabaseLinks,

        /// <summary>
        /// Represents a file containing a query that creates/drops a function
        /// </summary>
        CreateFunctions,

        /// <summary>
        /// Represents a file containing a query that creates/drops a package
        /// </summary>
        CreatePackages,

        /// <summary>
        /// Represents a file containing a query that creates/drops a package
        /// </summary>
        CreatePackageBody,

        /// <summary>
        /// Represents a file containing a query that is used as a predicate (prepend) to another query
        /// </summary>
        Predicates,

        /// <summary>
        /// Represents a file containing a query that creates/drops a stored procedure
        /// </summary>
        StoredProcedures,

        /// <summary>
        /// Represents a file containing more than one query/query type
        /// </summary>
        Compounds,

        /// <summary>
        /// Represents a file containing a query that creates/drops a snapshot
        /// </summary>
        Snapshots,

        /// <summary>
        /// Unknown query
        /// We can look at removing this when the data is cleaned up
        /// </summary>
        UnknownDdls
    }
}
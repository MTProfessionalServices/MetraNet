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
// MODULE: DataQueryLanguageEnum.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.EnumeratedTypes
{
    using System.Runtime.InteropServices;

    /// <summary>
    /// Enumerated type for Data Query Language Types
    /// </summary>
    [ComVisible(true)]
    [Guid("16FD34B9-B699-4AD6-8812-A645114ECF70")]
    public enum DataQueryLanguageEnum
    {
        /// <summary>
        /// Used to indicate that all database statements types are applicable.
        /// </summary>
        All,

        /// <summary>
        /// Data Manipulation Language (DML) statements are used for managing data within schema objects.
        /// </summary>
        DataModelingLanguage,

        /// <summary>
        /// Data Definition Language (DDL) statements are used to define the database structure or schema.
        /// </summary>
        DataDefinitionLanguage
    }
}

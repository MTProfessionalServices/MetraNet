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
// MODULE: DatabaseTypeEnum.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.EnumeratedTypes
{
    using System;
    using System.Runtime.InteropServices;

    /// <summary>
    /// Enumerated type of supported databases
    /// </summary>
    [ComVisible(true)]
    [Guid("D6513839-515F-4ECD-BD2C-9319CCD520B6")]
    public enum DatabaseTypeEnum
    {
        /// <summary>
        /// All supported databases
        /// </summary>
        All = 0, 

        /// <summary>
        /// Oracle database name
        /// </summary>
        Oracle,

        /// <summary>
        /// SqlServer database name
        /// </summary>
        SqlServer
    }
}
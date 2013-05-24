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
// MODULE: InfoFileValidationTypeEnum.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.EnumeratedTypes
{
    using System.Runtime.InteropServices;

    /// <summary>
    /// Enumerated type of QuaryManagement info file business rules validation types.
    /// </summary>
    [ComVisible(true)]
    [Guid("DEABABBD-0BFA-47DF-A60A-7CCA01DFAA8C")]
    public enum InfoFileValidationTypeEnum
    {
        /// <summary>
        /// Indicates no InforFileValidationType value was specified.
        /// </summary>
        None,

        /// <summary>
        /// Indicates the directory contains implementations that are not supported in 
        /// the infofile or the infofile contains implementations that are not supported.
        /// </summary>
        Implementations,

        /// <summary>
        /// Indicates the infofile has parameters that are not supported or do not match in the queries.
        /// </summary>
        Parameters,
    }
}

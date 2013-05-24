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
// MODULE: IQueryManagementValidator.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.Business.Logic
{
    using System.Runtime.InteropServices;

    using Entities;

    /// <summary>
    /// The Query Management Validator Interface
    /// </summary>
    [ComVisible(true)]
    [Guid("9CC0D0A3-197A-450B-A408-D2DD3F5D0CDD")]
    public interface IQueryManagementValidator
    {
        /// <summary>
        /// Performs business validations pertinent to the QueryManagement feature
        /// </summary>
        /// <param name="querySearchResults">Contains the directories to perform the directory validations on.</param>  
        /// <returns>A QueryValidationResults class containing the validation results.</returns>
        ValidationResults Execute(QuerySearchResults querySearchResults);
    }
}

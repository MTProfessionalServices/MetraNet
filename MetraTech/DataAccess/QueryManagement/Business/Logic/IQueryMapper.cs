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
// MODULE: IQueryMapper.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.Business.Logic
{
    using System.Collections;
    using System.Collections.Generic;
    using System.Runtime.InteropServices;

    using Entities;
    using EnumeratedTypes;

    /// <summary>
    /// The Query Management Validator Interface
    /// </summary>
    [ComVisible(true)]
    [Guid("F486D980-6077-4690-A421-C40536C9AB0B")]
    public interface IQueryMapper
    {
        /// <summary>
        /// Returns true if the QueryManagement configuration is set to enabled, otherwise it will return false.
        /// </summary>
        bool Enabled { get; }

        /// <summary>
        /// Performs the search for "query" files based on the search context
        /// and if one or more validations are configured performs the validations.
        /// </summary>
        /// <param name="querySearchContext">The QuerySearchContext to construct the QuerySearchResults from.</param>
        /// <returns>A QueryTags object containing the query tags with their appropriate </returns>
        QueryTags Execute(QuerySearchContext querySearchContext);

        /// <summary>
        /// MTQueryCache Interface - returns the effective set of queries to be used by the cache
        /// </summary>
        /// <param name="queryTagProperties">Array of QueryTagProperties</param>
        void QueryCache(out IEnumerator queryTagProperties);
    }
}

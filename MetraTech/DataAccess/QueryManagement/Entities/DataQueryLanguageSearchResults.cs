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
// MODULE: DataQueryLanguageSearchResults.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.Entities
{
    using System;
    using System.Collections.Generic;
    using System.Runtime.InteropServices;
    using System.Runtime.Serialization;

    using EnumeratedTypes;

    /// <summary>
    /// Dictionary of directory search results keyed by the value of the DataQueryLanguageEnum searched for
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("149627C1-84E6-4E52-AA65-289D451ECA5F")]
    public class DataQueryLanguageSearchResults : Dictionary<DataQueryLanguageEnum, DirectoryTypeNameSearchResults>
    {
        /// <summary>
        /// Initializes a new instance of the DataQueryLanguageSearchResults class
        /// </summary>
        public DataQueryLanguageSearchResults()
        {
        }

        /// <summary>
        /// Microsoft design...
        /// </summary>
        /// <param name="info">The serialization info object</param>
        /// <param name="context">The streaming context object</param>
        protected DataQueryLanguageSearchResults(SerializationInfo info, StreamingContext context)
            : base(info, context)
        {
        }
    }
}
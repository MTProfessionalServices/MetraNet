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
// MODULE: DirectoryTypeNameSearchResults.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.Entities
{
    using System;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Globalization;
    using System.Runtime.InteropServices;
    using System.Runtime.Serialization;

    
    
    

    /// <summary>
    /// Dictionary containing directory search results keyed by the folder search type
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("32D0ED45-BA29-4A51-BD46-A053B5A030F5")]
    public class DirectoryTypeNameSearchResults : Dictionary<DirectorySearchTypeValue, DirectoryListWithFiles>
    {
        /// <summary>
        /// Initializes a new instance of the DirectoryTypeNameSearchResults class
        /// </summary>
        public DirectoryTypeNameSearchResults()
        {
        }

        /// <summary>
        /// Microsoft design...
        /// </summary>
        /// <param name="info">The serialization info object</param>
        /// <param name="context">The streaming context object</param>
        protected DirectoryTypeNameSearchResults(SerializationInfo info, StreamingContext context)
            : base(info, context)
        {
        }
    }
}
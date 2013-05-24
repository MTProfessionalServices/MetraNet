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
// MODULE: QueryTags.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.Entities
{
    using System.Collections.Generic;
    using System.Runtime.InteropServices;

    /// <summary>
    /// Dictionary class representing a query tag and it's associated properties.
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("53C67159-E745-4BB6-8778-AC5A3E33AD6B")]
    public class QueryTags : Dictionary<string, QueryTagProperties>
    {
    }
}

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
// MODULE: DirectoryValidationTypeEnum.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.EnumeratedTypes
{
    using System.Runtime.InteropServices;

    /// <summary>
    /// Enumerated type of QuaryManagement directory business rules validation types.
    /// </summary>
    [ComVisible(true)]
    [Guid("EC483B2C-7E36-4848-8C76-0FF9DDD99234")]
    public enum DirectoryValidationTypeEnum
    {
        /// <summary>
        /// Indicates no DirectoryValidationType value was specified.
        /// </summary>
        None,

        /// <summary>
        /// Indicates the directory contains files that are not of type ".xml" and/or ".sql".
        /// </summary>
        DisAllowedFilesFound,
        
        /// <summary>
        /// Indicates there are no files in the directory.
        /// </summary>
        EmptyDirectory,

        /// <summary>
        /// Indicates the directory does not contain any query info files.
        /// </summary>
        NoQueryInfoFiles


    }
}

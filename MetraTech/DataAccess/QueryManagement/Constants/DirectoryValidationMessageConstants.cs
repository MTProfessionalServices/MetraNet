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
// MODULE: ClassNameConstants.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.Constants
{
    using System.Runtime.InteropServices;

    /// <summary>
    /// Classs of Directory Validation Message Constants
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("B48B4DC9-8D9C-4632-A616-6138990CD13C")]
    public class DirectoryValidationMessageConstants
    {
        /// <summary>
        /// Message indicating the directory validated did not contain any files to validate
        /// </summary>
        public const string EmptyDirectory = "The specified directory does not contain any files.";

        /// <summary>
        /// Message indicating the direcotory validated contains files that are not allowed.
        /// </summary>
        public const string DisAllowedFilesFound = "The specified directory contains files that are disallowed.";

        /// <summary>
        /// Message indicating no query infor files were found in the directory specified.
        /// </summary>
        public const string NoQueryInfoFilesFound = "No \"Info\" files were found in the specified directory.";
    }
}

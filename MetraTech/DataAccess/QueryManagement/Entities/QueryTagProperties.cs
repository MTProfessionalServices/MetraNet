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
// MODULE: QueryTagProperties.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.Entities
{
    using System;
    using System.Diagnostics;
    using System.Globalization;
    using System.Runtime.InteropServices;

    using Constants;
    using EnumeratedTypes;
    using Helpers;

    /// <summary>
    /// This class is used by the QueryCache
    /// </summary>
    [ComVisible(true)]
    [Guid("BA7A2439-E259-496C-B0D4-F3B9B5C738F0")]
    [StructLayout(LayoutKind.Sequential)]
    public struct QueryTagProperties
    {
        /// <summary>
        /// Indicates the relative path to the query based on the RMP installation location
        /// </summary>
        [MarshalAs(UnmanagedType.LPWStr)]
        public string ConfigurationDirectory;

        /// <summary>
        /// Indicates if the DbAccess file data is the only thing present in this instance
        /// </summary>
        [MarshalAs(UnmanagedType.Bool)]
        public bool DbAccessFileInfoOnly;

        /// <summary>
        /// Indicates if the DbAccess file is the default
        /// </summary>
        [MarshalAs(UnmanagedType.Bool)]
        public bool DefaultDbAccessFile;

        /// <summary>
        /// The closest DbAccess.xml relative to the folder path where the query file resides.
        /// </summary>
        [MarshalAs(UnmanagedType.LPWStr)]
        public string DbAccessFileName;

        /// <summary>
        /// The folder where the file containing the effective database access file resides.
        /// </summary>
        [MarshalAs(UnmanagedType.LPWStr)]
        public string DbAccessFilePath;

        /// <summary>
        /// The name of the query file that matches the query tag and contains the query to execute.
        /// </summary>
        [MarshalAs(UnmanagedType.LPWStr)]
        public string QueryFileName;

        /// <summary>
        /// The folder where the file containing the query resides
        /// </summary>
        [MarshalAs(UnmanagedType.LPWStr)]
        public string QueryFilePath;

        /// <summary>
        /// The QueryTag name
        /// </summary>
        [MarshalAs(UnmanagedType.LPWStr)]
        public string QueryTag;

        /// <summary>
        /// The hinter string in the info file it if exists, otherwise an empty string
        /// </summary>
        [MarshalAs(UnmanagedType.LPWStr)]
        public string QueryHinterString;

        /// <summary>
        /// The enumerated type the query corresponds to.
        /// </summary>
        [MarshalAs(UnmanagedType.LPWStr)]
        public string QueryTypeEnumName;

        /// <summary>
        /// The value of the enumerated type the query corresponds to.
        /// </summary>
        [MarshalAs(UnmanagedType.I4)]
        public int QueryTypeEnumValue;
    }
}
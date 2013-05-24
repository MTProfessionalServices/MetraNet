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
// MODULE: LogLevelEnum.cs
//
//=============================================================================

namespace MetraTech.DataAccess.QueryManagement.EnumeratedTypes
{
    using System.Runtime.InteropServices;

    /// <summary>
    /// Log level message eneumrated type
    /// </summary>
    [ComVisible(true)]
    [Guid("D7D0A24B-4ED6-4F1C-8D92-2E5EF8BBD412")]
    public enum LogLevelEnum
    {
        /// <summary>
        /// Indicates the level of the message is debug
        /// </summary>
        Debug,

        /// <summary>
        /// Indicates the level of the message is error
        /// </summary>
        Error,

        /// <summary>
        /// Indicates the level of the message is exception
        /// </summary>
        Exception,

        /// <summary>
        /// Indicates the level of the message is fatal
        /// </summary>
        Fatal,

        /// <summary>
        /// Indicates the level of the message is informational
        /// </summary>
        Info,

        /// <summary>
        /// Indicates the level of the message is trace
        /// </summary>
        Trace,

        /// <summary>
        /// Indicates the level of the message is warning
        /// </summary>
        Warning
    }
}
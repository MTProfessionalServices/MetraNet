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
// MODULE: IPerformanceStopWatchWrapper.cs
//
//=============================================================================

namespace MetraTech.Performance
{
    using System.Runtime.InteropServices;

    /// <summary>
    /// Provides acess to the PerformanceStopWatch for non C# code.
    /// </summary>
    [ComVisible(true)]
    [Guid("2003FC9E-79B5-4F60-9D54-62B5756CCCEE")]
    public interface IPerformanceStopWatchWrapper
    {
        /// <summary>
        /// Starts the PerformanceStopWatch
        /// </summary>
        void Start();

        /// <summary>
        /// Stops the PerformanceStopWatch
        /// </summary>
        void Stop(string performanceKey);
    }
}
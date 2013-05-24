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
// MODULE: PerformanceStopWatchWrapper.cs
//
//=============================================================================

namespace MetraTech.Performance
{
    using System.Runtime.InteropServices;

    /// <summary>
    /// Provides acess to the PerformanceStopWatch for non C# code.
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("0394DB94-E45D-41B1-A99C-4E121CE33B24")]
    public class PerformanceStopWatchWrapper : IPerformanceStopWatchWrapper
    {
        /// <summary>
        /// Local instance of the PerformanceStopWatch class wrapped by this class.
        /// </summary>
        private PerformanceStopWatch performanceStopWatch = null;

        /// <summary>
        /// Initializes a new instance of the PerformanceStopWatchWrapper class
        /// </summary>
        public PerformanceStopWatchWrapper()
        {
            performanceStopWatch = new PerformanceStopWatch();
        }

        /// <summary>
        /// Starts the PerformanceStopWatch
        /// </summary>
        public void Start()
        {
            this.performanceStopWatch.Start();
        }

        /// <summary>
        /// Stops the PerformanceStopWatch and adds the timing to the PerformanceManager
        /// </summary>
        public void Stop(string performanceKey)
        {
            this.performanceStopWatch.Stop(performanceKey);
        }
    }
}

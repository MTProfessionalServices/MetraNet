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
// MODULE: PerformanceStopWatch.cs
//
//=============================================================================

namespace MetraTech.Performance
{
    using System;
    using System.Diagnostics;
    using System.Runtime.InteropServices;

    /// <summary>
    /// Delegate for the Disabled/Enabled PerformanceStopWatch methods.
    /// </summary>
    public delegate void StartAction();

    /// <summary>
    /// Delegate for the Disabled/Enabled PerformanceStopWatch methods.
    /// </summary>
    public delegate void StopAction(string performanceKey);

    /// <summary>
    /// Stopwatch specific to Performance
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("E64BD0AF-6A49-404B-862B-67FB417B7757")]
    public sealed class PerformanceStopWatch
    {
        /// <summary>
        /// Stopwatch to capture the performance timing.
        /// </summary>
        private Stopwatch stopWatch;

        /// <summary>
        /// Local instance of the StartAction delegate
        /// </summary>
        /// <returns></returns>
        public StartAction Start = null;

        /// <summary>
        /// Local instance of the StopAction delegate
        /// </summary>
        /// <returns></returns>
        public StopAction Stop = null;

        /// <summary>
        /// Prevents a default instance of the PerformanceStopWatch class from being instantiated.
        /// </summary>
        public PerformanceStopWatch()
        {
            if (PerformanceConfiguration.Enabled)
            {
                this.stopWatch = new Stopwatch();
                this.Start = this.EnabledStart;
                this.Stop = this.EnabledStop;
                return;
            }

            this.Start = this.DisabledStart;
            this.Stop = this.DisabledStop;
        }

        /// <summary>
        /// Disabled start method - called when the perfomance configuration is disabled.
        /// </summary>
        private void DisabledStart()
        {
        }

        /// <summary>
        /// Disabled stop method - called when the perfomance configuration is disabled.
        /// </summary>
        private void DisabledStop(string performanceKey)
        {
        }

        /// <summary>
        /// Enabled start method - called when the perfomance configuration is enabled.
        /// </summary>
        private void EnabledStart()
        {
            if (this.stopWatch.ElapsedMilliseconds > 0)
            {
                this.stopWatch.Reset();
            }

            this.stopWatch.Start();
        }

        /// <summary>
        /// Enabled stop method - called when the perfomance configuration is enabled.
        /// Stops the stopwatch and adds the ElapsedMilliseconds to the PerfromanceManager
        /// </summary>
        private void EnabledStop(string performanceKey)
        {
            if (string.IsNullOrEmpty(performanceKey))
            {
                return;
            }

            this.stopWatch.Stop();
            PerformanceManager.AddTiming(performanceKey, this.stopWatch.ElapsedMilliseconds);
        }
    }
}

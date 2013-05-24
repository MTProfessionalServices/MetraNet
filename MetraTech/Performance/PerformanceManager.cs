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
// MODULE: PerformanceManager.cs
//
//=============================================================================

namespace MetraTech.Performance
{
    using System;
    using System.Collections;
    using System.Runtime.InteropServices;

    /// <summary>
    /// Delegate for the Disabled/Enabled PerformanceStopWatch methods.
    /// </summary>
    public delegate void AddTimingAction(string key, long milliSeconds);

    /// <summary>
    /// The PerformanceStatisticManagaer class is responsible for 
    /// managing the PerformanceStatistics it maintains 
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("C2BA7387-8ED3-46E5-A080-EAB9918951C5")]
    public static class PerformanceManager
    {
        /// <summary>
        /// AddTimingAction function pointer/delegate for enabled/disabled method calls
        /// </summary>
        public static AddTimingAction AddTiming = null;

        /// <summary>
        /// Name of this class.
        /// </summary>
        private const string ClassName = "PerformanceManager";

        /// <summary>
        /// Local logging object
        /// </summary>
        private static ILogger Logger = null;

        /// <summary>
        /// Hashtable keyed by the name of the performance statistic.
        /// </summary>
        private volatile static Hashtable PerformanceStatistics;

        /// <summary>
        /// Synchronization object.
        /// </summary>
        private static object SyncObject;

        /// <summary>
        /// Instantiates a new instance of the PerformanceManager class
        /// </summary>
        static PerformanceManager()
        {
            if (PerformanceConfiguration.Enabled)
            {
                PerformanceManager.PerformanceStatistics = new Hashtable();
                PerformanceManager.SyncObject = new object();
                PerformanceManager.AddTiming = PerformanceManager.EnabledAddTiming;
                PerformanceManager.Logger = new Logger(@"Logging\Performance", string.Concat("[", PerformanceManager.ClassName, "]"));
                return;
            }

            PerformanceManager.AddTiming = PerformanceManager.DisbledAddTiming;
        }

        /// <summary>
        /// Returns immediately on invocation (does not execute any code)
        /// </summary>
        /// <param name="key">The name of the performance statistic that would be stored if the performance configuration is enabled.</param>
        /// <param name="milliSeconds">The timing in milliseconds for the performance statistic.</param>
        public static void DisbledAddTiming(string key, long milliSeconds)
        {
            return;
        }

        /// <summary>
        /// Adds a performance timing
        /// </summary>
        /// <param name="key">The name of the performance statistic.</param>
        /// <param name="milliSeconds">The timing in milliseconds for the performance statistic.</param>
        public static void EnabledAddTiming(string key, long milliSeconds)
        {
            lock (PerformanceManager.SyncObject)
            {
                if (PerformanceManager.PerformanceStatistics[key] == null)
                { 
                    var performanceStatistic = new PerformanceStatistic(key, milliSeconds);
                    PerformanceManager.PerformanceStatistics.Add(key, performanceStatistic);
                    return;                    
                }

                var performanceStatistic2 = PerformanceManager.PerformanceStatistics[key] as PerformanceStatistic;
                performanceStatistic2.AddTiming(milliSeconds);
            }            
        }
    }
}

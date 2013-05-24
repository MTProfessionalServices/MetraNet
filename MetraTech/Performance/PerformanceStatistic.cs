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
// MODULE: PerformanceTiming.cs
//
//=============================================================================

namespace MetraTech.Performance
{
    using System;
    using System.Diagnostics;
    using System.Runtime.InteropServices;

    using MetraTech;

    /// <summary>
    /// Keeps track of performance metrics.
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("82B8D159-58EE-41D6-9CE1-70C795711B64")]
    public class PerformanceStatistic
    {
        /// <summary>
        /// The name of this class.
        /// </summary>
        private const string ClassName = "[PerformanceStatistic]";

        /// <summary>
        /// Local logging object.
        /// </summary>
        private Logger Logger = null;

        /// <summary>
        /// Synchronization object
        /// </summary>
        private object SyncObject = null;

        /// <summary>
        /// Gets or sets the Average timing value
        /// </summary>
        public long Average
        {
            get
            {
                return this.TotalExecutionTime / this.NumberOfExecutions;
            }
            private set
            {
            }
        }

        /// <summary>
        /// Gets or sets the Maximum timing value
        /// </summary>
        public long Maximum
        {
            get;
            private set;
        }

        /// <summary>
        /// Gets or sets the Minimmum timing value
        /// </summary>
        public long Minimum
        {
            get;
            private set;
        }

        /// <summary>
        /// The name of this performance statistic
        /// </summary>
        public string Name
        {
            get;
            private set;
        }

        /// <summary>
        /// Gets or sets the NumberOfExecutions
        /// </summary>
        public long NumberOfExecutions
        {
            get;
            private set;
        }

        /// <summary>
        /// Gets or sets the TotalExecutionTime
        /// </summary>
        public long TotalExecutionTime
        {
            get;
            private set;
        }

        /// <summary>
        /// Prevents a default instance of a PerformanceStatistic clas from being instantiated.
        /// </summary>
        private PerformanceStatistic()
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Initializes a new instance of the PerformanceTimings class
        /// </summary>
        public PerformanceStatistic(string name, long milliSeconds)
        {
            this.Name = string.Concat("[", name, "]");
            
            this.Logger = new Logger(@"Logging\Performance", string.Concat(ClassName, this.Name));
            this.Initialize(milliSeconds);
            this.SyncObject = new object();
        }

        /// <summary>
        /// Deconstructor - dumps the performance statistics to the logfile.
        /// </summary>
        ~PerformanceStatistic()
        {
            lock (this.SyncObject)
            {
                if (PerformanceConfiguration.Enabled && this.NumberOfExecutions > 0)
                {
                    this.WritePerformanceStatisticLog();
                }
            }
        }

        /// <summary>
        /// Adds the new perfomance timing to the current performance metrics
        /// </summary>
        /// <param name="milliseconds">The number of milliseconds for the new performance timing</param>
        public void AddTiming(long milliseconds)
        {
            lock (this.SyncObject)
            {
                if (long.MaxValue - this.TotalExecutionTime < milliseconds)
                {
                    this.WritePerformanceStatisticLog();
                    this.Initialize(milliseconds);
                }

                if (milliseconds < this.Minimum)
                {
                    this.Minimum = milliseconds;
                }

                if (milliseconds > this.Maximum)
                {
                    this.Maximum = milliseconds;
                }

                this.NumberOfExecutions++;
                this.TotalExecutionTime += milliseconds;
            }
        }

        /// <summary>
        /// Initializes this class's properties.
        /// </summary>
        /// <param name="milliSeconds">The initial timing to initialize this class's properties from.</param>
        private void Initialize(long milliSeconds)
        {
            this.Minimum = milliSeconds;
            this.Maximum = milliSeconds;
            this.NumberOfExecutions = 1;
            this.TotalExecutionTime = milliSeconds;
        }

        /// <summary>
        /// Writes the performance statistics to the log file.
        /// </summary>
        private void WritePerformanceStatisticLog()
        {
            this.Logger.LogInfo("|Minimum={0}|Maximum={1}|NumberOfExecutions={2}|Average={3}|", this.Minimum, this.Maximum, this.NumberOfExecutions, this.Average);
        }
    }
}
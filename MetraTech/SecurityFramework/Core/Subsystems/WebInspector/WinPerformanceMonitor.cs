/**************************************************************************
* Copyright 1997-2010 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Authors: 
*
* Kyle C. Quest <kquest@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;
using System.Diagnostics;

namespace MetraTech.SecurityFramework.WebInspector
{
    internal class WinPerformanceMonitor
    {
        [DllImport("Kernel32.dll")]
        public static extern void QueryPerformanceCounter(ref long ticks);

        private const string CATEGORY_NAME = "SecurityFrameworkWaf";
        private const string CATEGORY_DESC = "Security Framework Web Application Firewall performance counters";

        private const string TRC_COUNTER_NAME = "TotalRequestCount";
        private const string TRC_COUNTER_HELP = "Total number of processed HTTP requests";

        private const string RPC_COUNTER_NAME = "RequestsPerSec";
        private const string RPC_COUNTER_HELP = "Number of processed HTTP requests per second";

        private const string ART_COUNTER_NAME = "AverageRequestTime";
        private const string ART_COUNTER_HELP = "Average time to process HTTP request";

        private const string ARTB_COUNTER_NAME = "AverageRequestTimeBase";
        private const string ARTB_COUNTER_HELP = "Average time to process HTTP request (base)";

        private const string RAT_BLB_COUNTER_NAME = "BlacklistBlockRequestCount";
        private const string RAT_BLB_COUNTER_HELP = "Number of HTTP requests blocked with blacklist";

        private const string RAT_LOG_COUNTER_NAME = "LogRequestCount";
        private const string RAT_LOG_COUNTER_HELP = "Number of HTTP request log actions";

        private const string RAT_BLK_COUNTER_NAME = "BlockRequestCount";
        private const string RAT_BLK_COUNTER_HELP = "Number of HTTP request block actions";

        private const string RAT_BLS_COUNTER_NAME = "BlacklistRequestCount";
        private const string RAT_BLS_COUNTER_HELP = "Number of HTTP request blacklist actions";

        private const string RAT_RDR_COUNTER_NAME = "RedirectRequestCount";
        private const string RAT_RDR_COUNTER_HELP = "Number of HTTP request redirect actions";

        private const string RAT_RWU_COUNTER_NAME = "RewriteUrlRequestCount";
        private const string RAT_RWU_COUNTER_HELP = "Number of HTTP request URL rewrite actions";

        private PerformanceCounter _trcCounter = null;
        private PerformanceCounter _rpcCounter = null;
        private PerformanceCounter _artCounter = null;
        private PerformanceCounter _artbCounter = null;

        private PerformanceCounter _ratBlacklistBlockCounter = null;
        private PerformanceCounter _ratLogCounter = null;
        private PerformanceCounter _ratBlockCounter = null;
        private PerformanceCounter _ratBlacklistCounter = null;
        private PerformanceCounter _ratRedirectCounter = null;
        private PerformanceCounter _ratRewriteCounter = null;

        internal void CreateCounters()
        {
            if (!PerformanceCounterCategory.Exists(CATEGORY_NAME))
            {
                CounterCreationDataCollection cc = new CounterCreationDataCollection();

                CounterCreationData trc = new CounterCreationData(TRC_COUNTER_NAME, TRC_COUNTER_HELP, PerformanceCounterType.NumberOfItems64);
                cc.Add(trc);

                CounterCreationData rpc = new CounterCreationData(RPC_COUNTER_NAME, RPC_COUNTER_HELP, PerformanceCounterType.RateOfCountsPerSecond32);
                cc.Add(rpc);

                CounterCreationData art = new CounterCreationData(ART_COUNTER_NAME, ART_COUNTER_HELP, PerformanceCounterType.AverageTimer32);
                cc.Add(art);

                CounterCreationData artb = new CounterCreationData(ARTB_COUNTER_NAME,ARTB_COUNTER_HELP,PerformanceCounterType.AverageBase);
                cc.Add(artb);

                CounterCreationData blb = new CounterCreationData(RAT_BLB_COUNTER_NAME,RAT_BLB_COUNTER_HELP,PerformanceCounterType.NumberOfItems64);
                cc.Add(blb);

                CounterCreationData log = new CounterCreationData(RAT_LOG_COUNTER_NAME,RAT_LOG_COUNTER_HELP,PerformanceCounterType.NumberOfItems64);
                cc.Add(log);

                CounterCreationData blk = new CounterCreationData(RAT_BLK_COUNTER_NAME,RAT_BLK_COUNTER_HELP,PerformanceCounterType.NumberOfItems64);
                cc.Add(blk);

                CounterCreationData bls = new CounterCreationData(RAT_BLS_COUNTER_NAME,RAT_BLS_COUNTER_HELP,PerformanceCounterType.NumberOfItems64);
                cc.Add(bls);

                CounterCreationData rdr = new CounterCreationData(RAT_RDR_COUNTER_NAME,RAT_RDR_COUNTER_HELP,PerformanceCounterType.NumberOfItems64);
                cc.Add(rdr);

                CounterCreationData rwu = new CounterCreationData(RAT_RWU_COUNTER_NAME,RAT_RWU_COUNTER_HELP,PerformanceCounterType.NumberOfItems64);
                cc.Add(rwu);

                //NOTE: TO FIX
                //Need special privileges to create counters
                //We should be doing it during installation only
                //For now simply don't do performance monitoring in deployments
                PerformanceCounterCategory.Create(CATEGORY_NAME, CATEGORY_DESC, PerformanceCounterCategoryType.SingleInstance, cc);
            }

            _trcCounter = new PerformanceCounter(CATEGORY_NAME, TRC_COUNTER_NAME, false);

            _rpcCounter = new PerformanceCounter(CATEGORY_NAME, RPC_COUNTER_NAME, false);
            _artCounter = new PerformanceCounter(CATEGORY_NAME, ART_COUNTER_NAME, false);
            _artbCounter = new PerformanceCounter(CATEGORY_NAME, ARTB_COUNTER_NAME, false);

            _ratBlacklistBlockCounter = new PerformanceCounter(CATEGORY_NAME, RAT_BLB_COUNTER_NAME, false);
            _ratLogCounter = new PerformanceCounter(CATEGORY_NAME, RAT_LOG_COUNTER_NAME, false);
            _ratBlockCounter = new PerformanceCounter(CATEGORY_NAME, RAT_BLK_COUNTER_NAME, false);
            _ratBlacklistCounter = new PerformanceCounter(CATEGORY_NAME, RAT_BLS_COUNTER_NAME, false);
            _ratRedirectCounter = new PerformanceCounter(CATEGORY_NAME, RAT_RDR_COUNTER_NAME, false);
            _ratRewriteCounter = new PerformanceCounter(CATEGORY_NAME, RAT_RWU_COUNTER_NAME, false);
        }

        internal void UpdateCommonRequestStats(long ticks)
        {
            if ((null == _trcCounter) || (null == _rpcCounter) || (null == _artCounter) || (null == _artbCounter))
                return;

            _trcCounter.Increment();
            _rpcCounter.Increment();
            _artCounter.IncrementBy(ticks);
            _artbCounter.Increment();
        }

        internal void UpdateBlacklistBlockCount()
        {
            if (null != _ratBlacklistBlockCounter)
                _ratBlacklistBlockCounter.Increment();
        }

        internal void UpdateLogCount()
        {
            if (null != _ratLogCounter)
                _ratLogCounter.Increment();
        }

        internal void UpdateBlockCount()
        {
            if (null != _ratBlockCounter)
                _ratBlockCounter.Increment();
        }

        internal void UpdateBlacklistCount()
        {
            if (null != _ratBlacklistCounter)
                _ratBlacklistCounter.Increment();
        }

        internal void UpdateRedirectCount()
        {
            if (null != _ratRedirectCounter)
                _ratRedirectCounter.Increment();
        }

        internal void UpdateRewriteUrlCount()
        {
            if (null != _ratRewriteCounter)
                _ratRewriteCounter.Increment();
        }

        internal long CurrentTickCount()
        {
            long tickCount = 0;
            QueryPerformanceCounter(ref tickCount);
            return tickCount;
        }
    }
}

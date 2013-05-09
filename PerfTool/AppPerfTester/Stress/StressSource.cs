using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using log4net;

namespace BaselineGUI
{
    public class StressSource
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(StressSource));

        public string appMethodKey;
        public DateTime lastRun;
        public bool nextRunValid = false;
        public DateTime nextRun;

        public AMPreferences pref;

        public StressSource(string key)
        {
            this.appMethodKey = key;
            this.lastRun = DateTime.Now;
            this.nextRunValid = false;
            this.nextRun = DateTime.Now;

            pref = PrefRepo.active.findAMPreferences( key);
        }

        public void schedule()
        {
            if (nextRunValid)
                return;

            if (pref.stressEnabled)
            {
                // Poisson distribution
                // Get a lambda measured in milliseconds
                double interarrivalTimeSecs = 3600.0 / pref.stressRate;
                double avg_msecs = 1000.0 * interarrivalTimeSecs;
                int msecToAdd = PoissonDist.GetPoisson(avg_msecs);
                nextRun = lastRun.AddMilliseconds(msecToAdd);
                nextRunValid = true;
                log.DebugFormat("scheduled {0} for {1}", appMethodKey, nextRun);
            }
        }
    }
}

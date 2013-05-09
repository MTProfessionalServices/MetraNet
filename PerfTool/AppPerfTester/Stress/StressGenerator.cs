using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using log4net;
using System.Threading;

namespace BaselineGUI
{

    public class StressGenerator
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(StressGenerator));

        public StressQueue queue;
        public volatile bool runFlag;

        List<StressSource> sources = new List<StressSource>();

        public StressGenerator()
        {
            log.Debug("enter constructor");
            foreach (string key in AppMethodFactory.appMethods.Keys)
            {
                StressSource src = new StressSource(key);
                sources.Add(src);
            }
            log.Debug("exit constructor");
        }


        public void schedule()
        {
            foreach (StressSource src in sources)
            {
                if (!src.nextRunValid)
                {
                    src.schedule();
                }
            }
        }

        public void waitForIt()
        {
            DateTime now = DateTime.Now;
            int timeToWait = 500;
            foreach (StressSource src in sources)
            {
                if (!src.nextRunValid)
                    continue;
                TimeSpan delta = src.nextRun.Subtract(now);
                int t = (int)delta.TotalMilliseconds;
                timeToWait = Math.Min(timeToWait, t);
            }
            if (timeToWait > 10)
                Thread.Sleep(timeToWait);
        }



        public void go()
        {
            log.Debug("go entered");

            DateTime startTime = DateTime.Now;
            DateTime now = DateTime.Now;
            DateTime stopTime = now.AddSeconds(PrefRepo.active.stress.maxRunTime);

            Progressable progress = ProgressableFactory.find("stress");
            progress.Minimum = 0;
            progress.Value = 0;
            progress.Maximum = PrefRepo.active.stress.maxRunTime;
            progress.isRunning = true;
            ProgressableFactory.active = progress;

            foreach (StressSource src in sources)
            {
                src.lastRun = startTime;
                src.nextRunValid = false;
            }


            while (runFlag && DateTime.Now < stopTime)
            {
                now = DateTime.Now;

                TimeSpan dur = now.Subtract(startTime);
                progress.Value = (int)dur.TotalSeconds;
                
                schedule();
                waitForIt();

                foreach (StressSource src in sources)
                {
                    if (src.nextRunValid && src.nextRun <= now)
                    {
                        StressTask task = new StressTask();
                        task.appMethodKey = src.appMethodKey;
                        queue.Enqueue(task);
                        src.lastRun = src.nextRun;
                        src.nextRunValid = false;
                        log.DebugFormat("go: queued task {0}", src.appMethodKey);
                    }
                }
            }

            progress.isRunning = false;
            log.Debug("go exits");

        }

    }
}

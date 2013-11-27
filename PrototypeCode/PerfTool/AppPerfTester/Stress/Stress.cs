using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using log4net;

namespace BaselineGUI
{
    public class Stress
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(Stress));


        public volatile bool runFlag;
        public StressQueue queue;
        public StressGenerator generator;
        List<StressWorker> workers;

        // This should move to configuration
        public int numWorkers = PrefRepo.active.stress.numThreads;

        public Stress()
        {
            queue = new StressQueue();
            generator = new StressGenerator();
            generator.queue = queue;

            workers = new List<StressWorker>();
            for (int ix = 0; ix < numWorkers; ++ix)
            {
                StressWorker worker = new StressWorker();
                worker.queue = queue;
                workers.Add(worker);
            }
        }

        public void setup()
        {
            queue.clearDone();
            foreach (StressWorker worker in workers)
            {
                worker.Start();
            }
        }

        public void teardown()
        {
            log.Debug("teardown entered");
            queue.setDone();

            foreach (StressWorker worker in workers)
            {
                worker.Join();
            }
            log.Debug("teardown complete");
        }

        public void run()
        {
            log.Debug("run entered");
            generator.runFlag = true;
            generator.go();
            log.Debug("run exits");

            teardown();
        }

    }
}

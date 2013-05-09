using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Threading;
using System.IO;
using System.Diagnostics;
using log4net;

namespace BaselineGUI
{
    public class StressWorker
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(StressWorker));

        public Thread thread;
        public int workerNumber = 0;
        public StressQueue queue;

        public StressWorker()
        {
        }

        public void Start()
        {
            thread = new Thread(new ThreadStart(this.Work));
            thread.Start();
        }

         public void Join()
         {
             if (!thread.IsAlive)
             {
                 log.DebugFormat("Thread is not alive");
                 thread = null;
             }
            else if (thread.Join(10000) == false)
            {
                log.DebugFormat("Thread join was successful");
                thread = null;
            }
            else
            {
                thread.Abort();
                log.DebugFormat("Thread aborted");
                thread = null;
            }
         }


        public void Work()
        {
            log.Debug("worker starting");
            StressTask task = null;
            while (queue.Dequeue(ref task))
            {
                log.DebugFormat("task: {0}", task.appMethodKey);
                task.execute();
            }
            log.Debug("worker exits");
        }

    }
}

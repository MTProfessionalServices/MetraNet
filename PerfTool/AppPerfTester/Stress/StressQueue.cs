using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using log4net;

namespace BaselineGUI
{
    public class StressQueue
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(StressQueue));
        Queue<StressTask> toDo = new Queue<StressTask>();
        bool doneFlag = false;

        public StressQueue()
        {
        }

        public bool Dequeue(ref StressTask task)
        {
            lock (this)
            {
                while (true)
                {
                    if (doneFlag)
                        return false;

                    if (toDo.Count > 0)
                    {
                        task = toDo.Dequeue();
                        return true;
                    }
                    else
                    {
                        Monitor.Wait(this, 500);
                    }
                }
            }
        }


        public void Enqueue(StressTask task)
        {
            lock (this)
            {
                toDo.Enqueue(task);
                Monitor.Pulse(this);
            }
        }

        public void setDone()
        {
            log.DebugFormat("entered setDone()");
            lock (this)
            {
                log.DebugFormat("got lock");
                doneFlag = true;
                toDo.Clear();
                Monitor.Pulse(this);
            }
        }

        public void clearDone()
        {
            lock (this)
            {
                doneFlag = false;
            }
        }

    }
}

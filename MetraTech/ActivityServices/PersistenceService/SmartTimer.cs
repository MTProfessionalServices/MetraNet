using System;
using System.Threading;

namespace MetraTech.ActivityServices.PersistenceService
{
    internal class SmartTimer : IDisposable
    {
        private TimerCallback callback;
        private TimeSpan infinite;
        private object locker;
        private TimeSpan minUpdate;
        private DateTime next;
        private bool nextChanged;
        private TimeSpan period;
        private Timer timer;

        public SmartTimer(TimerCallback callback, object state, TimeSpan due, TimeSpan period)
        {
            locker = new object();
            minUpdate = new TimeSpan(0, 0, 5);
            infinite = new TimeSpan((long) (-1));
            this.period = period;
            this.callback = callback;
            next = DateTime.UtcNow + due;
            timer = new Timer(new TimerCallback(HandleCallback), state, due, infinite);
        }

      ~SmartTimer()
      {
        Dispose();
      }

        public void Dispose()
        {
            lock (locker)
            {
                if (timer != null)
                {
                    timer.Dispose();
                    timer = null;
                }
            }

            GC.SuppressFinalize(this);
        }


        private void HandleCallback(object state)
        {
            try
            {
                callback(state);
            }
            finally
            {
                lock (locker)
                {
                    if (timer != null)
                    {
                        if (!nextChanged)
                        {
                            next = DateTime.UtcNow + period;
                        }
                        else
                        {
                            nextChanged = false;
                        }
                        TimeSpan span1 = (TimeSpan) (next - DateTime.UtcNow);
                        if (span1 < TimeSpan.Zero)
                        {
                            span1 = TimeSpan.Zero;
                        }
                        timer.Change(span1, infinite);
                    }
                }
            }
        }


        public void Update(DateTime newNext)
        {
            if ((newNext < next) && ((next - DateTime.UtcNow) > minUpdate))
            {
                lock (locker)
                {
                    if (((newNext < next) && ((next - DateTime.UtcNow) > minUpdate)) && (timer != null))
                    {
                        next = newNext;
                        nextChanged = true;
                        TimeSpan span1 = (TimeSpan) (next - DateTime.UtcNow);
                        if (span1 < TimeSpan.Zero)
                        {
                            span1 = TimeSpan.Zero;
                        }
                        timer.Change(span1, infinite);
                    }
                }
            }
        }
    }
}
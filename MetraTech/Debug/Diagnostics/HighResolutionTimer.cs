using System;
using System.Diagnostics;

namespace MetraTech.Debug.Diagnostics
{
    /// <summary>
    /// To use the HighResolutionTimer wrap your code in a 'using' block, passing in a unique string and max time in milliseconds.
    /// If the max time is reached an error will be logged instead of an info message.
    /// <example>
    ///   using (new HighResolutionTimer("TimerTest", 1000)) { … }
    /// </example>
    /// </summary>
    public class HighResolutionTimer : IDisposable
    {
        private readonly static Logger logger = new Logger("Logging\\HighResolutionTimer", "[HighResolutionTimer]");
        private readonly string timingId;
        private readonly long maxTime;
        private readonly Stopwatch stopWatch = new Stopwatch();
        private bool disposed;
    private string _internalInfo;

    public string InternalInfo
    {
      get { return _internalInfo; }
      
      set
      {
        if (!String.IsNullOrEmpty(value))
        {
          _internalInfo = String.Concat("[", value, "]");
        }
      }
    }

        public HighResolutionTimer(string id)
        {
            timingId = id;
            maxTime = TimerWarningThresholdManager.Instance.GetMaxMillisecondsBeforeWarning(id);
            stopWatch.Start();
        }

        public HighResolutionTimer(string id, long maxTimeInMilliseconds)
        {
            timingId = id;
            maxTime = TimerWarningThresholdManager.Instance.GetMaxMillisecondsBeforeWarning(id, maxTimeInMilliseconds);
            stopWatch.Start();
        }

        // Stop the timer
        private void Stop()
        {
            if (disposed) return;

            // stop timer
            stopWatch.Stop();
            long elapsed = stopWatch.ElapsedMilliseconds;

            if (maxTime == long.MaxValue)
            {
        logger.LogInfo(string.Format("[{0}] {2} completed in: {1} (ms)", timingId, elapsed, InternalInfo));
            }
            else
            {
                if (elapsed <= maxTime)
                {
          logger.LogInfo(string.Format("[{0}] {3} Elapsed time: {1} (ms).  Max time: {2} (ms)", timingId, elapsed, maxTime, InternalInfo));
                }
                else
                {
          logger.LogWarning(string.Format("[{0}] {3} Elapsed time: {1} (ms) was greater than the Max time: {2} (ms)", timingId, elapsed, maxTime, InternalInfo));
                }
            }

            disposed = true;
        }

        // Free your own state, call dispose on all state you hold, 
        // and take yourself off the Finalization queue.
        public void Dispose()
        {
            Stop();
            GC.SuppressFinalize(this);
        }

        // Free your own state (not other state you hold) 
        // and give your base class a chance to finalize. 
        ~HighResolutionTimer()
        {
            Stop();
        }
    }

}

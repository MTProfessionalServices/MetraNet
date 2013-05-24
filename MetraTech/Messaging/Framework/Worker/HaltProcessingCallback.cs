using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.Messaging.Framework.Worker
{
  public static class HaltProcessingCallback
  {
    static HaltProcessingCallback()
    {
      mIsShuttingDown = false;
      mIsAbortable = false;
    }

    private static object l = new object();

    // determines whether the process is currently shutting down.
    // used to safely breaking out of deep loops inside of the
    // RecurringEventManager.ProcessEvents method
    // NOTE: should only be set by Processor
    public static bool IsShuttingDown
    {
      set
      {
        lock (l)
        {
          mIsShuttingDown = value;
        }
      }
      get { return mIsShuttingDown; }
    }

    public static bool IsAbortable
    {
      set
      {
        lock (l)
        {
          mIsAbortable = value;
        }
      }
      get { return mIsAbortable; }
    }

    static bool mIsAbortable;
    static bool mIsShuttingDown;
  }
}

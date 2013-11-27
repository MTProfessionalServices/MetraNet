using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Diagnostics;

namespace Messages
{
  public class NodeIdentifier
  {
    public static string GetNodeIdentifier()
    {
      return Environment.MachineName + "_" + Process.GetCurrentProcess().ProcessName + "_" + Process.GetCurrentProcess().Id;
    }

    public static string GetThreadedNodeIdentifier()
    {
      return GetNodeIdentifier() + "_" + Thread.CurrentThread.ManagedThreadId;
    }
  }
}

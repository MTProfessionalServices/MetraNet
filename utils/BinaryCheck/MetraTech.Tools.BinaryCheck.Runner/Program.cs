using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Diagnostics;

namespace MetraTech.Tools.BinaryCheck.Runner
{
  class Program
  {
    static Stopwatch s_sw = new Stopwatch();
    static SearchAgent s_sa = new SearchAgent();
    static int Main(string[] args)
    {
      if (args.Length != 1)
      {
        Console.WriteLine("Output file name is required");
        return 1;
      }
      string outputFile = args[0];

      Console.WriteLine("BinaryCheck running with {0} threads and being output to {1}", Config.Default.NumThreads, outputFile);

      s_sw.Start();

      s_sa.SearchStarted += new SearchStarted(sa_SearchStarted);
      s_sa.SearchCompleted += new SearchCompleted(sa_SearchCompleted);
      s_sa.InterrogationStarted += new InterrogationStarted(sa_InterrogationStarted);
      s_sa.InterrogationCompleted += new InterrogationCompleted(sa_InterrogationCompleted);

      s_sa.Start();

      while (s_sa.IsRunning)
      {
        Console.Write('.');
        Thread.Sleep(500);
      }

      Console.WriteLine("Writing report");
      ReportGenerator.Generate(s_sa.Output, outputFile);
      Console.WriteLine("Complete");

      return 0;
    }

    static void sa_InterrogationCompleted(object sender)
    {
      s_sw.Stop();
      Console.WriteLine("");
      Console.WriteLine("Completed in " + s_sw.Elapsed.TotalSeconds + " seconds.");
    }

    static void sa_InterrogationStarted(object sender)
    {
      Console.Write("Retrieving binary information");
    }

    static void sa_SearchCompleted(object sender)
    {
      Console.WriteLine("");
      Console.WriteLine("Found " + s_sa.NumFilesFound + " files.");
    }

    static void sa_SearchStarted(object sender)
    {
      Console.Write("Searching for binary files");
    }
  }
}

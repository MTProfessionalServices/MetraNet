using System;
using System.Collections.Generic;
using System.Text;

using MetraTech.UsageServer.Test;

namespace MetraTech.UsageServer.AdapterTest
{
  class AdapterTest
  {
    static void Main(string[] args)
    {
      try
      {
        AdapterTestConfig config = GetConfiguration(args);
        string errors;
        AdapterTestManager.RunTests(config, out errors);

        if (!String.IsNullOrEmpty(errors))
        {
          Console.WriteLine(errors);
        }
      }
      catch (Exception e)
      {
        Console.WriteLine(e.Message);
        Console.WriteLine(e.StackTrace);
        DisplayUsage();
      }
    }

    static AdapterTestConfig GetConfiguration(string[] args)
    {
      AdapterTestConfig config = null;

      if (args.Length != 1)
      {
        throw new ApplicationException("Incorrect number of arguments.");
      }

      // Retrieve the config file
      config = AdapterTestManager.GetAdapterTestConfig(args[0]);

      if (config == null)
      {
        throw new ApplicationException("Unable to parse configuration file '" + args[1] + "'");
      }

      return config;
    }

    static void DisplayUsage()
    {
      Console.WriteLine("Usage: AdapterTest configFile.xml\n");
    }
  }
}

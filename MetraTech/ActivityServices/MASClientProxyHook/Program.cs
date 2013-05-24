using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Text;
using MetraTech.ActivityServices.Configuration;
using MetraTech.ActivityServices.Runtime;
using RCD = MetraTech.Interop.RCD;
using System.Reflection;
using MetraTech.ActivityServices.ClientCodeGenerators;

namespace MetraTech.ActivityServices.ClientProxyHook
{
  class Program
  {
    static int Main(string[] args)
    {
      List<string> extensionNames = new List<string>();
      bool bDebug = false;
      bool bPrintUsage = false;

      foreach (string arg in args)
      {
        switch (arg.ToUpper())
        {
          case "/D":
          case "-D":
            bDebug = true;
            break;
          case "/?":
          case "-?":
            bPrintUsage = true;
            break;
          default:
            extensionNames.Add(arg);
            break;
        };

        if (bPrintUsage)
        {
          break;
        }
        
      }

      if (bPrintUsage)
      {
        PrintUsage();
        return 1;
      }
      else
      {
        return BuildClientProxies(extensionNames, bDebug);
      }
    }

    private static int BuildClientProxies(List<string> extensionNames, bool bDebug)
    {
      RCD.IMTRcd rcd = new RCD.MTRcd();

      if (extensionNames.Count == 0)
      {
        foreach (string extension in rcd.ExtensionList)
        {
          extensionNames.Add(extension);
        }
      }

      string basePathFormat = Path.Combine(rcd.ExtensionDir, "{0}\\Bin");
      CMASClientProxyGenerator.BasePathFormatString = basePathFormat;
      CMASProxyActivityGenerator.BasePathFormatString = basePathFormat;
      CMASClientWCFConfigGenerator.BasePathFormatString = basePathFormat;

      foreach (string extensionName in extensionNames)
      {
        string path = Path.Combine(rcd.ExtensionDir, extensionName);
        if (Directory.Exists(Path.Combine(path, @"config\ActivityServices")))
        {
          string[] files = Directory.GetFiles(path, @"config\ActivityServices\*.xml", SearchOption.AllDirectories);

          CMASConfiguration config;

          bool bBuild = false;
          try
          {
            if (files.Length > 0)
            {
              CMASClientProxyGenerator proxyGenerator = new CMASClientProxyGenerator(extensionName, bDebug);
              CMASProxyActivityGenerator activityGenerator = new CMASProxyActivityGenerator(extensionName, CMASHost.GENERATED_CODE_NAMESPACE, bDebug);
              CMASClientWCFConfigGenerator wcfConfigGen = new CMASClientWCFConfigGenerator(extensionName);

                  DateTime lastModifiedDate = DateTime.MinValue;

              foreach (string configFile in files)
              {
                if (configFile.Contains(extensionName))
                {
                          FileInfo fi = new FileInfo(configFile);
                          if (fi.LastWriteTime > lastModifiedDate)
                          {
                              lastModifiedDate = fi.LastWriteTime;
                          }

                  config = new CMASConfiguration(configFile);

                  if (config.EventServiceDefs.Count > 0 || config.ProceduralServiceDefs.Count > 0)
                  {
                    proxyGenerator.AddClientProxies(config);
                    activityGenerator.AddProxyActivities(config);

                    foreach (CMASProceduralService iFace in config.ProceduralServiceDefs.Values)
                    {
                      wcfConfigGen.AddServiceWCFConfig(iFace.InterfaceName);
                    }

                    foreach (CMASEventService iFace in config.EventServiceDefs.Values)
                    {
                      wcfConfigGen.AddServiceWCFConfig(iFace.InterfaceName);
                    }

                    bBuild = true;
                  }
                }

              }

              if (bBuild)
              {
                wcfConfigGen.SaveConfig();

                      bool bBuilt = false;
                      if (!File.Exists(proxyGenerator.OutputAssembly) || lastModifiedDate > new FileInfo(proxyGenerator.OutputAssembly).LastWriteTime)
                {
                          bBuilt = true;
                          if (!proxyGenerator.BuildClientProxies())
                  {
                              Console.WriteLine("Failed to build client proxies for {0}.  Please see MTLog for more info.", extensionName);
                              return 4;
                          }
                  }
                  else
                  {
                          Console.WriteLine("Skipping build of client proxies for {0} as output assembly is up-to-date.", extensionName);
                      }

                      if (!File.Exists(activityGenerator.OutputAssembly) || lastModifiedDate > new FileInfo(activityGenerator.OutputAssembly).LastWriteTime)
                      {
                          bBuilt = true;
                          if (!activityGenerator.BuildProxyActivities())
                          {
                    Console.WriteLine("Failed to build proxy activities for {0}.  Please see MTLog for more info.", extensionName);
                              return 3;
                  }
                }
                else
                {
                          Console.WriteLine("Skipping build of proxy activities for {0} as output assembly is up-to-date.", extensionName);
                      }

                      if (bBuilt)
                      {
                          Console.WriteLine("Successfully built both client proxies and proxy activities for {0}.", extensionName);
                }
              }
            }
          }
          catch (Exception)
          {
            Console.WriteLine("Error: Exception occurred generating client proxies for {0}. Please see MTLog.txt", extensionName);
            return 2;
          }
        }
      }
      return 0;
    }

    private static void PrintUsage()
    {
      Console.WriteLine("Usage:");
      Console.WriteLine("MASClientProxyHook /? /D [<Extension Folder Names>]");
      Console.WriteLine("/?\t\t\t\tPrint Usage");
      Console.WriteLine("/D\t\t\t\tBuild Debug");
      Console.WriteLine("[<Extension Folder Names>]\tList of zero or more extension folders to build");
    }
  }
}

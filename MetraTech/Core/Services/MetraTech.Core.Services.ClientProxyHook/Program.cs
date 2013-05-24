using System;
using System.Collections.Generic;
using System.Text;
using System.Reflection;
using System.IO;

using MetraTech.ActivityServices.Configuration;
using System.ServiceModel;
using MetraTech.ActivityServices.Services.Common;
using RCD = MetraTech.Interop.RCD;
using MetraTech.ActivityServices.Runtime;
using MetraTech.ActivityServices.ClientCodeGenerators;

namespace MetraTech.Core.Services.ClientProxyHook
{
    class Program
    {

        static void Main(string[] args)
        {
            bool bDebug = false;
            bool bPrintUsage = false;
            List<string> assemblyNames = new List<string>();

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
                        assemblyNames.Add(arg);
                        break;
                };

                if (bPrintUsage)
                {
                    break;
                }

            }

            if (bPrintUsage || assemblyNames.Count == 0)
            {
                PrintUsage();
            }
            else
            {
                BuildClientProxies(assemblyNames, bDebug);
            }

        }

        static Assembly CurrentDomain_AssemblyResolve(object sender, ResolveEventArgs args)
        {
            Assembly retval = null;
            string searchName = args.Name.Substring(0, (args.Name.IndexOf(',') == -1 ? args.Name.Length : args.Name.IndexOf(','))).ToUpper();

            if (!searchName.Contains(".DLL"))
            {
                searchName += ".DLL";
            }

            try
            {
                AssemblyName nm = AssemblyName.GetAssemblyName(searchName);
                retval = Assembly.Load(nm);
            }
            catch (Exception)
            {
                try
                {
                    retval = Assembly.LoadFile(Path.Combine(Path.GetDirectoryName(Assembly.GetEntryAssembly().Location), searchName));
                }
                catch (Exception)
                {
                    RCD.IMTRcd rcd = new RCD.MTRcd();
                    RCD.IMTRcdFileList fileList = rcd.RunQuery(string.Format("Bin\\{0}", searchName), false);

                    if (fileList.Count > 0)
                    {
                        AssemblyName nm2 = AssemblyName.GetAssemblyName(((string)fileList[0]));
                        retval = Assembly.Load(nm2);
                    }
                }
            }

            return retval;
        }

        static void BuildClientProxies(List<string> assemblyNames, bool bDebug)
        {
            AppDomainHelper.CleanShadowCopyDir();

            CMASClientProxyGenerator.NameSpaceBase = "";
            CMASClientProxyGenerator.BasePathFormatString = AppDomain.CurrentDomain.BaseDirectory;

            CMASProxyActivityGenerator.NameSpaceBase = "";
            CMASProxyActivityGenerator.BasePathFormatString = AppDomain.CurrentDomain.BaseDirectory;

            CMASClientWCFConfigGenerator.NameSpaceBase = "";
            CMASClientWCFConfigGenerator.BasePathFormatString = AppDomain.CurrentDomain.BaseDirectory;

            CMASConfiguration config;
            CMASClientProxyGenerator clientProxyGen;
            CMASProxyActivityGenerator proxyActivityGen;
            CMASClientWCFConfigGenerator wcfConfigGen;


            try
            {
              foreach (string assemblyName in assemblyNames)
              {
                if (CheckAssemblyExist(assemblyName))
                {
                  Dictionary<string, List<CMASProceduralService>> svcNames;
                  AppDomainHelper.BuildConfiguration(assemblyName, out svcNames);

                  string trueName = GetTrueAssemblyName(assemblyName);
                  string extension = Path.GetExtension(trueName);
                  string serviceAssembly = trueName;
                  if (extension.ToLower().Trim() == ".dll")
                    serviceAssembly = Path.GetFileNameWithoutExtension(assemblyName);

                  clientProxyGen = new CMASClientProxyGenerator(serviceAssembly, bDebug);
                  proxyActivityGen = new CMASProxyActivityGenerator(serviceAssembly, serviceAssembly, bDebug);
                  wcfConfigGen = new CMASClientWCFConfigGenerator(serviceAssembly);

                  config = new CMASConfiguration();

                  foreach (List<CMASProceduralService> procs in svcNames.Values)
                  {
                    foreach (CMASProceduralService proc in procs)
                    {
                      config.ProceduralServiceDefs.Add(proc.InterfaceName, proc);
                    }
                  }
                  clientProxyGen.AddClientProxies(config);


                  config = new CMASConfiguration();
                  CMASProceduralService iFace;
                  foreach (KeyValuePair<string, List<CMASProceduralService>> kvp in svcNames)
                  {
                    iFace = new CMASProceduralService();
                    iFace.InterfaceName = kvp.Key;

                    foreach (CMASProceduralService prcIntf in kvp.Value)
                    {
                      foreach (CMASProceduralMethod method in prcIntf.ProceduralMethods.Values)
                      {
                        if (!iFace.ProceduralMethods.ContainsKey(method.MethodName))
                        {
                          iFace.ProceduralMethods.Add(method.MethodName, method);
                        }
                      }
                    }

                    config.ProceduralServiceDefs.Add(iFace.InterfaceName, iFace);
                  }
                  proxyActivityGen.AddProxyActivities(config);

                  foreach (string name in svcNames.Keys)
                  {
                    wcfConfigGen.AddServiceWCFConfig(name);
                  }

                  wcfConfigGen.SaveConfig();

                  DateTime lastModifiedDate = new FileInfo(assemblyName).LastWriteTime;

                  bool bBuilt = false;

                  if (!File.Exists(clientProxyGen.OutputAssembly) ||
                      lastModifiedDate > new FileInfo(clientProxyGen.OutputAssembly).LastWriteTime)
                  {
                    bBuilt = true;
                    if (!clientProxyGen.BuildClientProxies())
                    {
                      Console.WriteLine("Failed to build client proxies for {0}.  Please see MTLog for more info.",
                                        assemblyName);
                      return;
                    }
                  }
                  else
                  {
                    Console.WriteLine("Skipping build of client proxies for {0} as output assembly is up-to-date.",
                                      assemblyName);
                  }

                  if (!File.Exists(proxyActivityGen.OutputAssembly) ||
                      lastModifiedDate > new FileInfo(proxyActivityGen.OutputAssembly).LastWriteTime)
                  {
                    bBuilt = true;
                    if (!proxyActivityGen.BuildProxyActivities())
                    {
                      Console.WriteLine("Failed to build proxy activities for {0}.  Please see MTLog for more info.",
                                        assemblyName);
                      return;
                    }
                  }
                  else
                  {
                    Console.WriteLine("Skipping build of proxy activities for {0} as output assembly is up-to-date.",
                                      assemblyName);
                  }

                  if (bBuilt)
                  {
                    Console.WriteLine("Successfully built both client proxies and proxy activities for {0}.",
                                      assemblyName);
                  }
                }
              }
            }
            catch (Exception e)
            {
                Console.WriteLine("Exception creating client proxy configuration. {0}", e.Message);
                Console.WriteLine("Occurred at: {0}", e.StackTrace);
            }
        }

      private static bool CheckAssemblyExist(string assemblyName)
      {
        if (!File.Exists(assemblyName))
        {
          Console.WriteLine("Couldn't find file: {0}", assemblyName);
          Console.WriteLine("Please enter the full path to the library");

          return false;
        }
        
        return true;
      }

      private static void PrintUsage()
        {
            Console.WriteLine("Usage:");
            Console.WriteLine("CoreServiceClientProxyHook /? /D <Core Service Assembly Names>");
            Console.WriteLine("/?\t\t\t\tPrint Usage");
            Console.WriteLine("/D\t\t\t\tBuild Debug");
            Console.WriteLine("<Core Service Assembly Names>\tList of one or more core service assemblies to build");
        }
        
        /// <summary>
        /// Returns the correctly cased filename of the actual file.
        /// Example: Occurs if the user passes a correct assembly path but as all lowercase; this name must be correctly cased before
        /// being used to generate the namespaces for the client classes.
        /// </summary>
        /// <param name="assemblyPath"></param>
        /// <returns>If given an actual file name that is all in lowercase, will return the file name as it is on disk, otherwise just
        /// returns what it was given.</returns>
        private static string GetTrueAssemblyName(string assemblyPath)
        {
          FileInfo file = new FileInfo(assemblyPath);
          if (Directory.Exists(file.DirectoryName))
          {
            string[] fileNames = Directory.GetFiles(file.DirectoryName, file.Name, SearchOption.TopDirectoryOnly);

            if ((fileNames.Length > 0) && (file.FullName.ToLower().Equals(fileNames[0].ToLower())))
            {
              return fileNames[0];
            }
          }

          return assemblyPath;
        }
    }
}
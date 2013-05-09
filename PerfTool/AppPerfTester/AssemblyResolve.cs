using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Reflection;
using System.IO;
using log4net;

namespace BaselineGUI
{
    public class AssemblyResolve
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(AssemblyResolve));

        public AssemblyResolve()
        {
            AppDomain currentDomain = AppDomain.CurrentDomain;
            currentDomain.AssemblyResolve += new ResolveEventHandler(OnResolveEvent);
        }

        private Assembly OnResolveEvent(object sender, ResolveEventArgs args)
        {
            log.InfoFormat("Resolving {0}", args.Name);

            //This handler is called only when the common language runtime tries to bind to the assembly and fails.

            //Retrieve the list of referenced assemblies in an array of AssemblyName.
            Assembly MyAssembly, objExecutingAssemblies;
            string strTempAssmbPath = "";
            objExecutingAssemblies = Assembly.GetExecutingAssembly();

            AssemblyName[] arrReferencedAssmbNames = objExecutingAssemblies.GetReferencedAssemblies();

            //Loop through the array of referenced assembly names.
            foreach (AssemblyName strAssmbName in arrReferencedAssmbNames)
            {
                //Check for the assembly names that have raised the "AssemblyResolve" event.
                if (strAssmbName.FullName.Substring(0, strAssmbName.FullName.IndexOf(",")) == args.Name.Substring(0, args.Name.IndexOf(",")))
                {
                    //Build the path of the assembly from where it has to be loaded.                         
                    strTempAssmbPath = FindFile(args.Name.Substring(0, args.Name.IndexOf(",")) + ".dll");
                    break;
                }

            }
            //Load the assembly from the specified path.                               
            MyAssembly = Assembly.LoadFrom(strTempAssmbPath);

            //Return the loaded assembly.
            return MyAssembly;
        }

        private string FindFile(string filename)
        {
            string sDir = string.Empty;
            String[] files = null;

            //String[] searchDirs = { ".." };
            String[] searchDirs = { Environment.GetEnvironmentVariable("MTRMPBIN") };

            foreach (string dir in searchDirs)
            {
                if (Directory.Exists(dir))
                    files = Directory.GetFiles(dir, filename, SearchOption.AllDirectories);
                // return the first instance we find
                if (files.Length > 0)
                    return files[0];
            }
            log.ErrorFormat("Failed to find {0}", filename);
            return null;
        }
    }
}

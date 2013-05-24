using System;
using System.EnterpriseServices;
using MetraTech;
using System.Reflection;

namespace RegisterServicedComponents
{
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	class RegisterServicedComponents
	{
		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main(string[] args)
		{
            try
            {
                ICommandLineParser parser = new CommandLineParser(args);
                parser.Parse();
                if (!parser.OptionExists("file") || !parser.OptionExists("app") || !parser.OptionExists("tlbdir"))
                {
                    PrintUsage();
                    return;
                }

                string fullpath = parser.GetStringOption("file");
                string app = parser.GetStringOption("app");
                string tlbdir = parser.GetStringOption("tlbdir");
                char[] seps = { '\\', '/' };

                string tlbfile;
                int nIndex = fullpath.LastIndexOfAny(seps);
                if (nIndex >= 0)
                {
                    string file = fullpath.Remove(0, nIndex);
                    nIndex = file.LastIndexOf('.');
                    if (nIndex >= 0)
                        file = file.Remove(nIndex + 1, 3) + "tlb";
                    else
                        throw new ApplicationException("Invalid file name: '.' not found in filename");

                    tlbfile = tlbdir + file;
                }
                else
                    tlbfile = tlbdir + fullpath;

                System.Console.Out.WriteLine(System.String.Format("Registering ServicedComponent: <{0}> in app: <{1}>, type lib: <{2}>", fullpath, app, tlbfile));

                RegistrationHelper helper = new RegistrationHelper();
                InstallationFlags flags = InstallationFlags.ExpectExistingTypeLib
                                          | InstallationFlags.FindOrCreateTargetApplication
                                          | InstallationFlags.ReportWarningsToConsole;
                helper.InstallAssembly(fullpath, ref app, ref tlbfile, flags);
            }
            catch (ReflectionTypeLoadException ex)
            {
                foreach (Exception loadException in ex.LoaderExceptions)
                {
                    if (loadException is TypeLoadException)
                    {
                        TypeLoadException tle = (TypeLoadException)loadException;
                        System.Console.Out.WriteLine("LoaderException: TypeName {0}, Message {1}",
                                                     tle.TypeName, tle.Message);
                    }
                    else
                        System.Console.Out.WriteLine("LoaderException: {0}", loadException.Message);
                }

                System.Console.Out.WriteLine(ex.Message);
                System.Console.Out.WriteLine(ex.StackTrace);
                throw ex;
            }
            catch (Exception ex)
            {
                System.Console.Out.WriteLine(ex.Message);
                System.Console.Out.WriteLine(ex.StackTrace);
                throw ex;
            }
		}
        static void PrintUsage()
        {
          System.Console.Out.WriteLine("Usage: RegisterServicedComponents [options]");
          System.Console.Out.WriteLine("Options:");
          System.Console.Out.WriteLine("file - Specify full file path of a .NET serviced component");
          System.Console.Out.WriteLine("app - Specify existing .NET application name. If it doesn't exist, it will be created");
          System.Console.Out.WriteLine("tlbdir - Specify Directory for existing type library");
          System.Console.Out.WriteLine("Example: ");
          System.Console.Out.WriteLine("Example: RegisterServicedComponents /file:o:\\debug\\bin\\MetraTech.Adjustments.dll /app:MetraNet /tlbdir:o:\\debug\\include");

        }
	}
}

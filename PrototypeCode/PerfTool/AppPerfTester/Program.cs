using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using DataGenerators;
using System.Threading;
using System.ComponentModel;
using System.Reflection;

using System.Runtime.InteropServices;
using log4net;

using NConsoler;

namespace BaselineGUI
{
	public class Program
	{
		// defines for commandline output
		[DllImport("kernel32.dll")]
		static extern bool AttachConsole(int dwProcessId);
		private const int ATTACH_PARENT_PROCESS = -1;

        private static readonly ILog log = LogManager.GetLogger(typeof(Program));

		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		public static void Main(params string[] args)
		{
            UsualLogging.SetUp();

            AssemblyResolve resolver = new AssemblyResolve();

			// redirect console output to parent process for CLI run;
			// must be before any calls to Console.WriteLine()
			AttachConsole(ATTACH_PARENT_PROCESS);

			Consolery.Run(typeof(Program), args);

			//// refresh the cmd prompt
			//System.Windows.Forms.SendKeys.SendWait("{ENTER}");
			//Application.Exit();

			#region Moved to RunGUI, will delete this soon
			//BaselineGUI.PerfTesterConfig PerfTesterConfig = PerfTesterConfig.Instance(@"assets\PerfTesterConfig.xml");
			//PerfTesterConfig.WriteSampleXml();

			//UsualLogging.SetUp();

			//Application.EnableVisualStyles();
			//Application.SetCompatibleTextRenderingDefault(false);

			//Framework.init();
			//AppMethodFactory.init();
			//UserInterface.init();

			//UserInterface.getPreferences();
			//UserInterface.bringup();
			//// CreateTableDemo.CreateTable();
			//UserInterface.runApplication();

			//Framework.stop();

			#endregion
		
		}

		[Action]
		public static void Method(
			//[Required] string name,
			[NConsoler.Optional(false,
				Description = "(/cli=true, /-cli=false) If true, will use the CLI,  \n\t\t if true (default) uses the GUI.\n")]
			bool cli,
            [NConsoler.Optional(null, //@"assets\PerfTesterConfig.xml", 
				Description = "PerfTesterConfig file to load, defaults to null, which will load some internal default values ")]  //\n\t\t <executabledir>\\assets\\PerfTesterConfig.xml.\n\t\t May be entered as relative to the executable location \n\t\t or absolute.\n")] 
			string cf
			)
		{

			Console.WriteLine(" Config file: {0}, cli: {1}", cf, cli);

			if (cli)
				RunCli();
			else
                RunGUI(cf);
		}

		private static void RunCli()
		{
			System.Windows.Forms.SendKeys.SendWait("{ENTER}");

			throw new NotImplementedException("CLI is not yet ready to go");

		}

		private static void RunGUI(string cf)
		{

			Application.EnableVisualStyles();
			Application.SetCompatibleTextRenderingDefault(false);

            MsgLoggerFactory.init();
            FrameworkComponentFactory.init();
			Framework.init();
            AppMethodFactory.init();
            if (cf != null)
                PrefRepo.active = PrefRepo.Fetch(cf);
            else
                PrefRepo.active = PrefRepo.GetDefaultSettings();

			UserInterface.init();

			UserInterface.getPreferences();
			UserInterface.bringup();
			UserInterface.runApplication();

			Framework.stop();

		    Application.Exit();

		}

 

	}

}

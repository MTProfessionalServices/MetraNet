
using System.Runtime.InteropServices;

[assembly: GuidAttribute("80264cc7-09fd-470f-b34a-cf4f0cde0a2d")]

namespace MetraTech.OnlineBill.TestTool
{
	using System;
	using System.Diagnostics;
	using MetraTech;
	using MetraTech.Xml;
  using MetraTech.Interop.MTAuth;
	using MetraTech.Interop.MTServerAccess;
	using MetraTech.OnlineBill;
	//using MetraTech.Interop.MTHierarchyReports;

	class Tool
	{
		[MTAThread]
		static int Main(string[] args)
		{
			Tool tool = new Tool(args);
			return tool.Execute();
		}

		public Tool(string [] args)
		{
			mArgs = args;
		}

		public int Execute()
		{
			// at least one argument, the action, is required
			if (mArgs.Length == 0)
			{
				DisplayUsage();
				return 1;
			}

			try
			{
				mParser = new CommandLineParser(mArgs, 0, mArgs.Length);
				mParser.Parse();

				mIntervalSpecified = mParser.OptionExists("interval");
				mAccountIDSpecified = mParser.OptionExists("accountid");

				if (mIntervalSpecified)
					mIntervalID = mParser.GetIntegerOption("interval");

				if (mAccountIDSpecified)
					mAccountID = mParser.GetIntegerOption("accountid");

				mAccountName = mParser.GetStringOption("accountname", null);
				mPassword = mParser.GetStringOption("password", null);
				mNamespace = mParser.GetStringOption("namespace", null);

				mReportIndex = mParser.GetIntegerOption("reportindex", 1);

				if (mParser.OptionExists("bill"))
					mReportType = MetraTech.Interop.MTHierarchyReports.MPS_REPORT_TYPE.REPORT_TYPE_BILL;
				else if (mParser.OptionExists("static"))
					mReportType = MetraTech.Interop.MTHierarchyReports.MPS_REPORT_TYPE.REPORT_TYPE_STATIC_REPORT;
				else if (mParser.OptionExists("interactive"))
					mReportType = MetraTech.Interop.MTHierarchyReports.MPS_REPORT_TYPE.REPORT_TYPE_INTERACTIVE_REPORT;
				else
					mReportType = MetraTech.Interop.MTHierarchyReports.MPS_REPORT_TYPE.REPORT_TYPE_BILL;

				if (mParser.OptionExists("byfolder"))
					mViewType = MetraTech.Interop.MTHierarchyReports.MPS_VIEW_TYPE.VIEW_TYPE_BY_FOLDER;
				else if (mParser.OptionExists("byproduct"))
					mViewType = MetraTech.Interop.MTHierarchyReports.MPS_VIEW_TYPE.VIEW_TYPE_BY_PRODUCT;
				else
					mViewType = MetraTech.Interop.MTHierarchyReports.MPS_VIEW_TYPE.VIEW_TYPE_BY_PRODUCT;
							
				mAutoOpen = mParser.GetBooleanOption("autoopen", true);

				if (mParser.OptionExists("metratime"))
				{
					DateTime newTime = mParser.GetDateTimeOption("metratime");
					// TODO:
				}

				mXMLBackend = mParser.GetBooleanOption("xmlbackend", false);

				mShowXML = mParser.GetBooleanOption("showxml", false);
				if (!mXMLBackend)
					mShowXML = false;

				return Test();
			}
			catch (CommandLineParserException e)
			{
				Console.WriteLine("{0}", e.Message);
				Console.WriteLine("For usage syntax, type: metraviewtest /?");
				return 1;
			}
#if XXX
			catch (Exception e)
			{
				Console.WriteLine("Unhandled exception:");
				Console.WriteLine("{0}\a", e);

				// rethrows the exception on debug builds
        #if DEBUG
				  throw;
        #else
				  return 1;
				#endif
			}
#endif
		}

		public int Test()
		{
			IMTSessionContext context;
			MetraTech.Interop.MTYAAC.IMTYAAC yaac;
			if (mAccountName != null && mPassword != null && mNamespace != null)
			{
				OutputLine("Logging in directly as {0}/{1}", mNamespace, mAccountName);

				IMTLoginContext login = new MTLoginContext();
				context = login.Login(mAccountName, mNamespace, mPassword);
				MetraTech.Interop.MTYAAC.IMTAccountCatalog catalog = new MetraTech.Interop.MTYAAC.MTAccountCatalog();
				catalog.Init((MetraTech.Interop.MTYAAC.IMTSessionContext) context);
				DateTime dt = MetraTime.Now;
				yaac = catalog.GetActorAccount(dt);
			}
			else if (mAccountName != null && mPassword == null && mNamespace != null)
			{
				OutputLine("Logging in as su");

				IMTServerAccessDataSet sa = new MTServerAccessDataSet();
				sa.Initialize();
				IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
				string suName = accessData.UserName;
				string suPassword = accessData.Password;

				IMTLoginContext login = new MTLoginContext();
				IMTSessionContext suContext = login.Login(suName, "system_user", suPassword);

				OutputLine("Impersonating {0}/{1}", mNamespace, mAccountName);

				MetraTech.Interop.MTYAAC.IMTAccountCatalog catalog = new MetraTech.Interop.MTYAAC.MTAccountCatalog();
				catalog.Init((MetraTech.Interop.MTYAAC.IMTSessionContext) suContext);
				DateTime dt = MetraTime.Now;
				yaac = catalog.GetAccountByName(mAccountName, mNamespace, dt);
				context = login.LoginAsAccount((MTSessionContext) suContext, yaac.ID);
			}
			else
				throw new CommandLineParserException("Invalid combination of login arguments");

			if (yaac.IsFolder)
				OutputLine("Logged in as folder {0} (ID={1})", yaac.LoginName, yaac.AccountID);
			else
				OutputLine("Logged in as account {0} (ID={1})",  yaac.LoginName, yaac.AccountID);

			string path = MTXmlDocument.ExtensionDir + "\\SampleSite\\MPS\\siteconfig\\reports.xml";
			MetraTech.Interop.MTHierarchyReports.IReportManager oldReportManager = new MetraTech.Interop.MTHierarchyReports.ReportManager();
			oldReportManager.Initialize(path);
			MetraTech.Interop.MTHierarchyReports.IReportHelper helper = oldReportManager.GetReportHelper((MetraTech.Interop.MTHierarchyReports.IMTYAAC) yaac, context.LanguageID);

			int defaultInterval = helper.DefaultIntervalID;


			int intervalID;
			if (mIntervalSpecified)
			{
				OutputLine("Using specified interval {0}", mIntervalID);
				intervalID = mIntervalID;
			}
			else
			{
				OutputLine("Using default interval ID {0}", defaultInterval);
				intervalID = defaultInterval;
			}

			MetraTech.Interop.MTHierarchyReports.ITimeSlice timeSlice = helper.GetIntervalTimeSlice(intervalID);

			bool secondPass = true;
			bool estimate = false;

			IReportManager manager;
			ProxyReportManager proxyManager = null;
			if (mXMLBackend)
			{
				proxyManager = new ProxyReportManager();
				proxyManager.Helper = helper;
				manager = proxyManager;
			}
			else
				manager = new ReportManager();

			mReport = manager;
			helper.ReportIndex = mReportIndex;
			MetraTech.Interop.MTHierarchyReports.IMTCollection reports = helper.GetAvailableReports((short) mReportType);

			if (mReportIndex > reports.Count || mReportIndex < 1)
			{
				OutputLine("Report index out of range");
				if (reports.Count == 0)
					OutputLine("There are no reports of the given type");
				else
					OutputLine("There are {0} reports of the given type", reports.Count);
				return 1;
			}
			MetraTech.Interop.MTHierarchyReports.IMPSReportInfo reportInfo =
				(MetraTech.Interop.MTHierarchyReports.IMPSReportInfo) reports[mReportIndex];
			helper.ReportInfo.ViewType = mViewType;
			MetraTech.Interop.MTHierarchyReports.MPS_VIEW_TYPE viewType = helper.ReportInfo.ViewType;
			manager.InitializeReport(yaac, timeSlice, (int) viewType, secondPass, estimate,
															 reportInfo, context.LanguageID);
															 
			if (mShowXML)
				OutputLine(proxyManager.Xml);

			//manager.LanguageID = context.LanguageID;
			//manager.TimeSlice = (objTimeSlice)
			ILevel root = manager.Root;
			OutputLevel(root, 0);

			return 0;
		}

		private void OutputCharge(ICharge charge, int indent)
		{
			OutputSpaces(indent);
			OutputLine("Charge: {0}: {1} {2}", charge.ID, charge.Amount, charge.Currency);
			foreach (ICharge sub in charge.SubCharges)
				OutputCharge(sub, indent + 2);
		}

		private void OutputPO(IProductOffering po, int indent)
		{
			OutputSpaces(indent);
			OutputLine("Product Offering: {0}", po.ID);
			foreach (ICharge charge in po.Charges)
				OutputCharge(charge, indent + 2);
		}

		private void OutputLevel(ILevel root, int indent)
		{
			if (!root.IsOpen && mAutoOpen)
			{
				mReport.OpenLevelByID(root.CacheID);
				Debug.Assert(root.IsOpen);
			}

			OutputSpaces(indent);
			OutputLine("{0} {1}: {2} {3}", root.IsOpen ? "-" : "+", root.ID, root.Amount, root.Currency);

			if (root.IsOpen)
			{
				// product offering
				if (root.ProductOfferings == null)
				{
					OutputSpaces(indent + 2);
					OutputLine("NULL PRODUCT OFFERINGS");
				}
				else
					foreach (IProductOffering po in root.ProductOfferings)
						OutputPO(po, indent + 2);

				if (root.Charges == null)
				{
					OutputSpaces(indent + 2);
					OutputLine("NULL CHARGES");
				}
				else
					foreach (ICharge charge in root.Charges)
						OutputCharge(charge, indent + 2);

				if (root.SubLevels == null)
				{
					OutputSpaces(indent + 2);
					OutputLine("NULL SUBLEVELS");
				}
				else
					foreach (ILevel child in root.SubLevels)
						OutputLevel(child, indent + 2);
			}
		}

		private void OutputSpaces(int spaces)
		{
			Output(new string(' ', spaces));
		}

		private void Output(string str)
		{
			Console.Write(str);
		}

		private void Output(string str, params object[] args)
		{
			Output(string.Format(str, args));
		}

		private void OutputLine(string str)
		{
			Console.WriteLine(str);
		}

		private void OutputLine(string str, params object[] args)
		{
			OutputLine(string.Format(str, args));
		}

    private void DisplayUsage()
		{
			// not yet supported: metratime, accountid

			Console.WriteLine("Usage: metraviewtest [options]");
			Console.WriteLine("");
			Console.WriteLine("Options:");
			Console.WriteLine("/interval:<id>         open a specific interval (otherwise use the default)");
			Console.WriteLine("/accountname:<name>    name of account to open");
			Console.WriteLine("/password:<pass>       account's password (if omitted, impersonate)");
			Console.WriteLine("/namespace:<namespace> account's namespace");
			Console.WriteLine("/reportindex:<num>     index of report to open (default: 1)");
			Console.WriteLine("/bill                  open a bill report");
			Console.WriteLine("/static                open a static report");
			Console.WriteLine("/interactive           open an interactive report");
			Console.WriteLine("/byfolder              view By Folder");
			Console.WriteLine("/byproduct             view By Product");
			Console.WriteLine("/xmlbackend:[+|-]      use the old XML backend (default: false)");
			Console.WriteLine("/showxml:[+|-]         show XML from XML backend (default: false)");
			Console.WriteLine("/autoopen:[+|-]        open all possible sublevels (default: false)");
		}

		private int mAccountID;
		private string mAccountName;
		private string mPassword;
		private string mNamespace;
		private int mIntervalID;
		private MetraTech.Interop.MTHierarchyReports.MPS_VIEW_TYPE mViewType;
		private int mReportIndex;
		private MetraTech.Interop.MTHierarchyReports.MPS_REPORT_TYPE mReportType;

		private bool mIntervalSpecified;
		private bool mAccountIDSpecified;
		private bool mAutoOpen;
		private bool mXMLBackend;
		private bool mShowXML;

		private IReportManager mReport;
		private string [] mArgs;
		private CommandLineParser mParser;
	}
}

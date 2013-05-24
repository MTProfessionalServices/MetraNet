using System;
using System.Collections;
using RCD = MetraTech.Interop.RCD;
using System.IO;
using System.Xml;
using System.Xml.XPath;
using System.Xml.Xsl;
using System.Diagnostics;
using MetraTech.Xml;


namespace MetraTech.Utils
{
	class StageInfoExec
	{
		[STAThread]
		static int Main(string[] args)
		{
			StageInfoExec exec = new StageInfoExec(args);
			if(StageInfoExec.bHelp) return 1;
			int status = exec.Execute();
			return status;
		}

		public StageInfoExec(string [] args)
		{
			mArgs = args;
			ParseArgs(args);
		}

		public int Execute()
		{
			mRcd = (RCD.IMTRcd) new RCD.MTRcd();
			RCD.IMTRcdFileList fileList = null;
			if(mExtension.Length > 0)
			{
				string folder = string.Format(@"{0}\{1}", mRcd.ExtensionDir, mExtension);
					fileList = mRcd.RunQueryInAlternateFolder("\\config\\pipeline\\stage.xml", true, folder);
			}
			else if(mStage.Length > 0)
			{
				string query = string.Format(@"\config\pipeline\{0}\stage.xml", mStage);
				fileList = mRcd.RunQuery(query, true);
			}
			else
				fileList = mRcd.RunQuery("\\config\\pipeline\\stage.xml", true);

			foreach (string fileName in fileList)
			{
				StageInfo si = new StageInfo(fileName, mbDetails, mbDirtyOnly);
				si.ToConsole();
			}

			return 0;
		}

		private string mExtension = string.Empty;
		private string mStage = string.Empty;
		private static bool bHelp = false;
		private static bool mbDetails = false;
		private static bool mbDirtyOnly = false;
		void ParseArgs(string [] args)
		{
			mParser = new CommandLineParser(args);
			mParser.Parse();
			if(mParser.OptionExists("extension"))
			{
				mExtension = mParser.GetStringOption("extension");
			}
			if(mParser.OptionExists("stage"))
			{
				mStage = mParser.GetStringOption("stage");
			}
			if(mParser.OptionExists("details"))
			{
				mbDetails = true;
			}
			if(mParser.OptionExists("dirty"))
			{
				mbDirtyOnly = true;
			}
			else if(mParser.OptionExists("?"))
			{
				PrintUsage();
				bHelp = true;
			}

			return;
		}
		static void PrintUsage()
		{
			System.Console.Out.WriteLine("Usage: stageinfo [options]");
			System.Console.Out.WriteLine("Options:");
			System.Console.Out.WriteLine("/extension - Name of the extension to print stage information from");
			System.Console.Out.WriteLine("/stage - Name of stage to print information from");
			System.Console.Out.WriteLine("Examples: ");
			System.Console.Out.WriteLine("1. 'stageinfo.exe /extension:audioconf' - print information about all stages in 'audioconf' extension");
			System.Console.Out.WriteLine("2. 'stageinfo.exe /stage:audioconfcall' - print information about 'audioconfcall' stage");
			System.Console.Out.WriteLine("3. 'stageinfo.exe /stage:audioconfcall /details' - print information about 'audioconfcall' stage with extra details");
			System.Console.Out.WriteLine("4. 'stageinfo.exe' - print information about all stages");
			System.Console.Out.WriteLine("5. 'stageinfo.exe /dirty' - only print stage information if there are unreferenced files in the stage directory");
		}
		
		string [] mArgs;
		CommandLineParser mParser;
		private RCD.IMTRcd mRcd;
	}

	class StageInfo
	{
		private const int WIDTH = 75;
		private static string LINE = string.Empty.PadRight(WIDTH, '-');
		private static string FATLINE = string.Empty.PadRight(WIDTH, '=');
		private bool mbDetails = false;
		private bool mbDirtyOnly = false;
		public void ToConsole()
		{
			if(mbDirtyOnly && !IsDirty())
				return;
			Header();
			ReferencedFilesSummary();
			UnreferencedFilesSummary();
			
			ReferencedFilesDetails();
			UnreferencedFilesDetails();
			if(mbDetails)
			{
				PluginDetails();
				RatePluginDetails();
				WeightedRatePluginDetails();
			}
			Footer();
		}

		private void Header()
		{
			Console.Out.WriteLine();
			Console.Out.WriteLine(FATLINE);
			string header = string.Format("Stage Info for Stage: {0}", Name);
			//Console.Out.WriteLine();
			Console.Out.WriteLine(header);
			//Console.Out.WriteLine(LINE);
			string nextStage = mbFinalStage == false ? "\nNext Stage: " + mNextStage : "";
			Console.Out.WriteLine(
				string.Format("\nStart Stage: {0} \nFinal Stage: {1}{2}", StartStage, FinalStage, nextStage));
		}

		private void ReferencedFilesSummary()
		{
			Console.Out.WriteLine();
			Debug.Assert(mReferencedStageFiles.Count == mReferencedPluginFiles.Count);
			//string str0 = "Summary For Referenced Stage Files:";
			string str1 = "Number of plugins referenced in stage.xml. . . . . . . . .";
			string str2 = "Number of test files referenced in at least one plugin. . . ";
			//Console.Out.WriteLine("{0, -60}", str0);
			//Console.Out.WriteLine(LINE);
			Console.Out.WriteLine("{0, -60}: {1}", str1, mReferencedStageFiles.Count);
			Console.Out.WriteLine("{0, -60}: {1}", str2, mReferencedTestFiles.Count);
			
		}

		private void UnreferencedFilesSummary()
		{
			Console.Out.WriteLine();
			//string str0 = "Summary For Unreferenced Stage Files:";
			string str1 = "Total number of unreferenced files:. . . . . . . . . . . . .";
			string str2 = "Unreferenced plugins:. . . . . . . . . . . . . . . . . . .  ";
			string str3 = "Unreferenced autotest files:. . . . . . . . . . . . . . . .";
			string str4 = "Unknown files:. . . . . . . . . . . . . . . . . . . . . . .";
			//Console.Out.WriteLine("{0, -60}", str0);
			//Console.Out.WriteLine(LINE);
			
			Console.Out.WriteLine("{0, -60}: {1}", str2, mUnreferencedPluginFiles.Count);
			Console.Out.WriteLine("{0, -60}: {1}", str3, mUnreferencedTestFiles.Count);
			Console.Out.WriteLine("{0, -60}: {1}", str4, mUnreferencedUnknownFiles.Count);
			//Console.Out.WriteLine();
			Debug.Assert(	mUnreferencedPluginFiles.Count + 
										mUnreferencedTestFiles.Count +
										mUnreferencedUnknownFiles.Count == mUnreferencedFiles.Count);
			Console.Out.WriteLine("{0, -60}: {1}", str1, mUnreferencedFiles.Count);
		}
		private void ReferencedFilesDetails()
		{
			Console.Out.WriteLine();
			//string str0 = "Details for referenced stage files:";
			//Console.Out.WriteLine("{0, -60}", str0);
			//Console.Out.WriteLine(LINE);
			ProgIdUsageDetails();
			TestFileUsageDetails();
			
		}

		private void UnreferencedFilesDetails()
		{
			if(mUnreferencedPluginFiles.Count + mUnreferencedTestFiles.Count + mUnreferencedUnknownFiles.Count == 0)
				return;
			Console.Out.WriteLine();
			//string str0 = "Details for unreferenced files in stage directory:";
			//Console.Out.WriteLine("{0, -60}", str0);
			//Console.Out.WriteLine(LINE);
			UnreferencedPluginsDetails();
			UnreferencedTestFileDetails();
			UnreferencedUnknownFileDetails();
			
		}

		private void ProgIdUsageDetails()
		{
			//Console.Out.WriteLine();
			string str0 = " ProgID usage breakdown:";
			string tableheader =			" Prog ID                                Num Plugins";
			string tableheaderline =	"|--------------------------------------|-----------|";
			Console.Out.WriteLine("{0}", str0);
			Console.Out.WriteLine();
			Console.Out.WriteLine("{0}", tableheader);
			Console.Out.WriteLine("{0}", tableheaderline);
			foreach(string progid in mProgIdUsage.Keys)
			{
				Console.Out.WriteLine("{0, -40}{1, 11}", " " +progid, (int)mProgIdUsage[progid]);
			}
			
		}
		private void PluginDetails()
		{
			Console.Out.WriteLine();
			string str0 = string.Format(" Stage plugins information ({0} plugins total):", mReferencedPluginFiles.Count);
			string tableheader =			" Name                              Prog ID                              Cond.";
			string tableheaderline =	"|---------------------------------|------------------------------------|----";
			Console.Out.WriteLine("{0}", str0);
			Console.Out.WriteLine();
			Console.Out.WriteLine("{0}", tableheader);
			Console.Out.WriteLine("{0}", tableheaderline);
			foreach(PluginFile pf in mReferencedPluginFiles)
			{
				Console.Out.WriteLine("{0, -35}{1, -39}{2, -3}", " " +pf.Name, pf.ProgId, pf.Conditional.ToString().Substring(0, 1));
			}
			
		}

		private void RatePluginDetails()
		{
			Console.Out.WriteLine();
			ArrayList pcrate = new ArrayList();
			foreach(PluginFile pf in mReferencedPluginFiles)
			{
				if (pf is RatePluginFile)
					pcrate.Add(pf);
			}
			if(pcrate.Count == 0) return;
			string str0 = string.Format(" PCRate plugins information ({0} plugins total):", pcrate.Count);
			string tableheader =			" Name                         Parameter Tables                       Pre-cache";
			string tableheaderline =	"|----------------------------|--------------------------------------|----------";
			Console.Out.WriteLine("{0}", str0);
			Console.Out.WriteLine();
			Console.Out.WriteLine("{0}", tableheader);
			Console.Out.WriteLine("{0}", tableheaderline);
			string pad = string.Empty.PadRight(30, ' ');
			foreach(PluginFile pf in pcrate)
			{
				RatePluginFile rpf = (RatePluginFile)pf;
				string paramtables = string.Empty;
				bool first = true;
				foreach(string paramtable in rpf.ParamTables)
				{
					if(first)
					{
						Console.Out.WriteLine("{0, -30}{1, -44}{2, -3}", " " +pf.Name, paramtable, rpf.CacheAllRS.ToString().Substring(0, 1));
					}
					else
					{
						Console.Out.WriteLine("{0, -30}{1, -44}", pad, paramtable);
					}
						
					first = false;
				}
			}

			
		}

		private void WeightedRatePluginDetails()
		{
			Console.Out.WriteLine();
			ArrayList wrate = new ArrayList();
			foreach(PluginFile pf in mReferencedPluginFiles)
			{
				if (pf is WeightedRatePluginFile)
					wrate.Add(pf);
			}
			if(wrate.Count == 0) return;
			string str0 = string.Format(" WeightedRate plugins information ({0} plugins total):", wrate.Count);
			string tableheader =			" Name                         Executant Name       ";
			string tableheaderline =	"|----------------------------|----------------------";
			Console.Out.WriteLine("{0}", str0);
			Console.Out.WriteLine();
			Console.Out.WriteLine("{0}", tableheader);
			Console.Out.WriteLine("{0}", tableheaderline);
			string pad = string.Empty.PadRight(30, ' ');
			foreach(PluginFile pf in wrate)
			{
				WeightedRatePluginFile wrpf = (WeightedRatePluginFile)pf;
				string paramtables = string.Empty;
				Console.Out.WriteLine("{0, -30}{1, -44}", " " +pf.Name, wrpf.ExecutePluginName);
			}

			
		}
		

		private void UnreferencedPluginsDetails()
		{
			if(mUnreferencedPluginFiles.Count == 0) return;
			Console.Out.WriteLine();
			string str0 = " Unreferenced plugin file list:";
			string tableheader =			" Plugin File Name:";
			string tableheaderline =	"|---------------------------|";
			Console.Out.WriteLine("{0}", str0);
			Console.Out.WriteLine();
			Console.Out.WriteLine("{0}", tableheader);
			Console.Out.WriteLine("{0}", tableheaderline);
			foreach(PluginFile pf in mUnreferencedPluginFiles)
			{
				string processor = pf.Name;
				string file = pf.FileName;
				Console.Out.WriteLine("{0, -40}", " " +file);
			}
			
		}

		private void UnreferencedTestFileDetails()
		{
			if(mUnreferencedTestFiles.Count == 0) return;
			Console.Out.WriteLine();
			string str0 = " Unreferenced test file list:";
			string tableheader =			" Test File Name:";
			string tableheaderline =	"|---------------------------|";
			Console.Out.WriteLine("{0}", str0);
			Console.Out.WriteLine();
			Console.Out.WriteLine("{0}", tableheader);
			Console.Out.WriteLine("{0}", tableheaderline);
			foreach(TestFile tf in mUnreferencedTestFiles)
			{
				string file = tf.FileName;
				Console.Out.WriteLine("{0, -40}", " " +file);
			}
			
			
		}

		private void UnreferencedUnknownFileDetails()
		{
			if(mUnreferencedUnknownFiles.Count == 0) return;
			Console.Out.WriteLine();
			string str0 = " Unknown file list:";
			string tableheader =			" File Name:";
			string tableheaderline =	"|---------------------------|";
			Console.Out.WriteLine("{0}", str0);
			Console.Out.WriteLine();
			Console.Out.WriteLine("{0}", tableheader);
			Console.Out.WriteLine("{0}", tableheaderline);
			foreach(StageFile sf in mUnreferencedUnknownFiles)
			{
				string file = sf.FileName;
				Console.Out.WriteLine("{0, -40}", " " +file);
			}
			
		}


		private void TestFileUsageDetails()
		{
			if(mReferencedTestFiles.Count == 0) return;
			Console.Out.WriteLine();
			string str0 = " Autotest files usage breakdown:";
			string tableheader =			" Autotest File Name                     Referencing Plugin Name(s)";
			string tableheaderline =	"|--------------------------------------|--------------------------|";
			Console.Out.WriteLine("{0}", str0);
			Console.Out.WriteLine();
			Console.Out.WriteLine("{0}", tableheader);
			Console.Out.WriteLine("{0}", tableheaderline);
			foreach(TestFile tf in mReferencedTestFiles)
			{
				string filename = tf.FileName;
				bool first = true;
				{
					foreach(PluginFile pf in tf.ReferencingPlugins)
					{
						string pluginname = string.Empty;
						
						pluginname = pf.FileName;
						if(first)
						{
							Console.Out.WriteLine("{0, -40}{1, 11}", " " +filename, pluginname);
						}
						else
						{
							Console.Out.WriteLine("{0, 51}", pluginname);
						}
						
						first = false;
					}
				}
			}
			
		}
		private void Footer()
		{
			Console.Out.WriteLine(FATLINE);
		}


		public StageInfo(string aFile, bool printdetails, bool printdirtyonly)
		{
			mbDetails = printdetails;
			mbDirtyOnly = printdirtyonly;
			mStagePlugins = new Hashtable();
			mProgIdUsage = new Hashtable();
			mReferencedStageFiles = new ArrayList();
			mUnreferencedFiles = new ArrayList();
			mReferencedPluginFiles = new ArrayList();
			mReferencedTestFiles = new ArrayList();
			mUnreferencedPluginFiles = new ArrayList();
			mUnreferencedTestFiles = new ArrayList();
			mUnreferencedUnknownFiles = new ArrayList();


			
			Parse(aFile);
		}
		void Parse(string aFile)
		{
			FileInfo stage = new FileInfo(aFile);
			mDir = stage.DirectoryName;
			MTXmlDocument doc = new MTXmlDocument();
			doc.Load(aFile);
			mName = MTXmlDocument.GetNodeValueAsString(doc, "/xmlconfig/stage/name");
			mbStartStage = MTXmlDocument.GetNodeValueAsBool(doc, "/xmlconfig/stage/startstage");
			mbFinalStage = MTXmlDocument.GetNodeValueAsBool(doc, "/xmlconfig/stage/finalstage");
			if(mbFinalStage == false)
				mNextStage = MTXmlDocument.GetNodeValueAsString(doc, "/xmlconfig/stage/nextstage");
			XmlNodeList refs = doc.SelectNodes
					(@"/xmlconfig/stage/dependencies//dependson | /xmlconfig/stage/dependencies//processor"); 
			foreach(XmlNode str in refs)
			{
				string key = (string)str.InnerXml.ToLower() + ".xml";
				if(mStagePlugins.ContainsKey(key) == false)
				{
					StageFile so = StageObjectFactory.CreateStageObject(key, stage);
					mStagePlugins[key] = so;
					mReferencedStageFiles.Add(so);
					if(so is PluginFile)
					{
						PluginFile pf = (PluginFile)so;
						if(mProgIdUsage.ContainsKey(pf.ProgId))
							mProgIdUsage[pf.ProgId] = (int)mProgIdUsage[pf.ProgId] + 1;
						else
							mProgIdUsage[pf.ProgId] = 1;
						mReferencedPluginFiles.Add(so);
					}
					else if (so is TestFile)
						mReferencedTestFiles.Add(so);

				}
			}
			//process files that are not referenced directly in stage.xml
			// this could be plugin autotest files, plugins referenced
			//by weightedrate, or some garbage
			StageFile dirfile = null;
			foreach (FileInfo fi in stage.Directory.GetFiles())
			{
				dirfile = StageObjectFactory.CreateStageObject(fi);
				bool found = false;
				if(string.Compare(dirfile.FileName, "stage.xml", true) == 0)
				{
					continue;
				}
				foreach(StageFile referenced in mReferencedStageFiles)
				{
					if(string.Compare(dirfile.FileName, referenced.FileName, true) == 0)
						found = true;
					
					else
					{
						
						if(referenced is PluginFile)
						{
							PluginFile pf = (PluginFile)referenced;

							//Is this a plugin referenced indirectly by weighted rate plugin?
							if(pf is WeightedRatePluginFile)
							{
								WeightedRatePluginFile rpf = (WeightedRatePluginFile)pf;
								string processor = rpf.ExecutePluginName + ".xml";
								if(string.Compare(dirfile.FileName, processor, true) == 0)
								{
									bool bpl = (dirfile is PluginFile);
									if(bpl == false)
									{
										throw new StageInfoException(string.Format("File {0}, referenced as 'execute_plug_in' in {1} plugin file is not a plugin (stage will not start).", dirfile.FileInfo.FullName, referenced.FileInfo.FullName));
									}
									found = true;
									continue;
								}
							}
							//No? Then is this a referenced test file?
							else if(string.Compare(dirfile.FileName, pf.TestFileName, true) == 0)
							{
								if(dirfile is TestFile)
								{
									TestFile tf = (TestFile)dirfile;
									tf.ReferencingPlugins.Add(referenced);
									mReferencedTestFiles.Add(tf);
									found = true;
								}
								else
								{
									throw new StageInfoException(string.Format("File {0}, referenced in autotest section of {1} plugin is not a test file (stage will not start).", dirfile.FileInfo.FullName, referenced.FileInfo.FullName));
								}
							}
						}
						else
						{
							//if(string.Compare(referenced.FileInfo.Extension, ".xml", true) == 0)
							throw new StageInfoException(string.Format("File {0}, referenced in {1} file is not a plugin (stage will not start).", referenced.FileName, stage.FullName));
						}
					}
				}
				if(!found)
				{
					mUnreferencedFiles.Add(dirfile);
					if(dirfile is PluginFile)
						mUnreferencedPluginFiles.Add(dirfile);
					else if(dirfile is TestFile)
						mUnreferencedTestFiles.Add(dirfile);
					else
						mUnreferencedUnknownFiles.Add(dirfile);

				}
			}
		}
		private string mDir;
		public string Directory
		{
			get{return mDir;}
			set{mDir = value;}
		}
		private string mName;
		public string Name
		{
			get{return mName;}
			set{mName = value;}
		}
		private bool mbStartStage;
		public bool StartStage
		{
			get{return mbStartStage;}
			set{mbStartStage = value;}
		}
		private bool mbFinalStage;
		public bool FinalStage
		{
			get{return mbFinalStage;}
			set{mbFinalStage = value;}
		}
		private string mNextStage;
		public string NextStage
		{
			get{return mNextStage;}
			set{mNextStage = value;}
		}

		private Hashtable mStagePlugins;
		public Hashtable StagePlugins
		{
			get{return mStagePlugins;}
		}

		private ArrayList mReferencedStageFiles;
		public ArrayList ReferencedStageFiles
		{
			get{return mReferencedStageFiles;}
		}

		private ArrayList mReferencedPluginFiles;
		public int NumReferencedPluginFiles
		{
			get{return mReferencedPluginFiles.Count;}
		}

		private ArrayList mReferencedTestFiles;
		public int NumReferencedTestFiles
		{
			get{return mReferencedTestFiles.Count;}
		}

		private ArrayList mUnreferencedFiles;
		public ArrayList TotalUnreferencedFiles
		{
			get{return mUnreferencedFiles;}
		}
		public int NumUnreferencedFiles
		{
			get{return mUnreferencedFiles.Count;}
		}

		private ArrayList mUnreferencedPluginFiles;
		public ArrayList UnreferencedPluginFiles
		{
			get{return mUnreferencedPluginFiles;}
		}
		private ArrayList mUnreferencedTestFiles;
		public ArrayList UnreferencedTestFiles
		{
			get{return mUnreferencedTestFiles;}
		}
		private ArrayList mUnreferencedUnknownFiles;
		public ArrayList UnreferencedUnknownFiles
		{
			get{return mUnreferencedUnknownFiles;}
		}

		public bool IsDirty()
		{
			return mUnreferencedFiles.Count > 0;
		}
		

		private Hashtable mProgIdUsage = null;

		
	}

	class StageFile
	{
		protected FileInfo mFi;
		public StageFile(FileInfo fi)
		{
			mFi = fi;
			mbReferenced = false;
		}
		protected bool mbReferenced;
		public virtual bool ReferencedInStageFile
		{
			get{return mbReferenced;}
			set{mbReferenced = value;}
		}
		public virtual string FileName
		{
			get{return mFi.Name;}
		}
		public virtual FileInfo FileInfo
		{
			get{return mFi;}
		}
	}
	class TestFile : StageFile
	{
		private ArrayList mReferencingPlugins = new ArrayList();
		public ArrayList ReferencingPlugins
		{
			get{return mReferencingPlugins;}
			set{mReferencingPlugins = value;}
		}

		public TestFile(FileInfo fi) : base(fi)
		{
			 mReferencingPlugins = new ArrayList();
		}


	}
	class PluginFile : StageFile
	{
		public PluginFile(FileInfo fi) : base(fi)
		{
			mTestFile = null;
		}

		private string mName;
		public string Name
		{
			get{return mName;}
			set{mName = value;}
		}

		private string mProgid;
		public string ProgId
		{
			get{return mProgid;}
			set{mProgid = value;}
		}

		private TestFile mTestFile;
		public TestFile TestFile
		{
			get{return mTestFile;}
			set{mTestFile = value;}
		}

		private string mTestFileName;
		public string TestFileName
		{
			get{return mTestFileName;}
			set{mTestFileName = value;}
		}

		private bool  mConditional;
		public bool Conditional
		{
			get{return mConditional;}
			set{mConditional = value;}
		}

	}

	class RatePluginFile : PluginFile
	{
		public RatePluginFile(FileInfo fi) : base(fi)
		{
		}
		private ArrayList mParamTables = new ArrayList();
		public ArrayList ParamTables
		{
			get{return mParamTables;}
		}

		private bool bCacheAllRS = false;
		public bool CacheAllRS
		{
			get{return bCacheAllRS;}
			set{bCacheAllRS = value;}
		}
	}

	class WeightedRatePluginFile : PluginFile
	{
		public WeightedRatePluginFile(FileInfo fi) : base(fi)
		{
		}
		private string mExecutePluginName = string.Empty;
		public string ExecutePluginName
		{
			get{return mExecutePluginName;}
			set{mExecutePluginName = value;}
		}
	}

	

	class StageObjectFactory
	{
		private StageObjectFactory(){}
		private static Hashtable dirs = new Hashtable();
		public static StageFile CreateStageObject(FileInfo fi)
		{
			if(string.Compare(".xml", fi.Extension, true) == 0)
			{
				try
				{
					MTXmlDocument doc = new MTXmlDocument();
					doc.Load(fi.FullName);
					//string nsprefix = doc.LastNode.Prefix;
					//plugin?
					try
					{
						XmlNodeList children = doc.ChildNodes;
						XmlNode xmlconfig = null;
						foreach(XmlNode child in children)
						{
							if(child is XmlElement)
							{
								xmlconfig = child;
								break;
							}
						}

						//Create an XmlNamespaceManager for resolving namespaces.
						XmlNamespaceManager nsmgr = new XmlNamespaceManager(doc.NameTable);
						nsmgr.AddNamespace("dummy", xmlconfig.NamespaceURI);
						
						string namestr = xmlconfig.SelectSingleNode
							("//dummy:processor/dummy:name", nsmgr).InnerXml;
						string progid = xmlconfig.SelectSingleNode
							("//dummy:processor/dummy:progid", nsmgr).InnerXml;
						string testfile = string.Empty;
						bool conditional = false;
									
						try
						{
							XmlNode autotest = MTXmlDocument.SelectOnlyNode
									(doc, "//mtconfigdata/processor/autotest");
							testfile = MTXmlDocument.GetNodeValueAsString(autotest, "file", "");
						}
						catch(Exception){}

						try
						{
							conditional = xmlconfig.SelectSingleNode
								("//dummy:processor/dummy:condition", nsmgr).InnerXml.Length > 0;
						}
						catch(Exception){}

						bool bRate = progid.ToUpper().StartsWith("METRAPIPELINE.PCRATE");
						bool bWeightedRate = progid.ToUpper().StartsWith("METRAPIPELINE.WEIGHTEDRATE");
						PluginFile plugin = null;

						if(bRate)
							plugin =  new RatePluginFile(fi);
						else if (bWeightedRate)
							plugin =  new WeightedRatePluginFile(fi);
						else
							plugin = new PluginFile(fi);

						plugin.Name = namestr;
						plugin.ProgId = progid;
						plugin.TestFileName = testfile;
						plugin.Conditional = conditional;

						if(plugin is RatePluginFile)
						{
							XmlNodeList ratelookups = xmlconfig.SelectNodes
								("//dummy:processor/dummy:configdata/dummy:RateLookup", nsmgr);
							foreach(XmlNode ratelookup in ratelookups)
							{
								try
								{
									string paramtable = ratelookup.SelectSingleNode("ParamTable").InnerXml;
									((RatePluginFile)plugin).ParamTables.Add(paramtable);
								}
								catch(Exception){throw;}
								
							}
							XmlNode cache = null;
							bool precache = false;
							try
							{
								cache = xmlconfig.SelectSingleNode
									("//dummy:processor/dummy:configdata/dummy:InitParamTableCache", nsmgr);
								if (cache != null)
								{
									precache = MTXmlDocument.GetNodeValueAsBool(cache);
									((RatePluginFile)plugin).CacheAllRS = precache;
								}
							}
							catch(Exception)
							{
								throw;
							}
						
						}

						else if(plugin is WeightedRatePluginFile)
						{
							XmlNode executant = null;
							try
							{
								executant = xmlconfig.SelectSingleNode
									("//dummy:processor/dummy:configdata/dummy:execute_plug_in", nsmgr);
								if (executant != null)
								{
									string str = MTXmlDocument.GetNodeValueAsString(executant);
									((WeightedRatePluginFile)plugin).ExecutePluginName = str;
								}
							}
							catch(Exception)
							{
								throw;
							}
						
						}

						return plugin;
					}


					catch(Exception)
					{
						//test file?
						XmlNodeList sessions = doc.SelectNodes("/xmlconfig/session");
						if(sessions.Count > 0)
						{
							TestFile test = new TestFile(fi);
							return test;
						}
						else
							return new StageFile(fi);

					}
				}
				catch(Exception )
				{
					//invalid XML
					return new StageFile(fi);
				}
			}
			else
				return new StageFile(fi);
		}
		public static StageFile CreateStageObject(string name, FileInfo info)
		{
			if(dirs.ContainsKey(info.DirectoryName) == false)
			{
				dirs[info.DirectoryName] = info.Directory.GetFiles();
			}
			foreach(FileInfo fi in (FileInfo[])dirs[info.DirectoryName])
			{
				//if(string.Compare(plfilename, fi.Name, true) == 0)
				string substr = name.ToLower().Substring(0, name.Length - 4) + "_";
				if(string.Compare(fi.Name.ToLower(), name, true) == 0 ||
					(fi.Name.ToLower().StartsWith(substr.ToLower()) && string.Compare(fi.Extension.ToLower(), ".xml", true) == 0))
				{
					StageFile sf = CreateStageObject(fi);
					sf.ReferencedInStageFile = true;
					return sf;
				}
			}
			//non existant plugin referenced in stage.xml
			throw new StageInfoException(string.Format("Plugin file {0}, referenced in {1} file does not exist (stage will not start).", name, info.FullName));
		
		}
	}

	class StageInfoException : ApplicationException
	{
		public StageInfoException(string msg) : base(string.Format("Stage Configuration Error: {0}", msg)){}
	}






}



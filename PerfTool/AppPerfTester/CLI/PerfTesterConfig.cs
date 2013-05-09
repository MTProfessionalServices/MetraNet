using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

//using System.Xml;
using System.IO;						// for TextWriter and FileStream
using System.Xml.Serialization;			// for XmlSerializer
using System.Reflection;				// for executable directory

namespace Baseline
{
	public sealed class PerfTesterConfig
	{
		private static PerfTesterConfig instance = null;
		private static readonly object syncRoot = new Object();

		public string TempDir
		{
			get { return _TempDir; }
			set { _TempDir = value; }
		}
		private string _TempDir;

		public CAppDbPreferences AppDbPreferences
		{
			get { return _AppDbPreferences; }
			set { _AppDbPreferences = value; }
		}
		private CAppDbPreferences _AppDbPreferences;

		public CAppFolderPreferences AppFolderPreferences
		{
			get { return _AppFolderPreferences; }
			set { _AppFolderPreferences = value; }
		}
		private CAppFolderPreferences _AppFolderPreferences;

		public CMASPreferences MASPreferences
		{
			get { return _MASPreferences; }
			set { _MASPreferences = value; }
		}
		private CMASPreferences _MASPreferences;

		//public AppDbPreferences AppDbPreferences
		//{
		//    get { return _AppDbPreferences; }
		//    set { _AppDbPreferences = value; }
		//}
		//private AppDbPreferences _AppDbPreferences;

		//public AppFolderPreferences AppFolderPreferences
		//{
		//    get { return _AppFolderPreferences; }
		//    set { _AppFolderPreferences = value; }
		//}
		//private AppFolderPreferences _AppFolderPreferences;

		private PerfTesterConfig()
		{
		}

		public static PerfTesterConfig Instance
		{
			get
			{
				lock (syncRoot)
				{
					if (instance == null)
						instance = new PerfTesterConfig();
					return instance;
				}

			}
		}
	
		public void Initialize(string config)
		{
			string absolutePath = string.Empty;
			if (!Path.IsPathRooted(config) || !config.Contains(":"))
				absolutePath = string.Format("{0}\\{1}",
					Path.GetDirectoryName(Assembly.GetAssembly(typeof(BaselineGUI.Program)).Location), config);
			else
				absolutePath = config;

			object tmpObj = (object)this;

			ReadObjectXmlSerializer(absolutePath, ref tmpObj);
			instance = (PerfTesterConfig)tmpObj;

			_TempDir = instance._TempDir;
			_AppDbPreferences = instance.AppDbPreferences;
			_AppFolderPreferences = instance.AppFolderPreferences;

			_MASPreferences = instance.MASPreferences;

		}

		public void WriteSampleXml()
		{
			//AppDbPreferences = new BaselineGUI.AppDbPreferences();
			//AppFolderPreferences = new BaselineGUI.AppFolderPreferences();
			AppDbPreferences = new PerfTesterConfig.CAppDbPreferences();
			AppFolderPreferences = new Baseline.PerfTesterConfig.CAppFolderPreferences();

			TempDir = @"D:\temp";

			AppDbPreferences.address = "perfdb";
			AppDbPreferences.port = "1433";
			AppDbPreferences.database = "perf682";
			AppDbPreferences.userName = "perf682";
			AppDbPreferences.password = "MetraTech1";

			AppFolderPreferences.extension = @"C:\dev\MetraNetDEV\RMP\Extensions\ldperf";
			AppFolderPreferences.fileLandingService = @"C:\FLS";
			AppFolderPreferences.visualStudioProject = @"C:\users\administrator\My Documents\Visual Studio 2010\Projects\GSM\BaselineGUI";

			WriteObjectXmlSerializer(@"assets\PerfTesterConfig_Out.xml", this);
		}

		/// <summary>Deserialize an object from a file using XmlSerializer</summary>
		/// <param name="file"></param>
		/// <param name="obj"></param>
		public void ReadObjectXmlSerializer(string file, ref object obj)
		{
			// Deserialization
			XmlSerializer s = new XmlSerializer(obj.GetType());
			TextReader r = new StreamReader(file);
			obj = (object)s.Deserialize(r);
			r.Close();
		}

		/// <summary>Serializes and writes an object to XML using XmlSerializer</summary>
		/// <param name="file"></param>
		/// <param name="obj"></param>
		public void WriteObjectXmlSerializer(string file, object obj)
		{
			TextWriter w = new StreamWriter(file);
			try
			{
				XmlSerializer s = new XmlSerializer(obj.GetType());
				s.Serialize(w, obj);
			}
			catch { throw; }
			finally { w.Close(); }
		}

		public class CAppDbPreferences
		{
			public string address = string.Empty;
			public string port = string.Empty;
			public string database = string.Empty;
			public string userName = string.Empty;
			public string password = string.Empty;
		}

		public class CAppFolderPreferences
		{
			public string extension = string.Empty;
			public string fileLandingService = string.Empty;
			public string visualStudioProject = string.Empty;
		}

		public class CMASPreferences
		{
			public string UserName = "su";
			public string Password = "su123";
		}
	}

}

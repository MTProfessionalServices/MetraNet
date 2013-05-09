using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.IO;
//using System.Xml;
//using System.Xml.Schema;		// for Schema validation
using System.Xml.Serialization;		// for XML attribs controlling Serialization

namespace BaselineGUI.Blaster
{
	public class DataBlasterBase
	{
		protected string outputCSVFilename;

		public static BlasterConfig blConfig// = new BasterConfig();
		{
			get { return _blConfig; }
			set { _blConfig = value; }
		}
		private static BlasterConfig _blConfig;

		public static Int64 Sequence
		{
			get { return _Sequence; }
			set { _Sequence = value; }
		}
		private static Int64 _Sequence;

		public DataBlasterBase()
		{
			if (blConfig == null)
			{
				blConfig = new BlasterConfig();
				Sequence = 0;
			}
		}

		public void ReadObjectXmlSerializer(string file, ref object obj)
		{
			TextReader r = new StreamReader(file);
			try
			{
				XmlSerializer s = new XmlSerializer(obj.GetType());
				obj = (object)s.Deserialize(r);
			}
			catch { throw; }
			finally { r.Close(); }
		}

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


		protected void WriteOutputFileHeader()
		{
			StreamWriter sw = new StreamWriter(outputCSVFilename);
			sw.WriteLine("Date,TimeStamp,Records Inserted,Inserts/Second,Overall Inserts/Second");
			sw.Close();
		}

		protected void WriteToFile(string str)
		{
			StreamWriter sw = new StreamWriter(outputCSVFilename, true);
			sw.WriteLine(str);
			sw.Close();
		}






	}
}

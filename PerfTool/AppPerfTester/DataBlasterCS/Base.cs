using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.IO;
//using System.Xml;
//using System.Xml.Schema;		// for Schema validation
using System.Xml.Serialization;		// for XML attribs controlling Serialization

namespace DataBlasterCS
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


		public class BlasterConfig
		{
			public string connectionString
			{
				get { return _connectionString; }
				set { _connectionString = value; }
			}
			private string _connectionString;

			public Int32 numThreads
			{
				get { return _numThreads; }
				set { _numThreads = value; }
			}
			private Int32 _numThreads;

			public Int64 IndexSeed
			{
				get { return _IndexSeed; }
				set { _IndexSeed = value; }
			}
			private Int64 _IndexSeed;

			public Int32 totalRowsPerTable
			{
				get { return _totalRowsPerTable; }
				set { _totalRowsPerTable = value; }
			}
			private Int32 _totalRowsPerTable;

			public Int32 rowsPerInsert
			{
				get { return _rowsPerInsert; }
				set { _rowsPerInsert = value; }
			}
			private Int32 _rowsPerInsert;

			public List<TableDef> Tables
			{
				get { return _Tables; }
				set { _Tables = value; }
			}
			private List<TableDef> _Tables;
		}

		public class TableDef
		{
			public string Name
			{
				get { return _Name; }
				set { _Name = value; }
			}
			private string _Name;

			public List<RowSpec> RowData
			{
				get { return _RowData; }
				set { _RowData = value; }
			}
			private List<RowSpec> _RowData;

			public List<RowSpecA> RowDataA
			{
				get { return _RowDataA; }
				set { _RowDataA = value; }
			}
			private List<RowSpecA> _RowDataA;

			public List<String> TableCreationSql
			{
				get { return _TableCreationSql; }
				set { _TableCreationSql = value; }
			}
			private List<String> _TableCreationSql;

		}

		public class ColumnSpec
		{
			/*
			public string 
			{
				get { return _; }
				set { _ = value; }
			}
			private string _;
			*/

			public string Name
			{
				get { return _Name; }
				set { _Name = value; }
			}
			private string _Name;

			public string DataType
			{
				get { return _DataType; }
				set { _DataType = value; }
			}
			private string _DataType;

			public string NullSetting
			{
				get { return _NullSetting; }
				set { _NullSetting = value; }
			}
			private string _NullSetting;
		}

		public class RowSpec
		{
			public string FieldName
			{
				get { return _FieldName; }
				set { _FieldName = value; }
			}
			private string _FieldName;

			public string DataType
			{
				get { return _datatype; }
				set { _datatype = value; }
			}
			private string _datatype;

			public DataGenType DataGenType
			{
				get { return _DataGenType; }
				set { _DataGenType = value; }
			}
			private DataGenType _DataGenType;

			public string Value
			{
				get { return _Value; }
				set { _Value = value; }
			}
			private string _Value;

			public bool ConvertToBinary
			{
				get { return _ConvertToBinary; }
				set { _ConvertToBinary = value; }
			}
			private bool _ConvertToBinary;

			public bool SqlQuoted
			{
				get { return _SqlQuoted; }
				set { _SqlQuoted = value; }
			}
			private bool _SqlQuoted;

		}
		public class RowSpecA
		{
			[XmlAttribute]
			public string name;

			[XmlAttribute]
			public string datatype;

			[XmlAttribute]
			public string datagentype;

			[XmlAttribute]
			public string value;

			[XmlAttribute]
			public string sqlquoted;
		}

		public enum DataGenType
		{
			none,
			bigint,
			datetime,
			guid,
			integer,
			nchar,
			numeric,
			varbinary,
			seqint,
			seqbigint

		}
	}
}

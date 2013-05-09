using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Xml;
using System.Xml.Schema;		// for Schema validation
using System.Xml.Serialization;		// for XML attribs controlling Serialization

namespace BaselineGUI.Blaster
{
	public class TestTable : DataBlasterBase
	{
		private static log4net.ILog log4NetLogger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
		static readonly object _locker = new object();
		const int MAXINT = 20000000;

		static Random rnd1 = new Random();
		static Random rnd2 = new Random();

		#region properties

		public string TableName
		{
			get { return _TableName; }
			set { _TableName = value; }
		}
		private string _TableName;

		//public int numIdices
		//{
		//    get { return _numIdices; }
		//    set { _numIdices = value; }
		//}
		//private int _numIdices;

		//public List<IndexStyle> IndexStyles
		//{
		//    get { return _IndexStyles; }
		//    set { _IndexStyles = value; }
		//}
		//private List<IndexStyle> _IndexStyles;

		//public List<IndexGen> IndexGen
		//{
		//    get { return _IndexGen; }
		//    set { _IndexGen = value; }
		//}
		//private List<IndexGen> _IndexGen;

		//public Int64 countDown = 0;

		public Int64 CountDown
		{
			get { return _CountDown; }
			set { _CountDown = value; }
		}
		private Int64 _CountDown;

		public Int64 IndexSeed
		{
			get { return _IndexSeed; }
			set { _IndexSeed = value; }
		}
		private Int64 _IndexSeed;

		public Int64 totalRowsToInsert
		{
			get { return _totalRowsToInsert; }
			set { _totalRowsToInsert = value; }
		}
		private Int64 _totalRowsToInsert;

		public Int64 totalRowsInserted
		{
			get { return _totalRowsInserted; }
			set { _totalRowsInserted = value; }
		}
		private Int64 _totalRowsInserted;

		#region table creation specs


		#endregion
		#endregion

		public TestTable()
		{ }
		//public TestTable(int indexnum)
		//{
		//    numIdices = indexnum;
		//    IndexStyles = new List<IndexStyle>(numIdices);
		//    IndexGen = new List<IndexGen>(numIdices);
		//}

		public void Create(ODBCUtil odbcUtil)
		{
			log4NetLogger.Info(string.Format("Creating table {0}", this.TableName));
			string sql = string.Format("CREATE TABLE {0} ([indx0] [int] NOT NULL,[indx1] [int] NOT NULL,[indx2] [int] NOT NULL,[indx3] [int] NOT NULL,"
				+ "[indx4] [int] NOT NULL,[indx5] [int] NOT NULL,[indx6] [int] NOT NULL,[indx7] [int] NOT NULL,[val] [nchar](24) NULL) ON [PRIMARY]", this.TableName);

			odbcUtil.Execute(sql);
		}

		public void Drop(ODBCUtil odbcUtil)
		{
			log4NetLogger.Info(string.Format("Dropping table {0}", this.TableName));
			odbcUtil.Execute(string.Format("drop table {0}", this.TableName));
		}

		// do the insert using the properties
		public void InsertP(ODBCUtil odbcUtil, WorkerArgs workerArgs)
		{

			if (totalRowsInserted >= totalRowsToInsert)
				return;
			#region get the rowcount and index
			Int64 rowsThisInsert;
			Int64 StartingIndex;
			lock (_locker)
			{
				StartingIndex = totalRowsInserted + 1;
				rowsThisInsert = (totalRowsToInsert - totalRowsInserted) < blConfig.rowsPerInsert ?
					(totalRowsToInsert - totalRowsInserted) : blConfig.rowsPerInsert;
				totalRowsInserted += rowsThisInsert;
			}
			#endregion

			#region foreach TableDef
			foreach (TableDef td in blConfig.Tables)
			{
				#region build the column list to insert to
				string columnList = " (";
				//foreach (RowSpec rs in td.RowData)
				for (int i2 = 0; i2 < td.RowData.Count; i2++)
				{
					if (td.RowData[i2].DataGenType != DataGenType.none  || td.RowData[i2].Value.Length > 0)
					{
						columnList += td.RowData[i2].FieldName;
						columnList += ", ";
					}
				}
				columnList = columnList.Substring(0, columnList.Length - 2);
				columnList += ")";
				#endregion

				#region build the input datatlist
				string rowData = string.Empty;

				#region non-generated data
				//for (int i1 = 0; i1 < rowsThisInsert; i1++)
				//{
				//    rowData += string.Format("({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, 'somvalue {8}'),"
				//        , 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
				//}

				//string sql = string.Format("insert into {0} {1} values {2}", td.Name, columnList, rowData.Substring(0, rowData.Length - 1));
				#endregion non-generated data

				#region Generated data
				rowData = " (";
				for (int i1 = 0; i1 < rowsThisInsert; i1++)
				{
					#region the for block
					for (int i2 = 0; i2 < td.RowData.Count; i2++)
					{
						RowSpec rs = td.RowData[i2];
						long seqIndx  = StartingIndex + IndexSeed + i1;

						// do we generate, use supplied or both
						string fieldData = string.Empty;
						if (rs.DataGenType != DataGenType.none && rs.Value != null && rs.Value.Length > 0)
						{
							if (rs.DataGenType == DataGenType.seqint)
								fieldData += rs.Value + seqIndx;
							else
								fieldData += rs.Value + GetGeneratedData(rs.DataGenType); //, td.RowData.IndexOf(rs));
						}
						else if (rs.DataGenType != DataGenType.none)
						{
							if (rs.DataGenType == DataGenType.seqint)
								fieldData += seqIndx;
							else
								fieldData += GetGeneratedData(rs.DataGenType); //, td.RowData.IndexOf(rs));
							#region set the datafiled
							//switch (rs.datagentype.ToLower())
							//{
							//    case "bigint":
							//        fieldData = Convert.ToString(GetRandomLong());
							//        break;
							//    case "int":
							//        fieldData = Convert.ToString(rnd1.Next(100, MAXINT));
							//        //if (Convert.ToInt32(ret) > MAXINT)
							//        //    Console.WriteLine("this one is too big");
							//        break;
							//    case "datetime":
							//        fieldData = Convert.ToString(DateTime.Now);
							//        break;
							//    //varbinary
							//    case "numeric":
							//        //ret = Convert.ToString((rnd1.NextDouble() / 100), 3);
							//        fieldData = Convert.ToString(Math.Round((rnd1.NextDouble() / 100), 3));
							//        break;
							//    default:
							//        fieldData = "1";
							//        break;
							//}
							#endregion
						}
						else if (rs.Value.Length > 0)
							fieldData += rs.Value;
						else
							continue;

						// does it need quotes
						if (rs.ConvertToBinary)
							rowData += string.Format("CONVERT(varbinary(16), '{0}')", fieldData);
						else if (rs.SqlQuoted )
							rowData += string.Format("'{0}'", fieldData);
						else
							rowData += fieldData;

						rowData += ", ";
					}
					rowData = rowData.Substring(0, rowData.Length - 2);
					rowData += ")";

					#endregion the for block
					#region the foreach block
					//    foreach (RowSpec rs in td.RowData)
					//    {
					//        // do we generate, use supplied or both
					//        string fieldData = string.Empty;
					//        if (rs.datagentype != null && rs.datagentype.Length > 0 && rs.value != null)
					//        {
					//            if (rs.datagentype.ToLower() == "seqint")
					//                fieldData += rs.value + StartingIndex + td.RowData.IndexOf(rs);
					//            else
					//                fieldData += rs.value + GetGeneratedData(rs.datagentype); //, td.RowData.IndexOf(rs));
					//        }
					//        else if (rs.datagentype != null && rs.datagentype.Length > 0)
					//        {
					//            {
					//                if (rs.datagentype.ToLower() == "seqint")
					//                    fieldData += StartingIndex + td.RowData.IndexOf(rs);
					//                else
					//                    fieldData += GetGeneratedData(rs.datagentype); //, td.RowData.IndexOf(rs));
					//                #region set the datafield
					//                //switch (rs.datagentype.ToLower())
					//                //{
					//                //    case "bigint":
					//                //        fieldData = Convert.ToString(GetRandomLong());
					//                //        break;
					//                //    case "int":
					//                //        fieldData = Convert.ToString(rnd1.Next(100, MAXINT));
					//                //        //if (Convert.ToInt32(ret) > MAXINT)
					//                //        //    Console.WriteLine("this one is too big");
					//                //        break;
					//                //    case "datetime":
					//                //        fieldData = Convert.ToString(DateTime.Now);
					//                //        break;
					//                //    //varbinary
					//                //    case "numeric":
					//                //        //ret = Convert.ToString((rnd1.NextDouble() / 100), 3);
					//                //        fieldData = Convert.ToString(Math.Round((rnd1.NextDouble() / 100), 3));
					//                //        break;
					//                //    default:
					//                //        fieldData = "1";
					//                //        break;
					//                //}
					//                #endregion
					//            }
					//        }
					//        else if (rs.value != null)
					//            fieldData += rs.value;

					//        // does it need quotes
					//        if (rs.datatype == "datetime" || rs.datatype == "nchar")
					//            rowData += string.Format("'{0}'", fieldData);
					//        else
					//            rowData += fieldData;

					//        // are we at the lasr field for this row
					//        if (td.RowData.IndexOf(rs) == td.RowData.Count - 1)
					//            rowData += ")";
					//        else
					//            rowData += ", ";
					//    }
					#endregion the foreach block

					// do we have more rows to add
					if (i1 < rowsThisInsert - 1)
						rowData += ",(";
				}
				#endregion Generated data

				string sql = string.Format("insert into {0} {1} values {2}", td.Name, columnList, rowData);
				#endregion

				odbcUtil.Execute(sql);
			}
			#endregion foreach TableDef

		}
		// do the insert using the attributes
		public void InsertA(ODBCUtil odbcUtil, WorkerArgs workerArgs)
		{

			if (totalRowsInserted >= totalRowsToInsert)
				return;
			Int64 rowsThisInsert;
			Int64 StartingIndex;
			lock (_locker)
			{
				StartingIndex = totalRowsInserted + 1;
				rowsThisInsert = (totalRowsToInsert - totalRowsInserted) < blConfig.rowsPerInsert ?
					(totalRowsToInsert - totalRowsInserted) : blConfig.rowsPerInsert;
				totalRowsInserted += rowsThisInsert;
			}

			#region foreach TableDef
			foreach (TableDef td in blConfig.Tables)
			{
				#region build the column list to insert to
				string columnList = " (";
				foreach (RowSpecA rs in td.RowDataA)
				{
					columnList += rs.name;
					if (td.RowDataA.IndexOf(rs) == td.RowDataA.Count - 1)
						columnList += ")";
					else
						columnList += ", ";
				}
				#endregion
				#region build the input datatlist
				string rowData = string.Empty;

				#region non-generated data
				//for (int i1 = 0; i1 < rowsThisInsert; i1++)
				//{
				//    rowData += string.Format("({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, 'somvalue {8}'),"
				//        , 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
				//}

				//string sql = string.Format("insert into {0} {1} values {2}", td.Name, columnList, rowData.Substring(0, rowData.Length - 1));
				#endregion non-generated data

				#region Generated data
				rowData = " (";
				for (int i1 = 0; i1 < rowsThisInsert; i1++)
				{
					#region the for block
					for (int i2 = 0; i2 < td.RowDataA.Count; i2++)
					{
						RowSpecA rs = td.RowDataA[i2];
						// do we generate, use supplied or both
						string fieldData = string.Empty;
						if (rs.datagentype != null && rs.datagentype.Length > 0 && rs.value != null && rs.value.Length > 0)
						{
							if (rs.datagentype.ToLower() == "seqint")
								fieldData += rs.value + StartingIndex + i1;
							else
								fieldData += rs.value + GetGeneratedData(rs.datagentype); //, td.RowData.IndexOf(rs));
						}
						else if (rs.datagentype != null && rs.datagentype.Length > 0)
						{
							if (rs.datagentype.ToLower() == "seqint")
								fieldData += StartingIndex + i1;
							else
								fieldData += GetGeneratedData(rs.datagentype); //, td.RowData.IndexOf(rs));
							#region set the datafiled
							//switch (rs.datagentype.ToLower())
							//{
							//    case "bigint":
							//        fieldData = Convert.ToString(GetRandomLong());
							//        break;
							//    case "int":
							//        fieldData = Convert.ToString(rnd1.Next(100, MAXINT));
							//        //if (Convert.ToInt32(ret) > MAXINT)
							//        //    Console.WriteLine("this one is too big");
							//        break;
							//    case "datetime":
							//        fieldData = Convert.ToString(DateTime.Now);
							//        break;
							//    //varbinary
							//    case "numeric":
							//        //ret = Convert.ToString((rnd1.NextDouble() / 100), 3);
							//        fieldData = Convert.ToString(Math.Round((rnd1.NextDouble() / 100), 3));
							//        break;
							//    default:
							//        fieldData = "1";
							//        break;
							//}
							#endregion
						}
						else if (rs.value != null)
							fieldData += rs.value;

						// does it need quotes
						if (rs.datatype == "datetime" || rs.datatype == "nchar")
							rowData += string.Format("'{0}'", fieldData);
						else
							rowData += fieldData;

						// are we at the lasr field for this row
						if (i2 == td.RowDataA.Count - 1)
							rowData += ")";
						else
							rowData += ", ";
					}
					#endregion the for block
					#region the foreach block
					//    foreach (RowSpec rs in td.RowData)
					//    {
					//        // do we generate, use supplied or both
					//        string fieldData = string.Empty;
					//        if (rs.datagentype != null && rs.datagentype.Length > 0 && rs.value != null)
					//        {
					//            if (rs.datagentype.ToLower() == "seqint")
					//                fieldData += rs.value + StartingIndex + td.RowData.IndexOf(rs);
					//            else
					//                fieldData += rs.value + GetGeneratedData(rs.datagentype); //, td.RowData.IndexOf(rs));
					//        }
					//        else if (rs.datagentype != null && rs.datagentype.Length > 0)
					//        {
					//            {
					//                if (rs.datagentype.ToLower() == "seqint")
					//                    fieldData += StartingIndex + td.RowData.IndexOf(rs);
					//                else
					//                    fieldData += GetGeneratedData(rs.datagentype); //, td.RowData.IndexOf(rs));
					//                #region set the datafield
					//                //switch (rs.datagentype.ToLower())
					//                //{
					//                //    case "bigint":
					//                //        fieldData = Convert.ToString(GetRandomLong());
					//                //        break;
					//                //    case "int":
					//                //        fieldData = Convert.ToString(rnd1.Next(100, MAXINT));
					//                //        //if (Convert.ToInt32(ret) > MAXINT)
					//                //        //    Console.WriteLine("this one is too big");
					//                //        break;
					//                //    case "datetime":
					//                //        fieldData = Convert.ToString(DateTime.Now);
					//                //        break;
					//                //    //varbinary
					//                //    case "numeric":
					//                //        //ret = Convert.ToString((rnd1.NextDouble() / 100), 3);
					//                //        fieldData = Convert.ToString(Math.Round((rnd1.NextDouble() / 100), 3));
					//                //        break;
					//                //    default:
					//                //        fieldData = "1";
					//                //        break;
					//                //}
					//                #endregion
					//            }
					//        }
					//        else if (rs.value != null)
					//            fieldData += rs.value;

					//        // does it need quotes
					//        if (rs.datatype == "datetime" || rs.datatype == "nchar")
					//            rowData += string.Format("'{0}'", fieldData);
					//        else
					//            rowData += fieldData;

					//        // are we at the lasr field for this row
					//        if (td.RowData.IndexOf(rs) == td.RowData.Count - 1)
					//            rowData += ")";
					//        else
					//            rowData += ", ";
					//    }
					#endregion the foreach block

					// do we have more rows to add
					if (i1 < rowsThisInsert - 1)
						rowData += ",(";
				}
				#endregion Generated data

				string sql = string.Format("insert into {0} {1} values {2}", td.Name, columnList, rowData);
				#endregion

				odbcUtil.Execute(sql);
			}
			#endregion foreach TableDef

		}
		public void xInsert(ODBCUtil odbcUtil, WorkerArgs workerArgs)
		{
			if (totalRowsInserted >= totalRowsToInsert)
				return;
			//Int64 rowsThisInsert = (rowsToInsert - rowsInserted) < workerArgs.rows_per_insert ? (rowsToInsert - rowsInserted) : workerArgs.rows_per_insert;
			Int64 rowsThisInsert = (totalRowsToInsert - totalRowsInserted) < workerArgs.rows_per_insert ?
				(totalRowsToInsert - totalRowsInserted) : workerArgs.rows_per_insert;
			//Int64 rowsThisInsert = (rowsToInsert - rowsInserted) < workerArgs.rows_per_insert ?
			//    (rowsToInsert - rowsInserted) : workerArgs.rows_per_insert;

			//log4NetLogger.Info(string.Format("Inserting {0} rows", rowsThisInsert));
			string sql = string.Format("insert into {0} values ", "foo"); //workerArgs.table1.TableName);
			for (int i1 = 0; i1 < rowsThisInsert - 1; i1++)
			{
				//totalRowsInserted ++;
				totalRowsInserted++;
				//sql += string.Format("({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, 'somvalue {8}'),"
				//    , rowsInserted, rowsInserted, rowsInserted, rowsInserted, rowsInserted, rowsInserted, rowsInserted, rowsInserted, totalRowsInserted, 1);
				sql += string.Format("({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, 'somvalue {8}'),"
					, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
			}
			//totalRowsInserted += rowsThisInsert;
			totalRowsInserted++;
			//sql += string.Format("({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, 'somvalue {8}')"
			//        , rowsInserted, rowsInserted, rowsInserted, rowsInserted, rowsInserted, rowsInserted, rowsInserted, rowsInserted, totalRowsInserted, 1);
			sql += string.Format("({0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, 'somvalue {8}')"
					, 1, 1, 1, 1, 1, 1, 1, 1, totalRowsInserted, 1);
			odbcUtil.Execute(sql);
		}

		private static string GetGeneratedData(DataGenType type) //, int seed)
		{

			//string ret = string.Empty;
			switch (type)
			{
				case DataGenType.guid:
					return Guid.NewGuid().ToString();

				case DataGenType.bigint:
					return Convert.ToString(GetRandomLong());

				case DataGenType.integer:
					return Convert.ToString(rnd1.Next(100, MAXINT));
					//if (Convert.ToInt32(ret) > MAXINT)
					//    Console.WriteLine("this one is too big");

				case DataGenType.datetime:
					return Convert.ToString(DateTime.Now);

				//varbinary
				case DataGenType.numeric:
					//ret = Convert.ToString((rnd1.NextDouble() / 100), 3);
					return Convert.ToString(Math.Round((rnd1.NextDouble() / 100), 3));

				case DataGenType.none :
					//ret = Convert.ToString((rnd1.NextDouble() / 100), 3);
					return null;

				default:
					return "1";

			}
			//return ret;
		}
		private static string GetGeneratedData(string type) //, int seed)
		{
			//string ret = string.Empty;
			switch (type.ToLower())
			{
				case "guid":
					return Guid.NewGuid().ToString();

				case "bigint":
					return Convert.ToString(GetRandomLong());

				case "int":
					return Convert.ToString(rnd1.Next(100, MAXINT));
					//if (Convert.ToInt32(ret) > MAXINT)
					//    Console.WriteLine("this one is too big");

				case "datetime":
					return Convert.ToString(DateTime.Now);

				//varbinary
				case "numeric":
					//ret = Convert.ToString((rnd1.NextDouble() / 100), 3);
					return Convert.ToString(Math.Round((rnd1.NextDouble() / 100), 3));

				default:
					return "1";

			}
			//return ret;
		}

		private static long GetRandomLong()
		{
			Int64 highorder = rnd1.Next(100, MAXINT);
			Int64 loworder = rnd2.Next(100, MAXINT);
			//long operator <<(long x, int count);

			//Int64 l = (highorder << 32) | loworder;
			return (highorder << 32) | loworder;
		}

	}

	//public enum IndexStyle { none, nonclustered, clustered }

	//public enum IndexGen { sequential, random }

}

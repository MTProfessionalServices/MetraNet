using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Text;

using System.Configuration;
using System.Threading;
using System.IO;
using System.Data;
using System.Data.Odbc;

using NConsoler;

namespace DataBlasterCS
{
	class DataBlaster : DataBlasterBase
	{
		private static log4net.ILog log4NetLogger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

		static string connString
		{
			get { return _connString; }
			set { _connString = value; }
		}
		private static string _connString;

		//static ConnectionStringSettings connString
		//{
		//    get { return _connString; }
		//    set { _connString = value; }
		//}
		//private static ConnectionStringSettings _connString;

		static int ret = 0;

		static bool workersDone = false;

		List<Thread> threads = new List<Thread>();
		List<Worker> workers = new List<Worker>();

		static int Main(string[] args)
		{
			string sArgs = null;
			foreach (string s in args)
				sArgs += s + " ";
			//MessageBox.Show(sArgs);

			//log4NetLogger.Info(">> Main -" + sArgs );
			log4NetLogger.Info(System.Reflection.MethodBase.GetCurrentMethod().Module + " args=" + sArgs);

			Consolery.Run(typeof(DataBlaster), args);

			log4NetLogger.Info("<< Main");
			//MessageBox.Show("Stopped to check things out", "Debug stop");
			return ret;
		}

		[Action("\n    Runs the inserts to the test table\n")]
		public static void RTT0(
			[Optional(null, new string[] { "op" }, Description = @"Output csv file to collect timings")]
			string OutputFile
			)
		{
			//connString = ConfigurationManager.ConnectionStrings["MyConnection"];

			//DataBlaster blaster = new DataBlaster();

			//List<TestTable> tables = new List<TestTable>();
			//blaster.xCreateTestTables(tables);

			//DateTime starttime = DateTime.Now;
			//blaster.xRunInserts(tables);

			//DateTime endtime = DateTime.Now;
			//log4NetLogger.Info(string.Format("All thread have ended, run time; {0}", endtime - starttime));

			#region config readers
			//connString = ConfigurationManager.ConnectionStrings["MyConnection"];
			//NameValueCollection runSettings = (NameValueCollection)ConfigurationManager.GetSection("TestSettings/RunSettings");
			
			//NameValueCollection  Table1 = (NameValueCollection)ConfigurationManager.GetSection("TestSettings/Table1");
			//log4NetLogger.Info(Table1["key1"]);
			//foreach(String aKey in Table1)
			//{
			//    log4NetLogger.Info(string.Format("{0} ; {1}", aKey, Table1[aKey]));
			//}	

			//Hashtable Table2 = (Hashtable)ConfigurationManager.GetSection("TestSettings/Table2");
			//log4NetLogger.Info(Table2["id2"]);
			//foreach(System.Collections.DictionaryEntry d in Table2)
			//{
			//    log4NetLogger.Info(string.Format("{0} ; {1}", d.Key, d.Value));
			//}
			#endregion config readers

		}

		//****************************
		[Action("\n    Create Test Tables as defined in the specified BlasterConfig\n")]
		public static void CTT1(
			[Required(Description = "XML file containing the BlasterConfig,")]
			    //+ "\n\t\t  Relative to TestSystem setting.")]
			string ConfigFile
			)
		{
			//connString = ConfigurationManager.ConnectionStrings["MyConnection"];
			DataBlaster blaster = new DataBlaster();

			object otd = (object)blConfig;
			new DataBlasterBase().ReadObjectXmlSerializer(ConfigFile, ref otd);
			blConfig = (BlasterConfig)otd;
			connString = blConfig.connectionString;

			List<TestTable> tables = new List<TestTable>();
			new DataBlaster().CreateTestTables(tables);
		}

		[Action("\n    Create Test Tables as defined in the specified BlasterConfig\n")]
		public static void RTT1(
			[Required(Description = "XML file containing the BlasterConfig,")]
			    //+ "\n\t\t  Relative to TestSystem setting.")]
			string ConfigFile,
			[Optional(null, new string[] { "op" }, Description = @"Output csv file to collect timings")]
			string OutputFile
			)
		{

			DataBlaster blaster = new DataBlaster();

			#region cleanup on ctrl C
			Console.CancelKeyPress += delegate
			{
				// call methods to clean up 
				log4NetLogger.Info("Shutting down threads from the ctr+c block.");
				foreach (Thread t in blaster.threads)
				{
					if (t.IsAlive)
					{
						log4NetLogger.Info(string.Format("Stopping thread {0}.", t.Name));
						blaster.workers[blaster.threads.IndexOf(t)].RequestStop();
						//t.Join();
						//t.Abort();
					}
				}
			};
			#endregion

			#region set the output file
			if (OutputFile != null)
			{
				if (!Directory.Exists(Path.GetDirectoryName(OutputFile)))
					Directory.CreateDirectory(Path.GetDirectoryName(OutputFile));
				blaster.outputCSVFilename = OutputFile;
				blaster.WriteOutputFileHeader();
			}
			#endregion

			#region ouput test
			//TableDef td = new TableDef();
			//td.Name = "TestTable";
			//td.Columns = new List<ColumnSpec>();

			//ColumnSpec cs = new ColumnSpec();
			//cs.Name = "col1";
			//cs.DataType = "bigint";
			//cs.NullSetting = "NOT NULL";

			//td.Columns.Add(cs);

			//td.TableCreationSql = new List<string>();
			//td.TableCreationSql.Add("sql1");
			//td.TableCreationSql.Add("sql2");

			//BasterConfig bl = new BasterConfig();
			//bl.Tables = new List<TableDef>();
			//bl.Tables.Add(td);

			//new DataBlasterBase().WriteObjectXmlSerializer(@"D:\QaOutDir\TestTable.xml", bl);
			#endregion

			object otd = (object)blConfig;
			new DataBlasterBase().ReadObjectXmlSerializer(ConfigFile, ref otd);
			blConfig = (BlasterConfig)otd;
			connString = blConfig.connectionString;

			string sRunIfo = string.Format("\n  About to begin inserting {0} rows on {1} threads with {2} rows per insert to each the following tables:",
				blConfig.totalRowsPerTable, blConfig.numThreads , blConfig.rowsPerInsert);

			List<TestTable> tables = new List<TestTable>();
			foreach (TableDef td in blConfig.Tables)
			{
				sRunIfo += " " + td.Name;
				TestTable table1 = new TestTable();
				table1.TableName = td.Name;
				tables.Add(table1);
			}
			log4NetLogger.Info(sRunIfo + "\n");

			DateTime starttime = DateTime.Now;
			try
			{
				blaster.RunInserts(tables);
			}
			catch
			{
				log4NetLogger.Info("Shutting down threads from the catch block.");
				foreach (Thread t in blaster.threads)
				{
					if (t.IsAlive)
					{
						log4NetLogger.Info(string.Format("Stopping thread {0}.", t.Name));
						blaster.workers[blaster.threads.IndexOf(t)].RequestStop();
						//t.Join();
						//t.Abort();
					}
				}
			}

			DateTime endtime = DateTime.Now;
			log4NetLogger.Info(string.Format("All thread have ended, run time; {0}", endtime - starttime));

		}



		private void CreateTestTables(List<TestTable> tables)
		{
			ODBCUtil odbcUtil = new ODBCUtil();
			odbcUtil.connString = connString.ToString();
			odbcUtil.DriverConnect();

			foreach (TableDef td in blConfig.Tables)
			{
				TestTable table1 = new TestTable();
				table1.TableName = td.Name;
				try { table1.Drop(odbcUtil); }
				catch { }

				log4NetLogger.Info(string.Format("Creating tables {0}", td.Name));
				foreach (string sql in td.TableCreationSql)
				{
					odbcUtil.Execute(sql);
				}
				//table1.Create(odbcUtil);
				tables.Add(table1);
			}
			

			odbcUtil.Disconnect();
		}
		private void xCreateTestTables(List<TestTable> tables)
		{
			ODBCUtil odbcUtil = new ODBCUtil();
			odbcUtil.connString = connString.ToString();
			odbcUtil.DriverConnect();

			TestTable table1 = new TestTable();
			table1.TableName = "aa_TestTable1";
			try { table1.Drop(odbcUtil); }
			catch { }
			table1.Create(odbcUtil);
			tables.Add(table1);

			odbcUtil.Disconnect();
		}

		private void RunInserts(List<TestTable> tables)
		{
			PrintTimerInfo();

			WorkerArgs workerArgs = new WorkerArgs();

			#region start the worker threads
			for (int i1 = 0; i1 < blConfig.numThreads; i1++)
			{
				workerArgs = new WorkerArgs();
				workerArgs.CountDown = blConfig.totalRowsPerTable;
				workerArgs.connStr = blConfig.connectionString;
				workerArgs.Tables = tables;
				workerArgs.Tables[0].totalRowsToInsert = blConfig.totalRowsPerTable;
				workerArgs.Tables[0].IndexSeed= blConfig.IndexSeed;

				//Thread t = new Thread(() => new DataBlaster().workerThread(workerArgs));
				Worker worker = new Worker();
				Thread t = new Thread(() => new Worker().DoInserts(workerArgs));
				t.Name = string.Format("worker{0}", i1);
				t.Start();
				while (!t.IsAlive);

				threads.Add(t);
				workers.Add(worker);
			}
			#endregion

			monitorThread(workerArgs);
			log4NetLogger.Info(string.Format("Monitor sees rowsInserted as {0} and workersDone as {1}", workerArgs.Tables[0].totalRowsInserted, workersDone));

			#region wait for threads to end
			//while (true)
			//{
			//    Thread.Sleep(10000);
			//    bool threadAreRunning = false;
			//    foreach (Thread thread in threads)
			//    {
			//        if (thread.IsAlive)
			//        {
			//            threadAreRunning = true;
			//            break;
			//        }
			//    }
			//    if (!threadAreRunning)
			//        break;
			//}
			//workersDone = true;
			#endregion

		}
		private void xRunInserts(List<TestTable> tables)
		{
			NameValueCollection runSettings = (NameValueCollection)ConfigurationManager.GetSection("TestSettings/RunSettings");
			PrintTimerInfo();

			Int64 rowsToInsert = Convert.ToInt64(runSettings["totalRows"]);
			int rows_per_insert = Convert.ToInt32(runSettings["rows_per_insert"]);
			Int32 threadCount = Convert.ToInt32(runSettings["numThreads"]);
			List<Thread> threads = new List<Thread>();

			WorkerArgs workerArgs = new WorkerArgs();
			workerArgs.table1 = tables[0];
			workerArgs.table1.totalRowsToInsert = rowsToInsert;
			workerArgs.rows_per_insert = rows_per_insert;

			Thread monitor = new Thread(() => new DataBlaster().xmonitorThread(workerArgs));
			monitor.Start();

			#region start the worker threads
			for (int i1 = 0; i1 < threadCount; i1++)
			{
				workerArgs = new WorkerArgs();
				workerArgs.table1 = tables[0];
				workerArgs.table1.totalRowsToInsert = rowsToInsert;
				workerArgs.rows_per_insert = rows_per_insert;

				Thread t = new Thread(() => new DataBlaster().xworkerThread(workerArgs));
				t.Name = string.Format("worker{0}", i1);
				t.Start();
				threads.Add(t);
				//t.Join();
			}
			#endregion
			#region wait for threads to end
			while (true)
			{
				bool threadAreRunning = false;
				foreach (Thread thread in threads)
					if (thread.IsAlive)
						threadAreRunning = true;
				if (!threadAreRunning)
					break;
			}
			workersDone = true;
			#endregion


		}

		private void workerThread(WorkerArgs workerArgs)
		{
			// good link on threading  http://www.albahari.com/threading/

			ODBCUtil odbcUtil = new ODBCUtil();
			odbcUtil.connString = connString.ToString();
			odbcUtil.DriverConnect();
			log4NetLogger.Info("Thread started");

			//for (int i1 = 0; i1 < workerArgs.inserts_per_thread; i1++)
			while (true)
			{
				if (workerArgs.Tables[0].totalRowsInserted >= workerArgs.Tables[0].totalRowsToInsert)
					break;

				workerArgs.Tables[0].InsertP(odbcUtil, workerArgs);

				if (workerArgs.Tables[0].totalRowsInserted >= workerArgs.Tables[0].totalRowsToInsert)
					break;
			}
			odbcUtil.Disconnect();
		}
		private void xworkerThread(WorkerArgs workerArgs)
		{
			// good link on threading  http://www.albahari.com/threading/

			ODBCUtil odbcUtil = new ODBCUtil();
			odbcUtil.connString = connString.ToString();
			odbcUtil.DriverConnect();
			log4NetLogger.Info("Thread started");
			//for (int i1 = 0; i1 < workerArgs.inserts_per_thread; i1++)
			while (true)
			{
				if (workerArgs.table1.totalRowsInserted >= workerArgs.table1.totalRowsToInsert)
					break;
				workerArgs.table1.xInsert(odbcUtil, workerArgs);
				if (workerArgs.table1.totalRowsInserted >= workerArgs.table1.totalRowsToInsert)
					break;
			}
			odbcUtil.Disconnect();
		}

		private void monitorThread(WorkerArgs workerArgs)
		{
			string sdateFormat = "MM/dd/yy";
			string stimeFormat = "HH:mm:ss";
			Cambia.CoreLib.StopWatch swPerInsert = new Cambia.CoreLib.StopWatch();
			Cambia.CoreLib.StopWatch swOverall = new Cambia.CoreLib.StopWatch();
			swOverall.Reset();
			Thread.Sleep(5000);

			//while (workerArgs.CountDown > 0)
			while (workerArgs.Tables[0].totalRowsInserted < workerArgs.Tables[0].totalRowsToInsert)
			{
				swPerInsert.Reset();
				//Int64 v1 = workerArgs.CountDown;
				Int64 v1 = workerArgs.Tables[0].totalRowsToInsert - workerArgs.Tables[0].totalRowsInserted;
				Thread.Sleep(5000);
				long perInsert = swPerInsert.Peek();
				long Overall = swOverall.Peek();
				//Int64 v2 = workerArgs.CountDown;
				Int64 v2 = workerArgs.Tables[0].totalRowsToInsert - workerArgs.Tables[0].totalRowsInserted;
				Int64 num = v1 - v2;

				DateTime datetime = DateTime.Now.ToLocalTime();
				//string sdate = string.Format("{0:00}/{1:00}/{2}", datetime.Month, datetime.Day, datetime.Year);
				//string stime = string.Format("{0:00}:{1:00}:{2:00}", datetime.Hour, datetime.Minute, datetime.Second);
				string sdate = datetime.ToString(sdateFormat);
				string stime = datetime.ToString(stimeFormat);

				double per_insert = ((double)perInsert) / (double)num;
				double cumulative = ((double)Overall) / workerArgs.Tables[0].totalRowsInserted;
				double insertRate = 10000.0 / per_insert;
				double overallInsertRate = 10000.0 / cumulative;

				string screenOutput = string.Format("\n{0}\n", stime);
				screenOutput += string.Format("Countdown: {0}\n", v2);
				screenOutput += string.Format("Each insert took {0:0.000} microseconds\n", per_insert);
				screenOutput += string.Format("Insert rate = {0:0.000} inserts per second\n", insertRate);
				screenOutput += string.Format("Overall Insert rate = {0:0.000} inserts per second\n", overallInsertRate);
				log4NetLogger.Info(screenOutput);

				if (outputCSVFilename != null)
					WriteToFile(string.Format("{0},{1},{2},{3:00.00},{4:00.00}", sdate, stime, workerArgs.Tables[0].totalRowsInserted, insertRate, overallInsertRate));

				//if (workersDone)
				//{
				//    log4NetLogger.Info(string.Format("Monitor sees rowsInserted as {0} and workersDone as {1}", workerArgs.Tables[0].totalRowsInserted, workersDone));
				//    return;
				//}
			}
			#region wait for threads to end
			while (true)
			{
				Thread.Sleep(10000);
				bool threadAreRunning = false;
				foreach (Thread thread in threads)
				{
					if (thread.IsAlive)
					{
						threadAreRunning = true;
						break;
					}
				}
				if (!threadAreRunning)
					break;
			}
			workersDone = true;
			#endregion

		}
		private void xmonitorThread(WorkerArgs workerArgs)
		{
			string sdateFormat = "MM/dd/yy";
			string stimeFormat = "HH:mm:ss";
			Cambia.CoreLib.StopWatch swPerInsert = new Cambia.CoreLib.StopWatch();
			Cambia.CoreLib.StopWatch swOverall = new Cambia.CoreLib.StopWatch();
			swOverall.Reset();

			while (workerArgs.table1.totalRowsInserted < workerArgs.table1.totalRowsToInsert)
			{
				swPerInsert.Reset();
				//Int64 v1 = rowsToInsert - rowsInserted;
				Int64 v1 = workerArgs.table1.totalRowsToInsert - workerArgs.table1.totalRowsInserted;
				Thread.Sleep(5000);
				long perInsert = swPerInsert.Peek();
				long Overall = swOverall.Peek();
				Int64 v2 = workerArgs.table1.totalRowsToInsert - workerArgs.table1.totalRowsInserted;
				Int64 num = v1 - v2;

				DateTime datetime = DateTime.Now.ToLocalTime();
				//string sdate = string.Format("{0:00}/{1:00}/{2}", datetime.Month, datetime.Day, datetime.Year);
				//string stime = string.Format("{0:00}:{1:00}:{2:00}", datetime.Hour, datetime.Minute, datetime.Second);
				string sdate = datetime.ToString(sdateFormat);
				string stime = datetime.ToString(stimeFormat);

				double per_insert = ((double)perInsert) / (double)num;
				double cumulative = ((double)Overall) / workerArgs.table1.totalRowsInserted;
				double insertRate = 10000.0 / per_insert;
				double overallInsertRate = 10000.0 / cumulative;

				string screenOutput = string.Format("\n{0}\n", stime);
				screenOutput += string.Format("Countdown: {0}\n", v2);
				screenOutput += string.Format("Each insert took {0:0.000} microseconds\n", per_insert);
				screenOutput += string.Format("Insert rate = {0:0.000} inserts per second\n", insertRate);
				screenOutput += string.Format("Overall Insert rate = {0:0.000} inserts per second\n", overallInsertRate);
				log4NetLogger.Info(screenOutput);
				//log4NetLogger.Info(string.Format("Monitor sees rowsInserted as {0} and workersDone as {1}", rowsInserted, workersDone));
				//Thread.Sleep(1000);
				if (workersDone)
				{
					log4NetLogger.Info(string.Format("Monitor sees rowsInserted as {0} and workersDone as {1}", workerArgs.table1.totalRowsInserted, workersDone));
					return;
				}
			}
		}

		private void PrintTimerInfo()
		{
			Cambia.CoreLib.StopWatch sw = new Cambia.CoreLib.StopWatch();
			long freq = sw.GetFrequency();

			log4NetLogger.Info(string.Format(" Timer frequency in ticks per second = {0}", freq));
			log4NetLogger.Info(string.Format(" Timer is accurate within  = {0}\n", (1000L * 1000L * 1000L) / freq));
		}
	}

	public class Worker
	{
		private static log4net.ILog log4NetLogger = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
		
		public void DoInserts(WorkerArgs workerArgs)
		{
			// good link on threading  http://www.albahari.com/threading/

			ODBCUtil odbcUtil = new ODBCUtil();
			odbcUtil.connString = workerArgs.connStr.ToString();
			try
			{
				odbcUtil.DriverConnect();
				log4NetLogger.Info("Thread started");

				//for (int i1 = 0; i1 < workerArgs.inserts_per_thread; i1++)
				while (!_shouldStop)
				{
					if (workerArgs.Tables[0].totalRowsInserted >= workerArgs.Tables[0].totalRowsToInsert)
						break;

					workerArgs.Tables[0].InsertP(odbcUtil, workerArgs);

					if (workerArgs.Tables[0].totalRowsInserted >= workerArgs.Tables[0].totalRowsToInsert)
						break;
				}
			}
			finally
			{
				ConnectionState ret = odbcUtil.GetState();
				if (ret == ConnectionState.Open)
					odbcUtil.Disconnect();
			}
		}

		public void RequestStop()
		{
			_shouldStop = true;
		}
		// Volatile is used as hint to the compiler that this data
		// member will be accessed by multiple threads.
		private volatile bool _shouldStop;
	}
	public class WorkerArgs
	{

		public string connStr
		{
			get { return _connStr; }
			set { _connStr = value; }
		}
		private string _connStr;

		public Int64 CountDown;
		public List<TestTable> Tables
		{
			get { return _Tables; }
			set { _Tables = value; }
		}
		private List<TestTable> _Tables;

		//public DataBlaster Blaster
		//{
		//    get { return _Blaster; }
		//    set { _Blaster = value; }
		//}
		//private DataBlaster _Blaster;

		//int threadId;
		public int rows_per_insert;
		public Int64 total_inserts;

		public Int64 seed;
		public int TableConfig;

		public TestTable table1;
		public TestTable table2;

	}

}

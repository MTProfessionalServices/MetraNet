using System;
using System.Collections;
using System.Xml;
using System.IO;
using System.Text;
using System.EnterpriseServices;
using System.Runtime.InteropServices;

using MetraTech.Pipeline;
using MetraTech.Pipeline.Messages;
using MetraTech;
using MetraTech.Utils;
using MetraTech.DataAccess;
using MetraTech.Interop.PipelineControl;
using MetraTech.Xml;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.PipelineTransaction;

namespace MetraTech.PipelineLibTest
{
	/// <summary>
	/// Summary description for Class1.
	/// </summary>
	class Test
	{

		public void TestMTTime()
		{
			DateTime currentTime = MetraTech.MetraTime.Now;
			Console.WriteLine("The time is " + currentTime);

			Console.WriteLine("Earliest time is " + MetraTech.MetraTime.Min);
			Console.WriteLine("Latest time is " + MetraTech.MetraTime.Max);
		}

		public void TestBCP()
		{
			// drop table t_test_table
			// create table t_test_table
			// (
			//   n_test int,
			//   tx_desc varchar(255),
			//   am_value numeric(22,10),
			//   dt_now datetime
			// )

			MetraTech.DataAccess.BCPBulkInsert bulkInsert = new MetraTech.DataAccess.BCPBulkInsert();
			ConnectionInfo connInfo = new ConnectionInfo("NetMeter");
			bulkInsert.Connect(connInfo);

			bulkInsert.PrepareForInsert("t_test_table", 1000);
			bulkInsert.SetValue(1, MTParameterType.Integer, 1);
			bulkInsert.SetValue(2, MTParameterType.String, "this is a test");
			bulkInsert.SetValue(3, MTParameterType.Decimal, 123.45m);
			bulkInsert.SetValue(4, MTParameterType.DateTime, System.DateTime.Now);
			bulkInsert.AddBatch();

			bulkInsert.SetValue(1, MTParameterType.Integer, 2);
			bulkInsert.SetValue(2, MTParameterType.String, "another string");
			bulkInsert.SetValue(3, MTParameterType.Decimal, -998877.99m);
			bulkInsert.SetValue(4, MTParameterType.DateTime, System.DateTime.Now);
			bulkInsert.AddBatch();

			bulkInsert.ExecuteBatch();
		}

		[DllImport("kernel32.dll")]
    extern static int QueryPerformanceFrequency(out long x);

		[DllImport("kernel32.dll")]
    extern static int QueryPerformanceCounter(out long x);

		public void InteropTest()
		{
			long startCount, endCount, frequency;
			QueryPerformanceFrequency(out frequency);

			MetraTech.Interop.PipelineControl.IMTPipeline mPipeline = new MetraTech.Interop.PipelineControl.MTPipeline();
			MetraTech.Interop.PipelineControl.IMTSessionServer mSessionServer = mPipeline.SessionServer;

			QueryPerformanceCounter(out startCount);
			MetraTech.Interop.PipelineControl.IMTSessionSet sessionSet = mSessionServer.CreateSessionSet();

			string strVal;
			for (int i = 0; i < 10240; i++)
			{
				string uid = MSIXUtils.CreateUID();
				byte[] bytes = MSIXUtils.DecodeUID(uid);

				MetraTech.Interop.PipelineControl.IMTSession session = mSessionServer.CreateSession(bytes, 700);

//				decimal decVal = i;
//				session.SetDecimalProperty(99, decVal);
//				int nVal = i;
//				session.SetLongProperty(99, nVal);
				strVal = uid;
				session.SetStringProperty(99, strVal);
				sessionSet.AddSession(session.sessionID, session.ServiceID);
			}
			QueryPerformanceCounter(out endCount);

			Console.WriteLine("creation time: {0} ms", 
							  (int) ((1000.0*(endCount - startCount))/frequency));

			QueryPerformanceCounter(out startCount);
			decimal sum = 0;

			IEnumerator enumerator = sessionSet.GetEnumerator();
			try
			{
				while (enumerator.MoveNext())
				{
					IMTSession session = (IMTSession) enumerator.Current;
					try
					{
						//decimal val = (decimal) session.GetDecimalProperty(99);
						//long val = (int) session.GetLongProperty(99);
						strVal = session.GetStringProperty(99);
						long val = strVal[0];
						sum += val;
					}
				 	finally
					{
						// important - explicitly release our reference to the object
						Marshal.ReleaseComObject(session);
					}
				}
			}
			finally
			{
				ICustomAdapter adapter = (ICustomAdapter)enumerator;
				Marshal.ReleaseComObject(adapter.GetUnderlyingObject());
				Marshal.ReleaseComObject(sessionSet);
			}

			QueryPerformanceCounter(out endCount);
			Console.WriteLine("Sum of connection minutes = {0}", sum);
			Console.WriteLine("iteration time: {0} ms", 
												(int) ((1000.0*(endCount - startCount))/frequency));
		}

/* This Test will not work, because CreateSession and CreateSessionSet methods
 * are not exposes on the ISessionServer interface.  Expose these methods and
 * recompile to run this test.
 * 
		public void InteropTestManaged()
		{
			long startCount, endCount, frequency;
			QueryPerformanceFrequency(out frequency);

			MetraTech.Pipeline.ISessionServer mSessionServer = MetraTech.Pipeline.SessionServer.Create();
			
			QueryPerformanceCounter(out startCount);
			MetraTech.Pipeline.ISessionSet sessionSet = mSessionServer.CreateSessionSet();

			string strVal;
			for (int i = 0; i < 10240; i++)
			{
				string uid = MSIXUtils.CreateUID();
				byte[] bytes = MSIXUtils.DecodeUID(uid);

				MetraTech.Pipeline.ISession session = mSessionServer.CreateSession(bytes, 700);

				//				decimal decVal = i;
				//				session.SetDecimalProperty(99, decVal);
				//				int nVal = i;
				//				session.SetLongProperty(99, nVal);
				strVal = uid;
				session.SetStringProperty(99, strVal);
				sessionSet.AddSession(session.InternalID, session.ServiceDefinitionID);
			}

			QueryPerformanceCounter(out endCount);

			Console.WriteLine("creation time: {0} ms", 
				(int) ((1000.0*(endCount - startCount))/frequency));

			QueryPerformanceCounter(out startCount);

			decimal sum = 0;

			foreach(ISession sess in sessionSet)
			{
				//decimal val = (decimal) session.GetDecimalProperty(99);
				//long val = (int) session.GetLongProperty(99);
				strVal = sess.GetStringProperty(99);
				long val = strVal[0];
				sum += val;
			}

			QueryPerformanceCounter(out endCount);

			Console.WriteLine("Sum of connection minutes = {0}", sum);
			Console.WriteLine("iteration time: {0} ms", 
							  (int) ((1000.0*(endCount - startCount))/frequency));
		}
*/
		public void InteropTest2()
		{
			long startCount, endCount, frequency;
			QueryPerformanceFrequency(out frequency);

			QueryPerformanceCounter(out startCount);
			ArrayList sessions = new ArrayList();

			for (int i = 0; i < 10240; i++)
			{
				string uid = MSIXUtils.CreateUID();
				byte[] bytes = MSIXUtils.DecodeUID(uid);

				PipelineSession session = new PipelineSession();
				session.UID = bytes;
				session.ServiceIndex = 7;

				decimal decVal = i;

				session.SetProperty(0, 99, decVal);

				sessions.Add(session);
			}
			QueryPerformanceCounter(out endCount);

			Console.WriteLine("creation time: {0} ms", 
												(int) ((1000.0*(endCount - startCount))/frequency));

			QueryPerformanceCounter(out startCount);
			decimal sum = 0;

			foreach (PipelineSession session in sessions)
			{
				PipelineProperty prop = session.GetProperty(0);
				decimal val = (decimal) prop.DecimalValue;
				sum += val;
			}

			QueryPerformanceCounter(out endCount);

			Console.WriteLine("Sum of connection minutes = {0}", sum);
			Console.WriteLine("iteration time: {0} ms", 
												(int) ((1000.0*(endCount - startCount))/frequency));

		}

		public void TestLargeText()
		{
			// read in a test file
			string testText;
			using (FileStream fileStream = new FileStream("e:\\scratch\\doc.xml",
																										FileMode.Open))
			{
				byte [] buffer = new byte[4096];
				char [] chars = new char[4096];
				UTF8Encoding encoding = new UTF8Encoding();
				Decoder decoder = encoding.GetDecoder();
				StringBuilder builder = new StringBuilder();
				while (fileStream.Position != fileStream.Length)
				{
					int readLength = fileStream.Read(buffer, 0, buffer.Length);
					int decodeLength = decoder.GetChars(buffer, 0, readLength, chars, 0);
					builder.Append(chars, 0, decodeLength);
				}
				testText = builder.ToString();
			}

			// add it to the database
			using (MetraTech.DataAccess.BCPBulkInsert bulkInsert =
						 new MetraTech.DataAccess.BCPBulkInsert())
			{
				ConnectionInfo connInfo = new ConnectionInfo("NetMeter");
				bulkInsert.Connect(connInfo);

				bulkInsert.PrepareForInsert("t_msix", 1000);

				// use ID 0
				LargeTextManager largeText = new LargeTextManager();
				largeText.Insert(bulkInsert, 0, testText);
			}

			// read it back from the database
			using(IMTConnection conn = ConnectionManager.CreateConnection())
			{
				LargeTextManager largeText = new LargeTextManager();
				// ID 0
				string resultText = largeText.Retrieve(conn, "t_msix", 0);

				if (resultText == testText)
					Console.WriteLine("result matches");
				else
				{
					Console.WriteLine("result mismatch");
					Console.WriteLine(resultText);
				}

				// now delete it
				largeText.Delete(conn, "t_msix", 0);

			}
		}

		public void TestEncode()
		{
			MessageUtils utils = new MessageUtils();
			string message = "<msix><timestamp>2002-10-07T21:08:01Z</timestamp><version>2.0</version><uid>wKgB2fgKwZ4pE/ZYw3cvPQ==</uid><entity>192.168.1.217</entity><beginsession><dn>metratech.com/TestService</dn><uid>wKgB2aj8vZ6D1vsgwncvPQ==</uid><commit>Y</commit><insert>Y</insert><properties><property><dn>Units</dn><value>1.000000000000000e+002</value></property><property><dn>Time</dn><value>1998-10-13T18:54:39Z</value></property><property><dn>Description</dn><value>Test Service4</value></property><property><dn>AccountName</dn><value>demo</value></property></properties></beginsession></msix>";
			string uid = "wKgB2fgKwZ4pE/ZYw3cvPQ==";

			string encoded = utils.EncodeMessage(message, uid, true, true);
			Console.WriteLine(encoded);

			string sourceUid;
			string sourceMessageUid;
			string decoded = utils.DecodeMessage(encoded, out sourceUid,
																					 out sourceMessageUid);

			Console.WriteLine("decoded: " + decoded);
			Console.WriteLine("uid: " + sourceUid);
			Console.WriteLine("message uid: " + sourceMessageUid);
		}

		public void TestEncrypt()
		{
			MetraTech.PipelineInterop.DataUtils dataUtils = new MetraTech.PipelineInterop.DataUtils();
			byte [] dataBytes = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 };

			for (int i = 0; i < dataBytes.Length; i++)
				System.Console.Write("{0} ", dataBytes[i]);
			Console.WriteLine();

			byte [] encryptedBytes = dataUtils.Encrypt(dataBytes);

			for (int i = 0; i < encryptedBytes.Length; i++)
				System.Console.Write("{0} ", encryptedBytes[i]);
			Console.WriteLine();

			int clearLength;
			dataUtils.Decrypt(encryptedBytes, out clearLength);

			for (int i = 0; i < clearLength; i++)
				System.Console.Write("{0} ", encryptedBytes[i]);
			Console.WriteLine();

		}


		public void TestReadMSIX()
		{
			ServiceDefinitionCollection collection = new ServiceDefinitionCollection();
			IServiceDefinition serviceDef = collection.GetServiceDefinition("metratech.com/testservice");

			Console.WriteLine("name = {0}, desc = {1}",
															 serviceDef.Name,
															 serviceDef.Description);

			foreach (IMTPropertyMetaData propMeta in serviceDef.Values)
			{
				Console.WriteLine("name = {0}, type = {1}, length = {2}, required = {3}, defaultValue = {4}",
																 propMeta.Name, propMeta.DataType, propMeta.Length, propMeta.Required, propMeta.DefaultValue);

				IMTAttributes attributes = propMeta.Attributes;
				foreach (IMTAttribute attr in attributes)
				{
					Console.WriteLine("  {0} = {1}", attr.Name, attr.Value);
				}
			}

			Console.WriteLine("Account identifiers:");
			IEnumerable accountIdentifiers = serviceDef.AccountIdentifiers;
			foreach (IMTPropertyMetaData accountID in accountIdentifiers)
			{
				Console.WriteLine("  {0}", accountID.Name);
			}
		}


		public void TestArrayInsert()
		{
			// drop table t_test_table
			// create table t_test_table
			// (
			//   n_test int,
			//   tx_desc varchar(255),
			//   am_value numeric(22,10),
			//   dt_now datetime
			// )

			MetraTech.Interop.PipelineTransaction.IMTTransaction txn =
				(MetraTech.Interop.PipelineTransaction.IMTTransaction)
				new CMTTransaction();

			txn.Begin("test", 40);

			object itxn = txn.GetTransaction();

			MetraTech.DataAccess.IBulkInsert bulkInsert = new MetraTech.DataAccess.ArrayBulkInsert();
			ConnectionInfo connInfo = new ConnectionInfo("NetMeter");
			bulkInsert.Connect(connInfo, itxn);

			bulkInsert.PrepareForInsert("t_test_table", 1000);
			bulkInsert.SetValue(1, MTParameterType.Integer, 1);
			bulkInsert.SetValue(2, MTParameterType.String, "this is a test");
			bulkInsert.SetValue(3, MTParameterType.Decimal, 123.45m);
			bulkInsert.SetValue(4, MTParameterType.DateTime, System.DateTime.Now);
			bulkInsert.AddBatch();

			bulkInsert.SetValue(1, MTParameterType.Integer, 2);
			bulkInsert.SetValue(2, MTParameterType.String, "another string");
			bulkInsert.SetValue(3, MTParameterType.Decimal, -998877.99m);
			bulkInsert.SetValue(4, MTParameterType.DateTime, System.DateTime.Now);
			bulkInsert.AddBatch();

			bulkInsert.ExecuteBatch();

			//			txn.Commit();
			txn.Rollback();

		}

        /*
        public void TestTransaction()
        {
            MetraTech.Interop.PipelineTransaction.IMTTransaction txn = (MetraTech.Interop.PipelineTransaction.IMTTransaction) new CMTTransaction();

            txn.Begin("test", 40);

            object itxn = txn.GetTransaction();

            //	ServicedConnectionManager connman = new ServicedConnectionManager();
            ServicedConnectionManager connman = (ServicedConnectionManager) BYOT.CreateWithTransaction(itxn, typeof(ServicedConnectionManager));
            IMTConnection conn = connman.CreateConnection();

            using(IMTStatement stmt = conn.CreateStatement("insert into t_txn_test values (1)"))
         {

            stmt.ExecuteNonQuery();
          }
         
            conn.Close();

            txn.Commit();
        }
        */

        /// <summary>
		/// The main entry point for the application.
		/// </summary>
		[MTAThread]
		static void Main(string[] args)
		{
			Test test = new Test();
			//test.TestUnfinished();
			//test.TestDataAccess();
			//test.TestSuspended();

			//-----
			// The following tests compare C#/COM vs C#/MC++ performance.
			Console.WriteLine("Testing C#/COM performance");
			test.InteropTest();
//			Console.WriteLine("Testing C#/Managed C++ performance");
//			test.InteropTestManaged();

			// This test pure C# performance.
			//test.InteropTest2();
			//-----

			//test.TestUIDs();
			//test.TestLogger();
			//test.TestMTTime();
			///test.TestBCP();

			//test.TestBulkFailed();
			//test.TestLargeText();

			//test.TestEncode();
			//test.TestReadMSIX();
			//test.TestTransaction();
			//test.TestEncrypt();
			//test.TestBulkInsert();
			//test.TestArrayInsert();
			//test.TestSaveMSIX();
		}
	}
}

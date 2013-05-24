using System;
using MetraTech;
using TestBatchClient;
using MetraTech.Pipeline.Batch;
using MetraTech.DataAccess;
using MetraTech.Interop.MeterRowset;
using MetraTech.Interop.MTEnumConfig;
using System.Web.Services.Protocols;

namespace TestBatchClient
{
	/// <summary>
	/// Summary description for TestBatchClient.
	/// </summary>
	class TestBatchClient
	{
		private int mID;
		public int ID
		{
			get { return mID; }
			set { mID = value; }
		}

		private string mName;
		public string Name
		{
			get { return mName; }
			set { mName = value; }
		}

		private string mNamespace;
		public string Namespace
		{
			get { return mNamespace; }
			set { mNamespace = value; }
		}

		private string mSource;
		public string Source
		{
			get { return  mSource; }
			set {  mSource = value; }
		}

		private string mUID;
		public string UID
		{
			get { return mUID; }
			set { mUID = value; }
		}

		private string mSequenceNumber;
		public string SequenceNumber
		{
			get { return mSequenceNumber; }
			set { mSequenceNumber = value; }
		}

		private string mURLString;
		public string URLString
		{
			get { return mURLString; }
			set { mURLString = value; }
		}

		public TestBatchClient()
		{
			mID = -1;
			mName = "";
			mNamespace = "";
			mUID = "";
		}

		public string CreateBatch()
		{
			TestClient.localhost.BatchObject batchObj = new TestClient.localhost.BatchObject();

			batchObj.ID									 = -1;
			batchObj.Name                = Name;
			batchObj.Namespace           = Namespace;
			batchObj.SourceCreationDate  = System.DateTime.Now;
			batchObj.Source              = "Test Client Program";
			batchObj.CompletedCount      = 10;
			batchObj.ExpectedCount       = 10;
			batchObj.SequenceNumber      = Name;

			string id = "";

			TestClient.localhost.Listener listener = new TestClient.localhost.Listener();
			listener.Url = URLString;
			try 
			{
				id = listener.Create(batchObj);
			}
			catch (SoapException e)
			{
				//System.Console.WriteLine("(Before) Error Message --> {0}", e.Message);
				string strippedMessage = StripSOAPException(e.Message);
				System.Console.WriteLine("-----------------------");
				System.Console.WriteLine("{0}", strippedMessage);
				System.Console.WriteLine("-----------------------");

				//System.Console.WriteLine("Fault Code Namespace --> {0}", e.Code.Namespace);
				//System.Console.WriteLine("Fault Code --> {0}", e.Code);
       	//System.Console.WriteLine("Fault Code Name --> {0}", e.Code.Name);
       	//System.Console.WriteLine("SOAP Actor that threw Exception --> {0}", e.Actor);
       	//System.Console.WriteLine("Code --> {0}", e.Code);
				//System.Console.WriteLine("Inner Exception is --> {0}",e.InnerException);
				return id;
			}

			DumpBatch(batchObj);

			UID = id;
			return id;
		}

		public bool testLoadByUID(string UID, string batchname, string batchnamespace)
		{
			TestClient.localhost.Listener listener = new TestClient.localhost.Listener();
			listener.Url = URLString;

			TestClient.localhost.BatchObject batchObj;
			try
			{
				batchObj = listener.LoadByUID(UID); 
			}
			catch (SoapException e)
			{
				//System.Console.WriteLine("(Before) Error Message --> {0}", e.Message);
				string strippedMessage = StripSOAPException(e.Message);
				System.Console.WriteLine("-----------------------");
				System.Console.WriteLine("{0}", strippedMessage);
				System.Console.WriteLine("-----------------------");

				return false;
			}

			DumpBatch(batchObj);
			
			if ((batchObj.Name == batchname) && 
					(batchObj.Namespace == batchnamespace)) 
			{
				ID = batchObj.ID;
				return true;
			}
			else
				return false;
		}

		public bool testLoadByName(string batchname, string batchnamespace, string batchsequencenumber, int expectedBatchID)
		{
			TestClient.localhost.Listener listener = new TestClient.localhost.Listener();
			listener.Url = URLString;

			TestClient.localhost.BatchObject batchObj;
			try
			{
				batchObj = listener.LoadByName(batchname, batchnamespace, batchsequencenumber); 
			}
			catch (SoapException e)
			{
				//System.Console.WriteLine("(Before) Error Message --> {0}", e.Message);
				string strippedMessage = StripSOAPException(e.Message);
				System.Console.WriteLine("-----------------------");
				System.Console.WriteLine("{0}", strippedMessage);
				System.Console.WriteLine("-----------------------");

				return false;
			}

			DumpBatch(batchObj);

			if (batchObj.ID == ID)
				return true;
			else
				return false;
		}

		public bool testMarkAsFailed(string UID, string comment)
		{
			TestClient.localhost.Listener listener = new TestClient.localhost.Listener();
			listener.Url = URLString;
			try
			{
				listener.MarkAsFailed(UID, comment);
			}
			catch (SoapException e)
			{
				//System.Console.WriteLine("(Before) Error Message --> {0}", e.Message);
				string strippedMessage = StripSOAPException(e.Message);
				System.Console.WriteLine("-----------------------");
				System.Console.WriteLine("{0}", strippedMessage);
				System.Console.WriteLine("-----------------------");

				return false;
			}

			TestClient.localhost.BatchObject batchObj = listener.LoadByUID(UID); 
			if (batchObj.Status == "F")
				return true;
			else
				return false;
		}

		public bool testMarkAsDismissed(string UID, string comment)
		{
			TestClient.localhost.Listener listener = new TestClient.localhost.Listener();
			listener.Url = URLString;
			try
			{
				listener.MarkAsDismissed(UID, comment); 
			}
			catch (SoapException e)
			{
				//System.Console.WriteLine("(Before) Error Message --> {0}", e.Message);
				string strippedMessage = StripSOAPException(e.Message);
				System.Console.WriteLine("-----------------------");
				System.Console.WriteLine("{0}", strippedMessage);
				System.Console.WriteLine("-----------------------");

				return false;
			}

			TestClient.localhost.BatchObject batchObj = listener.LoadByUID(UID); 
			if (batchObj.Status == "D")
				return true;
			else
			{
				System.Console.WriteLine("testMarkAsDismissed failed!");
				return false;
			}
		}

		public bool testMarkAsCompleted(string UID, string comment)
		{
			TestClient.localhost.Listener listener = new TestClient.localhost.Listener();
			listener.Url = URLString;
			try
			{
				listener.MarkAsCompleted(UID, comment); 
			}
			catch (SoapException e)
			{
				//System.Console.WriteLine("(Before) Error Message --> {0}", e.Message);
				string strippedMessage = StripSOAPException(e.Message);
				System.Console.WriteLine("-----------------------");
				System.Console.WriteLine("{0}", strippedMessage);
				System.Console.WriteLine("-----------------------");

				return false;
			}

			TestClient.localhost.BatchObject batchObj = listener.LoadByUID(UID); 
			if (batchObj.Status == "C")
				return true;
			else
			{
				System.Console.WriteLine("testMarkAsCompleted failed!");
				return false;
			}
		}

		public bool testMarkAsBackout(string UID, string comment)
		{
			TestClient.localhost.Listener listener = new TestClient.localhost.Listener();
			listener.Url = URLString;
			try
			{
				listener.MarkAsBackout(UID, comment); 
			}
			catch (SoapException e)
			{
				//System.Console.WriteLine("(Before) Error Message --> {0}", e.Message);
				string strippedMessage = StripSOAPException(e.Message);
				System.Console.WriteLine("-----------------------");
				System.Console.WriteLine("{0}", strippedMessage);
				System.Console.WriteLine("-----------------------");

				return false;
			}

			TestClient.localhost.BatchObject batchObj = listener.LoadByUID(UID); 
			if (batchObj.Status == "B")
				return true;
			else
			{
				System.Console.WriteLine("testMarkAsCompleted failed!");
				return false;
			}
		}

		public bool testUpdateMeteredCount(string UID, int meteredCount)
		{
			TestClient.localhost.Listener listener = new TestClient.localhost.Listener();
			listener.Url = URLString;
			try
			{
				listener.UpdateMeteredCount(UID, meteredCount); 
			}
			catch (SoapException e)
			{
				System.Console.WriteLine("Update Metered Count Failed!", e.ToString());
				return false;
			}


			TestClient.localhost.BatchObject batchObj = listener.LoadByUID(UID); 
			if (batchObj.MeteredCount == meteredCount)
				return true;
			else
			{
				System.Console.WriteLine("testUpdateMeteredCount failed!");
				return false;
			}
		}

		public bool testGeneralStuff()
		{
			// execute the query to get back the stuff to meter. query will look
			// only at those accounts for a specific interval in the t_invoice
			// table that have payment method "creditcard" or "creditorach"  
			IMeterRowset meterRowset = new MeterRowset();
			meterRowset.InitSDK("paymentserver");
			meterRowset.InitForService("metratech.com/ps_paymentscheduler");

			MetraTech.Interop.MeterRowset.IMTSQLRowset
				rowset = (MetraTech.Interop.MeterRowset.IMTSQLRowset) new MetraTech.Interop.Rowset.MTSQLRowset();

			// the config path isn't actually used but it has to be valid
			rowset.Init("Queries\\UsageServer\\Adapters\\PaymentBillingAdapter");

			rowset.SetQueryTag("__GET_LIST_FOR_PAYMENTS__");
			rowset.AddParam("%%INTERVAL_ID%%", 34269, false);

			IEnumConfig enumConfig = new MetraTech.Interop.MTEnumConfig.EnumConfigClass();
			int enumID = enumConfig.GetID("metratech.com/accountcreation", "PaymentMethod", "1");
			rowset.AddParam("%%ENUM_ID%%", enumID, false);

			System.Console.WriteLine("query: {0}", rowset.GetQueryString());

			rowset.Execute();

			meterRowset.CreateAdapterBatch(1, "xxx", "1"); 
			meterRowset.SessionSetSize = 100;
			
			meterRowset.MeterRowset(rowset);

			return true;
		}

		public string StripSOAPException(string soapexception) 
		{
			int index = soapexception.IndexOf("Fusion log");
			// this is a soap exception
			if (index != -1)
			{
				int totallength = soapexception.Length;
				System.Console.WriteLine("Index --> {0}", index);
				System.Console.WriteLine("Total Length --> {0}", totallength);
				return (soapexception.Remove(index, (totallength - index)));
			}
			else
				return soapexception;
		}

	  public void DumpBatch(TestClient.localhost.BatchObject batchobject) 
		{
			System.Console.WriteLine("---------------------------------------");
			System.Console.WriteLine("ID = {0}", batchobject.ID);
			System.Console.WriteLine("UID Encoded = {0}", batchobject.UID);
			System.Console.WriteLine("Name = {0}", batchobject.Name);
			System.Console.WriteLine("Namespace = {0}", batchobject.Namespace);
			System.Console.WriteLine("Status = {0}", batchobject.Status);
			System.Console.WriteLine("Creation Date = {0}", batchobject.CreationDate);
			System.Console.WriteLine("Source = {0}", batchobject.Source);
			System.Console.WriteLine("Sequence Number = {0}", batchobject.SequenceNumber);
			System.Console.WriteLine("Completed Count = {0}", batchobject.CompletedCount);
			System.Console.WriteLine("Expected Count = {0}", batchobject.ExpectedCount);
			System.Console.WriteLine("Failure Count = {0}", batchobject.FailureCount);
			System.Console.WriteLine("Source Creation Date = {0}", batchobject.SourceCreationDate);
			System.Console.WriteLine("---------------------------------------");

			return;
		}

		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static int Main(string[] args)
		{
			TestBatchClient testbatchclient = new TestBatchClient();
			CommandLineParser parser = new CommandLineParser(args, 0, args.Length);
			parser.Parse();
				
			try
			{
				int port = parser.GetIntegerOption("port");
				parser.CheckForUnusedOptions();
				if (port == 8080)
				{
					Console.WriteLine("Using SOAP server on port 8080");
					testbatchclient.URLString = "http://localhost:8080/Batch/Listener.asmx";
				}
				else if (port == 80)
				{
					Console.WriteLine("Using web server on port 80");
					testbatchclient.URLString = "http://localhost/Batch/Listener.asmx";
				}
				else
				{
					Console.WriteLine("Unknown port number {0}", port);
					return -1;
				}
			}
			catch (CommandLineParserException e)
			{
				Console.WriteLine(e.Message);
				testbatchclient.DisplayUsage();
				return -1;
			}

			/*
			// -----------------------------------------------------------------
			System.Console.WriteLine("Testing general stuff...");
			if (!testbatchclient.testGeneralStuff())
			{
				System.Console.WriteLine("General stuff failed...");
				return -1;
			}
			*/

			testbatchclient.Name = (System.Environment.TickCount).ToString();
			testbatchclient.Namespace = "Batch Listener Client";
			testbatchclient.Source = "Batch Listener Client";
			testbatchclient.SequenceNumber = testbatchclient.Name;

			// -----------------------------------------------------------------
			System.Console.WriteLine("Testing Creation...");
			string UID = testbatchclient.CreateBatch();
			if (UID == "")
			{
				System.Console.WriteLine("Creation test failed...");
				return -1;
			}
			
			// -----------------------------------------------------------------
			System.Console.WriteLine("Testing LoadByUID...");
			if (!(testbatchclient.testLoadByUID(testbatchclient.UID,
																		 testbatchclient.Name,
																		 testbatchclient.Namespace)))
			{
				System.Console.WriteLine("LoadByUID test failed...");
				return -1;
			}

			// -----------------------------------------------------------------
			System.Console.WriteLine("Testing LoadByName...");
			if (!(testbatchclient.testLoadByName(testbatchclient.Name,
																			testbatchclient.Namespace,
																			testbatchclient.SequenceNumber,
																			testbatchclient.ID)))
			{
				System.Console.WriteLine("LoadByName test failed...");
				return -1;
			}

			// -----------------------------------------------------------------
			System.Console.WriteLine("Testing MarkAsFailed...");
			if (!(testbatchclient.testMarkAsFailed(UID, 
									"Marking batch " + UID + " as failed from TestBatchClient")))
			{
				System.Console.WriteLine("MarkAsFailed test failed...");
				return -1;
			}

			// -----------------------------------------------------------------
			System.Console.WriteLine("Testing MarkAsCompleted...");
			if (!(testbatchclient.testMarkAsCompleted(UID, 
									"Marking batch " + UID + " as completed from TestBatchClient")))
			{
				System.Console.WriteLine("MarkAsCompleted test failed...");
				return -1;
			}

			// -----------------------------------------------------------------
			System.Console.WriteLine("Testing MarkAsFailed...");
			if (!(testbatchclient.testMarkAsFailed(UID, 
									"Marking batch " + UID + " as failed from TestBatchClient")))
			{
				System.Console.WriteLine("MarkAsFailed test failed...");
				return -1;
			}

			// -----------------------------------------------------------------
			System.Console.WriteLine("Testing MarkAsBackout...");
			if (!(testbatchclient.testMarkAsBackout(UID, 
									"Marking batch " + UID + " as backout from TestBatchClient")))
			{
				System.Console.WriteLine("MarkAsBackout test failed...");
				return -1;
			}

			// -----------------------------------------------------------------
			System.Console.WriteLine("Testing MarkAsDismissed...");
			if (!(testbatchclient.testMarkAsDismissed(UID, 
									"Marking batch " + UID + " as dismissed from TestBatchClient")))
			{
				System.Console.WriteLine("MarkAsDismissed test failed...");
				return -1;
			}

			// -----------------------------------------------------------------
			System.Console.WriteLine("Testing UpdateMeteredCount...");
			if (!(testbatchclient.testUpdateMeteredCount(UID, 10)))
			{
				System.Console.WriteLine("UpdateMeteredCount test failed...");
				return -1;
			}

			System.Console.WriteLine("------- SUCCESS ---------");

			return 0;
		}
		
    private void DisplayUsage()
		{
			Console.WriteLine("Usage: TestBatchClient [options]");
			Console.WriteLine();
			Console.WriteLine("Options (if using SOAP server, run mssoapt3.exe):");
			Console.WriteLine("  /port:<id>  port # (80 for web server)");
			Console.WriteLine("              port # (8080 for SOAP server)");
			Console.WriteLine();
		}
	}
}

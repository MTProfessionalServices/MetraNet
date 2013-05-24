
namespace MetraTech.Pipeline.ReRun
{
	using System.Runtime.Serialization.Formatters.Soap;
	using System.Runtime.InteropServices;
	using System.IO;
	using System.Net;

	using MetraTech.Interop.MTBillingReRun;
	using MetraTech.DataAccess;

	using System.Text;
	using System;



	[Guid("612b0293-793a-4f84-bd06-061535f3248b")]
	public class Client : IMTBillingReRun
	{
		private int mID;
		private string mSerializedContext;
		private Service mService;
		private bool mSynchronous = true;
		private string mTransactionID = null;

		public int ID
		{
			get
			{
				return mID;
			}
			set
			{
				mID = value;
			}
		}

		// sleep in between calls to check if the operation is finished
		private void Sleep()
		{
			System.Threading.Thread.Sleep(5 * 1000);
		}

		private int MaxRetries
		{
			// TODO: make this configurable.
			// NOTE: negative number means retry infinitely
			get { return -1; }
		}

		private void WaitForCompletion()
		{
			for (int i = 0; MaxRetries < 0 || i < MaxRetries; i++)
			{
				Sleep();
				if (mService.IsOperationComplete(mID))
					return;
			}
			throw new System.ApplicationException(
				string.Format("Timeout waiting for operation {0} to complete", mID));
		}

		public string TableName
		{
			get
			{
				return mService.GetTableName(mID);
			}
		}

		public int AnalyzeCount
		{
			get
			{
                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\BillingRerun", "__COUNT_RESULT_ANALIZE__"))
                    {
                        stmt.AddParam("%%TABLE_NAME%%", mService.GetTableName(mID));

                        using (IMTDataReader reader = stmt.ExecuteReader())
                        {
                            reader.Read();
                            return reader.GetInt32("analyze_count");
                        }
                    }
                }
			}
		}

		public void Setup(string comment)
		{
			mID = mService.Setup(mTransactionID, comment, mSerializedContext);
		}

		public void Identify(IMTIdentificationFilter filter, string comment)
		{
			SoapFormatter serializer = new SoapFormatter();
			MemoryStream memStream = new MemoryStream();
			serializer.Serialize(memStream, filter);
			string xmlFilter = System.Text.UTF8Encoding.UTF8.GetString(memStream.GetBuffer(), 0, (int) memStream.Length);

			if (mSynchronous)
			{
				mService.BeginIdentify(mID, mTransactionID, xmlFilter, comment, mSerializedContext);
				WaitForCompletion();
			}
			else
			{
				mService.BeginIdentify(mID, mTransactionID, xmlFilter, comment, mSerializedContext);
			}

		}

		public void IdentifyAndAnalyze(IMTIdentificationFilter filter, string comment)
		{
			SoapFormatter serializer = new SoapFormatter();
			MemoryStream memStream = new MemoryStream();
			serializer.Serialize(memStream, filter);
			string xmlFilter = System.Text.UTF8Encoding.UTF8.GetString(memStream.GetBuffer(), 0, (int) memStream.Length);

			if (mSynchronous)
			{
				mService.BeginIdentifyAndAnalyze(mID, mTransactionID, xmlFilter, comment, mSerializedContext);
				WaitForCompletion();
			}
			else
			{
				mService.BeginIdentifyAndAnalyze(mID, mTransactionID, xmlFilter, comment, mSerializedContext);
			}
		}

		public void IdentifyAnalyzeAndResubmit(IMTIdentificationFilter filter, string comment)
		{
			SoapFormatter serializer = new SoapFormatter();
			MemoryStream memStream = new MemoryStream();
			serializer.Serialize(memStream, filter);
			string xmlFilter = System.Text.UTF8Encoding.UTF8.GetString(memStream.GetBuffer(), 0, (int) memStream.Length);

			if (mSynchronous)
			{
				mService.BeginIdentifyAnalyzeAndResubmit(mID, mTransactionID, xmlFilter, comment, mSerializedContext);
				WaitForCompletion();
			}
			else
			{
				mService.BeginIdentifyAnalyzeAndResubmit(mID, mTransactionID, xmlFilter, comment, mSerializedContext);
			}
		}

		public void IdentifyAnalyzeAndDelete(IMTIdentificationFilter filter, string comment)
		{
			SoapFormatter serializer = new SoapFormatter();
			MemoryStream memStream = new MemoryStream();
			serializer.Serialize(memStream, filter);
			string xmlFilter = System.Text.UTF8Encoding.UTF8.GetString(memStream.GetBuffer(), 0, (int) memStream.Length);

			if (mSynchronous)
			{
				mService.BeginIdentifyAnalyzeAndDelete(mID, mTransactionID, xmlFilter, comment, mSerializedContext);
				WaitForCompletion();
			}
			else
			{
				mService.BeginIdentifyAnalyzeAndDelete(mID, mTransactionID, xmlFilter, comment, mSerializedContext);
			}
		}
		public void Analyze(string comment)
		{
			if (mSynchronous)
			{
				mService.BeginAnalyze(mID, mTransactionID, comment, mSerializedContext);
				WaitForCompletion();
			}
			else
			{
				mService.BeginAnalyze(mID, mTransactionID, comment, mSerializedContext);
			}
		}

	
		// begin 4.0 additions
		public void BackoutDelete(string comment)
		{
			if (mSynchronous)
			{
				mService.BeginBackoutDelete(mID, mTransactionID, comment, mSerializedContext);
				WaitForCompletion();
			}
			else
			{
				mService.BeginBackoutDelete(mID, mTransactionID, comment, mSerializedContext);
			}
		}
		public void BackoutResubmit(string comment)
		{
			if (mSynchronous)
			{
				mService.BeginBackoutResubmit(mID, mTransactionID, comment, mSerializedContext);
				WaitForCompletion();
			}
			else
			{
				mService.BeginBackoutResubmit(mID, mTransactionID, comment, mSerializedContext);
			}
		}
		// end 4.0 additions


		public void Delete(string comment)
		{
			if (mSynchronous)
			{
				mService.BeginDelete(mID, mTransactionID, comment, mSerializedContext);
				WaitForCompletion();
			}
			else
			{
				mService.BeginDelete(mID, mTransactionID, comment, mSerializedContext);
			}
		}

		public void Abandon(string comment)
		{
			if (mSynchronous)
			{
				mService.BeginAbandon(mID, mTransactionID, comment, mSerializedContext);
				WaitForCompletion();
			}
			else
			{
				mService.BeginAbandon(mID, mTransactionID, comment, mSerializedContext);
			}
		}


	
		public bool IsComplete()
		{
			if (mSynchronous)
				return true;
			else
				return mService.IsOperationComplete(mID);
		}



		public void Login(MetraTech.Interop.MTBillingReRun.IMTSessionContext context)
		{
			mSerializedContext = context.ToXML();
			mService = new Service();

            MetraTech.Interop.MTServerAccess.IMTServerAccessDataSet serverAccess =
				new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
			serverAccess.Initialize();

			MetraTech.Interop.MTServerAccess.IMTServerAccessData sa =
				serverAccess.FindAndReturnObject("billingrerun");

			string serverName = sa.ServerName;
			int port = sa.PortNumber;
			bool secure = sa.Secure != 0;

			if (sa.UserName != null && sa.UserName != "")
			{
				ICredentials credentials = new NetworkCredential(sa.UserName,
																												 sa.Password,
																												 "mydomain");
				mService.Credentials = credentials;
			}

			mService.Timeout = sa.Timeout * 1000;

			mService.Url = string.Format("http{0}://{1}:{2}/BillingReRun/Service.asmx",
																	 secure ? "s" : "",
																	 serverName, port);

            // trust all certificates
            // CORE-5922: SSL certificate name mismatch error should not be supressed. 
            // Suppressing is commented out
            //ServicePointManager.ServerCertificateValidationCallback = ((sender, certificate, chain, sslPolicyErrors) => true);
		}

		public IMTIdentificationFilter CreateFilter()
		{
			return new IdentificationFilter();
		}

		public string CreateIdentificationQuery(IMTIdentificationFilter filter)
		{
			//IMTBillingReRun rerun = new MTBillingReRun();
			//return rerun.CreateIdentificationQuery(filter);
            return "";
		}

        public bool Synchronous
		{
			get
			{ return mSynchronous; }
			set
			{ mSynchronous = value; }
		}

        public string TransactionID
		{
			get
			{ return mTransactionID; }
			set
			{ mTransactionID = value; }
		}

	}
}

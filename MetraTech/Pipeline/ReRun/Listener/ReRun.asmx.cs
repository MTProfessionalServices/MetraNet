using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Web;
using System.Web.Services;
using System.IO;
using System.EnterpriseServices;
using System.Runtime.InteropServices;
using System.Runtime.Serialization.Formatters.Soap;

using MetraTech.Interop.MTBillingReRun;
using MetraTech.Interop.PipelineTransaction;
using MetraTech.Interop.RCD;
using MetraTech.Pipeline.ReRun;
using MetraTech.PipelineInterop;
using MetraTech.Pipeline;
using MetraTech.DataAccess;
using System.Text;
using MetraTech.SecurityFramework;
using PCExec = MetraTech.Interop.MTProductCatalogExec;
using MetraTech.Security.Crypto;

namespace MetraTech.Pipeline.ReRun.Listener
{
	/// <summary>
	/// Summary description for Service.
	/// </summary>
	[WebService(Namespace="http://metratech.com/webservices/")]
	[ComVisible(false)]
	public class Service : System.Web.Services.WebService
	{
		public Service()
		{
			//CODEGEN: This call is required by the ASP.NET Web Services Designer
			InitializeComponent();

            using (var rcd1 = new MTComSmartPtr<IMTRcd>())
            {
                rcd1.Item = new MTRcdClass();
                rcd1.Item.Init();

                //SECENG: Change SecurityFramework version
                var path = System.IO.Path.Combine(rcd1.Item.ConfigDir, @"Security\Validation\MtSfConfigurationLoader.xml");
                var logger = new Logger("[ReRunService]");
                logger.LogDebug("Security framework path: {0}", path);
                SecurityKernel.Initialize(path);
                SecurityKernel.Start();
            }
		}

		#region Component Designer generated code
		
		//Required by the Web Services Designer 
		private IContainer components = null;
				
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
		}

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			if(disposing && components != null)
			{
				components.Dispose();
			}
			base.Dispose(disposing);		
		}
		
		#endregion

		// WEB SERVICE EXAMPLE
		// The HelloWorld() example service returns the string Hello World
		// To build, uncomment the following lines then save and build the project
		// To test this web service, press F5

//		[WebMethod]
//		public string HelloWorld()
//		{
//			return "Hello World";
//		}


		internal class ReRunOperationState
		{
			internal void SetOperationState(int rerun, IAsyncResult resultState, object workerDelegate)
			{
				lock (this)
				{
					IAsyncResult result = (IAsyncResult) mAsyncStates[rerun];
					if (result != null && !result.IsCompleted)
						throw new ApplicationException("previous operation incomplete");
					mAsyncStates[rerun] = resultState;
					mWorkers[rerun] = workerDelegate;
				}
			}

			internal bool IsOperationComplete(int rerun)
			{
				lock (this)
				{
					IAsyncResult result = (IAsyncResult) mAsyncStates[rerun];
					if (result == null)
						// if we have no record of it assume it's complete
						return true;
					return result.IsCompleted;
				}
			}

			internal void EndInvoke(int rerun)
			{
				lock (this)
				{
					IAsyncResult result = (IAsyncResult) mAsyncStates[rerun];
					if (result == null)
						// if we have no record of it assume it's complete
						return;

					Debug.Assert(result.IsCompleted);
					object worker = mWorkers[rerun];
					if (worker is IdentifyDelegate)
					{
						IdentifyDelegate identifyWorker = (IdentifyDelegate) worker;
						identifyWorker.EndInvoke(result);
					}
					else
					{
						BillingReRunDelegate rerunWorker = (BillingReRunDelegate) worker;
						rerunWorker.EndInvoke(result);
					}

					mAsyncStates.Remove(rerun);
					mWorkers.Remove(rerun);
				}
			}

			private Hashtable mAsyncStates = new Hashtable();
			private Hashtable mWorkers = new Hashtable();
		}

		private void StoreReRunState(int rerunID, IAsyncResult result, object del)
		{
			Application.Lock();
			ReRunOperationState state = (ReRunOperationState) Application["ReRunOperationState"];
			if (state == null)
			{
				state = new ReRunOperationState();
				Application["ReRunOperationState"] = state;
			}
			Application.UnLock();
			state.SetOperationState(rerunID, result, del);
		}

		private ReRunWorker CreateWorker(string transactionID)
		{
			if (transactionID == null || transactionID.Length == 0)
			{
				// no transaction
				mLogger.LogDebug("Creating worker with no transaction");
				ReRunWorker worker = new ReRunWorker();
				worker.Transaction = null;
				return worker;
			}
			else
			{
				mLogger.LogDebug("Creating worker with transaction ID {0}", transactionID);
				MetraTech.Interop.PipelineTransaction.IMTTransaction transaction =
					new MetraTech.Interop.PipelineTransaction.CMTTransaction();
				transaction.Import(transactionID);

				ReRunWorker worker = (ReRunWorker)
					BYOT.CreateWithTransaction(transaction.GetTransaction(),
																		 typeof(ReRunWorker));

				worker.Transaction = transaction;
				return worker;
			}
		}

		private delegate void IdentifyDelegate(int rerunID, string transactionID, string serializedFilter, string comment, string serializedContext);
		private delegate void BillingReRunDelegate(int rerunID, string transactionID, string comment, string serializedContext);

		private void Callback(IAsyncResult result)
		{
			mLogger.LogDebug("Async call completed");
		}


		[WebMethod]
		public string GetTableName(int rerunID)
		{
			ReRunWorker worker = CreateWorker(null);
			return worker.GetTableName(rerunID);
		}

		[WebMethod]
		public bool IsOperationComplete(int rerunID)
		{
			mLogger.LogDebug("IsOperationComplete called");

			ReRunOperationState state = (ReRunOperationState) Application["ReRunOperationState"];
			if (state == null)
			{
				mLogger.LogDebug("No operation state - assuming thread is complete");
				return true;
			}

			if (state.IsOperationComplete(rerunID))
			{
				mLogger.LogDebug("Operation considered complete - calling EndInvoke");
				state.EndInvoke(rerunID);
				return true;
			}
			else
			{
				mLogger.LogDebug("Operation not complete");
				return false;
			}
		}


		[WebMethod]
		public int Setup(string transactionID, string comment, string serializedContext)
		{
			mLogger.LogDebug("Setup called");

			ReRunWorker worker = CreateWorker(transactionID);
			return worker.Setup(comment, serializedContext);
		}

		[WebMethod]
		public void BeginIdentify(int rerunID, string transactionID, string serializedFilter, string comment, string serializedContext)
		{
			mLogger.LogDebug("BeginIdentify called");

			IdentifyDelegate worker = new IdentifyDelegate(IdentifyWork);
			IAsyncResult result = worker.BeginInvoke(rerunID, transactionID, serializedFilter, comment, serializedContext,
																							 new AsyncCallback(Callback), DateTime.Now);

			StoreReRunState(rerunID, result, worker);
		}


		private void IdentifyWork(int rerunID, string transactionID, string serializedFilter, string comment, string serializedContext)
		{
			ReRunWorker worker = CreateWorker(transactionID);
			worker.Identify(rerunID, serializedFilter, comment, serializedContext);
      //at this point the identify transaction may be committed (if the worker is not participating 
      //in a dtc transaction that originated elsewhere.)
      //Call update statistics.  Update statistics cannot be called from within a dtc transaction.
      string tablename = worker.GetTableName(rerunID);
			
			if (transactionID == null)
				RunUpdateStats(tablename);
		}


		[WebMethod]
		public void BeginAnalyze(int rerunID, string transactionID, string comment, string serializedContext)
		{
			mLogger.LogDebug("BeginAnalyze called");

			BillingReRunDelegate worker = new BillingReRunDelegate(AnalyzeWork);
			IAsyncResult result = worker.BeginInvoke(rerunID, transactionID, comment, serializedContext,
																							 new AsyncCallback(Callback), DateTime.Now);
			StoreReRunState(rerunID, result, worker);
		}

		private void AnalyzeWork(int rerunID, string transactionID, string comment, string serializedContext)
		{
			ReRunWorker worker = CreateWorker(transactionID);
			worker.Analyze(rerunID, comment, serializedContext);
      string tablename = worker.GetTableName(rerunID);

			if (transactionID == null)
				RunUpdateStats(tablename);
		}


		[WebMethod]
		public void BeginIdentifyAndAnalyze(int rerunID, string transactionID, string serializedFilter, string comment, string serializedContext)
		{
			mLogger.LogDebug("BeginIdentifyAndAnalyze called");

			IdentifyDelegate worker = new IdentifyDelegate(IdentifyAndAnalyzeWork);
			IAsyncResult result = worker.BeginInvoke(rerunID, transactionID, serializedFilter, comment, serializedContext,
																							 new AsyncCallback(Callback), DateTime.Now);

			StoreReRunState(rerunID, result, worker);
		}

		private void IdentifyAndAnalyzeWork(int rerunID, string transactionID, string serializedFilter, string comment, string serializedContext)
		{
			ReRunWorker worker = CreateWorker(transactionID);
			worker.Identify(rerunID, serializedFilter, comment, serializedContext);
      string tablename = worker.GetTableName(rerunID);
      if (transactionID == null)
        RunUpdateStats(tablename);

			worker.Analyze(rerunID, comment, serializedContext);
    
			if (transactionID == null)
				RunUpdateStats(tablename);
		}


		[WebMethod]
		public void BeginIdentifyAnalyzeAndResubmit(int rerunID, string transactionID, string serializedFilter,
																								string comment, string serializedContext)
		{
			mLogger.LogDebug("BeginIdentifyAnalyzeAndResubmit called");

			IdentifyDelegate worker = new IdentifyDelegate(IdentifyAnalyzeAndResubmitWork);
			IAsyncResult result = worker.BeginInvoke(rerunID, transactionID, serializedFilter, comment, serializedContext,
																							 new AsyncCallback(Callback), DateTime.Now);

			StoreReRunState(rerunID, result, worker);
		}

		[WebMethod]
		public void BeginIdentifyAnalyzeAndDelete(int rerunID, string transactionID, string serializedFilter,
			string comment, string serializedContext)
		{
			mLogger.LogDebug("BeginIdentifyAnalyzeAndDelete called");

			IdentifyDelegate worker = new IdentifyDelegate(IdentifyAnalyzeAndDeleteWork);
			IAsyncResult result = worker.BeginInvoke(rerunID, transactionID, serializedFilter, comment, serializedContext,
				new AsyncCallback(Callback), DateTime.Now);

			StoreReRunState(rerunID, result, worker);
		}

		private void IdentifyAnalyzeAndResubmitWork(int rerunID, string transactionID, string serializedFilter,
																								string comment, string serializedContext)
		{
			ReRunWorker worker = CreateWorker(transactionID);
      worker.Identify(rerunID, serializedFilter, comment, serializedContext);
      string tablename = worker.GetTableName(rerunID);
      if (transactionID == null)
        RunUpdateStats(tablename);

      worker.Analyze(rerunID, comment, serializedContext);
    
      if (transactionID == null)
        RunUpdateStats(tablename);

			worker.BackoutResubmit(rerunID, comment, serializedContext, serializedFilter);
		}



		private void IdentifyAnalyzeAndDeleteWork(int rerunID, string transactionID, string serializedFilter,
			string comment, string serializedContext)
		{
			ReRunWorker worker = CreateWorker(transactionID);
			worker.Identify(rerunID, serializedFilter, comment, serializedContext);
			string tablename = worker.GetTableName(rerunID);
			if (transactionID == null)
				RunUpdateStats(tablename);

			worker.Analyze(rerunID, comment, serializedContext);
    
			if (transactionID == null)
				RunUpdateStats(tablename);
 
			worker.BackoutDelete(rerunID, comment, serializedContext);
		}
	
		//begin 4.0 addition
		[WebMethod]
		public void BeginBackoutDelete(int rerunID, string transactionID, string comment, string serializedContext)
		{
			mLogger.LogDebug("BeginBackoutDelete called");

			BillingReRunDelegate worker = new BillingReRunDelegate(BackoutDeleteWork);
			IAsyncResult result = worker.BeginInvoke(rerunID, transactionID, comment, serializedContext,
				new AsyncCallback(Callback), DateTime.Now);
			StoreReRunState(rerunID, result, worker);
		}
		[WebMethod]
		public void BeginBackoutResubmit(int rerunID, string transactionID, string comment, string serializedContext)
		{
			mLogger.LogDebug("BeginBackoutResubmit called");

			BillingReRunDelegate worker = new BillingReRunDelegate(BackoutResubmitWork);
			IAsyncResult result = worker.BeginInvoke(rerunID, transactionID, comment, serializedContext,
				new AsyncCallback(Callback), DateTime.Now);
			StoreReRunState(rerunID, result, worker);
		}

		private void BackoutDeleteWork(int rerunID, string transactionID, string comment, string serializedContext)
		{
			ReRunWorker worker = CreateWorker(transactionID);
			worker.BackoutDelete(rerunID, comment, serializedContext);
		}

		private void BackoutResubmitWork(int rerunID, string transactionID, string comment, string serializedContext)
		{
			ReRunWorker worker = CreateWorker(transactionID);
			worker.BackoutResubmit(rerunID, comment, serializedContext);
		}
		//end 4.0 addition


		[WebMethod]
		public void BeginDelete(int rerunID, string transactionID, string comment, string serializedContext)
		{
			mLogger.LogDebug("BeginDelete called");

			BillingReRunDelegate worker = new BillingReRunDelegate(DeleteWork);
			IAsyncResult result = worker.BeginInvoke(rerunID, transactionID, comment, serializedContext,
																							 new AsyncCallback(Callback), DateTime.Now);
			StoreReRunState(rerunID, result, worker);
		}

		private void DeleteWork(int rerunID, string transactionID, string comment, string serializedContext)
		{
			ReRunWorker worker = CreateWorker(transactionID);
			worker.Delete(rerunID, comment, serializedContext);
		}

		[WebMethod]
		public void BeginAbandon(int rerunID, string transactionID, string comment, string serializedContext)
		{
			mLogger.LogDebug("BeginAbandon called");

			BillingReRunDelegate worker = new BillingReRunDelegate(AbandonWork);
			IAsyncResult result = worker.BeginInvoke(rerunID, transactionID, comment, serializedContext,
																							 new AsyncCallback(Callback), DateTime.Now);
			StoreReRunState(rerunID, result, worker);
		}

		private void AbandonWork(int rerunID, string transactionID, string comment, string serializedContext)
		{
			ReRunWorker worker = CreateWorker(transactionID);
			worker.Abandon(rerunID, comment, serializedContext);
		}

			
    private void RunUpdateStats(string rerunTableName)
    {
      string updateStatsQuery;
      PCExec.IMTDDLWriter writer = new PCExec.MTDDLWriterClass();
      using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\BillingRerun"))
      {
        //update statistics on the t_rerun_session_rerunid table
          using (IMTAdapterStatement stmt1 = conn.CreateAdapterStatement("queries\\BillingRerun", "__UPDATE_STATISTICS_ON_T_RERUN__"))
          {
              stmt1.AddParam("%%RERUN_TABLE_NAME%%", rerunTableName);
              updateStatsQuery = stmt1.Query;
          }
      }

      writer.ExecuteStatement(updateStatsQuery, @"Queries\BillingRerun");
      return;
    }
		private Logger mLogger = new Logger("[ReRunService]");
	}

  [Transaction(TransactionOption.Required, Timeout = 0, Isolation=TransactionIsolationLevel.Any)]
	[Guid("d23285f4-c9ff-4e7f-84ee-e9083f24ac94")]
	public class ReRunWorker : ServicedComponent
	{
		public MetraTech.Interop.PipelineTransaction.IMTTransaction Transaction;

	  public ReRunWorker()
	  {
		  //find out if dbqueues are being used.
		  MetraTech.PipelineInterop.PipelineConfig pc = new MetraTech.PipelineInterop.PipelineConfig();
		  mDBQueuesUsed = pc.IsDBQueue;
		  if (mDBQueuesUsed)
			mLogger.LogDebug("Using database queueing");
		  else
			mLogger.LogDebug("Using msmq for queueing");
	  }

		private IMTSessionContext DeserializeContext(string serializedContext)
		{
			mLogger.LogDebug("Serialized context: " + serializedContext);
			MetraTech.Interop.MTBillingReRun.IMTSessionContext context =
				(MetraTech.Interop.MTBillingReRun.IMTSessionContext)
				new MetraTech.Interop.MTAuth.MTSessionContext();
			context.FromXML(serializedContext);
			return context;
		}

		private IMTIdentificationFilter DeserializeFilter(string serializedFilter)
		{
			mLogger.LogDebug("Serialized filter: " + serializedFilter);
			byte [] rawBytes = System.Text.UTF8Encoding.UTF8.GetBytes(serializedFilter);
			MemoryStream memStream = new MemoryStream(rawBytes);
			SoapFormatter deserializer = new SoapFormatter();

			IdentificationFilter filter = (IdentificationFilter) deserializer.Deserialize(memStream);
			return filter;
		}

		[AutoComplete]
		public int Setup(string comment, string serializedContext)
		{
			IMTSessionContext context = DeserializeContext(serializedContext);
			int accID = context.AccountID;
	
	 		mLogger.LogDebug("Calling setup..");
			BillingRerun rerun = new BillingRerun();
			return rerun.Setup(accID, comment);
		}

		[AutoComplete]
		public string GetTableName(int rerunID)
		{
			BillingRerun rerun = new BillingRerun();
			return rerun.GetTableName(rerunID);
		}

		[AutoComplete]
		public void Identify(int rerunID, string serializedFilter, string comment, string serializedContext)
		{
			IMTSessionContext context = DeserializeContext(serializedContext);
			int accID = context.AccountID;

			IMTIdentificationFilter filter = DeserializeFilter(serializedFilter);

			mLogger.LogDebug("Calling identify ..");
			BillingRerun rerun = new BillingRerun();
			rerun.Identify(context, accID, rerunID, filter, comment);
		}


		[AutoComplete]
		public void Analyze(int rerunID, string comment, string serializedContext)
		{
			IMTSessionContext context = DeserializeContext(serializedContext);
			int accID = context.AccountID;

			mLogger.LogDebug("Calling analyze ..");
			BillingRerun rerun = new BillingRerun();
			rerun.Analyze(context, accID, rerunID, comment);
		}


	  [AutoComplete]
	  public void BackoutDelete(int rerunID, string comment, string serializedContext)
	  {
			IMTSessionContext context = DeserializeContext(serializedContext);
			int accID = context.AccountID;
			mLogger.LogDebug("Calling BackoutDelete ..");
			BillingRerun rerun = new BillingRerun();
			rerun.BackoutDelete(context, accID, rerunID, comment);
	  }

	  [AutoComplete]
	  public void BackoutResubmit(int rerunID, string comment, string serializedContext, string serializedFilter = null)
	  {
      CryptoManager crypto = new CryptoManager();
      string encryptedSerializedContext = crypto.Encrypt(CryptKeyClass.ServiceDefProp, serializedContext);

			IMTSessionContext context = DeserializeContext(serializedContext);
			int accID = context.AccountID;
			mLogger.LogDebug("Calling BackoutResubmit ..");
			BillingRerun rerun = new BillingRerun();

      if (serializedFilter != null)
      {
        IMTIdentificationFilter filter = DeserializeFilter(serializedFilter);
        rerun.AuditFailTransChangeStatus(accID, filter.SessionIDs, "Status Changed To ''Resubmitted''");
      }

			int result = rerun.BackoutResubmit(encryptedSerializedContext, context, accID, rerunID, comment);

	  }


	  [AutoComplete]
	  public void Delete(int rerunID, string comment, string serializedContext)
	  {
			mLogger.LogError("This method has been deprecated!");
		}

		[AutoComplete]
		public void Abandon(int rerunID, string comment, string serializedContext)
		{
			IMTSessionContext context = DeserializeContext(serializedContext);
			int accID = context.AccountID;

			mLogger.LogDebug("Calling Abandon ..");
			BillingRerun rerun = new BillingRerun();
			int result = rerun.Abandon(accID, rerunID, comment);
		}

		/*[AutoComplete]
		public void IdentifyAnalyzeAndResubmit(int rerunID, string serializedFilter, string comment, string serializedContext)
		{
			IMTSessionContext context = DeserializeContext(serializedContext);
			int accID = context.AccountID;
			IMTIdentificationFilter filter = DeserializeFilter(serializedFilter);
			
			if (!mDBQueuesUsed)
				throw new ApplicationException("MSMQ mode not supported!");

			BillingRerun rerun = new BillingRerun();
			rerun.Identify(context, accID, rerunID, filter, comment);
			rerun.Analyze(context, accID, rerunID, comment);
			BackoutResubmit(rerunID, comment, serializedContext);
		}*/

		private Logger mLogger = new Logger("[ReRunService]");
		private bool mDBQueuesUsed;
	}
}

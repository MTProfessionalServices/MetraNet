using System;
using System.Xml;
using System.Diagnostics;
using System.Runtime.InteropServices;
using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.Interop.MTAuth;
using MTAuth = MetraTech.Interop.MTAuth;
using MetraTech.Pipeline.ReRun;
using PipelineControl = MetraTech.Interop.PipelineControl;
using MetraTech.Interop.Rowset;
using BillingReRun = MetraTech.Interop.MTBillingReRun;
using BillingReRunClient = MetraTech.Pipeline.ReRun;
using ServerAccess = MetraTech.Interop.MTServerAccess;

// <xmlconfig>
//	<StoredProcs>
//		<CalculateInvoice>mtsp_InsertInvoice</CalculateInvoice>
//		<GenInvoiceNumbers>mtsp_GenerateInvoiceNumbers</GenInvoiceNumbers>
//	</StoredProcs>
//	<IsSample>N</IsSample>
// </xmlconfig>

//[assembly: AssemblyKeyFile("")]  //ask

namespace MetraTech.UsageServer.Adapters
{
	/// <summary>
	/// Invoice Adapter, used to generate invoices at EOP.
	/// </summary>
	public class FailedTransactionAdapter : MetraTech.UsageServer.IRecurringEventAdapter
	{
		// data
		private Logger mLogger = new Logger ("[FailedTransactionAdapter]");
		private string mConfigFile;
		private long mDelayDeletionDays;
        private TimeSpan mDelayPeriod = TimeSpan.FromDays(0);
		private long mDelayDeleteSuccessfulResubmitsDays = -1;

		//adapter capabilities
		public bool SupportsScheduledEvents { get { return true; }}
		public bool SupportsEndOfPeriodEvents { get { return false; }}
		public ReverseMode Reversibility {get { return ReverseMode.Custom; }}
		public bool AllowMultipleInstances { get { return false; }}
		
		public FailedTransactionAdapter()
		{
		}

		public void Initialize(string eventName, string configFile, MTAuth.IMTSessionContext context, bool limitedInit)
		{
			bool status;

			mLogger.LogDebug("Initializing Failed Transaction Adapter");
			mLogger.LogDebug("Using config file: {0}", configFile);
			mConfigFile = configFile;
			mLogger.LogDebug (mConfigFile);
			if (limitedInit)
				mLogger.LogDebug("Limited initialization requested");
			else
				mLogger.LogDebug("Full initialization requested");

			status = ReadConfigFile(configFile);
			if (status)
				mLogger.LogDebug("Initialize successful");
			else
				mLogger.LogError("Initialize failed, Could not read config file");
		}

		public string Execute(IRecurringEventRunContext context)
		{
			string detail;
			mLogger.LogDebug(String.Format("Executing Failed Transaction Adapter: Event type:{0} Run ID:{1} Start Date:{2} End Date:{3}",
							 context.EventType, context.RunID, context.StartDate, context.EndDate));

			using (IMTConnection conn = ConnectionManager.CreateConnection())
			{
				// Check if delete successful resubmits option is enabled. Find all failures in
				// t_failed_transaction that have records with only state 'R'. Look at the maximum
				// timestamp of record. If the difference between Now() and that time is greater
				// than the configured delay, delete all instances of this failed transaction.
				if (mDelayDeleteSuccessfulResubmitsDays != -1)
				{
					try
					{
						DateTime dt = MetraTech.MetraTime.Now;
						int DeletedCount = 0;
                        using (IMTCallableStatement stmt = conn.CreateCallableStatement("DelSuccessfullyResubmittedFT"))
                        {
                            stmt.AddParam("delay_time", MTParameterType.Integer, mDelayDeleteSuccessfulResubmitsDays);
                            stmt.AddParam("mt_now", MTParameterType.DateTime, MetraTech.MetraTime.Now);
                            stmt.AddOutputParam("DeletedCount", MTParameterType.Integer);
                            stmt.ExecuteNonQuery();
                            DeletedCount = (int)stmt.GetOutputValue("DeletedCount");
                        }

						if (DeletedCount > 0)
							detail = String.Format("Removed {0} successfully resubmitted failed transactions", DeletedCount);
						else
							detail = String.Format("No successfully resubmitted transactions to delete");

						context.RecordInfo(detail);
						mLogger.LogDebug(detail);
					}
					catch (Exception e)
					{
						string msg = "Unable to delete successfully resubmited failed transactions. ";
						mLogger.LogError(msg + e.ToString());
						throw new Exception(msg + e.Message);
					}
				}

	
				try
				{
					BillingReRun.IMTBillingReRun rerun = new BillingReRunClient.Client();

					// Log in as super user
					MTAuth.IMTSessionContext sessionContext = GetSuperUserContext();
					rerun.Login((BillingReRun.IMTSessionContext) sessionContext);

					// Create rerun table and set something in comment field.
					rerun.Setup("Delete failed transactions adapter execution");

					// Populate the rerun table.
                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\UsageServer\\Adapters\\FailedTransaction",
                        "__UPDATE_RERUN_TABLE_WITH_DISMISSED_FAILED_TRANSACTIONS__"))
                    {
                        stmt.AddParam("%%TABLE_NAME%%", rerun.TableName);
                        stmt.AddParam("%%DT_END%%", context.EndDate - mDelayPeriod);
                        stmt.ExecuteNonQuery();
                    }

					// Analize the failed transactions
					mLogger.LogDebug("Analyzing failed transactions..");
					context.RecordInfo("In analyze phase for failed transactions");
					rerun.Analyze("Analyze failed transactions from Delete Dismissed Failed Transaction Adapter");
					mLogger.LogDebug("Deleting failed transactions..");
					context.RecordInfo("In Backout Delete phase for failed transactions");
					rerun.BackoutDelete("Backing out and deleting dismissed failed transactions");
					mLogger.LogDebug("Completed Deleting Dismissed Failed Transactions.");
					context.RecordInfo("Completed Deleting Dismissed Failed Transactions.");
					rerun.Abandon("");
					detail = "Successfully deleted dismissed failed transactions";
				}
					
				catch (Exception e)
				{
					mLogger.LogError(e.ToString());
					throw new Exception(e.Message);
				}
		
			}

			return detail;
		}

		public string Reverse(IRecurringEventRunContext context)
		{
			string detail;

			detail = string.Format("Reverse Not Needed/Not Implemented");
			return detail;
		}

		public void Shutdown()
		{
			mLogger.LogDebug("Shutting down Failed Transaction Adapter");
		}
	
		private bool ReadConfigFile(string configFile)
		{
			MTXmlDocument doc = new MTXmlDocument();
			doc.Load(configFile);  
			mDelayDeletionDays = doc.GetNodeValueAsInt("/xmlconfig/DelayDeletionDays");
			mDelayPeriod = TimeSpan.FromDays(mDelayDeletionDays);

			// Optional configuration parameter.
			if (doc.SingleNodeExists("/xmlconfig/DeleteSuccessfulResubmitsAfter") != null)
				mDelayDeleteSuccessfulResubmitsDays = doc.GetNodeValueAsInt("/xmlconfig/DeleteSuccessfulResubmitsAfter");

			return true;
		}

		/// <summary>
		/// Conveniently log in as su.
		/// </summary>
		internal static IMTSessionContext GetSuperUserContext()
		{
			IMTLoginContext loginCtx = new MTLoginContextClass();
			
			ServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
			sa.Initialize();
			ServerAccess.IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
			string suName = accessData.UserName;
			string suPassword = accessData.Password;
			
			return loginCtx.Login(suName, "system_user", suPassword);
		}
	}
}

class ConsoleProgress : MetraTech.Interop.MTProgressExec.IMTProgress
{
  private string mProgressString;

  public void SetProgress(int aCurrentPos, int aMaxPos)
  {
    System.Console.WriteLine("progress: {0}/{1}: {2}%",
      aCurrentPos, aMaxPos,
      ((double) aCurrentPos / (double) aMaxPos) * 100.0);
  }

  public string ProgressString
  {
    get
    {
      return mProgressString;
    }
    set
    {
      System.Console.WriteLine("Progress string: {0}", value);
      mProgressString = value;
    }
  }

  public void Reset()
  {
    System.Console.WriteLine("Reset");
  }
}
namespace MetraTech.Pipeline.ReRun
{
	using MetraTech.Xml;
	using MetraTech.DataAccess;

	using System;
	using System.Xml;
	using System.Collections;
	using System.EnterpriseServices;
	using System.Runtime.InteropServices;

	[Guid("03ecdc86-7173-42b7-8426-45599d0cac27")]
  public interface IReRunTask
  {
    /// <summary>
    /// Given a list of sessions that have been identified for
    /// backout, mark any that cannot be backed out for some reason
    /// (for example they match a given service def/product view/priceable item)
    /// </summary>
    /// <param name = "context">Session context of user initiating rerun.</param>
    /// <param name = "rerunID">The key into t_rerun_sessions for all sessions
    /// that were identified for backout.</param>
    /// <param name="rerunTableName">The table in the database that would contain all the sessions identified and analyzed</param>
    void Analyze(MetraTech.Interop.MTBillingReRun.IMTSessionContext context,
								 int rerunID, string rerunTableName, bool useDBQueues);
 
    /// <summary>
    /// Perform custom compensation/back out actions for
    /// sessions being backed out.  This action is performed before
		/// the sessions are removed from t_acc_usage and t_pv_*.
    /// </summary>
    /// <param name = "context">Session context of user initiating rerun.</param>    /// <param name = "rerunID">The key into t_rerun_sessions for all sessions
    /// that are being backed out.</param>
    /// <param name="rerunTableName"The table in the database that would contain all the sessions identified and analyzed.
    void Backout(MetraTech.Interop.MTBillingReRun.IMTSessionContext context,
								 int rerunID, string rerunTableName, bool useDBQueues);
  }


  [Transaction(TransactionOption.Required, Timeout=0, Isolation=TransactionIsolationLevel.Any)]
	[Guid("f72e9319-5ff9-4483-bfb3-e412adabd147")]
	[ClassInterface(ClassInterfaceType.None)]
	public class AnalyzeIntervals : ServicedComponent, IReRunTask
	{
		public void Analyze(MetraTech.Interop.MTBillingReRun.IMTSessionContext context,
												int rerunID, string rerunTableName, bool useDBQueues)
		{

			using(IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\BillingRerun"))
			{

				Logger logger = new Logger("[BillingReRun]");
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__UPDATE_STATE_FROM_INTERVALS_V40__"))
                {
                    stmt.AddParam("%%TABLE_NAME%%", rerunTableName);
                    int rowsChanged = stmt.ExecuteNonQuery();
                    logger.LogDebug("{0} rows identified as being hardclosed for rerun {1}",
                        rowsChanged, rerunID);
                }
			}
		}

    public void Backout(MetraTech.Interop.MTBillingReRun.IMTSessionContext context,
												int rerunID, string rerunTableName, bool useDBQueues)
		{
			// nothing needs to be done here
		}
	}
		
  [Transaction(TransactionOption.Required, Timeout=0, Isolation=TransactionIsolationLevel.Any)]
	[Guid("6ceaf388-7c7d-4056-af75-7a8af992a67c")]
	[ClassInterface(ClassInterfaceType.None)]
	public class BackoutBatchStats :  ServicedComponent, IReRunTask
	{
		public void Analyze(MetraTech.Interop.MTBillingReRun.IMTSessionContext context,
												int rerunID, string rerunTableName, bool useDBQueues)
		{
			// nothing needs to be done here
		}

    public void Backout(MetraTech.Interop.MTBillingReRun.IMTSessionContext context,
												int rerunID, string rerunTableName, bool useDBQueues)
		{
			// decrement the completed counts
			using(IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\BillingRerun"))
			{
				Logger logger = new Logger("[BillingReRun]");

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__UPDATE_BATCH_COUNTS_ON_BACKOUT__"))
                {
                    stmt.AddParam("%%TABLE_NAME%%", rerunTableName);
                    int rowsChanged = stmt.ExecuteNonQuery();
                    logger.LogDebug("{0} batches updated for rerun {1}",
                        rowsChanged, rerunID);
                }
			}
	


			// TODO: account for backout of errors
		}
	}

  [Transaction(TransactionOption.Required, Timeout=0, Isolation=TransactionIsolationLevel.Any)]
  [Guid("ECAC19FD-060F-4f0b-8E75-B0D14B332FB0")]
  [ClassInterface(ClassInterfaceType.None)]
  public class AnalyzeSynchronousSessions : ServicedComponent, IReRunTask
  {
    public void Analyze(MetraTech.Interop.MTBillingReRun.IMTSessionContext context,
      int rerunID, string rerunTableName, bool useDBQueues)
    {

      using(IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\BillingRerun"))
      {

        Logger logger = new Logger("[BillingReRun]");
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\billingrerun", "__UPDATE_STATE_FOR_SYNC_METERING__"))
        {
            stmt.AddParam("%%TABLE_NAME%%", rerunTableName);
            int rowsChanged = stmt.ExecuteNonQuery();
            logger.LogDebug("{0} rows identified as being synchronously metered transactions for rerun {1}.  These will not be deleted or resubmitted.",
              rowsChanged, rerunID);
        }
      }
    }

    public void Backout(MetraTech.Interop.MTBillingReRun.IMTSessionContext context,
      int rerunID, string rerunTableName, bool useDBQueues)
    {
      // nothing needs to be done here
    }
  }
		
	internal class Tasks
	{
		public static IReRunTask LoadTask(string taskClass)
		{
			// try to create with .NET class name
			Type taskType = Type.GetType(taskClass, false);
			IReRunTask task;
			if (taskType != null)
			{
				task = (IReRunTask) Activator.CreateInstance(taskType);
				return task;
			}

			// class name didn't work, tries to create by ProgID
			taskType = Type.GetTypeFromProgID(taskClass, true);  // throws
			object obj = Activator.CreateInstance(taskType);
			task = (IReRunTask) obj;
			return task;
		}

		public static ArrayList AnalysisTasks
		{
			get
			{
				return GetTasks("analysis_tasks");
			}
		}

		public static ArrayList BackoutTasks
		{
			get
			{
				return GetTasks("backout_tasks");
			}
		}

		private static ArrayList GetTasks(string taskType)
		{
			string xpath = string.Format("/xmlconfig/{0}/task", taskType);
			ArrayList tasks = new ArrayList();
			foreach (string filename in MTXmlDocument.FindFilesInExtensions("config\\rerun\\rerun.xml"))
			{
				MTXmlDocument doc = new MTXmlDocument();
				doc.Load(filename);
				foreach (XmlNode node in doc.SelectNodes(xpath))
					tasks.Add(node.InnerText);
			}
			return tasks;
		}
	}
}

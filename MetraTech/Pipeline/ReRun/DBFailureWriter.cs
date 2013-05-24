using System;
using System.Collections;
using System.EnterpriseServices;
using System.Runtime.InteropServices;
using System.Collections.Specialized;

using MetraTech.DataAccess;
using MetraTech.Interop.PipelineControl;
using MetraTech.Interop.MTBillingReRun;

using BillingReRun = MetraTech.Interop.MTBillingReRun;
using PipelineTransaction = MetraTech.Interop.PipelineTransaction;
using Auth = MetraTech.Interop.MTAuth;


namespace MetraTech.Pipeline.ReRun
{
  using MetraTech.Interop.MTProgressExec;
  using RS=MetraTech.Interop.Rowset;
  using Auth = MetraTech.Interop.MTAuth;
  using MetraTech.Utils;

	/// <summary>
	/// DBFailureWriter represents a concrete IBulkFailureWriter
	/// used internally by the BulkFailedTransactions object when the 
	/// system is configured in DB queue mode. It uses billing rerun
	/// functionallity to resubmit and delete failed transactions.
	/// </summary>
  [ClassInterface(ClassInterfaceType.None)]
  [Guid("d9985bfc-690f-40d1-86f1-797d3db547e9")]
  public class DBFailureWriter : IBulkFailureWriter
  {
		

		/// <summary>
		/// The session context used to perform resubmits.
		/// Resubmitted failures will inherit this context for pipeline processing
		/// so it must have enough permissions to process the usage in question.
		/// </summary>
		public Auth.IMTSessionContext SessionContext 
		{
			get
			{ 
				return mSessionContext; 
			}
			set
			{
				mSessionContext = value;
			}
		}

		/// <summary>
		/// Resubmits a set of failed transactions.
		/// It is assumed that edits have already been saved via updates to t_svc tables.
		/// Failed transactions will be marked as 'R' and batch statistics are
		/// updated by Billing ReRun.
		/// </summary>

		public void ResubmitFailures(Logger logger, IMessageLabelSet failures, IMTProgress progress, Hashtable exceptions)
		{
		  string comment = String.Format("Resubmitting {0} failed transactions for processing...", failures.Count);
		  logger.LogInfo(comment);
		  int rerunID = 0;
			try
			{
				BillingReRun.IMTBillingReRun rerun = SetupBillingReRun(comment, ref rerunID);
				// adds the failure session UIDs to the identification filter
				BillingReRun.IMTIdentificationFilter filter = rerun.CreateFilter();
				foreach (string uid in failures)
					filter.AddSessionID(uid);

				// calling this method makes sure that on the server, the identify, analyze, backout and resubmit 
				// operations happen in one transaction.  This is important.
				rerun.IdentifyAnalyzeAndResubmit(filter, comment);

			}
			catch(Exception ex)
			{
				logger.LogError(ex.ToString());
				throw ex;
			}
			finally
			{
				AbandonRerun(rerunID, comment);
			}
		}

        /// <summary>
        /// Resubmits all failed transactions.
        /// It is assumed that edits have already been saved via updates to t_svc tables.
        /// Failed transactions will be marked as 'R' and batch statistics are
        /// updated by Billing ReRun.
        /// </summary>

        public int ResubmitAll(Logger logger)
        {
            string comment = "Resubmitting all failed transactions for processing...";
            logger.LogInfo(comment);
            int rerunID = 0;
            int totalSessions = 0;
            try
            {
                BillingReRun.IMTBillingReRun rerun = SetupBillingReRun(comment, ref rerunID);
                string rerunTable = rerun.TableName;

                using (IMTConnection aConn = ConnectionManager.CreateConnection())
                {
                    using (IMTAdapterStatement adptStmt = aConn.CreateAdapterStatement(@"Queries\BillingRerun", "__IDENTIFY_FAILED_USAGE__"))
                    {
                        adptStmt.AddParam("%%TABLE_NAME%%", rerunTable);
                        adptStmt.AddParam("%%STATE%%", "E");
                        adptStmt.AddParam("%%JOIN_CLAUSE%%", "");
                        adptStmt.AddParam("%%WHERE_CLAUSE%%", "");
                        adptStmt.ExecuteNonQuery();

                        rerun.Analyze("Analyzing all failed transactions for resubmit");
                        totalSessions = rerun.AnalyzeCount;
                        rerun.BackoutResubmit("Resubmitting all failed transactions.");
                    }
                }

                return totalSessions;

            }
            catch (Exception ex)
            {
                logger.LogError(ex.ToString());
                throw ex;
            }
            finally
            {
                AbandonRerun(rerunID, "Abandoning rerun");
            }
        }

	    /// <summary>
		/// Resubmits a set of failed transactions (same as above) except that
		/// the work is done asynchronously. A billing rerun ID is returned to 
		/// the caller which can be used to poll for status.
		/// </summary>
		public int ResubmitFailuresAsync(Logger logger, IMessageLabelSet failures)
		{
			int rerunID = 0;
			string comment = String.Format("Asynchronously resubmitting {0} failed transactions for processing...", failures.Count);
			logger.LogInfo(comment);

			BillingReRun.IMTBillingReRun rerun = SetupBillingReRun(comment, ref rerunID);

			// adds the failure session UIDs to the identification filter
			BillingReRun.IMTIdentificationFilter filter = rerun.CreateFilter();
			foreach (string uid in failures)
				filter.AddSessionID(uid);

			// kicks this trio of operations off asynchronously
			rerun.Synchronous = false;
			rerun.IdentifyAnalyzeAndResubmit(filter, comment);
			return rerun.ID;
		}

    /// <summary>
    /// Updates the status of a set of failed transactions.
    /// It will also add audit entries for the individual failed transactions
    /// </summary>
    /// 


	  public void UpdateFailureStatuses(Logger logger, MetraTech.Interop.PipelineControl.IMTCollection idsFailedTransaction, string newStatus, string reasonCode, string comment, Hashtable exceptions)
	  {
		  //pass through to the com+ component.
      DBFailureWriterServicedComp transactionalWriter = new DBFailureWriterServicedComp() { SessionContext = mSessionContext };
		  transactionalWriter.UpdateFailureStatuses(logger, idsFailedTransaction, newStatus, reasonCode, comment, exceptions, isOracle);
	  }

   
		/// <summary>
		/// Deletes a set of failed transactions. 
		/// Failed transactions are now physically deleted by Billing ReRun (in MSMQ mode
		/// they were logically deleted by being marked as 'D'). Batch statistics are also
		/// updated by Billing ReRun. 
		/// </summary>
		public void DeleteFailures(Logger logger, IMessageLabelSet failures, IMTProgress progress, Hashtable exceptions)
		{
			int rerunID = 0;
			string comment = String.Format("Deleting {0} failed transactions...", failures.Count);
			logger.LogInfo(comment);
			try
			{
				BillingReRun.IMTBillingReRun rerun = SetupBillingReRun(comment, ref rerunID);

				// adds the failure session UIDs to the identification filter
				BillingReRun.IMTIdentificationFilter filter = rerun.CreateFilter();
				foreach (string uid in failures)
					filter.AddSessionID(uid);

				rerun.IdentifyAnalyzeAndDelete(filter, comment);		
			}
			catch (Exception ex)
			{
				logger.LogError(ex.ToString());
				throw ex;
			}
			finally
			{
				 AbandonRerun(rerunID, comment); //CR:12998
			}
		}


	  
		/// <summary>
		/// Resubmits a set of suspended messages
		/// </summary>
		public void ResubmitSuspendedMessages(Logger logger, IMessageLabelSet messages)
		{
			if (messages.Count == 0)
				throw new ApplicationException("No message IDs where supplied to be resubmitted!");

			logger.LogInfo("Resubmitting {0} suspended message(s)...", messages.Count);

			DBFailureWriterServicedComp transactionalWriter = new DBFailureWriterServicedComp();
			transactionalWriter.ResubmitSuspendedMessages(messages, isOracle);
			
    		logger.LogInfo("{0} suspended message(s) successfully resubmitted", messages.Count);
		}

	
		/// <summary>
		/// Deletes a set of suspended messages. 
		/// Suspended message svc data is physically deleted. Message metadata remains in various tables.
		/// </summary>
		public void DeleteSuspendedMessages(Logger logger, IMessageLabelSet messages)
		{
			string comment = String.Format("Deleting {0} suspended messages...", messages.Count);
			logger.LogInfo(comment);
			int rerunID = 0;
			try 
			{
				DBFailureWriterServicedComp transactionalWriter = new DBFailureWriterServicedComp();
				transactionalWriter.SessionContext = SessionContext;
				rerunID= transactionalWriter.DeleteSuspendedMessages(messages, comment);
			}
			catch (Exception ex)
			{
				logger.LogError(ex.ToString());
				throw ex;
			}
			finally
			{
				AbandonRerun(rerunID, comment); //CR:12998
			}
		
		}

	
		private BillingReRun.IMTBillingReRun SetupBillingReRun(string comment, ref int rerunid)
		{
			BillingReRun.IMTBillingReRun rerun = new MetraTech.Pipeline.ReRun.Client();

			// logs in with the current session context or
			// with anonymous if none was supplied
			Auth.IMTSessionContext sessionContext;
			if (mSessionContext == null)
			{
				Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
				sessionContext = loginContext.LoginAnonymous();
			}
			else
				sessionContext = mSessionContext;

			rerun.Login((MetraTech.Interop.MTBillingReRun.IMTSessionContext) sessionContext);
			
			rerun.Setup(comment);
			rerunid = rerun.ID;
	
			return rerun;
		}


	  private void AbandonRerun(int rerunID, string comment)
	  {
		  BillingReRun.IMTBillingReRun abandonRerun = new MetraTech.Pipeline.ReRun.Client();
		  Auth.IMTSessionContext sessionContext;
		  if (mSessionContext == null)
		  {
			  Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
			  sessionContext = loginContext.LoginAnonymous();
		  }
		  else
			  sessionContext = mSessionContext;

		  abandonRerun.Login((MetraTech.Interop.MTBillingReRun.IMTSessionContext) sessionContext);
		  abandonRerun.ID = rerunID;
		  abandonRerun.Abandon(comment);
	  }

    public DBFailureWriter()
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        isOracle = conn.ConnectionInfo.IsOracle;
      }
    }

        bool isOracle;
		Auth.IMTSessionContext mSessionContext = null;
	}

}

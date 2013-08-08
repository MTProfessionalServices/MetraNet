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
using PCExec = MetraTech.Interop.MTProductCatalogExec;

namespace MetraTech.Pipeline.ReRun
{
	using Auth = MetraTech.Interop.MTAuth;
	using MetraTech.Utils;

	/// <summary>
	/// DBFailureWriter represents a concrete IBulkFailureWriter
	/// used internally by the BulkFailedTransactions object when the 
	/// system is configured in DB queue mode. It uses billing rerun
	/// functionallity to resubmit and delete failed transactions.
	/// </summary>
	[ClassInterface(ClassInterfaceType.None)]
	[Transaction(TransactionOption.Required, Timeout=0, Isolation=TransactionIsolationLevel.Any)]
	[Guid("E6406546-DAD0-4878-8DFF-B415EA47441B")]
	public class DBFailureWriterServicedComp : ServicedComponent
	{
		[AutoComplete]
		public void UpdateFailureStatuses(Logger aLogger, MetraTech.Interop.PipelineControl.IMTCollection idsFailedTransaction,
			string newStatus, string reasonCode, string comment, Hashtable exceptions, bool isOracle)
		{
			PCExec.IMTDDLWriter writer = new PCExec.MTDDLWriterClass();
			IMTConnection aConn = ConnectionManager.CreateConnection();
			try
			{
			  
				//Create a temp table.  In case of sql server, we actually create the temp table.
				//For oracle we are using a global temp table that has already been created.
				//But, we need to create a sequence for use in this transaction.  This
				//sequence needs to be deleted at the end.
                using (IMTAdapterStatement adptStmt = aConn.CreateAdapterStatement(@"Queries\Pipeline", "__FAILED_STATUS_BULK_CREATE_TEMP_TABLE__"))
                {
                    if (isOracle)
                    {
                        //this is a DDL statement.  Execute it outside of DTC.
                        string ddlQuery = adptStmt.Query;
                        writer.ExecuteStatement(ddlQuery, @"Queries\Pipeline");
                    }
                    else
                    {
                        adptStmt.ExecuteNonQuery();
                    }


                    string queryPopulate = isOracle ? "begin\n" : "";
                    int n = 0;
                    bool start = false;
                    foreach (string uidEncoded in idsFailedTransaction)
                    {
                        string uid = string.Format(isOracle ? "'{0}'" : "0x{0}",
                            MSIXUtils.DecodeUIDAsString(uidEncoded));

                        if (start)
                        {
                            queryPopulate = isOracle ? "begin\n" : "";
                            start = false;
                        }

                        if (isOracle)
                        {
                            queryPopulate += string.Format("insert into tmp_fail_txn_bulk_stat_upd(sequence, status, tx_FailureCompoundID) values({0}, 0, {1});\n",
                                "seq_tmp_fail_txn_bulk_stat_upd.NEXTVAL", uid);

                        }
                        else
                        {
                            queryPopulate += string.Format(
                                "insert into #tmp_fail_txn_bulk_stat_upd (status, tx_FailureCompoundID) values(0, {0});\n",
                                uid);
                        }


                        //do 100 inserts at a time
                        if (++n % 100 == 0)
                        {
                            if (isOracle)
                                queryPopulate += "end;\n";
                            using (IMTStatement stmt1 = aConn.CreateStatement(queryPopulate))
                            {
                                stmt1.ExecuteNonQuery();
                            }

                            queryPopulate = string.Empty;
                            start = true;
                        }
                    }

                    //Do the remaining inserts if any
                    if (queryPopulate != string.Empty)
                    {
                        if (isOracle)
                            queryPopulate += "end;\n";
                        using (IMTStatement stmt1 = aConn.CreateStatement(queryPopulate))
                        {
                            stmt1.ExecuteNonQuery();
                        }
                    }

                    adptStmt.ClearQuery();
                    adptStmt.QueryTag = "__FAILED_STATUS_BULK_VALIDATE_REQUEST__";
                    adptStmt.ExecuteNonQuery();

                    //Issue update statement to t_failed_transaction table
                    adptStmt.ClearQuery();
                    if ((reasonCode == null) || (reasonCode.Length == 0))
                    {
                        adptStmt.QueryTag = "__FAILED_STATUS_BULK_UPDATE_FROM_BULK_TABLE__";
                        adptStmt.AddParam("%%NEWSTATUS%%", newStatus, true);
                    }
                    else
                    {
                        adptStmt.QueryTag = "__FAILED_STATUS_BULK_UPDATE_WITH_REASON_CODE_FROM_BULK_TABLE__";
                        adptStmt.AddParam("%%NEWSTATUS%%", newStatus, true);
                        adptStmt.AddParam("%%NEWREASONCODE%%", reasonCode, true);
                    }
                    adptStmt.ExecuteNonQuery();

                    //Audit status change
                    int iUpdateCount = n;

                    IIdGenerator2 idAuditGenerator = new IdGenerator("id_audit", iUpdateCount);

                    string auditDetails;
                    string newStatusName; //TODO: Get english string for status to use in details
                    switch (newStatus)
                    {
                        case "N": newStatusName = "Open"; break;
                        case "I": newStatusName = "Under Investigation"; break;
                        case "C": newStatusName = "Corrected - Pending Resubmit"; break;
                        case "P": newStatusName = "Dismissed"; break;
                        case "R": newStatusName = "Resubmitted"; break;
                        case "D": newStatusName = "Deleted"; break;
                        default: newStatusName = "Unknown Status"; break;
                    }
                    auditDetails = "Status Changed To '" + newStatusName + "'";

                    if ((newStatus == "P" || newStatus == "I") && reasonCode.Length > 0)
                    {
                        auditDetails += " : " + reasonCode;
                    }
                    auditDetails += " : " + comment;

                    adptStmt.ClearQuery();
                    adptStmt.QueryTag = "__FAILED_STATUS_BULK_AUDIT_FROM_BULK_TABLE__";
                    adptStmt.AddParam("%%AUDITSTARTID%%", idAuditGenerator.NextId, false);
                    int iUserAccountId = 0;
                    if (mSessionContext != null) { iUserAccountId = mSessionContext.AccountID; };
                    adptStmt.AddParam("%%USERID%%", iUserAccountId, false);
                    adptStmt.AddParam("%%AUDITDETAILS%%", auditDetails, false);
                    adptStmt.ExecuteNonQuery();
                    //ESR-4574 MetraControl- correct and resubmit failed transactions- dismissed count increases and status goes to failed
                    //running update of the t_batch counters
                    string failureCompoundId = string.Format(isOracle ? "'{0}'" : "0x{0}",
                        MSIXUtils.DecodeUIDAsString(idsFailedTransaction[1].ToString()));//indexation starts from 1

                    adptStmt.ClearQuery();
                    adptStmt.QueryTag = "__UPDATE_T_BATCH_COUNTERS__";
                    adptStmt.AddParam("%%FAILURECOMPOUNDID%%", failureCompoundId, false);
                    adptStmt.ExecuteNonQuery();
                    //end of ESR-4574  

                    adptStmt.ClearQuery();
                    adptStmt.QueryTag = "__FAILED_STATUS_BULK_GET_ERRORS_FROM_TEMP_TABLE__";
                    using (IMTDataReader errorRowset = adptStmt.ExecuteReader())
                    {
                        while (errorRowset.Read())
                        {
                            string uidEncoded = MSIXUtils.EncodeUID((byte[])errorRowset.GetBytes("tx_FailureCompoundID"));
                            exceptions[uidEncoded] = (int)errorRowset.GetInt32("status");
                        }
                        errorRowset.Close();
                    }
                }
			}
			finally
			{
				//for oracle, we are dropping the sequence that was created earlier.
				if (isOracle)
				{
					//this is a DDL statement.  Execute it outside of DTC.
                    using (IMTAdapterStatement aStmt = aConn.CreateAdapterStatement(@"Queries\Pipeline", "__FAILED_STATUS_BULK_DROP_TEMP_TABLE__"))
                    {
                        string dropSequenceQuery = aStmt.Query;
                        writer.ExecuteStatement(dropSequenceQuery, @"Queries\Pipeline");
                    }
				}
				if (aConn != null)
					aConn.Dispose();
			}
		}

		[AutoComplete]
		public void ResubmitSuspendedMessages(IMessageLabelSet messages, bool isOracle)
		{
			//maybe, we will need to do special handling for oracle someday.
			int count;
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\Pipeline",
                    "__RESUBMIT_SUSPENDED_MESSAGES__"))
                {
                    stmt.AddParam("%%SUSPENDED_DURATION%%", PipelineConfig.SuspendedDuration);
                    stmt.AddParam("%%MESSAGE_ID_LIST%%", GenerateMessageIDList(messages));
                    count = stmt.ExecuteNonQuery();
                }
            }

			// updates the original messages so that they appear new again
			// the router will see them as routable
			if (count != messages.Count)
				throw new ApplicationException("Suspended messages could not successfully be resubmitted. " +
					"Perhaps they aren't really suspended?");
		}


		private string GenerateMessageIDList(IMessageLabelSet messages)
		{
			string messageIDList = null;
			bool firstTime = true;
			foreach (string messageID in messages)
			{
				// validates the message ID is well-formed (CR12415)
				try
				{
					Int32.Parse(messageID);
				} 
				catch (Exception)
				{
					throw new ApplicationException("Invalid message ID! Message ID must be an integral value.");
				}

				if (!firstTime)
					messageIDList += ", ";
				else
					firstTime = false;
				messageIDList += messageID;
			}

			return messageIDList;
		}

		[AutoComplete]
		public int DeleteSuspendedMessages(IMessageLabelSet messages, string comment)
		{
			int rerunID = 0;

			BillingReRun.IMTBillingReRun rerun = new MetraTech.Pipeline.ReRun.Client();
			rerun.TransactionID = GetTransactionCookieFromContext();
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
			rerunID = rerun.ID;

			int count;
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"Queries\Pipeline",
                    "__POPULATE_RERUN_TABLE_FOR_SUSPENDED_MESSAGE_DELETION__"))
                {
                    stmt.AddParam("%%RERUN_TABLE%%", rerun.TableName);
                    stmt.AddParam("%%SUSPENDED_DURATION%%", PipelineConfig.SuspendedDuration);
                    stmt.AddParam("%%MESSAGE_ID_LIST%%", GenerateMessageIDList(messages));
                    count = stmt.ExecuteNonQuery();
                }
            }

			// each message should have at least one session
			// if it doesn't, something is wrong
			if (count < messages.Count)
				throw new ApplicationException("Suspended messages could not successfully be deleted. " +
					"Perhaps they aren't really suspended?");
		
			// thank god for billing rerun - it does all the hard work for us!
			rerun.Analyze(comment);
			// TODO: validate that Analyze did not drop any UIDs
			rerun.BackoutDelete(comment);
			return rerunID;
		}


		// exports a DTC transaction cookie from the current COM+ context
		private string GetTransactionCookieFromContext()
		{
			ITransaction contextTxn = (ITransaction) ContextUtil.Transaction;

			PipelineTransaction.IMTTransaction txnWrapper = new PipelineTransaction.CMTTransactionClass();
			// false means no ownership, otherwise it'll rollback when MTTransaction object is destroyed
			txnWrapper.SetTransaction(contextTxn, false);

			PipelineTransaction.IMTWhereaboutsManager whereAbouts = new PipelineTransaction.CMTWhereaboutsManagerClass();
			string cookie = whereAbouts.GetLocalWhereabouts();

			return txnWrapper.Export(cookie);
		}

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

		Auth.IMTSessionContext mSessionContext = null;
	}
}
	
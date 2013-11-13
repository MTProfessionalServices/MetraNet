using System;
using System.Collections;
using System.EnterpriseServices;
using System.Runtime.InteropServices;
using MetraTech.DataAccess;
using BillingReRun = MetraTech.Interop.MTBillingReRun;
using PipelineTransaction = MetraTech.Interop.PipelineTransaction;
using Auth = MetraTech.Interop.MTAuth;
using PCExec = MetraTech.Interop.MTProductCatalogExec;

namespace MetraTech.Pipeline.ReRun
{
  using Auth = Interop.MTAuth;
  using Utils;

  /// <summary>
  /// DBFailureWriter represents a concrete IBulkFailureWriter
  /// used internally by the BulkFailedTransactions object when the 
  /// system is configured in DB queue mode. It uses billing rerun
  /// functionallity to resubmit and delete failed transactions.
  /// </summary>
  [ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Required, Timeout = 0, Isolation = TransactionIsolationLevel.Any)]
  [Guid("E6406546-DAD0-4878-8DFF-B415EA47441B")]
  public class DBFailureWriterServicedComp : ServicedComponent
  {
    [AutoComplete]
    public void UpdateFailureStatuses(
      Logger aLogger,
      Interop.PipelineControl.IMTCollection idsFailedTransaction,
      string newStatus,
      string reasonCode,
      string comment,
      Hashtable exceptions,
      bool isOracle)
    {
      PCExec.IMTDDLWriter writer = new PCExec.MTDDLWriterClass();
      using (var aConn = ConnectionManager.CreateConnection())
        try
        {
          //Create a temp table.  In case of sql server, we actually create the temp table.
          //For oracle we are using a global temp table that has already been created.
          //But, we need to create a sequence for use in this transaction.  This
          //sequence needs to be deleted at the end.
          using (
            var adptStmt = aConn.CreateAdapterStatement(@"Queries\Pipeline", "__FAILED_STATUS_BULK_CREATE_TEMP_TABLE__")
            )
          {
            if (isOracle)
            {
              //this is a DDL statement. Execute it outside of DTC.
              writer.ExecuteStatement(adptStmt.Query, @"Queries\Pipeline");
            }
            else
            {
              adptStmt.ExecuteNonQuery();
            }

            var queryPopulate = isOracle ? "begin\n" : "";
            var n = 0;
            var start = false;
            foreach (string uidEncoded in idsFailedTransaction)
            {
              var uid = string.Format(isOracle ? "'{0}'" : "0x{0}",
                                      MSIXUtils.DecodeUIDAsString(uidEncoded));

              if (start)
              {
                queryPopulate = isOracle ? "begin\n" : "";
                start = false;
              }

              if (isOracle)
              {
                queryPopulate +=
                  string.Format(
                    "insert into tmp_fail_txn_bulk_stat_upd(sequence, status, tx_FailureCompoundID) values({0}, 0, {1});\n",
                    "seq_tmp_fail_txn_bulk_stat_upd.NEXTVAL", uid);

              }
              else
              {
                queryPopulate += string.Format(
                  "insert into #tmp_fail_txn_bulk_stat_upd (status, tx_FailureCompoundID) values(0, {0});\n",
                  uid);
              }


              //do 100 inserts at a time
              if (++n%100 == 0)
              {
                if (isOracle)
                  queryPopulate += "end;\n";
                using (var stmt1 = aConn.CreateStatement(queryPopulate))
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
              using (var stmt1 = aConn.CreateStatement(queryPopulate))
              {
                stmt1.ExecuteNonQuery();
              }
            }

            adptStmt.ClearQuery();
            adptStmt.QueryTag = "__FAILED_STATUS_BULK_VALIDATE_REQUEST__";
            adptStmt.ExecuteNonQuery();

            //Issue update statement to t_failed_transaction table
            adptStmt.ClearQuery();
            if (string.IsNullOrEmpty(reasonCode))
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
            var iUpdateCount = n;

            IIdGenerator2 idAuditGenerator = new IdGenerator("id_audit", iUpdateCount);

            string newStatusName; //TODO: Get english string for status to use in details
            switch (newStatus)
            {
              case "N":
                newStatusName = "Open";
                break;
              case "I":
                newStatusName = "Under Investigation";
                break;
              case "C":
                newStatusName = "Corrected - Pending Resubmit";
                break;
              case "P":
                newStatusName = "Dismissed";
                break;
              case "R":
                newStatusName = "Resubmitted";
                break;
              case "D":
                newStatusName = "Deleted";
                break;
              default:
                newStatusName = "Unknown Status";
                break;
            }
            var auditDetails = "Status Changed To '" + newStatusName + "'";

            if ((newStatus == "P" || newStatus == "I") && !string.IsNullOrEmpty(reasonCode))
            {
              auditDetails += " : " + reasonCode;
            }
            auditDetails += " : " + comment;

            adptStmt.ClearQuery();
            adptStmt.QueryTag = "__FAILED_STATUS_BULK_AUDIT_FROM_BULK_TABLE__";
            adptStmt.AddParam("%%AUDITSTARTID%%", idAuditGenerator.NextId, false);
            var iUserAccountId = 0;
            if (_mSessionContext != null)
            {
              iUserAccountId = _mSessionContext.AccountID;
            }

            adptStmt.AddParam("%%USERID%%", iUserAccountId, false);
            adptStmt.AddParam("%%AUDITDETAILS%%", auditDetails, false);
            adptStmt.ExecuteNonQuery();
            //ESR-4574 MetraControl- correct and resubmit failed transactions- dismissed count increases and status goes to failed
            //running update of the t_batch counters
            var failureCompoundId = string.Format(isOracle ? "'{0}'" : "0x{0}",
                                                  MSIXUtils.DecodeUIDAsString(idsFailedTransaction[1].ToString())); //index starts from 1

            adptStmt.ClearQuery();
            adptStmt.QueryTag = "__UPDATE_T_BATCH_COUNTERS__";
            adptStmt.AddParam("%%FAILURECOMPOUNDID%%", failureCompoundId, isOracle);
            adptStmt.ExecuteNonQuery();
            //end of ESR-4574  

            adptStmt.ClearQuery();
            adptStmt.QueryTag = "__FAILED_STATUS_BULK_GET_ERRORS_FROM_TEMP_TABLE__";
            using (var errorRowset = adptStmt.ExecuteReader())
            {
              while (errorRowset.Read())
              {
                var uidEncoded = MSIXUtils.EncodeUID(errorRowset.GetBytes("tx_FailureCompoundID"));
                exceptions[uidEncoded] = errorRowset.GetInt32("status");
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
            using (var aStmt = aConn.CreateAdapterStatement(@"Queries\Pipeline", "__FAILED_STATUS_BULK_DROP_TEMP_TABLE__"))
            {
              var dropSequenceQuery = aStmt.Query;
              writer.ExecuteStatement(dropSequenceQuery, @"Queries\Pipeline");
            }
          }
        }
    }

    [AutoComplete]
    public void ResubmitSuspendedMessages(IMessageLabelSet messages, bool isOracle)
    {
      //maybe, we will need to do special handling for oracle someday.
      int count;
      using (var conn = ConnectionManager.CreateConnection())
      using (var stmt = conn.CreateAdapterStatement(@"Queries\Pipeline",
                                                    "__RESUBMIT_SUSPENDED_MESSAGES__"))
      {
        stmt.AddParam("%%SUSPENDED_DURATION%%", PipelineConfig.SuspendedDuration);
        stmt.AddParam("%%MESSAGE_ID_LIST%%", GenerateMessageIdList(messages));
        count = stmt.ExecuteNonQuery();
      }

      // updates the original messages so that they appear new again
      // the router will see them as routable
      if (count != messages.Count)
        throw new ApplicationException("Suspended messages could not successfully be resubmitted. " +
                                       "Perhaps they aren't really suspended?");
    }

    private static string GenerateMessageIdList(IMessageLabelSet messages)
    {
      string messageIdList = null;
      var firstTime = true;
      foreach (string messageId in messages)
      {
        // validates the message ID is well-formed (CR12415)
        int intRes;
        if (int.TryParse(messageId, out intRes))
          throw new ApplicationException("Invalid message ID! Message ID must be an integral value.");

        if (!firstTime)
          messageIdList += ", ";
        else
          firstTime = false;
        messageIdList += messageId;
      }

      return messageIdList;
    }

    [AutoComplete]
    public int DeleteSuspendedMessages(IMessageLabelSet messages, string comment)
    {
      BillingReRun.IMTBillingReRun rerun = new Client();
      rerun.TransactionID = GetTransactionCookieFromContext();
      Auth.IMTSessionContext sessionContext;
      if (_mSessionContext == null)
      {
        Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
        sessionContext = loginContext.LoginAnonymous();
      }
      else
        sessionContext = _mSessionContext;

      rerun.Login((Interop.MTBillingReRun.IMTSessionContext) sessionContext);

      rerun.Setup(comment);
      var rerunId = rerun.ID;

      int count;
      using (var conn = ConnectionManager.CreateConnection())
      using (var stmt = conn.CreateAdapterStatement(@"Queries\Pipeline",
                                                    "__POPULATE_RERUN_TABLE_FOR_SUSPENDED_MESSAGE_DELETION__"))
      {
        stmt.AddParam("%%RERUN_TABLE%%", rerun.TableName);
        stmt.AddParam("%%SUSPENDED_DURATION%%", PipelineConfig.SuspendedDuration);
        stmt.AddParam("%%MESSAGE_ID_LIST%%", GenerateMessageIdList(messages));
        count = stmt.ExecuteNonQuery();
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
      return rerunId;
    }

    // exports a DTC transaction cookie from the current COM+ context
    private static string GetTransactionCookieFromContext()
    {
      var contextTxn = (ITransaction) ContextUtil.Transaction;

      PipelineTransaction.IMTTransaction txnWrapper = new PipelineTransaction.CMTTransactionClass();
      // false means no ownership, otherwise it'll rollback when MTTransaction object is destroyed
      txnWrapper.SetTransaction(contextTxn, false);

      PipelineTransaction.IMTWhereaboutsManager whereAbouts = new PipelineTransaction.CMTWhereaboutsManagerClass();
      var cookie = whereAbouts.GetLocalWhereabouts();

      return txnWrapper.Export(cookie);
    }

    public Auth.IMTSessionContext SessionContext
    {
      get { return _mSessionContext; }
      set { _mSessionContext = value; }
    }

    private Auth.IMTSessionContext _mSessionContext;
  }
}
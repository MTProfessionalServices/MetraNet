using System;
using System.EnterpriseServices;
using System.Collections;
using System.Runtime.InteropServices;

using RS =  MetraTech.Interop.Rowset;
using MetraTech.Interop.MeterRowset;
using MetraTech.DataAccess;
using MetraTech.Interop.MTServerAccess;
using TRX = MetraTech.Interop.PipelineTransaction;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.DataAccess.MaterializedViews;
using MetraTech.Collections;

namespace  MetraTech.Adjustments
{
  /// <summary>
  /// Summary description for AdjustmentTransactionWriter.
  /// </summary>
  /// 
  [Guid("5b2bf19d-7f40-4cb3-89c1-77e5ed721cab")]
  public interface IAdjustmentTransactionWriter
  {
	void UpdateState(IMTSessionContext aCTX, MetraTech.Interop.MTProductCatalog.IMTCollection qualifiedsessions, AdjustmentStatus final, object aProgressObject);
    
	void Approve(IMTSessionContext aCTX, MetraTech.Interop.MTProductCatalog.IMTCollection qualifiedsessions, object aProgressObject);
    
	RS.IMTRowSet SaveOrphans(IAdjustmentTransactionSet aSet, AdjustmentStatus aStatus, object aProgressObject);
  }

 
  [ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
  [Guid("fb619640-c88c-4bd8-a588-010d9c545ef3")]
  public class AdjustmentTransactionWriter : ServicedComponent,IAdjustmentTransactionWriter
  {
    // Materialized View manager object.
    private Manager mMaterializedViewMgr = null;
	private string mBaseTableName;
	private string mDeltaInsertTableName;
	private string mDeltaDeleteTableName;

	// Log object
	private Logger mLogger = null;

    // looks like this is necessary for COM+?
    public AdjustmentTransactionWriter()
	{
		mLogger = new Logger("[AdjustmentTransactionWriter]");

		// INitialize materialized view manager.
		mMaterializedViewMgr = new Manager();
		mMaterializedViewMgr.Initialize();

		// Set delta table name needed by materialized view framework.
		mBaseTableName = "t_adjustment_transaction";

		// Provide bindings to trnasaction delta tables.
		if (mMaterializedViewMgr.IsMetraViewSupportEnabled)
		{
			mDeltaInsertTableName = mMaterializedViewMgr.GenerateDeltaInsertTableName(mBaseTableName);
			mDeltaDeleteTableName = mMaterializedViewMgr.GenerateDeltaDeleteTableName(mBaseTableName);
			mMaterializedViewMgr.AddInsertBinding(mBaseTableName, mDeltaInsertTableName);
			mMaterializedViewMgr.AddDeleteBinding(mBaseTableName, mDeltaDeleteTableName);
		}
	}

	[AutoComplete]
	internal string GetSessionIDList
						(IMTServicedConnection conn,
						 MetraTech.Interop.MTProductCatalog.IMTCollection qualifiedsessions,
						 bool bCheckOpenIntervals)
	{
		// Populate backout table with session id's.
		string sesslist = String.Empty;
		int lIntervalID;
		ArrayList evaluatedIntervals = new ArrayList();
		foreach(IAdjustmentTransaction trx in qualifiedsessions)
		{
			// Now, evaluate that all payers have open intervals. Otherwise
			// it would fail in the query because GetOpenInterval will return NULL
			if (bCheckOpenIntervals)
			{
				lIntervalID = trx.IntervalID;
				if (!evaluatedIntervals.Contains(lIntervalID))
					evaluatedIntervals.Add(Utils.GetOpenInterval(trx.PayerAccountID));
			}

			// Add to where clause for delta table insert.
			if (sesslist.Length > 0)
				sesslist += ",";

			sesslist += trx.SessionID;
		}

		// Populate delta delete table.
		if (sesslist.Length > 0)
		{
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments",
                                                                   "__POPULATE_ADJUSTMENT_DELTA_TABLE__"))
            {
                stmt.AddParam("%%DELTA_TABLE_NAME%%", mDeltaDeleteTableName);
                stmt.AddParam("%%TABLE_NAME%%", mBaseTableName);
                stmt.AddParam("%%WHERE_CLAUSE%%", System.String.Format("WHERE id_sess in ({0}) and c_status != 'D'", sesslist), false);
                mLogger.LogDebug("Query used to populate delta delete adjustment transaction table: " + stmt.Query);
                stmt.ExecuteNonQuery();
            }
		}

		return sesslist;
	}

	[AutoComplete]
	internal void UpdateMaterializedViews(IMTServicedConnection conn, string columnname, string idlist)
	{
		// Populate delta insert table.
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments",
                                                               "__POPULATE_ADJUSTMENT_DELTA_TABLE__"))
        {
            stmt.AddParam("%%DELTA_TABLE_NAME%%", mDeltaInsertTableName);
            stmt.AddParam("%%TABLE_NAME%%", mBaseTableName);
            stmt.AddParam("%%WHERE_CLAUSE%%", System.String.Format("WHERE {0} in ({1})", columnname, idlist), false);
            mLogger.LogDebug("Query used to populate delta insert adjustment transaction table: " + stmt.Query);
            stmt.ExecuteNonQuery();
        }

		// Prepare trigger list.
		string[] Triggers = new string[1];
		Triggers[0] = mBaseTableName;

		// Get queries to execute.
		string QueriesToExecute = mMaterializedViewMgr.GetMaterializedViewUpdateQuery(Triggers);
		if (QueriesToExecute != null)
		{
			// Execute the queries.
            using (IMTStatement stmtNQ = conn.CreateStatement(QueriesToExecute))
            {
                stmtNQ.ExecuteNonQuery();
            }
		}
	}

    [AutoComplete]
    public void UpdateState(IMTSessionContext aCTX, MetraTech.Interop.MTProductCatalog.IMTCollection qualifiedsessions, AdjustmentStatus final, object aProgressObject)
    {
		using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
		{
			string NewStatus = TypeConverter.ConvertAdjustmentStatus(final);

			// Prepare for materialized view update.
			string sesslist = String.Empty;
			if (mMaterializedViewMgr.IsMetraViewSupportEnabled)
				sesslist = GetSessionIDList(conn, qualifiedsessions, false);

			// Update adjustment transaction.
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__UPDATE_ADJUSTMENT_STATUS__"))
            {
                stmt.AddParam("%%PREDICATE%%",
                    Utils.CreateTransactionListWherePredicate(
                    (MetraTech.Interop.MTProductCatalog.IMTCollection)qualifiedsessions, false),
                    false);
                stmt.AddParam("%%STATUS%%", NewStatus, false);
                stmt.ExecuteNonQuery();
            }

			// Update materialized views.
			if (mMaterializedViewMgr.IsMetraViewSupportEnabled && sesslist.Length > 0)
			{
				UpdateMaterializedViews(conn, "id_sess", sesslist);

				// Truncate the delta table.
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__TRUNCATE_ADJUSTMENT_DELTA_TABLE__"))
                {
                    stmt.AddParam("%%DELTA_TABLE_NAME%%", mDeltaInsertTableName);
                    stmt.ExecuteNonQuery();
                }

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__TRUNCATE_ADJUSTMENT_DELTA_TABLE__"))
                {
                    stmt.AddParam("%%DELTA_TABLE_NAME%%", mDeltaDeleteTableName);
                    stmt.ExecuteNonQuery();
                }
			}
		}
	}

	private void UpdateOrphanState(IMTSessionContext aCTX, MetraTech.Interop.MTProductCatalog.IMTCollection qualifiedsessions, AdjustmentStatus final, object aProgressObject)
	{
		using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
		{
			string NewStatus = TypeConverter.ConvertAdjustmentStatus(final);

			// Update adjustment transaction.
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__UPDATE_ADJUSTMENT_STATUS__"))
            {
                stmt.AddParam("%%PREDICATE%%",
                    Utils.CreateAdjustmentIDListWherePredicate(
                    (MetraTech.Interop.MTProductCatalog.IMTCollection)qualifiedsessions),
                    false);
                stmt.AddParam("%%STATUS%%", NewStatus, false);
                stmt.ExecuteNonQuery();
            }
		}
	}
    
    [AutoComplete]
    public void Approve(IMTSessionContext aCTX, MetraTech.Interop.MTProductCatalog.IMTCollection qualifiedsessions, object aProgressObject)
    {
		using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
		{
			// Prepare for materialized view update.
			string sesslist = String.Empty;
			if (mMaterializedViewMgr.IsMetraViewSupportEnabled)
				sesslist = GetSessionIDList(conn, qualifiedsessions, true);

			// If Materialized views is disabled we need to run the check,
			// Otherwise we'll run the check while prepping for MV.
			else
			{
				// Now, evaluate that all payers have open intervals. Otherwise
				// it would fail in the query because GetOpenInterval will return NULL
				int lIntervalID;
				ArrayList evaluatedIntervals = new ArrayList();
				foreach(IAdjustmentTransaction trx in qualifiedsessions)
				{
					lIntervalID = trx.IntervalID;
					if (!evaluatedIntervals.Contains(lIntervalID))
						evaluatedIntervals.Add(Utils.GetOpenInterval(trx.PayerAccountID));
				}
			}

			// Update the records.
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__APPROVE_ADJUSTMENTS__"))
            {
                stmt.AddParam("%%PREDICATE%%",
                    Utils.CreateTransactionListWherePredicate(
                    (MetraTech.Interop.MTProductCatalog.IMTCollection)qualifiedsessions, false),
                    false);
                stmt.ExecuteNonQuery();
            }

			// Update materialized views.
			if (mMaterializedViewMgr.IsMetraViewSupportEnabled && sesslist.Length > 0)
				UpdateMaterializedViews(conn, "id_sess", sesslist);
		}
    }

    [AutoComplete]
    public RS.IMTRowSet SaveOrphans(
                                    IAdjustmentTransactionSet aSet, 
                                    AdjustmentStatus aStatus, 
                                    object aProgressObject)
    {
      string sStatus = (aStatus == AdjustmentStatus.APPROVED) ? "APPROVED" : "DENIED";
      RS.IMTSQLRowset warnings = Utils.CreateWarningsRowset();

      IBatch batch = (MetraTech.Interop.MeterRowset.IBatch)AdjustmentCache.GetInstance().GetMeter().CreateBatch();
      batch.NameSpace = "Metratech.Adjustments";
      batch.Name = String.Format("Convert {0} Orphan Adjustments to miscellaneous ({1})",
        aSet.GetAdjustmentTransactions().Count, MetraTech.MetraTime.Now);
      batch.ExpectedCount = aSet.GetAdjustmentTransactions().Count;
      batch.Source = ToString();
      batch.SequenceNumber = "1";
      batch.SourceCreationDate = MetraTech.MetraTime.Now;
      batch.Save();
      
      ISessionSet sset = batch.CreateSessionSet();
      sset.SessionContext = aSet.GetSessionContext().ToXML();

      TRX.IMTWhereaboutsManager whereaboutsmgr = new TRX.CMTWhereaboutsManagerClass();
      string cookie = whereaboutsmgr.GetWhereaboutsForServer("AdjustmentsServer");

      ITransaction oTransaction = (ITransaction)ContextUtil.Transaction;
      TRX.IMTTransaction oMTTransaction = new TRX.CMTTransactionClass();
      /*false means no ownership, otherwise it'll rollback when MTTransaction object is destroyed*/
      oMTTransaction.SetTransaction(oTransaction, false);
      string encodedCookie = oMTTransaction.Export(cookie);

      sset.TransactionID = encodedCookie;
      
      foreach (IAdjustmentTransaction trx in aSet.GetAdjustmentTransactions())
      {
        try
        { 
          ISession session = sset.CreateSession(@"metratech.com/AccountCredit");
          session.InitProperty("_AccountID", trx.PayerAccountID);
          session.InitProperty("_Currency", trx.Currency);
          session.InitProperty("InternalComment", trx.Description);
          session.InitProperty("_Amount", System.Convert.ToDecimal(trx.PrebillAdjustmentAmount));
          session.InitProperty("RequestAmount",  System.Convert.ToDecimal(trx.PrebillAdjustmentAmount));
          session.InitProperty("CreditAmount",  System.Convert.ToDecimal(trx.PrebillAdjustmentAmount));
          session.InitProperty("Status", sStatus);
          session.InitProperty("CreditTime", MetraTech.MetraTime.Now);
          session.InitProperty("RequestID", -1);
          session.InitProperty("ContentionSessionID", string.Empty);
          session.InitProperty("Issuer", System.Convert.ToString(aSet.GetSessionContext().AccountID));
					session.InitProperty("Reason", "Other");
          session.InitProperty("ReturnCode", 0);
          session.RequestResponse = true;
        }
        catch(AdjustmentUserException ex)
        {
          warnings.AddRow();
          warnings.AddColumnData("id_sess",trx.SessionID);
          warnings.AddColumnData("description", ex.Message);
          continue;
        }
      }

      sset.Close();
      
      //now update Orphan records in t_adjustment_transaction to have delete status
      UpdateOrphanState((IMTSessionContext)aSet.GetSessionContext(), 
                  (MetraTech.Interop.MTProductCatalog.IMTCollection)((AdjustmentTransactionSet)aSet).GetIDCollection(), 
                  AdjustmentStatus.DELETED, 
                  aProgressObject
                 );

      //When Batch Read transactionaility is fixed, put it back. Right now
      //rely on Sync metering
      //Utils.WaitForBatchCompletion((MetraTech.Interop.COMMeter.IBatch)batch);

      //warnings rowset is always empty here.
      //What are the cases where we could generate a warning?
      return warnings;
    }
  }
}

// EOF
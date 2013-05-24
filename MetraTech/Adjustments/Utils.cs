using System;
using System.Collections;
using System.Diagnostics;
using  RS = MetraTech.Interop.Rowset;
using MetraTech.DataAccess;
using MetraTech.Interop.COMMeter;

namespace MetraTech.Adjustments
{
  /// <summary>
  /// Summary description for Utils.
  /// </summary>
  internal class Utils
  {
    private static Hashtable transitiontable;
    static Utils()
    {
      //State
      //DELETED can not be transitioned from

      transitiontable = new Hashtable();
      ArrayList finals = new ArrayList();
      //from Pending
      finals.Add(AdjustmentStatus.APPROVED); 
      finals.Add(AdjustmentStatus.DELETED); 
      finals.Add(AdjustmentStatus.AUTODELETED); 
      finals.Add(AdjustmentStatus.ORPHAN); 
      
      transitiontable.Add(AdjustmentStatus.PENDING, finals);
      finals = new ArrayList();
      
      //from Approved
      finals.Add(AdjustmentStatus.DELETED); 
      finals.Add(AdjustmentStatus.AUTODELETED); 
      finals.Add(AdjustmentStatus.ORPHAN);
      //idempotent
      finals.Add(AdjustmentStatus.APPROVED); 

      transitiontable.Add(AdjustmentStatus.APPROVED, finals);
      
      finals = new ArrayList();

      //from AutoDeleted
      finals.Add(AdjustmentStatus.APPROVED); 
      finals.Add(AdjustmentStatus.PENDING); 
      finals.Add(AdjustmentStatus.ORPHAN);
      //idempotent
      finals.Add(AdjustmentStatus.AUTODELETED); 

      transitiontable.Add(AdjustmentStatus.AUTODELETED, finals);

      finals = new ArrayList();

      //from Orphan
      finals.Add(AdjustmentStatus.DELETED);
      finals.Add(AdjustmentStatus.AUTODELETED);
      //idempotent
      finals.Add(AdjustmentStatus.ORPHAN); 

      transitiontable.Add(AdjustmentStatus.ORPHAN, finals);

      //from Not adjusted
      finals.Add(AdjustmentStatus.APPROVED);
      finals.Add(AdjustmentStatus.PENDING);
      //idempotent
      finals.Add(AdjustmentStatus.NOT_ADJUSTED); 

      transitiontable.Add(AdjustmentStatus.NOT_ADJUSTED, finals);

			
    }


    internal static void EvaluateStateTransition(AdjustmentStatus initial, AdjustmentStatus final,
												 int aAcountID, int aUsageInterval)
    {
      System.Collections.ArrayList evaluatedIntervals = new ArrayList();
      if(!transitiontable.ContainsKey(initial))
        throw new AdjustmentStateTransitionException
          (String.Format("Adjustment State {0} can not be transitioned from", initial));
      if (!((ArrayList)transitiontable[initial]).Contains(final))
        throw new AdjustmentStateTransitionException(String.Format
          ("Adjustment State {0} can not be transitioned to {1}", initial, final));

      //is it safe? What if some one is trying to close this interval at the same time?
      if(final == AdjustmentStatus.DELETED && !evaluatedIntervals.Contains(aUsageInterval))
      {
        if(IsIntervalOpen(aAcountID, aUsageInterval))
        {
          evaluatedIntervals.Add(aUsageInterval);
        }
        else if (initial == AdjustmentStatus.APPROVED)
          throw new AdjustmentStateTransitionException(String.Format
            ("Adjustment State {0} can not be transitioned to {1}, because usage interval {2} is already closed", initial, final, aUsageInterval));
      }
    }

    internal static RS.IMTSQLRowset CreateWarningsRowset()
    {
      RS.IMTSQLRowset warnings = new RS.MTSQLRowset();
      
      //initialize "warning rowset"
      // build the output rowset
      warnings.InitDisconnected();
      warnings.AddColumnDefinition("id_sess","int64", 6);
      warnings.AddColumnDefinition("description","string", 2048);
      warnings.OpenDisconnected();
	  return warnings;
    }
		internal static RS.IMTSQLRowset MergeAllWarningsRowset(MetraTech.Interop.GenericCollection.IMTCollection collRS)
		{
			RS.IMTSQLRowset mergedRowset = Utils.CreateWarningsRowset();
			foreach (RS.IMTSQLRowset rs in collRS)
			{
				rs.MoveFirst();
				for (int iRecordCount = 0; iRecordCount < rs.RecordCount; iRecordCount++)
				{
					if ((System.Decimal)rs.get_Value(0) != 0)
					{
						Utils.InsertWarningRecord(ref mergedRowset, (System.Decimal)rs.get_Value(0), (string)rs.get_Value(1));
						rs.MoveNext();
					}

				}
			}
			return mergedRowset;
		}
		internal static void InsertWarningRecord(ref RS.IMTSQLRowset rs, System.Decimal aSessionID, string aMessage)
    {
      if (rs == null)
        return;
      rs.AddRow();
			rs.AddColumnData("id_sess", aSessionID);
      rs.AddColumnData("description", aMessage);
    }
    internal static string CreateSessionListWherePredicate
      (MetraTech.Interop.MTProductCatalog.IMTCollection aSessions, bool bGetChildren)
    {
      string outstr = "";
      string sesslist = "";
      bool first = true;
      string column = bGetChildren ? "id_parent_sess" : "id_sess";
     
      foreach(object session in aSessions)
      {
        if(!first)
        {
          sesslist += ",";
        }
        sesslist += System.String.Format("{0}", session);
        first = false;
      }
      outstr = System.String.Format("WHERE ajv.{0} in ({1})", column, sesslist);
     
      return outstr;
    }

    internal static string CreateAdjustmentIDListWherePredicate
      (MetraTech.Interop.MTProductCatalog.IMTCollection aAdjustmentIDs)
    {
      string outstr = "";
      string sesslist = "";
      bool first = true;
      foreach(object session in aAdjustmentIDs)
      {
        if(!first)
        {
          sesslist += ",";
        }
        sesslist += System.String.Format("{0}", session);
        first = false;
      }
      outstr = System.String.Format("\nWHERE id_adj_trx in ({0})", sesslist);
     
      return outstr;
    }
    internal static string CreateTransactionListWherePredicate
      (MetraTech.Interop.MTProductCatalog.IMTCollection aSessions, bool bGetChildren)
    {
      string outstr = "";
      string sesslist = "";
      bool first = true;
      string column = bGetChildren ? "id_parent_sess" : "id_sess";
      foreach(object session in aSessions)
      {
        if(!first)
        {
          sesslist += ",";
        }
        sesslist += System.String.Format("{0}", ((IAdjustmentTransaction)session).SessionID);
        first = false;
      }
      outstr = System.String.Format("WHERE {0} in ({1})", column, sesslist);
      
      return outstr;
    }
    internal static bool IsIntervalOpen(int aAccountID, int aIntervalID)
    {
        using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
        {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__IS_INTERVAL_OPEN__"))
            {
                stmt.AddParam("%%ID_ACC%%", aAccountID);
                stmt.AddParam("%%INTERVAL_ID%%", aIntervalID);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    bool gotsomething = reader.Read();
                    Debug.Assert(gotsomething);
                    return reader.GetBoolean("IsIntervalOpen");
                }
            }
        }
    }

    internal static int GetOpenInterval(int aAccountID)
    {
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__GET_OPEN_INTERVAL__"))
          {
              stmt.AddParam("%%ID_ACC_PAYER%%", aAccountID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  bool gotsomething = reader.Read();
                  Debug.Assert(gotsomething);
                  if (reader.IsDBNull("IntervalID"))
                      throw new AdjustmentException(String.Format("Unable to find open interval for account {0}", aAccountID));
                  return reader.GetInt32("IntervalID");
              }
          }
      }

    }

    internal static TransactionInfo GetAdjustmentTransactionInfo(int aAJID)
    {
      TransactionInfo info = new TransactionInfo(aAJID);

      using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          //get pi template and type based on session id
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement
            ("queries\\Adjustments", "__GET_AJ_TRANSACTION_INFO__"))
          {
              stmt.AddParam("%%ID_TRX%%", aAJID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  if (!reader.Read())
                      throw new AdjustmentException(String.Format("Usage not found for transaction {0}", aAJID));

                  if (reader.IsDBNull("id_pi_template"))
                      throw new AdjustmentException
                        (String.Format("Unable to find id_pi_template for for session with id {0} (non ProdCat usage?)", aAJID));
                  info.PITemplateID = reader.GetInt32("id_pi_template");
                  info.PITypeID = reader.GetInt32("PITypeID");
                  info.ServiceID = reader.GetInt32("id_svc");
                  info.IsPrebill = (reader.GetString("IsPrebill")[0] == 'Y') ? true : false;
                  info.IsPrebillAdjusted = reader.GetString("IsPrebillAdjusted")[0] == 'Y' ? true : false;
                  info.IsPostbillAdjusted = reader.GetString("IsPostbillAdjusted")[0] == 'Y' ? true : false;
                  info.UID = reader.GetConvertedString("tx_uid");
                  info.AJTemplateID = reader.IsDBNull("id_aj_template") ? -1 : reader.GetInt32("id_aj_template");
                  info.AJInstanceID = reader.IsDBNull("id_aj_instance") ? -1 : reader.GetInt32("id_aj_instance");
                  info.AJTypeID = reader.IsDBNull("id_aj_type") ? -1 : reader.GetInt32("id_aj_type");
                  info.SessionID = reader.GetInt64("id_sess");
                  return info;
              }
          }
      }
    }

    internal static string PVTableFromAJTable(string aAJTable)
    {
      return aAJTable.Replace("t_aj", "t_pv");;
    }

    internal static void WaitForBatchCompletion(IBatch aBatch)
    {
      int iRetryInterval = AdjustmentCache.GetInstance().GetBatchRetryInterval();
      int iMaxRetries = AdjustmentCache.GetInstance().GetBatchMAXRetries();
      aBatch.Refresh();
      AdjustmentCache.GetInstance().GetLogger().LogDebug("Waiting for completion of batch {0}",aBatch.Name);

      int count = 0;
      while (aBatch.Status != "C" && count < iMaxRetries)
      {
        System.Threading.Thread.Sleep(iRetryInterval * 1000);
        // TODO: this should call Refresh()!
        aBatch.Refresh();
        //batch.Refresh();
        count++;
      }
      if(aBatch.ExpectedCount != (aBatch.CompletedCount + aBatch.FailureCount))
        throw new AdjustmentException(String.Format(@"Expected Count for batch {0} ({1}) is not equal to sum of +
          Completed Count ({2}) and Failure Count ({3})", aBatch.Name, aBatch.ExpectedCount,
          aBatch.CompletedCount, aBatch.FailureCount));
      if(aBatch.FailureCount > 0)
        throw new AdjustmentException(String.Format("{0} Sessions failed on {1} batch", aBatch.FailureCount, aBatch.Name));

    }

  }
}

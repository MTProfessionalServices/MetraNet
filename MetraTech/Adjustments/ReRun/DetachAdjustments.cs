using System;
using System.Collections;
using MetraTech.Pipeline.ReRun;
using System.EnterpriseServices;
using System.Runtime.InteropServices;
using MetraTech.DataAccess;
using MetraTech.Adjustments;
using MetraTech.Interop.MTBillingReRun;
using MetraTech;

[assembly: Guid("d81ae761-4cfb-4819-8a70-addbbed085e7")]

namespace MetraTech.Adjustments.ReRun
{
	/// <summary>
	/// When a transaction is backed out, adjustments created against it
	/// need to be converted to "miscellaneous"
	/// </summary>
	/// 
  [ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
  [Guid("45faeae5-c30d-4e38-ac4d-4466f119c9a3")]
	public class DetachAdjustments : ServicedComponent, IReRunTask
	{
		public DetachAdjustments()
		{
    
		}

    [AutoComplete]
    public void Analyze(MetraTech.Interop.MTBillingReRun.IMTSessionContext context, int rerunID, string rerunTableName, bool useDBQueues)
    {
      using(IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\BillingRerun"))
      {
        Logger logger = new Logger("[DetachAdjustmentsReRunTask]");

        // step: see if rerun set contains any payments or ARAdjustments that have been exported
        logger.LogDebug(String.Format("Identifying adjustment transactions affected by Rerun with ID {0}", rerunID));

        ArrayList SessionsToOrphanize = null;
        ArrayList TransactionsToDelete = null;
        Hashtable AJTables = null;

        DetermineAdjustmentTransactions(context, rerunID, rerunTableName, useDBQueues, out SessionsToOrphanize, out TransactionsToDelete, out AJTables);

        logger.LogDebug(String.Format("Analyze: {0} Pending or Approved adjustment transactions will be marked as ORPHAN during ReRun with ID {1}", SessionsToOrphanize.Count, rerunID));
        logger.LogDebug(String.Format("Analyze: {0} Deleted adjustment transactions will be physically deleted during ReRun with ID {1}", TransactionsToDelete.Count, rerunID));
        
        
      }
    }

    [AutoComplete]
    public void Backout(MetraTech.Interop.MTBillingReRun.IMTSessionContext context, int rerunID, string rerunTableName, bool useDBQueues)
    {
      Logger logger = new Logger("[DetachAdjustmentsReRunTask]");
      
      logger.LogDebug(String.Format("Backing out adjustment transactions affected by Rerun with ID {0}", rerunID));

      ArrayList SessionsToOrphanize = null;
      ArrayList TransactionsToDelete = null;
      Hashtable AJTables = null;

      DetermineAdjustmentTransactions(context, rerunID, rerunTableName, useDBQueues, out SessionsToOrphanize, out TransactionsToDelete, out AJTables);

      string sSessList = CreateInPredicate(SessionsToOrphanize);
      string sTrxList = CreateInPredicate(TransactionsToDelete);

      logger.LogDebug(String.Format("Backout: {0} Pending or Approved adjustment transactions will be marked as ORPHAN during ReRun with ID {1}", SessionsToOrphanize.Count, rerunID));
      logger.LogDebug(String.Format("Backout: {0} Deleted adjustment transactions will be physically deleted during ReRun with ID {1}", TransactionsToDelete.Count, rerunID));
        
      
      using(IMTServicedConnection conn = ConnectionManager.CreateConnection(@"Queries\BillingRerun"))
      {
        logger.LogDebug(String.Format("Backout: Setting adjustment status to ORPHAN for following sessions: {0}", sSessList));
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__ORPHANIZE_ADJUSTMENTS__"))
        {
            stmt.AddParam("%%ID_SESS_LIST%%", sSessList);
            stmt.ExecuteNonQuery();
        }

        logger.LogDebug(String.Format("Backout: Deleting adjustment records with following ids: {0}", sTrxList));
        //delete records from AJ tables first
        foreach (string ajtable in AJTables.Values)
        {
            using (IMTAdapterStatement stmt1 = conn.CreateAdapterStatement("queries\\Adjustments", "__DELETE_AJCHARGE_RECORDS__"))
            {
                stmt1.AddParam("%%AJ_TABLE%%", ajtable);
                stmt1.AddParam("%%ID_AJ_LIST%%", sTrxList);
                stmt1.ExecuteNonQuery();
            }
        }

        using (IMTAdapterStatement stmt2 = conn.CreateAdapterStatement("queries\\Adjustments", "__DELETE_AJ_RECORDS__"))
        {
            stmt2.AddParam("%%ID_AJ_LIST%%", sTrxList);
            stmt2.ExecuteNonQuery();
        }
          //delete t_adjustment_transaction records


      }
    }

    [AutoComplete]
    private void DetermineAdjustmentTransactions(
      MetraTech.Interop.MTBillingReRun.IMTSessionContext context,
      int aRerunID, 
	    string rerunTableName,
	    bool useDBQueues,
      out ArrayList apSessionsToOrphanize, 
      out ArrayList apSessionsToDelete,
      out Hashtable apAJTables)
    {
      ArrayList ajsessions = new ArrayList();
      ArrayList ajdeletedtransactions = new ArrayList();
      Hashtable ajtables = new Hashtable();
      int SessionID = 0;
      int ajtypeid;

      using(IMTServicedConnection conn = ConnectionManager.CreateConnection(@"Queries\BillingRerun"))
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\Adjustments", "__IDENTIFY_RERUN_ADJUSTMENTS_40__"))
          {
              stmt.AddParam("%%TABLE_NAME%%", rerunTableName);

              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      if (reader.GetString("c_status").CompareTo("D") == 0)
                      {
                          SessionID = reader.GetInt32("id_adj_trx");
                          if (ajdeletedtransactions.Contains(SessionID) == false)
                              ajdeletedtransactions.Add(reader.GetInt32("id_adj_trx"));
                      }
                      else
                      {
                          long tmp = reader.GetInt64("id_sess");
                          if (ajsessions.Contains(tmp) == false)
                              ajsessions.Add(reader.GetInt64("id_sess"));
                      }

                      ajtypeid = reader.GetInt32("id_aj_type");
                      string ajtable = reader.GetString("ajtable");

                      if (ajtables.Contains(ajtypeid) == false)
                      {
                          ajtables.Add(ajtypeid, ajtable);
                      }

                  }
              }
          }

        apSessionsToOrphanize = ajsessions;
        apSessionsToDelete = ajdeletedtransactions;
        apAJTables = ajtables;

      } 
    }

    internal string CreateInPredicate(ArrayList aSessions)
    {
      string sesslist = "NULL";
      bool first = true;

      foreach(object session in aSessions)
      {
        if(first)
          sesslist = string.Empty;
        else
        {
          sesslist += ",";
        }

        sesslist += System.Convert.ToString(session);
        first = false;
      }

      return String.Format("({0})", sesslist);
    }

    
	}
}


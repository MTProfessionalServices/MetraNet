using System;
using MetraTech.Interop.GenericCollection;
using MetraTech.Interop.MTAuth;
using IMTCollection = MetraTech.Interop.GenericCollection.IMTCollection;

/// <summary>
/// Common Routines for handling FailedTransactions
/// </summary>
public static class FailedTransactions
{
  
  /// <summary>
  /// Get an MTCollection from a list of comma separated ids
  /// </summary>
  /// <param name="separatedValues"></param>
  /// <param name="separator"></param>
  /// <returns></returns>
  public static MTCollection GetMTCollectionFromValues(string separatedValues, char separator)
  {
    var result = new MTCollection();
    if (!String.IsNullOrEmpty(separatedValues))
    {
      foreach (var id in separatedValues.Split(new[] { separator }))
      {
        result.Add(id.Trim());
      }
    }
    return result;
  }

  /// <summary>
  /// Update the failed transactions statuses
  /// </summary>
  /// <param name="colFailureIDs"></param>
  /// <param name="newStatus"></param>
  /// <param name="reasonCode"></param>
  /// <param name="comment"></param>
  /// <param name="sessionContext"></param>
  public static void BulkUpdateFailedTransactionStatus(IMTCollection colFailureIDs, string newStatus, string reasonCode, string comment, IMTSessionContext sessionContext)
  {
    var bulkFailedTransactions = new MetraTech.Pipeline.ReRun.BulkFailedTransactions { SessionContext = sessionContext };

    bulkFailedTransactions.UpdateStatusCollection((MetraTech.Interop.PipelineControl.IMTCollection)colFailureIDs, newStatus, reasonCode, comment);
  }

  /// <summary>
  /// Resubmit the failed transactions
  /// </summary>
  /// <param name="colFailureIDs"></param>
  /// <param name="sessionContext"></param>
  /// <returns></returns>
  public static int BulkResubmitFailedTransactions(IMTCollection colFailureIDs, IMTSessionContext sessionContext)
  {
    var bulkFailedTransactions = new MetraTech.Pipeline.ReRun.BulkFailedTransactions { SessionContext = sessionContext };

    var rerunID = bulkFailedTransactions.ResubmitCollectionAsync((MetraTech.Interop.PipelineControl.IMTCollection)colFailureIDs);
    return rerunID;
  }

  /// <summary>
  /// Check if a rerun is complete
  /// </summary>
  /// <param name="id"></param>
  /// <param name="sessionContext"></param>
  /// <returns></returns>
  public static bool CheckIsComplete(int id, IMTSessionContext sessionContext)
  {
    var rerun = new MetraTech.Pipeline.ReRun.Client();
    rerun.Login((MetraTech.Interop.MTBillingReRun.IMTSessionContext)sessionContext);
    rerun.ID = id;
    rerun.Synchronous = false;
    return rerun.IsComplete();
  }

}


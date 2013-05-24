using System;
using System.Collections;
using System.EnterpriseServices;
using System.Runtime.InteropServices;
using System.Collections.Specialized;

using MetraTech;
using MetraTech.DataAccess;
using MetraTech.Xml;
using Rowset = MetraTech.Interop.Rowset;
using Coll = MetraTech.Interop.GenericCollection;
using PipelineTransaction = MetraTech.Interop.PipelineTransaction;
using MetraTech.Interop.MTBillingReRun;
using Auth = MetraTech.Interop.MTAuth;

namespace MetraTech.UsageServer
{
  /// <summary>
  ///    This methods on this interface perform transactional
  ///    units of work related to billing groups. It is used
  ///    as a helper class by BillingGroupManager.
  /// </summary>
  [Guid("73CAC3BD-7E46-49b0-B8B0-43F5149DD286")]
  public interface IBillingGroupWriter
  {
    void BackoutUsage(BillingGroupManager billingGroupManager,
                      int intervalId, 
                      string commaSeparatedAccounts,
                      Auth.IMTSessionContext sessionContext,
                      bool updateAccountsToHardClosed,
                      bool resubmit);

    int FinishChildGroupCreation(BillingGroupManager billingGroupManager,
                                 int materializationId);
  }

  /// <summary>
  ///    Implementation of IBillingGroupWriter.  Proxy class for the
  ///    worker class.  The worker is a ServicedComponent.  The cleanup DDL
  ///    operations have to be done after the transaction.
  /// </summary>
  [ClassInterface(ClassInterfaceType.None)]
  [Guid("E02F1733-43FF-4358-92FC-5AC4203ACB75")]
  public class BillingGroupWriter : IBillingGroupWriter
  {

    public void BackoutUsage(BillingGroupManager billingGroupManager,
      int intervalId, 
      string commaSeparatedAccounts,
      Auth.IMTSessionContext sessionContext,
      bool updateAccountsToHardClosed,
      bool resubmit)
    {
      int rerunID = -1;
      string comment = "";

      try 
      {
        BillingGroupWriterWorker worker = new BillingGroupWriterWorker();
        worker.BackoutUsage(billingGroupManager,
          intervalId, 
          commaSeparatedAccounts,
          sessionContext,
          updateAccountsToHardClosed,
          resubmit,
          ref rerunID,
          ref comment);
      
      }
      catch(Exception e) 
      {
        throw new UsageServerException
          (String.Format("An error occurred while backing out and resubmitting " +
          "usage for unassigned accounts for interval '{0}' : " + 
          e.Message, 
          intervalId), true);
      }
      finally
      {
        if (rerunID != -1)
        {
          AbandonRerun(rerunID, comment);
        }
      }
    }

    public int FinishChildGroupCreation(BillingGroupManager billingGroupManager,
      int materializationId)
    {
      BillingGroupWriterWorker worker = new BillingGroupWriterWorker();
      return worker.FinishChildGroupCreation(billingGroupManager, materializationId);
    }

    private void AbandonRerun(int rerunID, string comment)
    {
      IMTBillingReRun abandonRerun = new MetraTech.Pipeline.ReRun.Client();

      Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
      Auth.IMTSessionContext sessionContext = loginContext.LoginAnonymous();

      abandonRerun.Login((MetraTech.Interop.MTBillingReRun.IMTSessionContext) sessionContext);
      abandonRerun.ID = rerunID;
      abandonRerun.Abandon(comment);
    }

  }

	/// <summary>
	///    Implementation of IBillingGroupWriter.
	/// </summary>
  [ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Required, Timeout=0, Isolation=TransactionIsolationLevel.Any)]
  [Guid("6f1e5826-c261-432b-8d02-e650a75028db")]
  public class BillingGroupWriterWorker : ServicedComponent
  {
    #region Public Methods
    
    /// <summary>
    ///    This is used to back out the usage for the given interval and the
    ///    given accounts (in commaSeparatedAccounts) and resubmit the usage
    ///    to the next open interval.
    /// </summary>
    [AutoComplete]
    public void BackoutUsage(BillingGroupManager billingGroupManager,
      int intervalId, 
      string commaSeparatedAccounts,
      Auth.IMTSessionContext sessionContext,
      bool updateAccountsToHardClosed,
      bool resubmit,
      ref int rerunID,
      ref string comment)
    {
      IMTBillingReRun rerun = null;

      comment = String.Format("Backing out and resubmitting " +
        "usage for unassigned accounts for interval '{0}'...", 
        intervalId);

      // Create/Initialize the billing rerun client and return the new transaction
      rerun = billingGroupManager.SetupBillingReRun(comment, sessionContext);
      rerunID = rerun.ID;

      // Create a temporary table and populate it with the accounts in
      // commaSeparatedAccounts
      billingGroupManager.CreateAndPopulateTempBillingRerunAccountsTable(commaSeparatedAccounts);

      // Execute a query which will identify the usage based
      // on the temporary table and t_acc_usage and populate
      // the t_rerun_session_X table
      billingGroupManager.RunIdentifyAccountUsageForBillingRerun(rerun, intervalId);

      // Drop the temporary table created earlier
      billingGroupManager.DeleteTempBillingRerunAccountsTable();

      // Analyze
      rerun.Analyze(comment);

      // Set the account status to 'H'
      if (updateAccountsToHardClosed)
      {
        billingGroupManager.
          UpdateUnassignedAccountsToHardClosed(commaSeparatedAccounts, 
          intervalId,
          false,  // do not check usage
          false); // non-transactional
      }

      if (resubmit)
      {
        // Backout and Resubmit
        rerun.BackoutResubmit(comment);
      }
      else 
      {
        rerun.BackoutDelete(comment);
      }
    }

    /// <summary>
    ///    Completes the process of creating a pull list transactionally.
    /// </summary>
    /// <param name="billingGroupManager"></param>
    [AutoComplete]
    public int FinishChildGroupCreation(BillingGroupManager billingGroupManager,
                                        int materializationId)
    {
      int childBillingGroupId;
      int parentBillingGroupId;
      
      // Move data from temporary to system tables 
      billingGroupManager.CompleteChildGroupCreation(materializationId);

      // Create recurring event instance data for the new child billing group
      Hashtable adapterRunDataMap = 
        billingGroupManager.CopyAdapterInstances(materializationId,
                                                  out childBillingGroupId,
                                                  out parentBillingGroupId);
      
      // Run SplitReverseState for relevant adapters
      billingGroupManager.RunAdapterSplitReverseState(materializationId,
                                                      parentBillingGroupId,
                                                      childBillingGroupId,
                                                      adapterRunDataMap);    
      
      return childBillingGroupId;
    }
    
    #endregion

    #region Private Methods
   
    #endregion

    #region Data
    private const string mUsageServerQueryPath = @"Queries\UsageServer";
    #endregion

	}
}

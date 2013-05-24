using System;
using System.Xml;
using System.Xml.Xsl;
using System.Xml.XPath;
using System.IO;
using System.Collections;
using System.Diagnostics;
using System.EnterpriseServices;
using System.Runtime.InteropServices;
using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.AR;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTARInterfaceExec;

namespace MetraTech.AR.Adapters
{
  public enum ExportType
  {
    PAYMENTS,
    AR_ADJUSTMENTS,
    PB_ADJUSTMENTS,
    DELETED_PB_ADJUSTMENTS
  };

  /// <summary>
  /// Export payments, A/R adjustments, and post-bill adjustments to the A/R system
  /// 
  /// Dependencies:
  /// None
  /// 
  /// Details:
  /// Run on a schedule (1 min – 1 day). Frequency should be configured based on the allowed
  /// latency between A/R and MetraNet.
  /// Exports all payments/adjustments that have not been exported at the time the adapter runs,
  /// and whose source is not A/R.
  /// The adapter will use an A/R batch ID based on the CurrentRunTime, the format will
  /// be "XXXyyyymmddhhmm", e.g. "PMT200212312359". The ID is unique by minute only,
  /// since G/P has a 15 char maximum. Therefore, the adapter's run frequency must not be less 
  /// than a minute.
  /// Payments/adjustments that do not belong to a MetraNet batch (of configured BatchNameSpace)
  /// will be exported using the A/R batch ID.
  /// Payments/adjustments that do belong to a MetraNet batch (of configured BatchNameSpace)
  /// will be exported using the MetraNet batch name. This will allow posting of a MetraNet batch in A/R.
  /// All payments/adjustments that have been exported, will have their c_ARBatchID field set to 
  /// the A/RBatchID (even if they belong to a MetraNet batch, to allow for a complete back out
  /// of the adapter run).
  /// 
  /// Deletion of post-bill adjustments:
  /// A post-bill adjustment can be deleted after it has been exported to AR. The adapter examines 
  /// deleted PB adjustments that have not been examined before and does the following:
  /// - if the deleted PBA has not been exported: do nothing
  /// - if the deleted PBA has been exported but not posted: delete it in AR
  /// - if the deleted PBA has been exported and posted: create a compensating adjustment in AR
  ///   (with a new unique ID, "PBC<adjustmentID>").The date of the compensating adjustment will
  ///   be the date the PB adjustment was deleted (we should not add to old, possibly closed buckets).
  /// - if the deleted PBA has been exported but already deleted in AR: log warning
  /// The propagation state of deleted post-bill adjustments will be tracked in two t_adjustment_transaction
  /// fields: ARDelBatchID (batch that identifies the run) and ARDelAction:
  ///   'N' = does not exist in AR, nothing to do
  ///   'D' = delete in AR
  ///   'C' = compensate in AR (create new adjustment)
  /// On reverse, the adapter examines these fields and does the following:
  /// - if the deleted PBA had been exported and then deleted ('D'): recreate the original adjustment
  /// - if the deleted PBA had been exported and then compensated ('C'): delete the compensating adjustment.
  ///   If the compensating adjustment had been posted, fail.
  /// </summary>
  public class PaymentAndAdjustmentAdapter : MetraTech.UsageServer.IRecurringEventAdapter
  {
    // data
    private Logger mLogger = new Logger("[ARPmtAdjAdapter]");
    private int mSetSize = 0;
    private bool mExportPayments = false;
    private bool mExportARAdjustments = false;
    private bool mExportPostBillAdjustments = false;
    private ArrayList mAccountNameSpaces;
    private string mBatchNameSpace;
    private object mARConfigState;

    // adapter capabilities
    public bool SupportsScheduledEvents     { get { return true; }}
    public bool SupportsEndOfPeriodEvents   { get { return false; }}
    public ReverseMode Reversibility        { get { return ReverseMode.Custom; }}
    public bool AllowMultipleInstances      { get { return false; }}

    public PaymentAndAdjustmentAdapter()
    {
    }

    public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
    {
      if (limitedInit)
      {
        mLogger.LogDebug("Intializing adapter (limited)");
      }
      else
      {
        mLogger.LogDebug("Intializing Adapter");

        ReadConfig (configFile); 

        mAccountNameSpaces = ARConfiguration.GetInstance().AccountNameSpaces;
        mBatchNameSpace = ARConfiguration.GetInstance().BatchNameSpace;

        //configure ARInterface
        IMTARConfig ARConfig = new MTARConfigClass();
        mARConfigState = ARConfig.Configure("");
      }
    }

    public string Execute(IRecurringEventRunContext context)
    {
      mLogger.LogDebug("executing PmtAndAdjAdapter in context: {0}",  context);
      
      int numPaymentsExported = 0;
      int numARAdjustmentsExported = 0;
      int numPostBillAdjustmentsExported = 0;
      int numDeletedPostBillAdjustmentsExported = 0;

      if(mExportPayments)
      {
        numPaymentsExported = Export(ExportType.PAYMENTS, context);
      }

      if(mExportARAdjustments)
      {
        numARAdjustmentsExported = Export(ExportType.AR_ADJUSTMENTS, context);
      }

      if(mExportPostBillAdjustments)
      {
        numPostBillAdjustmentsExported = Export(ExportType.PB_ADJUSTMENTS, context);
        numDeletedPostBillAdjustmentsExported = Export(ExportType.DELETED_PB_ADJUSTMENTS, context);
      }

			string detail;
      detail = String.Format(
        "Exported {0} payment{1}, {2} AR adjustment{3}, {4} post-bill adjustment{5}",
        numPaymentsExported,
        numPaymentsExported == 1 ? "" : "s",
        numARAdjustmentsExported,
        numARAdjustmentsExported == 1 ? "" : "s",
        numPostBillAdjustmentsExported,
        numPostBillAdjustmentsExported == 1 ? "" : "s");

      if (numDeletedPostBillAdjustmentsExported > 0)
      {
        detail += String.Format("; deleted {0} post-bill adjustment{1}",
          numDeletedPostBillAdjustmentsExported, 
          numDeletedPostBillAdjustmentsExported == 1 ? "" : "s"  );
      }

      mLogger.LogDebug(detail);

			return detail;
    }

    /// <summary>
    /// Reverse and does the following:
    /// 1. finds all payments/adjustmens for the ARBatchID
    /// 2. deletes (still) existing payments/adjustments from AR
    /// 3. updates propagation status for all deleted payments/adjustments
    /// 4. delete corresponding batches in AR if their number of txn is 0
    /// </summary>
    public string Reverse(IRecurringEventRunContext context)
    {
      mLogger.LogDebug("reversing PmtAndAdjAdapter in context: {0}",  context);
      
      int numPaymentsReversed = 0;
      int numARAdjustmentsReversed = 0;
      int numPostBillAdjustmentsReversed = 0;
      int numDeletedPostBillAdjustmentsReversed = 0;
    
      if(mExportPayments)
      {
        numPaymentsReversed = Reverse(ExportType.PAYMENTS, context);
      }

      if(mExportARAdjustments)
      {
        numARAdjustmentsReversed = Reverse(ExportType.AR_ADJUSTMENTS, context);
      }

      if(mExportPostBillAdjustments)
      {
        numPostBillAdjustmentsReversed = Reverse(ExportType.PB_ADJUSTMENTS, context);
        numDeletedPostBillAdjustmentsReversed = Reverse(ExportType.DELETED_PB_ADJUSTMENTS, context);
      }

			string detail;
      detail = String.Format(
        "Reversed export of {0} payment{1}, {2} AR adjustment{3}, {4} post bill adjustment{5}",
        numPaymentsReversed,
        numPaymentsReversed == 1 ? "" : "s",
        numARAdjustmentsReversed,
        numARAdjustmentsReversed == 1 ? "" : "s",
        numPostBillAdjustmentsReversed,
        numPostBillAdjustmentsReversed == 1 ? "" : "s");

      if (numDeletedPostBillAdjustmentsReversed > 0)
        detail += String.Format("; reversed deletion of {0} post-bill adjustment{1}",
          numDeletedPostBillAdjustmentsReversed,
          numDeletedPostBillAdjustmentsReversed == 1 ? "" : "s");

      mLogger.LogDebug(detail);

			return detail;
    }

    public void Shutdown()
    {
    }

    private void ReadConfig(string configFile)
    {
      MTXmlDocument doc = new MTXmlDocument();
      doc.Load(configFile);

      mSetSize = doc.GetNodeValueAsInt("//SetSize", 500);
      mExportPayments = doc.GetNodeValueAsBool("//ExportPayments", false);
      mExportARAdjustments = doc.GetNodeValueAsBool("//ExportARAdjustments", false);
      mExportPostBillAdjustments = doc.GetNodeValueAsBool("//ExportPostBillAdjustments", false);
    }

    /// <summary>
    /// returns a batch ID given prefix and context
    /// for scheduled: "PREFIXyyyymmddhhmm", using the end time
    /// for interval: "PREFIX123", using the interval id
    /// (EOP is not really supported yet. Since the EOP semantics
    ///  would require to only export the payments for the soft-closed accounts)
    /// </summary>
    private string MakeBatchID(string prefix, IRecurringEventRunContext context)
    {
      if (context.EventType == RecurringEventType.EndOfPeriod)
        return prefix + context.UsageIntervalID;
      else
        return prefix + context.EndDate.ToString("yyyyMMddHHmm");
    }
  
    private int Export(ExportType expType, IRecurringEventRunContext context)
    {
      int numItemsExported = 0;

      //get prefixes according to type
      string batchPrefix;
      string IDPrefix;

      switch(expType)
      {
        case ExportType.PAYMENTS:
          batchPrefix = ARConfiguration.GetInstance().PaymentBatchPrefix;
          IDPrefix = ARConfiguration.GetInstance().PaymentIDPrefix;
          break;
        case ExportType.AR_ADJUSTMENTS:
          batchPrefix = ARConfiguration.GetInstance().ARAdjustmentBatchPrefix;
          IDPrefix = ARConfiguration.GetInstance().ARAdjustmentIDPrefix;
          break;
        case ExportType.PB_ADJUSTMENTS:
        case ExportType.DELETED_PB_ADJUSTMENTS:
          batchPrefix = ARConfiguration.GetInstance().PostBillAdjustmentBatchPrefix;
          IDPrefix = ARConfiguration.GetInstance().PostBillAdjustmentIDPrefix;
          break;
        default:
          throw new ARException("unknown ExportType");
      }

      // set default batchID (to be used for sessions without MT Batches)
      string defBatchID = MakeBatchID(batchPrefix, context);
      
      string sAccountNameSpace;

      // export for each account namespace
      for (int i = 0; i < mAccountNameSpaces.Count; i++)
      {
        sAccountNameSpace = mAccountNameSpaces[i].ToString();

        // loop to export mSetSize rows at a time
        while(true)
        {
          //step: Export payments and update state in one txn
          PaymentAndAdjustmentWriter writer = new PaymentAndAdjustmentWriter();
          int numRowsRead = writer.ExportSet(expType, mSetSize, IDPrefix, defBatchID, sAccountNameSpace, mBatchNameSpace, context, mARConfigState, mLogger);
          numItemsExported += numRowsRead;

          if (numRowsRead < mSetSize)
          {
            break;
          }
        }
      }

      return numItemsExported;
    }

    private int Reverse(ExportType expType, IRecurringEventRunContext context)
    {
      int numItemsReversed = 0;

      //get prefixes according to type
      string batchPrefix;

      switch(expType)
      {
        case ExportType.PAYMENTS:
          batchPrefix = ARConfiguration.GetInstance().PaymentBatchPrefix;
          break;
        case ExportType.AR_ADJUSTMENTS:
          batchPrefix = ARConfiguration.GetInstance().ARAdjustmentBatchPrefix;
          break;
        case ExportType.PB_ADJUSTMENTS:
        case ExportType.DELETED_PB_ADJUSTMENTS:
          batchPrefix = ARConfiguration.GetInstance().PostBillAdjustmentBatchPrefix;
          break;
        default:
          throw new ARException("unknown ExportType");
      }

      // set default batchID (of sessions without MT Batches)
      string defBatchID = MakeBatchID(batchPrefix, context);

      // loop to reverse mSetSize rows at a time
      while(true)
      {
        PaymentAndAdjustmentWriter writer = new PaymentAndAdjustmentWriter();
        int numRowsRead = writer.ReverseSet(expType, mSetSize, defBatchID, context, mBatchNameSpace, mARConfigState, mLogger);
        numItemsReversed += numRowsRead;

        if (numRowsRead < mSetSize)
        {
          break;
        }
      }
      return numItemsReversed;
    }
  }
}

using System;

using MetraTech.DataAccess;
using MetraTech.Interop.MTAuth;
using MetraTech.Xml;


namespace MetraTech.UsageServer.Adapters
{
  /// <summary>
  /// This adapter will delete all pending non standard charges in an interval that have not been managed
  /// by the time we run EOP.  This will prevent pending requests to queue up in the database.
  /// 
  /// </summary>
  public class DeletePendingNonStandardChargesAdapter : MetraTech.UsageServer.IRecurringEventAdapter2
  {
    //adapter capabilities
    public bool SupportsScheduledEvents { get { return false; } }
    public bool SupportsEndOfPeriodEvents { get { return true; } }
    public ReverseMode Reversibility { get { return ReverseMode.NotImplemented; } }
    public bool AllowMultipleInstances { get { return false; } }
    public void CreateBillingGroupConstraints(int intervalID, int materializationID) { }
    public BillingGroupSupportType BillingGroupSupport { get { return BillingGroupSupportType.Account; } }
    public bool HasBillingGroupConstraints { get { return false; } }

    private Logger mLogger = new Logger("[DeletePendingNonStandardChargesAdapter]");

    // configuration tags
    private string mQueryTag = "";

    public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
    {
      MTXmlDocument doc = new MTXmlDocument();
      doc.Load(configFile);

      mQueryTag = doc.GetNodeValueAsString("//QueryTag", "");
      if (String.IsNullOrEmpty(mQueryTag))
        throw new Exception("Could not read query tag from adapter config file.");

      return;
    }


    public string Execute(IRecurringEventRunContext param)
    {
      mLogger.LogDebug("Executing {0}", mQueryTag);
      string detail = "Execute failed.";
      using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
        using (
          IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\NonStandardCharges", mQueryTag))
        {
          stmt.AddParam("%%INTERVAL_ID%%", param.UsageIntervalID);
          long result = stmt.ExecuteNonQuery();

          if (result < 1)
            detail = "There are no pending unmanaged nonstandard charges to be deleted for this interval";
          else if (result == 1)
            detail = "Successfully deleted 1 pending unmanaged nonstandard charges to be deleted for this interval";
          else
            detail =
              String.Format("Successfully deleted {0} pending unmanaged nonstandard charges to be deleted for this interval",
                            result);
        }

        mLogger.LogDebug(detail);
      }
      return detail;
    }


    /// <summary>
    /// The DeletePendingNonStandardChargesAdapter will not support reversals.  
    /// </summary>
    /// <param name="param"></param>
    /// <returns></returns>
    public string Reverse(IRecurringEventRunContext param)
    {
      return "This adapter is not reversable.";
    }

    public void Shutdown()
    {
      mLogger.LogDebug("Shutting down DeletePendingNonStandardChargesAdapter Adapter");
      return;
    }

    public void SplitReverseState(int parentRunID, int parentBillingGroupID, int childRunID, int childBillingGroupID)
    {
      mLogger.LogDebug("Splitting reverse state of PaymentBilling Adapter");
    }

    
  }
}

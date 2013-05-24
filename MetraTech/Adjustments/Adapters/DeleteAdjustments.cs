using System.Reflection;

namespace MetraTech.Adjustments.Adapters
{
  using MetraTech.UsageServer;
  using MetraTech.DataAccess;
  using MetraTech;
  using MetraTech.Xml;
  using MetraTech.Interop.MTAuth;
  using System.Diagnostics;
  using System;

  /// <summary>
  /// DeleteAdjustments EOP Adapter's Execute method performs two functions:
  /// 
  /// 1. Marks pre-bill pending adjustments against the interval being closed as 'AD' (auto-deleted)
  /// 2. Marks pre-bill "Orphan" adjustments against the interval being closed as 'AD' (auto-deleted)
  /// 
  /// DeleteAdjustments EOP Adapter's Reverse method performs two functions:
  /// 
  /// 1. Puts Autodeleted ('AD') pre-bill adjustments that are still linked to usage transaction back
  ///    to Pending State ('P').
  /// 2. Puts Autodeleted ('AD') pre-bill adjustments that are not linked to usage transaction
  ///    (id_sess == NULL) back to Orphan State ('O').
  /// </summary>

  public class DeleteAdjustments : IRecurringEventAdapter2
  {
    private Logger mLogger = new Logger("[DeleteAdjustmentsAdapter]");
    private string mEvent;
    private string mConfigFile;
    private enum PreBillAdjustmentSettingType {Delete, Abort};
    private PreBillAdjustmentSettingType mPreBillAdjustmentSetting;

	public void CreateBillingGroupConstraints(int intervalID, int materializationID) { }
	public bool HasBillingGroupConstraints { get { return false; } }
	public BillingGroupSupportType BillingGroupSupport { get { return BillingGroupSupportType.Account; } }

    public DeleteAdjustments()
    {
      mPreBillAdjustmentSetting = PreBillAdjustmentSettingType.Delete;
    }

	public void SplitReverseState(int parentRunID, 
		int parentBillingGroupID,
		int childRunID, 
		int childBillingGroupID)
	{
		mLogger.LogDebug("Splitting reverse state of DeleteAdjustments Adapter");
	}

    public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
    {
      mEvent = eventName;
      mConfigFile = configFile;

      MTXmlDocument doc = new MTXmlDocument();
      doc.Load(mConfigFile);

      string preBillAdjustmentSettingString;

      preBillAdjustmentSettingString = doc.GetNodeValueAsString("//PreBillAdjustmentSetting", "");
      preBillAdjustmentSettingString.ToLower();

      if ((String.Empty == preBillAdjustmentSettingString)
       || ("delete" == preBillAdjustmentSettingString))
      {
        mPreBillAdjustmentSetting = PreBillAdjustmentSettingType.Delete;
        mLogger.LogDebug("The pre-bill adjustment setting has been set to delete.");
      }
      else if ("abort" == preBillAdjustmentSettingString)
      {
        mPreBillAdjustmentSetting = PreBillAdjustmentSettingType.Abort;
        mLogger.LogDebug("The pre-bill adjustment setting has been set to abort.");
      }
      else
      {
        mLogger.LogError("The pre-bill adjustment setting (<PreBillAdjustmentSetting>) in the DeletePendingAdjustments adapter configuration file was unrecognized.");
        throw new ApplicationException("The pre-bill adjustment setting (<PreBillAdjustmentSetting>) in the DeletePendingAdjustments adapter configuration file was unrecognized.");
      }
    }

    public string Execute(IRecurringEventRunContext param)
    {
      string detail = "Execute Failed";

      using(IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          if (mPreBillAdjustmentSetting == PreBillAdjustmentSettingType.Delete)
          {
              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__AUTODELETE_ADJUSTMENTS__"))
              {
                  stmt.AddParam("%%INTERVAL_ID%%", param.UsageIntervalID);
                  stmt.AddParam("%%BILLGROUP_ID%%", param.BillingGroupID);
                  long result = stmt.ExecuteNonQuery();

                  if (result < 1)
                      detail = "There are no pending and/or orphaned pre-bill adjustments to be deleted for this interval";
                  else if (result == 1)
                      detail = "Successfully deleted 1 pending or orphaned pre-bill adjustment for this interval";
                  else
                      detail = String.Format("Successfully deleted {0} pending and/or orphaned pre-bill adjustments for this interval", result);
              }
          }
          else  // Must be ABORT
          {
              long numExisting;

              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__PREBILL_ADJUSTMENT_COUNT__"))
              {
                  stmt.AddParam("%%INTERVAL_ID%%", param.UsageIntervalID);
                  stmt.AddParam("%%BILLGROUP_ID%%", param.BillingGroupID);

                  using (IMTDataReader reader = stmt.ExecuteReader())
                  {
                      reader.Read();
                      numExisting = reader.GetInt32(0);
                  }
              }

              if (numExisting < 1)
                  detail = "No pending or orphaned pre-bill adjustments exist for this interval, processing not aborted";
              if (numExisting == 1)
                  detail = "1 pending or orphaned pre-bill adjustment exists for this interval, processing aborted";
              else
                  detail = String.Format("{0} pending or orphaned pre-bill adjustments exist for this interval, processing aborted", numExisting);

              mLogger.LogError(detail);

              if (numExisting > 0)
                  throw new ApplicationException(detail);
          }
      }

      mLogger.LogDebug(detail);
      return detail;
    }

    public string Reverse(IRecurringEventRunContext param)
    {
      string detail = "Reverse Failed";
      using (IMTServicedConnection conn = ConnectionManager.CreateConnection())
      {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\Adjustments", "__REVERSE_AUTODELETED_ADJUSTMENTS__"))
          {
              stmt.AddParam("%%INTERVAL_ID%%", param.UsageIntervalID);
              stmt.AddParam("%%BILLGROUP_ID%%", param.BillingGroupID);

              long result = stmt.ExecuteNonQuery();
              if (result < 1)
                  detail = "There were no deleted pre-bill adjustments to reverse";
              else if (result == 1)
                  detail = "Successfully reversed 1 deleted pre-bill adjustment to its prior state";
              else
                  detail = String.Format("Successfully reversed {0} deleted pre-bill adjustments to their prior state", result);
          }
      }

      mLogger.LogDebug(detail);
      return detail;
    }

    public void Shutdown()
    {
    }
  
    public bool SupportsScheduledEvents
    {
      get
      { return false; }
    }

    public bool SupportsEndOfPeriodEvents
    {
      get
      { return true; }
    }

    public ReverseMode Reversibility
    {
      get
      { return ReverseMode.Custom; }
    }

    public bool AllowMultipleInstances
    {
      get
      { return true; }
    }
  }
}

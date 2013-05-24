#region

using MetraTech.UsageServer;
//using MetraTech.Xml;

#endregion

namespace MetraTech.Tax.Adapters
{
  public class TaxCalculateAdapter : MetraTech.UsageServer.IRecurringEventAdapter2
  {
    // data

    //TODO: create actual assistant.
    private MetraTech.Tax.Framework.TaxAdapterAssistant assistant; //new MetraTech.Tax.Framework.TaxAdapterAssistant();
    private string mConfigFile;
    private Logger mLogger = new Logger("[TaxCalculateAdapter]");

    public TaxCalculateAdapter()
    {
      assistant = new Framework.TaxAdapterAssistant();
    }

    //adapter capabilities

    #region IRecurringEventAdapter Members

    public bool SupportsScheduledEvents { get { return false; } }
    public bool SupportsEndOfPeriodEvents { get { return true; } }
    public ReverseMode Reversibility { get { return ReverseMode.Custom; } }
    public bool AllowMultipleInstances { get { return false; } }
    public BillingGroupSupportType BillingGroupSupport { get { return BillingGroupSupportType.Account; } }
    public bool HasBillingGroupConstraints { get { return false; } }
    public void CreateBillingGroupConstraints(int intervalID, int materializationID) { }

    public void Initialize(string eventName, string configFile, Interop.MTAuth.IMTSessionContext context,
                           bool limitedInit)
    {
      bool status;

      mLogger.LogDebug("Initializing Calculate Tax Adapter");
      mLogger.LogDebug("Using config file: {0}", configFile);
      mConfigFile = configFile;
      mLogger.LogDebug(mConfigFile);
      if (limitedInit)
        mLogger.LogDebug("Limited initialization requested");
      else
        mLogger.LogDebug("Full initialization requested");

      status = ReadConfigFile(configFile);
      if (status)
        mLogger.LogDebug("Initialize successful");
      else
        mLogger.LogError("Initialize failed, Could not read config file");
    }

    public string Execute(IRecurringEventRunContext context)
    {
      string detail = "";

      mLogger.LogDebug("Executing Calculate Tax Adapter");

      mLogger.LogDebug("Event type = {0}", context.EventType);
      mLogger.LogDebug("Run ID = {0}", context.RunID);
      mLogger.LogDebug("Usage interval ID = {0}", context.UsageIntervalID);
      mLogger.LogDebug("Billing Group ID = {0}", context.BillingGroupID);

      assistant.SetAdapterContext(context);
      assistant.LoadTaxRunForContext();

      assistant.CalculateTaxes();

      return detail;
    }

    public string Reverse(IRecurringEventRunContext context)
    {
      string detail;
      context.RecordInfo("Starting reverse of tax calculation adapter.");

      mLogger.LogDebug("Event type = {0}", context.EventType);
      mLogger.LogDebug("Run ID = {0}", context.RunID);
      mLogger.LogDebug("Usage interval ID = {0}", context.UsageIntervalID);
      mLogger.LogDebug("Billing Group ID = {0}", context.BillingGroupID);

      assistant.SetAdapterContext(context);
      assistant.LoadTaxRunForContext();
      context.RecordInfo("Reversing Taxes ... ");
      assistant.ReverseTaxRun();

      context.RecordInfo("Done reversing tax calculation adapter.");

      detail = string.Format("Successfully reversed.");
      return detail;
    }

    public void Shutdown()
    {
      mLogger.LogDebug("Shutting down Calculate Tax Adapter");
    }

    public void SplitReverseState(int parentRunID, int parentBillingGroupID, int childRunID, int childBillingGroupID)
    {
      mLogger.LogDebug("Splitting reverse state of Calculat Tax Adapter");
    }
    
    #endregion

    private bool ReadConfigFile(string configFile)
    {
      return assistant.ReadConfigFile(configFile);
    }
  }
}

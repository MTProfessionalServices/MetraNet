#region

using MetraTech.UsageServer;
using MetraTech.Interop.QueryAdapter;

#endregion

namespace MetraTech.Tax.Adapters
{
  public class TaxOutputAdapter : MetraTech.UsageServer.IRecurringEventAdapter2
  {
    // data

    //TODO: create actual assistant.
    private MetraTech.Tax.Framework.TaxAdapterAssistant assistant; //new MetraTech.Tax.Framework.TaxAdapterAssistant();
    private string mConfigFile;
    private Logger mLogger = new Logger("[TaxOutputAdapter]");
    private static IMTQueryAdapter mQueryAdapter = new MTQueryAdapter();

    public TaxOutputAdapter()
    {
      assistant = new Framework.TaxAdapterAssistant();
      mQueryAdapter.Init(@"Queries\Tax");
    }

    //adapter capabilities

    #region IRecurringEventAdapter Members

    public bool SupportsScheduledEvents { get { return false; } }
    public bool SupportsEndOfPeriodEvents { get { return true; } }
    public ReverseMode Reversibility { get { return ReverseMode.NotNeeded; } }
    public bool AllowMultipleInstances { get { return false; } }
    public BillingGroupSupportType BillingGroupSupport { get { return BillingGroupSupportType.Account; } }
    public bool HasBillingGroupConstraints { get { return false; } }
    public void CreateBillingGroupConstraints(int intervalID, int materializationID) { }

    public void Initialize(string eventName, string configFile, Interop.MTAuth.IMTSessionContext context,
                           bool limitedInit)
    {
      bool status;

      mLogger.LogDebug("Initializing Tax Output Adapter");
      mLogger.LogDebug("Using config file: {0}", configFile);
      mConfigFile = configFile;
      mLogger.LogDebug(mConfigFile);
      mLogger.LogDebug(limitedInit ? "Limited initialization requested" : "Full initialization requested");

      status = ReadConfigFile(configFile);
      if (status)
        mLogger.LogDebug("Initialize successful");
      else
        mLogger.LogError("Initialize failed, Could not read config file");
    }

    public string Execute(IRecurringEventRunContext context)
    {
      var detail = "";
      mLogger.LogDebug("Executing Tax Output Adapter");
      context.RecordInfo("Starting tax output adapter.");

      mLogger.LogDebug("Event type = {0}", context.EventType);
      mLogger.LogDebug("Run ID = {0}", context.RunID);
      mLogger.LogDebug("Usage interval ID = {0}", context.UsageIntervalID);
      mLogger.LogDebug("Billing Group ID = {0}", context.BillingGroupID);

      assistant.SetAdapterContext(context);
      assistant.LoadTaxRunForContext();
      context.RecordInfo("Updating based on results from tax calculation.");
      assistant.FetchTaxResultsFromTaxOutputTable();

      context.RecordInfo("Tax output adapter done.");

      //TODO: return something useful
      return detail;
    }

    public string Reverse(IRecurringEventRunContext context)
    {
      string detail;

      context.RecordInfo("Starting reverse of tax output adapter.");

      // When Adapter ran, it called the hook to update some tables with tax results
      // We will not clean them and treat the data as estimates.
      // So there is nothing to do.
      detail = string.Format("Nothing to do");

      context.RecordInfo("Reverse of tax output adapter done.");
      return detail;
    }

    public void Shutdown()
    {
      mLogger.LogDebug("Shutting down Tax Output Adapter");
    }

    public void SplitReverseState(int parentRunID, int parentBillingGroupID, int childRunID, int childBillingGroupID)
    {
      mLogger.LogDebug("Splitting reverse state of Tax Output Adapter");
    }
    
    #endregion

    private bool ReadConfigFile(string configFile)
    {
      return assistant.ReadConfigFile(configFile);
    }
  }
}

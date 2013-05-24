#region

using MetraTech.UsageServer;
//using MetraTech.Xml;

#endregion

namespace MetraTech.Tax.Adapters
{
  public class TaxInputAdapter : MetraTech.UsageServer.IRecurringEventAdapter2
  {
    // data

    //TODO: create actual assistant.
    private MetraTech.Tax.Framework.TaxAdapterAssistant assistant; //new MetraTech.Tax.Framework.TaxAdapterAssistant();
    private string mConfigFile;
    private Logger mLogger = new Logger("[TaxInputAdapter]");

    public TaxInputAdapter()
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

      mLogger.LogDebug("Initializing Tax Input Adapter");
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
      mLogger.LogDebug("Executing Prepare Tax Input Adapter");

      context.RecordInfo("Starting tax input adapter.");

      mLogger.LogDebug("Event type = {0}", context.EventType);
      mLogger.LogDebug("Run ID = {0}", context.RunID);
      mLogger.LogDebug("Usage interval ID = {0}", context.UsageIntervalID);
      mLogger.LogDebug("Billing Group ID = {0}", context.BillingGroupID);

      assistant.SetAdapterContext(context);
      assistant.GenerateTaxRunForContext(); //save tax run id in the database
      int tax_run_id = assistant.TaxRunId;

      context.RecordInfo("Creating tax input table. ");
      assistant.CreateTaxInputTable();

      context.RecordInfo("Populating tax input table. ");
      assistant.PopulateTaxInputTableWithCharges();

      context.RecordInfo("Building tax input table indices ");
      assistant.CreateTaxInputIndexes();

      context.RecordInfo("Tax input adapter done.");

      detail = string.Format("TaxRunID {0} created.", tax_run_id);
      return detail;
    }

    public string Reverse(IRecurringEventRunContext context)
    {
      string detail;
      mLogger.LogDebug("Reversing Prepare Tax Input Adapter");

      context.RecordInfo("Starting reverse of tax input adapter.");

      mLogger.LogDebug("Event type = {0}", context.EventType);
      mLogger.LogDebug("Run ID = {0}", context.RunID);
      mLogger.LogDebug("Usage interval ID = {0}", context.UsageIntervalID);
      mLogger.LogDebug("Billing Group ID = {0}", context.BillingGroupID);

      assistant.SetAdapterContext(context);
      assistant.LoadTaxRunForContext();
      int tax_run_id = assistant.TaxRunId;
      //TODO: Figure out what should the behavior be when adapter failed and this tables have not been created.

      context.RecordInfo("Dropping tax input table.");
      assistant.DropInputTable();

      assistant.DeleteTaxRunForContext();
      detail = string.Format("TaxRunID {0} reversed", tax_run_id);

      context.RecordInfo("Reverse of tax input adapter done.");

      return detail;
    }

    public void Shutdown()
    {
      mLogger.LogDebug("Shutting down Tax Input Adapter");
    }

    public void SplitReverseState(int parentRunID, int parentBillingGroupID, int childRunID, int childBillingGroupID)
    {
      mLogger.LogDebug("Splitting reverse state of Tax Input Adapter");
    }

    #endregion

    private bool ReadConfigFile(string configFile)
    {
      return assistant.ReadConfigFile(configFile);
    }
  }
}

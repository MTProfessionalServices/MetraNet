#region

using MetraTech.UsageServer;
//using MetraTech.Xml;

#endregion

namespace MetraTech.Tax.Adapters
{
  public class TaxScheduledAdapter : MetraTech.UsageServer.IRecurringEventAdapter
  {
    // data

    //TODO: create actual assistant.
    private MetraTech.Tax.Framework.TaxAdapterAssistant assistant; //new MetraTech.Tax.Framework.TaxAdapterAssistant();
    private string mConfigFile;
    private Logger mLogger = new Logger("[TaxScheduledAdapter]");

    public TaxScheduledAdapter()
    {
      assistant = new Framework.TaxAdapterAssistant();
    }

    //adapter capabilities

    #region IRecurringEventAdapter Members

    public bool SupportsScheduledEvents { get { return true; } }
    public bool SupportsEndOfPeriodEvents { get { return false; } }
    public ReverseMode Reversibility { get { return ReverseMode.Custom; } }
    public bool AllowMultipleInstances { get { return false; } }
    //public BillingGroupSupportType BillingGroupSupport { get { return BillingGroupSupportType.Interval; } }
    public bool HasBillingGroupConstraints { get { return false; } }


    public void Initialize(string eventName, string configFile, Interop.MTAuth.IMTSessionContext context,
                           bool limitedInit)
    {
      bool status;

      mLogger.LogDebug("Initializing Tax Scheduled Adapter");
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
      mLogger.LogDebug("Executing Prepare Tax Scheduled Adapter");

      mLogger.LogDebug("Event type = {0}", context.EventType);
      mLogger.LogDebug("Run ID = {0}", context.RunID);
      mLogger.LogDebug("Usage interval ID = {0}", context.UsageIntervalID);
      mLogger.LogDebug("Billing Group ID = {0}", context.BillingGroupID);
      mLogger.LogDebug("Start Date = {0}", context.StartDate.ToString());
      mLogger.LogDebug("End Date ID = {0}", context.EndDate.ToString());


      assistant.SetAdapterContext(context);
      assistant.GenerateTaxRunForContext(); //save tax run id in the database
      int tax_run_id = assistant.TaxRunId;
      context.RecordInfo("Creating Tax Scheduled table ... ");
      assistant.CreateTaxInputTable();
      context.RecordInfo("Populating input table with charges ... ");
      assistant.PopulateTaxInputTableWithCharges();
      context.RecordInfo("Building indexes on the Tax Scheduled table ... ");
      assistant.CreateTaxInputIndexes();
      detail = string.Format("TaxRunID {0} created.", tax_run_id);

      context.RecordInfo("Calculating Taxes ... ");
      assistant.CalculateTaxes();

      context.RecordInfo("Fetching results from the tax output table ... ");
      assistant.FetchTaxResultsFromTaxOutputTable();

      return detail;
    }

    public string Reverse(IRecurringEventRunContext context)
    {
      string detail;
      mLogger.LogDebug("Reversing Prepare Tax Scheduled Adapter");

      mLogger.LogDebug("Event type = {0}", context.EventType);
      mLogger.LogDebug("Run ID = {0}", context.RunID);
      mLogger.LogDebug("Usage interval ID = {0}", context.UsageIntervalID);
      mLogger.LogDebug("Billing Group ID = {0}", context.BillingGroupID);
      mLogger.LogDebug("Start Date = {0}", context.StartDate.ToString());
      mLogger.LogDebug("End Date ID = {0}", context.EndDate.ToString());

      assistant.SetAdapterContext(context);
      assistant.LoadTaxRunForContext();
      int tax_run_id = assistant.TaxRunId;

      context.RecordInfo("Reversing Taxes ... ");
      assistant.ReverseTaxRun();

      context.RecordInfo("Dropping Tax Scheduled table ... ");
      assistant.DropInputTable();
      assistant.DeleteTaxRunForContext();

      detail = string.Format("TaxRunID {0} reversed", tax_run_id);
      return detail;
    }

    public void Shutdown()
    {
      mLogger.LogDebug("Shutting down Tax Scheduled Adapter");
    }

    #endregion

    private bool ReadConfigFile(string configFile)
    {
      return assistant.ReadConfigFile(configFile);
    }
  }
}
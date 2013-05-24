using System;
using System.Xml;
using System.Diagnostics;
using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.UsageServer;
using MetraTech.Interop.MTAuth;
//using MetraTech.Interop.RCD;
using RCD = MetraTech.Interop.RCD;
using System.IO;
using System.Text.RegularExpressions;


// <xmlconfig>
//	<StoredProcs>
//		<CalculateInvoice>mtsp_InsertInvoice</CalculateInvoice>
//		<GenInvoiceNumbers>mtsp_GenerateInvoiceNumbers</GenInvoiceNumbers>
//	</StoredProcs>
//	<IsSample>N</IsSample>
// </xmlconfig>

//[assembly: AssemblyKeyFile("")]  //ask

namespace MetraTech.UsageServer.Adapters
{
  /// <summary>
  /// Invoice Adapter, used to generate invoices at EOP.
  /// </summary>
  public class MetraARInvoiceExportAdapter : MetraTech.UsageServer.IRecurringEventAdapter2
  {
    // data
    private Logger mLogger = new Logger("[MetraARInvoiceExportAdapter]");
    private MetraFlowConfig mMetraFlowConfig;
    private String mTempDir;
    private String mConfigFile;

    //adapter capabilities
    public bool SupportsScheduledEvents { get { return false; } }
    public bool SupportsEndOfPeriodEvents { get { return true; } }
    public ReverseMode Reversibility { get { return ReverseMode.NotNeeded; } }
    public bool AllowMultipleInstances { get { return false; } }
    public void CreateBillingGroupConstraints(int intervalID, int materializationID) { }
    public BillingGroupSupportType BillingGroupSupport { get { return BillingGroupSupportType.Account; } }
    public bool HasBillingGroupConstraints { get { return false; } }

    public MetraARInvoiceExportAdapter()
    {
      mMetraFlowConfig = null;
    }

    public void Initialize(string eventName, string configFile, IMTSessionContext context, bool limitedInit)
    {
      bool status;

      mLogger.LogDebug("Initializing MetraARInvoiceExportAdapter");
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

    public string Execute(IRecurringEventRunContext param)
    {
      mLogger.LogDebug("Executing MetraARInvoiceExportAdapter");

      mLogger.LogDebug("Event type = {0}", param.EventType);
      mLogger.LogDebug("Run ID = {0}", param.RunID);
      mLogger.LogDebug("Usage interval ID = {0}", param.UsageIntervalID);
      mLogger.LogDebug("Billing Group ID = {0}", param.BillingGroupID);

      if (!Directory.Exists(mTempDir))
      {
        string msg = string.Format("Temp directory {0} specified in config file {1} not found!", mTempDir, mConfigFile);
        mLogger.LogWarning(msg);
        try
        {
          Directory.CreateDirectory(mTempDir);
        }
        catch (Exception ex)
        {
          string exmsg = string.Format("Cannot create directory {0}", mTempDir);
          mLogger.LogException(exmsg, ex);
          throw new Exception(exmsg, ex);
        }
      }

      param.RecordInfo("Exporting Account Contact data to MetraAR ... ");

      RCD.IMTRcd rcd = new RCD.MTRcd();
      string pathToScripts = Path.Combine(rcd.ExtensionDir, @"AccountsReceivableClient\Config\MetraFlow\Scripts\");
      if (!Directory.Exists(pathToScripts)) 
        throw new ApplicationException(string.Format("Where is scripts folder?! {0} not found", pathToScripts));

      string extractProgram = System.IO.File.ReadAllText(Path.Combine(pathToScripts, "AccountExport.mfs"));
      extractProgram = Regex.Replace(extractProgram, "%%TEMP_DIR%%", mTempDir);
      extractProgram = Regex.Replace(extractProgram, "%%ID_INTERVAL%%", param.UsageIntervalID.ToString());
      extractProgram = Regex.Replace(extractProgram, "%%ID_BILLGROUP%%", param.BillingGroupID.ToString());

      MetraFlowRun r = new MetraFlowRun();
      int ret = r.Run(extractProgram, "[MetraARInvoiceExportAdapter]", mMetraFlowConfig);
      if (ret != 0)
      {
        throw new ApplicationException("MetraARInvoiceExportAdapter failed during Account Export.  Check log for details.");
      }

      param.RecordInfo("Exporting Invoice records to MetraAR... ");

      string myprogram = System.IO.File.ReadAllText(Path.Combine(pathToScripts, "InvoiceExport.mfs"));
      myprogram = Regex.Replace(myprogram, "%%TEMP_DIR%%", mTempDir);
      myprogram = Regex.Replace(myprogram, "%%ID_INTERVAL%%", param.UsageIntervalID.ToString());
      myprogram = Regex.Replace(myprogram, "%%ID_BILLGROUP%%", param.BillingGroupID.ToString());
      r = new MetraFlowRun();
      ret = r.Run(myprogram, "[MetraARInvoiceExportAdapter]", mMetraFlowConfig);
      if (ret != 0)
      {
        throw new ApplicationException("Invoice adapter failed during invoice creation.  Check log for details.");
      }

      param.RecordInfo("Comparing totals for invoices in the interval in NetMeter and MetraAR. Matching totals is our only way to see if adapter succeded");
      string UsageIntervalId = param.UsageIntervalID.ToString();
      IntervalTotals BillingTotal = GetIntervalTotalsFromBilling(UsageIntervalId);
      IntervalTotals ArTotal = GetIntervalTotalsFromAR(UsageIntervalId);
      if (!BillingTotal.Equals(ArTotal))
      {
        mLogger.LogError("Totals amounts for invoices do not match in Billing and AR systems. Billing reported {0}, AR reported {1}",
          BillingTotal.ToString(), ArTotal.ToString());
        mLogger.LogError("This means that MetraFlow operator had non fatal errors synchronizing data.");
        mLogger.LogError("Possible causes - null constraint violations on insert to account or invoice. No domains in the system, etc...");
        throw new ApplicationException("Adapter finished, but totals do not match in Billing and AR systems. Check log for details");
      }

      string returnMessage = String.Format("Exported {0}", ArTotal.ToString());
      mLogger.LogInfo(returnMessage);
      return returnMessage;
    }

    private class IntervalTotals
    {
      public decimal InvoiceAmountTotal;
      public int InvoiceCount;
      
      public void Load(IMTDataReader rdr) {
        if (!rdr.IsDBNull(0))
          InvoiceAmountTotal = rdr.GetDecimal(0);
        if (!rdr.IsDBNull(1))
          InvoiceCount = rdr.GetInt32(1);
      }

      public override bool Equals(object obj)
      {
        //Check for null and compare run-time types.
        if (obj == null || GetType() != obj.GetType()) return false;
        IntervalTotals it = (IntervalTotals)obj;
        return (it.InvoiceCount == InvoiceCount && it.InvoiceAmountTotal == InvoiceAmountTotal);
      }

      public override int GetHashCode()
      {
        return InvoiceCount;
      }

      public override string ToString()
      {
        return string.Format("{0} invoice{1}, total amount {2}", InvoiceCount, InvoiceCount == 1 ? "" : "s", InvoiceAmountTotal);
      }
    }

    private IntervalTotals GetIntervalTotalsFromBilling(string UsageIntervalId)
    {
      IntervalTotals totals = new IntervalTotals();
      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\ARClient", "__GET_INVOICE_TOTAL_FOR_INTERVAL__"))
          {
            stmt.AddParam("%%ID_INTERVAL%%", UsageIntervalId);
            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
              if (rdr.Read())
                totals.Load(rdr);
            }
          }
        }
      }
      catch (Exception e)
      {
        mLogger.LogException(String.Format("Unable to retrieve totals for interval {0} from NetMeter", UsageIntervalId), e);
        throw;
      }
      return totals;
    }

    private IntervalTotals GetIntervalTotalsFromAR(string UsageIntervalId)
    {
      IntervalTotals totals = new IntervalTotals();
      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\ARClient", "__GET_AR_INVOICE_TOTAL_FOR_INTERVAL__"))
          {
            stmt.AddParam("%%ID_INTERVAL%%", UsageIntervalId);
            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
              if (rdr.Read())
                totals.Load(rdr);
            }
          }
        }
      }
      catch (Exception e)
      {
        mLogger.LogException(String.Format("Unable to retrieve totals for interval {0} from MetraAR", UsageIntervalId), e);
        throw;
      }
      return totals;
    }

    public string Reverse(IRecurringEventRunContext param)
    {
      // We are not reversable so don't bother implementing
      return "Not reversable";
    }

    public void Shutdown()
    {
      mLogger.LogDebug("Shutting down MetraAR Invoice Export Adapter");

    }

    public void SplitReverseState(int parentRunID,
                                  int parentBillingGroupID,
                                  int childRunID,
                                  int childBillingGroupID)
    {
      mLogger.LogDebug("Splitting reverse state of MetraAR Invoice Export Adapter");
    }

    private bool ReadConfigFile(string configFile)
    {
      MTXmlDocument doc = new MTXmlDocument();
      doc.Load(configFile);
      if (null != doc.SingleNodeExists("/xmlconfig/TempDir"))
      {
        mTempDir = doc.GetNodeValueAsString("/xmlconfig/TempDir");
      }
      else
      {
        mTempDir = System.Environment.GetEnvironmentVariable("TEMP");
      }

      mMetraFlowConfig = new MetraFlowConfig();
      mMetraFlowConfig.Load(configFile);
      return (true);
    }

  }

}

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml;
using System.Xml.Linq;
using MetraTech.Basic.Config;

namespace MetraTech.Quoting
{
  public class QuotingConfiguration
  {
    //Configuration stuff needed
    //Hard code for now and then we can worry about reading/writing

    public int MeteringSessionSetSize { get; set; }
    public string RecurringChargeServerToMeterTo { get; set; }
    public string RecurringChargeStoredProcedureQueryTag { get; set; }
    public string NonRecurringChargeStoredProcedureQueryTag { get; set; }
    public string GetUsageIntervalIdForQuotingQueryTag { get; set; }
    public string CalculateQuoteTotalAmountQueryTag { get; set; }
    public string RemoveRCMetricValuesQueryTag { get; set; }
    public string GetAccountBillingCycleQueryTag { get; set; }
    public string GetAccountPayerQueryTag { get; set; }

    public string ReportDefaultTemplateName { get; set; }
    public string ReportInstancePartialPath { get; set; }

    //Read from the system configuration, this value allows quoting to know
    //if it is on a development or production system (currently used only for controlling if
    //usage can be saved for debugging quotes and reports)
    public bool CurrentSystemIsProductionSystem { get; set; }

  }

  public class QuotingConfigurationManager
  {
    private static Logger m_Logger = new Logger("[Quoting Configuration Manager]");

    const string FILE_NAME = "QuotingConfiguration.xml";
    static string filePath = Path.Combine(SystemConfig.GetRmpDir(), "config", "Quoting", FILE_NAME);

    // Default configuration values
    const string DEFAULT_RECCURING_CHARGE_SERVER_TO_METER_TO = "DiscountServer";
    const string DEFAULT_RECCURING_CHARGE_STORED_PROCEDURE_QUERY_TAG = "MTSP_GENERATE_ST_RCS_QUOTING"; // "mtsp_generate_stateful_rcs";
    const string DEFAULT_NON_RECCURING_CHARGE_STORED_PROCEDURE_QUERY_TAG = "MTSP_GENERATE_ST_NRCS_QUOTING"; // "mtsp_generate_stateful_nrcs";
    const string DEFAULT_GET_USAGE_INTERVAL_ID_FOR_QUOTING_QUERY_TAG = "__GET_USAGE_INTERVAL_ID_FOR_QUOTING__";
    const string DEFAULT_CALCULATE_QUOTE_TOTAL_AMOUNT_QUERY_TAG = "__GET_QUOTE_TOTAL_AMOUNT__";
    const string DEFAULT_REMOVE_RC_METRIC_VALUES_QUERY_TAG = "__REMOVE_RC_METRIC_VALUES__";
    const string DEFAULT_GET_ACCOUNT_BILLING_CYCLE_QUERY_TAG = "__GET_ACCOUNT_BILLING_CYCLE__";
    const string DEFAULT_GET_ACCOUNT_PAYER_QUERY_TAG = "__GET_ACCOUNT_PAYER__";
    const int DEFAULT_METERING_SESSION_SET_SIZE = 500;
    const bool DEFAULT_CURRENT_SYSTEM_IS_PRODUCTION_SYSTEM = false;
    const string DEFAULT_REPORT_DEFAULT_TEMPLATE_NAME = "Quote Report";
    const string DEFAULT_REPORT_INSTANCE_PARTIAL_PATH = @"\Quotes\{AccountId}\Quote_{QuoteId}";

    public static string FilePath
    {
      get
      {
        return filePath;
      }
      set
      {
        filePath = value;
      }
    }
    
    public static void WriteConfigurationToFile(QuotingConfiguration configuration)
    {
      try
      {
        if (!File.Exists(FilePath))
        {
          XmlDocument document = new XmlDocument();

          XmlNode node = new XmlDocument();
          node = document.CreateNode(XmlNodeType.XmlDeclaration, "", "");
          document.AppendChild(node);

          node = document.CreateNode(XmlNodeType.Element, "QuotingConfiguration", "");
          document.AppendChild(node);

          document.Save(FilePath);
        }

        XElement doc = XElement.Load(FilePath);
        
        doc.ReplaceAll(new XElement("RecurringChargeServerToMeterTo", configuration.RecurringChargeServerToMeterTo),
                  new XElement("RecurringChargeStoredProcedureQueryTag",
                               configuration.RecurringChargeStoredProcedureQueryTag),
                  new XElement("NonRecurringChargeStoredProcedureQueryTag",
                               configuration.NonRecurringChargeStoredProcedureQueryTag),
                  new XElement("GetUsageIntervalIdForQuotingQueryTag",
                               configuration.GetUsageIntervalIdForQuotingQueryTag),
                  new XElement("CalculateQuoteTotalAmountQueryTag", configuration.CalculateQuoteTotalAmountQueryTag),
                  new XElement("RemoveRCMetricValuesQueryTag", configuration.RemoveRCMetricValuesQueryTag),
                  new XElement("GetAccountBillingCycleQueryTag", configuration.GetAccountBillingCycleQueryTag),
                  new XElement("GetAccountPayerQueryTag", configuration.GetAccountPayerQueryTag),
                  new XElement("MeteringSessionSetSize", configuration.MeteringSessionSetSize),
                  new XElement("CurrentSystemIsProductionSystem", configuration.CurrentSystemIsProductionSystem),
                  new XElement("ReportDefaultTemplateName", configuration.ReportDefaultTemplateName),
                  new XElement("ReportInstancePartialPath", configuration.ReportInstancePartialPath));


        doc.Save(FilePath);
      }
      catch (Exception ex)
      {
        m_Logger.LogException("Exception while writting configuration", ex);
        throw ex;
      }
    }

    public static QuotingConfiguration WriteDefaultConfigurationToFile()
    {
      QuotingConfiguration configuration = new QuotingConfiguration();

      configuration.RecurringChargeServerToMeterTo = DEFAULT_RECCURING_CHARGE_SERVER_TO_METER_TO;
      configuration.RecurringChargeStoredProcedureQueryTag = DEFAULT_RECCURING_CHARGE_STORED_PROCEDURE_QUERY_TAG;
      configuration.NonRecurringChargeStoredProcedureQueryTag = DEFAULT_NON_RECCURING_CHARGE_STORED_PROCEDURE_QUERY_TAG;
      configuration.GetUsageIntervalIdForQuotingQueryTag = DEFAULT_GET_USAGE_INTERVAL_ID_FOR_QUOTING_QUERY_TAG;
      configuration.CalculateQuoteTotalAmountQueryTag = DEFAULT_CALCULATE_QUOTE_TOTAL_AMOUNT_QUERY_TAG;
      configuration.RemoveRCMetricValuesQueryTag = DEFAULT_REMOVE_RC_METRIC_VALUES_QUERY_TAG;
      configuration.GetAccountBillingCycleQueryTag = DEFAULT_GET_ACCOUNT_BILLING_CYCLE_QUERY_TAG;
      configuration.GetAccountPayerQueryTag = DEFAULT_GET_ACCOUNT_PAYER_QUERY_TAG;
      configuration.MeteringSessionSetSize = DEFAULT_METERING_SESSION_SET_SIZE;
      configuration.CurrentSystemIsProductionSystem = DEFAULT_CURRENT_SYSTEM_IS_PRODUCTION_SYSTEM;
      configuration.ReportDefaultTemplateName = DEFAULT_REPORT_DEFAULT_TEMPLATE_NAME;
      configuration.ReportInstancePartialPath = DEFAULT_REPORT_INSTANCE_PARTIAL_PATH;

      WriteConfigurationToFile(configuration);

      return configuration;
    }

    public static QuotingConfiguration LoadConfigurationFromFile()
    {
      QuotingConfiguration loadedConfiguration;

      try
      {
        if (File.Exists(filePath))
        {
          XElement doc = XElement.Load(filePath);

          if (doc.HasElements)
          {
            var configuration = from config in doc.DescendantsAndSelf()
                                select new QuotingConfiguration()
                                {
                                  RecurringChargeServerToMeterTo = config.GetElementValue("RecurringChargeServerToMeterTo", DEFAULT_RECCURING_CHARGE_SERVER_TO_METER_TO),
                                  RecurringChargeStoredProcedureQueryTag = config.GetElementValue("RecurringChargeStoredProcedureQueryTag", DEFAULT_RECCURING_CHARGE_STORED_PROCEDURE_QUERY_TAG),
                                  NonRecurringChargeStoredProcedureQueryTag = config.GetElementValue("NonRecurringChargeStoredProcedureQueryTag", DEFAULT_NON_RECCURING_CHARGE_STORED_PROCEDURE_QUERY_TAG),
                                  GetUsageIntervalIdForQuotingQueryTag = config.GetElementValue("GetUsageIntervalIdForQuotingQueryTag", DEFAULT_GET_USAGE_INTERVAL_ID_FOR_QUOTING_QUERY_TAG),
                                  CalculateQuoteTotalAmountQueryTag = config.GetElementValue("CalculateQuoteTotalAmountQueryTag", DEFAULT_CALCULATE_QUOTE_TOTAL_AMOUNT_QUERY_TAG),
                                  RemoveRCMetricValuesQueryTag = config.GetElementValue("RemoveRCMetricValuesQueryTag", DEFAULT_REMOVE_RC_METRIC_VALUES_QUERY_TAG),
                                  GetAccountBillingCycleQueryTag = config.GetElementValue("GetAccountBillingCycleQueryTag", DEFAULT_GET_ACCOUNT_BILLING_CYCLE_QUERY_TAG),
                                  GetAccountPayerQueryTag = config.GetElementValue("GetAccountPayerQueryTag", DEFAULT_GET_ACCOUNT_PAYER_QUERY_TAG),
                                  MeteringSessionSetSize = config.GetElementValue("MeteringSessionSetSize", DEFAULT_METERING_SESSION_SET_SIZE),
                                  CurrentSystemIsProductionSystem = config.GetElementValue("CurrentSystemIsProductionSystem", DEFAULT_CURRENT_SYSTEM_IS_PRODUCTION_SYSTEM),
                                  ReportDefaultTemplateName = config.GetElementValue("ReportDefaultTemplateName", DEFAULT_REPORT_DEFAULT_TEMPLATE_NAME),
                                  ReportInstancePartialPath = config.GetElementValue("ReportInstancePartialPath", DEFAULT_REPORT_INSTANCE_PARTIAL_PATH)
                                };

            loadedConfiguration = configuration.First();
          }
          else
          {
            loadedConfiguration = WriteDefaultConfigurationToFile();
          }
        }
        else
        {
          loadedConfiguration = WriteDefaultConfigurationToFile();
        }
      }
      catch (Exception ex)
      {
        m_Logger.LogException("Exception while loading configuration", ex);
        throw ex;
      }

      return loadedConfiguration;
    }
  }
}

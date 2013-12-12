using System;
using System.IO;
using System.Linq;
using System.Xml;
using System.Xml.Linq;
using MetraTech.Basic.Config;

namespace MetraTech.Core.Services.Quoting
{
  /// <summary>
  /// Class for reading/writing the quoting configuration
  /// </summary>
  public class QuotingConfigurationManager
  {
    private static ILogger m_Logger = new Logger("[Quoting Configuration Manager]");

    // Default configuration values
    const string DEFAULT_RECCURING_CHARGE_SERVER_TO_METER_TO = "DiscountServer";
    const string DEFAULT_RECCURING_CHARGE_STORED_PROCEDURE_QUERY_TAG = "MTSP_GENERATE_ST_RCS_QUOTING"; // "mtsp_generate_stateful_rcs";
    const string DEFAULT_NON_RECCURING_CHARGE_STORED_PROCEDURE_QUERY_TAG = "MTSP_GENERATE_ST_NRCS_QUOTING"; // "mtsp_generate_stateful_nrcs";
    const string DEFAULT_GET_USAGE_INTERVAL_ID_FOR_QUOTING_QUERY_TAG = "__GET_USAGE_INTERVAL_ID_FOR_QUOTING__";
    const string DEFAULT_CALCULATE_QUOTE_TOTAL_AMOUNT_QUERY_TAG = "__GET_QUOTE_TOTAL_AMOUNT__";
    const string DEFAULT_GET_MAX_QUOTE_ID_QUERY_TAG = "__GET_MAX_QUOTE_ID__";
    const string DEFAULT_BACKUP_QUOTE_USAGES_QUERY_TAG = "__BACKUP_QUOTE_USAGES__";
    const string DEFAULT_REMOVE_QUOTE_USAGES_QUERY_TAG = "__REMOVE_QUOTE_USAGES__";
    const string DEFAULT_COUNT_TOTAL_QUOTE_USAGES_QUERY_TAG = "__COUNT_TOTAL_QUOTE_USAGES__";
    const string DEFAULT_REMOVE_RC_METRIC_VALUES_QUERY_TAG = "__REMOVE_RC_METRIC_VALUES__";
    const string DEFAULT_GET_ACCOUNT_BILLING_CYCLE_QUERY_TAG = "__GET_ACCOUNT_BILLING_CYCLE__";
    const string DEFAULT_GET_ACCOUNT_PAYER_QUERY_TAG = "__GET_ACCOUNT_PAYER__";
    const int DEFAULT_METERING_SESSION_SET_SIZE = 500;
    const string DEFAULT_REPORT_DEFAULT_TEMPLATE_NAME = "Quote Report";
    const string DEFAULT_REPORT_INSTANCE_PARTIAL_PATH = @"\Quotes\{AccountId}\Quote_{QuoteId}";
    const string DEFAULT_QUOTING_QUERY_FOLDER = @"Queries\Quoting";
    const bool DEFAULT_IS_CLEANUP_QUOTE_AUTOMATICALY = true;
    const bool DEFAULT_IS_ALLOWED_USE_ACTIVITY_SERVICE_FOR_QUOTE_CREATION = true;

    public static string DefaultSystemConfigurationFilePath
    {
      get { return Path.Combine(SystemConfig.GetRmpDir(), "config", "Quoting", "QuotingConfiguration.xml"); }
    }

    /// <summary>
    /// Load the quoting configuration from the default system location
    /// </summary>
    /// <returns></returns>
    public static QuotingConfiguration LoadConfigurationFromDefaultSystemLocation()
    {
      return LoadConfigurationFromFile(DefaultSystemConfigurationFilePath);
    }

    /// <summary>
    /// Load the quoting configuration from the specified file
    /// </summary>
    /// <param name="filePath"></param>
    /// <returns></returns>
    public static QuotingConfiguration LoadConfigurationFromFile(string filePath)
    {
      QuotingConfiguration loadedConfiguration;

      try
      {
        if (File.Exists(filePath))
        {
          XElement doc = XElement.Load(filePath);

          if (doc.HasElements)
          {
            var configuration =
              from config in doc.DescendantsAndSelf()
              select new QuotingConfiguration()
                  {
                    RecurringChargeServerToMeterTo =
                        config.GetElementValueOrDefault("RecurringChargeServerToMeterTo", DEFAULT_RECCURING_CHARGE_SERVER_TO_METER_TO),
                    RecurringChargeStoredProcedureQueryTag =
                        config.GetElementValueOrDefault("RecurringChargeStoredProcedureQueryTag", DEFAULT_RECCURING_CHARGE_STORED_PROCEDURE_QUERY_TAG),
                    NonRecurringChargeStoredProcedureQueryTag =
                        config.GetElementValueOrDefault("NonRecurringChargeStoredProcedureQueryTag", DEFAULT_NON_RECCURING_CHARGE_STORED_PROCEDURE_QUERY_TAG),
                    GetUsageIntervalIdForQuotingQueryTag =
                        config.GetElementValueOrDefault("GetUsageIntervalIdForQuotingQueryTag", DEFAULT_GET_USAGE_INTERVAL_ID_FOR_QUOTING_QUERY_TAG),
                    CalculateQuoteTotalAmountQueryTag =
                        config.GetElementValueOrDefault("CalculateQuoteTotalAmountQueryTag", DEFAULT_CALCULATE_QUOTE_TOTAL_AMOUNT_QUERY_TAG),
                    GetMaxQuoteIdQueryTag =
                        config.GetElementValueOrDefault("GetMaxQuoteIdQueryTag", DEFAULT_GET_MAX_QUOTE_ID_QUERY_TAG),
                    BackupQuoteUsagesQueryTag =
                        config.GetElementValueOrDefault("BackupQuoteUsagesQueryTag", DEFAULT_BACKUP_QUOTE_USAGES_QUERY_TAG),
                    RemoveQuoteUsagesQueryTag =
                        config.GetElementValueOrDefault("RemoveQuoteUsagesQueryTag", DEFAULT_REMOVE_QUOTE_USAGES_QUERY_TAG),
                    CountTotalQuoteUsagesQueryTag =
                        config.GetElementValueOrDefault("CountTotalQuoteUsagesQueryTag", DEFAULT_COUNT_TOTAL_QUOTE_USAGES_QUERY_TAG),
                    RemoveRCMetricValuesQueryTag =
                        config.GetElementValueOrDefault("RemoveRCMetricValuesQueryTag", DEFAULT_REMOVE_RC_METRIC_VALUES_QUERY_TAG),
                    GetAccountBillingCycleQueryTag =
                        config.GetElementValueOrDefault("GetAccountBillingCycleQueryTag", DEFAULT_GET_ACCOUNT_BILLING_CYCLE_QUERY_TAG),
                    GetAccountPayerQueryTag =
                        config.GetElementValueOrDefault("GetAccountPayerQueryTag", DEFAULT_GET_ACCOUNT_PAYER_QUERY_TAG),
                    MeteringSessionSetSize =
                        config.GetElementValueOrDefault("MeteringSessionSetSize", DEFAULT_METERING_SESSION_SET_SIZE),
                    ReportDefaultTemplateName =
                        config.GetElementValueOrDefault("ReportDefaultTemplateName", DEFAULT_REPORT_DEFAULT_TEMPLATE_NAME),
                    ReportInstancePartialPath =
                        config.GetElementValueOrDefault("ReportInstancePartialPath", DEFAULT_REPORT_INSTANCE_PARTIAL_PATH),
                    QuotingQueryFolder =
                        config.GetElementValueOrDefault("QuotingQueryFolder", DEFAULT_QUOTING_QUERY_FOLDER),
                    IsCleanupQuoteAutomaticaly =
                        config.GetElementValueOrDefault("IsCleanupQuoteAutomaticaly", DEFAULT_IS_CLEANUP_QUOTE_AUTOMATICALY),
                    IsAllowedUseActivityService =
                        config.GetElementValueOrDefault("IsAllowedUseActivityService", DEFAULT_IS_ALLOWED_USE_ACTIVITY_SERVICE_FOR_QUOTE_CREATION)
                  };

            loadedConfiguration = configuration.First();
          }
          else
          {
            var message =
              string.Format("Expected quoting configuration in file {0} but file did not contain elements", filePath);
            throw new Exception(message);
          }

        }
        else
        {
          var message = string.Format("Quoting configuration file does not exist: {0}", filePath);
          throw new Exception(message);
        }
      }
      catch (Exception ex)
      {
        m_Logger.LogException(string.Format("Exception while loading quoting configuration from file {0}", filePath), ex);
        throw;
      }

      return loadedConfiguration;
    }

    #region Write methods, useful for testing and eventually to aid in configuration editing from places such as ICE
    public static void WriteConfigurationToFile(QuotingConfiguration config, string filePath)
    {
      try
      {
        if (!File.Exists(filePath))
        {
          var document = new XmlDocument();

          var node = document.CreateNode(XmlNodeType.XmlDeclaration, "", "");
          document.AppendChild(node);

          node = document.CreateNode(XmlNodeType.Element, "QuotingConfiguration", "");
          document.AppendChild(node);

          document.Save(filePath);
        }

        var doc = XElement.Load(filePath);

        doc.ReplaceAll(new XElement("RecurringChargeServerToMeterTo", config.RecurringChargeServerToMeterTo),
                  new XElement("RecurringChargeStoredProcedureQueryTag", config.RecurringChargeStoredProcedureQueryTag),
                  new XElement("NonRecurringChargeStoredProcedureQueryTag", config.NonRecurringChargeStoredProcedureQueryTag),
                  new XElement("GetUsageIntervalIdForQuotingQueryTag", config.GetUsageIntervalIdForQuotingQueryTag),
                  new XElement("CalculateQuoteTotalAmountQueryTag", config.CalculateQuoteTotalAmountQueryTag),
                  new XElement("GetMaxQuoteIdQueryTag", config.GetMaxQuoteIdQueryTag),
                  new XElement("BackupQuoteUsagesQueryTag", config.BackupQuoteUsagesQueryTag),
                  new XElement("RemoveQuoteUsagesQueryTag", config.RemoveQuoteUsagesQueryTag),
                  new XElement("CountTotalQuoteUsagesQueryTag", config.CountTotalQuoteUsagesQueryTag),
                  new XElement("RemoveRCMetricValuesQueryTag", config.RemoveRCMetricValuesQueryTag),
                  new XElement("GetAccountBillingCycleQueryTag", config.GetAccountBillingCycleQueryTag),
                  new XElement("GetAccountPayerQueryTag", config.GetAccountPayerQueryTag),
                  new XElement("MeteringSessionSetSize", config.MeteringSessionSetSize),
                  new XElement("ReportDefaultTemplateName", config.ReportDefaultTemplateName),
                  new XElement("ReportInstancePartialPath", config.ReportInstancePartialPath),
                  new XElement("QuotingQueryFolder", config.QuotingQueryFolder),
                  new XElement("IsCleanupQuoteAutomaticaly", config.IsCleanupQuoteAutomaticaly),
                  new XElement("IsAllowedUseActivityService", config.IsAllowedUseActivityService)
                  );

        doc.Save(filePath);
      }
      catch (Exception ex)
      {
        m_Logger.LogException(string.Format("Exception while writting configuration to file {0}", filePath), ex);
        throw;
      }
    }

    public static QuotingConfiguration WriteDefaultConfigurationToFile(string filePath)
    {
      var config = new QuotingConfiguration();

      config.RecurringChargeServerToMeterTo = DEFAULT_RECCURING_CHARGE_SERVER_TO_METER_TO;
      config.RecurringChargeStoredProcedureQueryTag = DEFAULT_RECCURING_CHARGE_STORED_PROCEDURE_QUERY_TAG;
      config.NonRecurringChargeStoredProcedureQueryTag = DEFAULT_NON_RECCURING_CHARGE_STORED_PROCEDURE_QUERY_TAG;
      config.GetUsageIntervalIdForQuotingQueryTag = DEFAULT_GET_USAGE_INTERVAL_ID_FOR_QUOTING_QUERY_TAG;
      config.CalculateQuoteTotalAmountQueryTag = DEFAULT_CALCULATE_QUOTE_TOTAL_AMOUNT_QUERY_TAG;
      config.GetMaxQuoteIdQueryTag = DEFAULT_GET_MAX_QUOTE_ID_QUERY_TAG;
      config.BackupQuoteUsagesQueryTag = DEFAULT_BACKUP_QUOTE_USAGES_QUERY_TAG;
      config.RemoveQuoteUsagesQueryTag = DEFAULT_REMOVE_QUOTE_USAGES_QUERY_TAG;
      config.CountTotalQuoteUsagesQueryTag = DEFAULT_COUNT_TOTAL_QUOTE_USAGES_QUERY_TAG;
      config.RemoveRCMetricValuesQueryTag = DEFAULT_REMOVE_RC_METRIC_VALUES_QUERY_TAG;
      config.GetAccountBillingCycleQueryTag = DEFAULT_GET_ACCOUNT_BILLING_CYCLE_QUERY_TAG;
      config.GetAccountPayerQueryTag = DEFAULT_GET_ACCOUNT_PAYER_QUERY_TAG;
      config.MeteringSessionSetSize = DEFAULT_METERING_SESSION_SET_SIZE;
      config.ReportDefaultTemplateName = DEFAULT_REPORT_DEFAULT_TEMPLATE_NAME;
      config.ReportInstancePartialPath = DEFAULT_REPORT_INSTANCE_PARTIAL_PATH;
      config.QuotingQueryFolder = DEFAULT_QUOTING_QUERY_FOLDER;
      config.IsCleanupQuoteAutomaticaly = DEFAULT_IS_CLEANUP_QUOTE_AUTOMATICALY;
      config.IsAllowedUseActivityService = DEFAULT_IS_ALLOWED_USE_ACTIVITY_SERVICE_FOR_QUOTE_CREATION;

      WriteConfigurationToFile(config, filePath);

      return config;
    }
    #endregion

  }
}

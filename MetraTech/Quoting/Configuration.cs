using System;
using System.IO;
using System.Linq;
using System.Xml;
using System.Xml.Linq;
using MetraTech.Basic.Config;

namespace MetraTech.Quoting
{
    /// <summary>
    /// Class containing all the data members representing the quoting configuration options
    /// </summary>
    public class QuotingConfiguration
    {
        //When metering to pipeline, batch metering size to use
        public int MeteringSessionSetSize { get; set; }

        //Server to meter to
        public string RecurringChargeServerToMeterTo { get; set; }

        //Configuration options for reporting
        public string ReportDefaultTemplateName { get; set; }
        public string ReportInstancePartialPath { get; set; }

        //Configurable query tags for quoting
        public string RecurringChargeStoredProcedureQueryTag { get; set; }
        public string NonRecurringChargeStoredProcedureQueryTag { get; set; }
        public string GetUsageIntervalIdForQuotingQueryTag { get; set; }
        public string CalculateQuoteTotalAmountQueryTag { get; set; }
        public string GetMaxQuoteIdQueryTag { get; set; }
        public string RemoveRCMetricValuesQueryTag { get; set; }
        public string GetAccountBillingCycleQueryTag { get; set; }
        public string GetAccountPayerQueryTag { get; set; }
        public string QuotingQueryFolder { get; set; }

        /// <summary>
        /// Should Quote artefacts be removed after call CreateQuote()
        /// By default is should be removed.
        /// </summary>
        /// <remarks>This options is used for debugin and for tests.
        /// If IsCleanupQuoteAutomaticaly = false all subscriptions (includes group subscriptions) and all usages were not removed automaticaly.
        /// To cleanup artifacts Cleaup() methods should be used</remarks>
        public bool IsCleanupQuoteAutomaticaly { get; set; }

        /// <summary>
        /// Allow using MAS to create subcsriptions throug Subscription\GroupSubscriptopn service
        /// </summary>
        public bool IsAllowedUseActivityService { get; set; }

    }

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
                        var configuration = from config in doc.DescendantsAndSelf()
                                            select new QuotingConfiguration()
                                              {
                                                  RecurringChargeServerToMeterTo =
                                                    config.GetElementValueOrDefault("RecurringChargeServerToMeterTo",
                                                                                    DEFAULT_RECCURING_CHARGE_SERVER_TO_METER_TO),
                                                  RecurringChargeStoredProcedureQueryTag =
                                                    config.GetElementValueOrDefault("RecurringChargeStoredProcedureQueryTag",
                                                                                    DEFAULT_RECCURING_CHARGE_STORED_PROCEDURE_QUERY_TAG),
                                                  NonRecurringChargeStoredProcedureQueryTag =
                                                    config.GetElementValueOrDefault("NonRecurringChargeStoredProcedureQueryTag",
                                                                                    DEFAULT_NON_RECCURING_CHARGE_STORED_PROCEDURE_QUERY_TAG),
                                                  GetUsageIntervalIdForQuotingQueryTag =
                                                    config.GetElementValueOrDefault("GetUsageIntervalIdForQuotingQueryTag",
                                                                                    DEFAULT_GET_USAGE_INTERVAL_ID_FOR_QUOTING_QUERY_TAG),
                                                  CalculateQuoteTotalAmountQueryTag =
                                                    config.GetElementValueOrDefault("CalculateQuoteTotalAmountQueryTag",
                                                                                    DEFAULT_CALCULATE_QUOTE_TOTAL_AMOUNT_QUERY_TAG),
                                                  GetMaxQuoteIdQueryTag =
                                                    config.GetElementValueOrDefault("GetMaxQuoteIdQueryTag",
                                                                                    DEFAULT_GET_MAX_QUOTE_ID_QUERY_TAG),
                                                  RemoveRCMetricValuesQueryTag =
                                                    config.GetElementValueOrDefault("RemoveRCMetricValuesQueryTag",
                                                                                    DEFAULT_REMOVE_RC_METRIC_VALUES_QUERY_TAG),
                                                  GetAccountBillingCycleQueryTag =
                                                    config.GetElementValueOrDefault("GetAccountBillingCycleQueryTag",
                                                                                    DEFAULT_GET_ACCOUNT_BILLING_CYCLE_QUERY_TAG),
                                                  GetAccountPayerQueryTag =
                                                    config.GetElementValueOrDefault("GetAccountPayerQueryTag",
                                                                                    DEFAULT_GET_ACCOUNT_PAYER_QUERY_TAG),
                                                  MeteringSessionSetSize =
                                                    config.GetElementValueOrDefault("MeteringSessionSetSize",
                                                                                    DEFAULT_METERING_SESSION_SET_SIZE),

                                                  ReportDefaultTemplateName =
                                                    config.GetElementValueOrDefault("ReportDefaultTemplateName",
                                                                                    DEFAULT_REPORT_DEFAULT_TEMPLATE_NAME),
                                                  ReportInstancePartialPath =
                                                    config.GetElementValueOrDefault("ReportInstancePartialPath",
                                                                                    DEFAULT_REPORT_INSTANCE_PARTIAL_PATH),

                                                  QuotingQueryFolder = config.GetElementValueOrDefault("QuotingQueryFolder",
                                                                                    DEFAULT_QUOTING_QUERY_FOLDER),

                                                  IsCleanupQuoteAutomaticaly = config.GetElementValueOrDefault("IsCleanupQuoteAutomaticaly",
                                                                                    DEFAULT_IS_CLEANUP_QUOTE_AUTOMATICALY),

                                                  IsAllowedUseActivityService = config.GetElementValueOrDefault("IsAllowedUseActivityService",
                                                                                    DEFAULT_IS_ALLOWED_USE_ACTIVITY_SERVICE_FOR_QUOTE_CREATION)
                                              };

                        loadedConfiguration = configuration.First();
                    }
                    else
                    {
                        string message =
                          string.Format("Expected quoting configuration in file {0} but file did not contain elements", filePath);
                        throw new Exception(message);
                    }

                }
                else
                {
                    string message = string.Format("Quoting configuration file does not exist: {0}", filePath);
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
        public static void WriteConfigurationToFile(QuotingConfiguration configuration, string filePath)
        {
            try
            {
                if (!File.Exists(filePath))
                {
                    XmlDocument document = new XmlDocument();

                    XmlNode node = new XmlDocument();
                    node = document.CreateNode(XmlNodeType.XmlDeclaration, "", "");
                    document.AppendChild(node);

                    node = document.CreateNode(XmlNodeType.Element, "QuotingConfiguration", "");
                    document.AppendChild(node);

                    document.Save(filePath);
                }

                XElement doc = XElement.Load(filePath);

                doc.ReplaceAll(new XElement("RecurringChargeServerToMeterTo", configuration.RecurringChargeServerToMeterTo),
                          new XElement("RecurringChargeStoredProcedureQueryTag",
                                       configuration.RecurringChargeStoredProcedureQueryTag),
                          new XElement("NonRecurringChargeStoredProcedureQueryTag",
                                       configuration.NonRecurringChargeStoredProcedureQueryTag),
                          new XElement("GetUsageIntervalIdForQuotingQueryTag",
                                       configuration.GetUsageIntervalIdForQuotingQueryTag),
                          new XElement("CalculateQuoteTotalAmountQueryTag", configuration.CalculateQuoteTotalAmountQueryTag),
                          new XElement("GetMaxQuoteIdQueryTag", configuration.GetMaxQuoteIdQueryTag),
                          new XElement("RemoveRCMetricValuesQueryTag", configuration.RemoveRCMetricValuesQueryTag),
                          new XElement("GetAccountBillingCycleQueryTag", configuration.GetAccountBillingCycleQueryTag),
                          new XElement("GetAccountPayerQueryTag", configuration.GetAccountPayerQueryTag),
                          new XElement("MeteringSessionSetSize", configuration.MeteringSessionSetSize),
                          new XElement("ReportDefaultTemplateName", configuration.ReportDefaultTemplateName),
                          new XElement("ReportInstancePartialPath", configuration.ReportInstancePartialPath),
                          new XElement("QuotingQueryFolder", configuration.QuotingQueryFolder),
                          new XElement("IsCleanupQuoteAutomaticaly", configuration.IsCleanupQuoteAutomaticaly),
                          new XElement("IsAllowedUseActivityService", configuration.IsAllowedUseActivityService)
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
            QuotingConfiguration configuration = new QuotingConfiguration();

            configuration.RecurringChargeServerToMeterTo = DEFAULT_RECCURING_CHARGE_SERVER_TO_METER_TO;
            configuration.RecurringChargeStoredProcedureQueryTag = DEFAULT_RECCURING_CHARGE_STORED_PROCEDURE_QUERY_TAG;
            configuration.NonRecurringChargeStoredProcedureQueryTag = DEFAULT_NON_RECCURING_CHARGE_STORED_PROCEDURE_QUERY_TAG;
            configuration.GetUsageIntervalIdForQuotingQueryTag = DEFAULT_GET_USAGE_INTERVAL_ID_FOR_QUOTING_QUERY_TAG;
            configuration.CalculateQuoteTotalAmountQueryTag = DEFAULT_CALCULATE_QUOTE_TOTAL_AMOUNT_QUERY_TAG;
            configuration.GetMaxQuoteIdQueryTag = DEFAULT_GET_MAX_QUOTE_ID_QUERY_TAG;
            configuration.RemoveRCMetricValuesQueryTag = DEFAULT_REMOVE_RC_METRIC_VALUES_QUERY_TAG;
            configuration.GetAccountBillingCycleQueryTag = DEFAULT_GET_ACCOUNT_BILLING_CYCLE_QUERY_TAG;
            configuration.GetAccountPayerQueryTag = DEFAULT_GET_ACCOUNT_PAYER_QUERY_TAG;
            configuration.MeteringSessionSetSize = DEFAULT_METERING_SESSION_SET_SIZE;
            configuration.ReportDefaultTemplateName = DEFAULT_REPORT_DEFAULT_TEMPLATE_NAME;
            configuration.ReportInstancePartialPath = DEFAULT_REPORT_INSTANCE_PARTIAL_PATH;
            configuration.QuotingQueryFolder = DEFAULT_QUOTING_QUERY_FOLDER;
            configuration.IsCleanupQuoteAutomaticaly = DEFAULT_IS_CLEANUP_QUOTE_AUTOMATICALY;
            configuration.IsAllowedUseActivityService = DEFAULT_IS_ALLOWED_USE_ACTIVITY_SERVICE_FOR_QUOTE_CREATION;

            WriteConfigurationToFile(configuration, filePath);

            return configuration;
        }
        #endregion

    }
}

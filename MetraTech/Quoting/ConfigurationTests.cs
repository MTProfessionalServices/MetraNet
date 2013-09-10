using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.IO;

namespace MetraTech.Quoting.Test
{
  [TestClass]
  public class ConfigurationTests 
  {

    #region tests
    
    [TestMethod]
    public void WriteConfigurationToFile()
    {
      #region Prepare

      const string FILE_NAME = "QuotingConfiguration_ForTest.xml";
      string filePathToTestFile = Path.Combine(Directory.GetCurrentDirectory(), FILE_NAME);

      const string RECCURING_CHARGE_SERVER_TO_METER_TO = "DiscountServer";
      const string RECCURING_CHARGE_STORED_PROCEDURE_QUERY_TAG = "MTSP_GENERATE_ST_RCS_QUOTING";
      const string NON_RECCURING_CHARGE_STORED_PROCEDURE_QUERY_TAG = "MTSP_GENERATE_ST_NRCS_QUOTING";
      const string GET_USAGE_INTERVAL_ID_FOR_QUOTING_QUERY_TAG = "__GET_USAGE_INTERVAL_ID_FOR_QUOTING__";
      const string CALCULATE_QUOTE_TOTAL_AMOUNT_QUERY_TAG = "__GET_QUOTE_TOTAL_AMOUNT__";
      const string DEFAULT_REMOVE_RC_METRIC_VALUES_QUERY_TAG = "__REMOVE_RC_METRIC_VALUES__";
      const string DEFAULT_GET_ACCOUNT_BILLING_CYCLE_QUERY_TAG = "__GET_ACCOUNT_BILLING_CYCLE__";
      const string DEFAULT_GET_ACCOUNT_PAYER_QUERY_TAG = "__GET_ACCOUNT_PAYER__";
      const int METERING_SESSION_SET_SIZE = 500;
    
      const string REPORT_DEFAULT_TEMPLATE_NAME = "Quote Report";
      const string REPORT_INSTANCE_PARTIAL_PATH = @"\Quotes\{AccountId}\Quote_{QuoteId}";
      const string DEFAULT_QUOTING_QUERY_FOLDER = @"Queries\Quoting";
      const bool   DEFAULT_IS_CLEANUP_QUOTE_AUTOMATICALY = true;

      var configurationToWrite = new QuotingConfiguration();

      configurationToWrite.RecurringChargeServerToMeterTo = RECCURING_CHARGE_SERVER_TO_METER_TO;
      configurationToWrite.RecurringChargeStoredProcedureQueryTag = RECCURING_CHARGE_STORED_PROCEDURE_QUERY_TAG;
      configurationToWrite.NonRecurringChargeStoredProcedureQueryTag = NON_RECCURING_CHARGE_STORED_PROCEDURE_QUERY_TAG;
      configurationToWrite.GetUsageIntervalIdForQuotingQueryTag = GET_USAGE_INTERVAL_ID_FOR_QUOTING_QUERY_TAG;
      configurationToWrite.CalculateQuoteTotalAmountQueryTag = CALCULATE_QUOTE_TOTAL_AMOUNT_QUERY_TAG;
      configurationToWrite.RemoveRCMetricValuesQueryTag = DEFAULT_REMOVE_RC_METRIC_VALUES_QUERY_TAG;
      configurationToWrite.GetAccountBillingCycleQueryTag = DEFAULT_GET_ACCOUNT_BILLING_CYCLE_QUERY_TAG;
      configurationToWrite.GetAccountPayerQueryTag = DEFAULT_GET_ACCOUNT_PAYER_QUERY_TAG;
      configurationToWrite.MeteringSessionSetSize = METERING_SESSION_SET_SIZE;
      configurationToWrite.ReportDefaultTemplateName = REPORT_DEFAULT_TEMPLATE_NAME;
      configurationToWrite.ReportInstancePartialPath = REPORT_INSTANCE_PARTIAL_PATH;
      configurationToWrite.QuotingQueryFolder = DEFAULT_QUOTING_QUERY_FOLDER;
      configurationToWrite.IsCleanupQuoteAutomaticaly = DEFAULT_IS_CLEANUP_QUOTE_AUTOMATICALY;
      
      
      #endregion

      #region Run and Verify

      QuotingConfigurationManager.WriteConfigurationToFile(configurationToWrite, filePathToTestFile);
      QuotingConfiguration readConfiguration = QuotingConfigurationManager.LoadConfigurationFromDefaultSystemLocation();

      Assert.AreEqual(configurationToWrite.GetUsageIntervalIdForQuotingQueryTag, readConfiguration.GetUsageIntervalIdForQuotingQueryTag);
      Assert.AreEqual(configurationToWrite.MeteringSessionSetSize, readConfiguration.MeteringSessionSetSize);
      Assert.AreEqual(configurationToWrite.NonRecurringChargeStoredProcedureQueryTag, readConfiguration.NonRecurringChargeStoredProcedureQueryTag);
      Assert.AreEqual(configurationToWrite.RecurringChargeServerToMeterTo, readConfiguration.RecurringChargeServerToMeterTo);
      Assert.AreEqual(configurationToWrite.RecurringChargeStoredProcedureQueryTag, readConfiguration.RecurringChargeStoredProcedureQueryTag);
      Assert.AreEqual(configurationToWrite.ReportDefaultTemplateName, readConfiguration.ReportDefaultTemplateName);
      Assert.AreEqual(configurationToWrite.ReportInstancePartialPath, readConfiguration.ReportInstancePartialPath);
      Assert.AreEqual(configurationToWrite.CalculateQuoteTotalAmountQueryTag, readConfiguration.CalculateQuoteTotalAmountQueryTag);
      Assert.AreEqual(configurationToWrite.RemoveRCMetricValuesQueryTag, readConfiguration.RemoveRCMetricValuesQueryTag);
      Assert.AreEqual(configurationToWrite.GetAccountBillingCycleQueryTag, readConfiguration.GetAccountBillingCycleQueryTag);
      Assert.AreEqual(configurationToWrite.GetAccountPayerQueryTag, readConfiguration.GetAccountPayerQueryTag);
      Assert.AreEqual(configurationToWrite.QuotingQueryFolder, readConfiguration.QuotingQueryFolder);
      Assert.AreEqual(configurationToWrite.IsCleanupQuoteAutomaticaly, readConfiguration.IsCleanupQuoteAutomaticaly);

      #endregion
    }

    [TestMethod]
    public void LoadConfigurationFromFile()
    {
      var loadedConfiguration = QuotingConfigurationManager.LoadConfigurationFromDefaultSystemLocation();

      Assert.IsFalse(string.IsNullOrEmpty(loadedConfiguration.GetUsageIntervalIdForQuotingQueryTag));
      Assert.IsFalse(string.IsNullOrEmpty(loadedConfiguration.NonRecurringChargeStoredProcedureQueryTag));
      Assert.IsFalse(string.IsNullOrEmpty(loadedConfiguration.RecurringChargeServerToMeterTo));
      Assert.IsFalse(string.IsNullOrEmpty(loadedConfiguration.RecurringChargeStoredProcedureQueryTag));
      Assert.IsFalse(string.IsNullOrEmpty(loadedConfiguration.ReportDefaultTemplateName));
      Assert.IsFalse(string.IsNullOrEmpty(loadedConfiguration.ReportInstancePartialPath));
      Assert.IsFalse(string.IsNullOrEmpty(loadedConfiguration.CalculateQuoteTotalAmountQueryTag));
      Assert.IsFalse(string.IsNullOrEmpty(loadedConfiguration.RemoveRCMetricValuesQueryTag));
      Assert.IsFalse(string.IsNullOrEmpty(loadedConfiguration.GetAccountBillingCycleQueryTag));
      Assert.IsFalse(string.IsNullOrEmpty(loadedConfiguration.GetAccountPayerQueryTag));
      Assert.IsFalse(string.IsNullOrEmpty(loadedConfiguration.QuotingQueryFolder));

    }

    #endregion
  }
    
}
namespace MetraTech.Core.Services.Quoting
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
    public string BackupQuoteUsagesQueryTag { get; set; }
    public string RemoveQuoteUsagesQueryTag { get; set; }
    public string CountTotalQuoteUsagesQueryTag { get; set; }
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
}
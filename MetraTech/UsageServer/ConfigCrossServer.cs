
namespace MetraTech.UsageServer
{
  /// <summary>
  /// These USM Configuration properties apply across all servers.
  /// The values are stored in the database.
  /// </summary>
  public class ConfigCrossServer
	{
		public bool isGracePeriodDailyEnabled;
    public bool isGracePeriodWeeklyEnabled;
    public bool isGracePeriodBiWeeklyEnabled;
    public bool isGracePeriodSemiMonthlyEnabled;
    public bool isGracePeriodQuarterlyEnabled;
    public bool isGracePeriodSemiAnnuallyEnabled;
    public bool isGracePeriodMonthlyEnabled;
    public bool isGracePeriodAnnuallyEnabled;
		public int gracePeriodDailyInDays;
    public int gracePeriodWeeklyInDays;
    public int gracePeriodBiWeeklyInDays;
    public int gracePeriodSemiMonthlyInDays;
    public int gracePeriodQuarterlyInDays;
    public int gracePeriodSemiAnnuallyInDays;
    public int gracePeriodMonthlyInDays;
    public int gracePeriodAnnuallyInDays;

    /// <summary>
    /// Is "automatically soft close the billing groups of expired
    /// usage intervals" enabled?
    /// </summary>
    public bool isAutoSoftCloseBillGroupsEnabled;

    // Is "when automatically closing intervals, block the intervals to
    // new accounts" enabled?
    public bool isBlockNewAccountsWhenClosingEnabled;

    // Is "automatically run eop adapters on soft closed billing groups"
    // enabled?
    public bool isAutoRunEopOnSoftCloseEnabled;

    // Is "run scheduled adapters" enabled?
    public bool isRunScheduledAdaptersEnabled;

    public string multicastAddress;
    public int multicastPort;
    public int multicastTimeToLive;

    public override string ToString()
    {
      string result = "gracePeriodBiWeeklyInDays(" + gracePeriodBiWeeklyInDays + 
            ") gracePeriodDailyInDays(" + gracePeriodDailyInDays +
            ") gracePeriodQuarterlyInDays(" + gracePeriodQuarterlyInDays +
            ") gracePeriodSemiAnnuallyInDays(" + gracePeriodSemiAnnuallyInDays +
            ") gracePeriodSemiMonthlyInDays(" + gracePeriodSemiMonthlyInDays +
            ") gracePeriodWeeklyInDays(" + gracePeriodWeeklyInDays +
            ") isGracePeriodBiWeeklyEnabled(" + isGracePeriodBiWeeklyEnabled +
            ") isGracePeriodDailyEnabled(" + isGracePeriodDailyEnabled  +
            ") isGracePeriodQuarterlyEnabled(" + isGracePeriodQuarterlyEnabled +
            ") isGracePeriodSemiAnnuallyEnabled(" + isGracePeriodSemiAnnuallyEnabled +
            ") isGracePeriodSemiMonthlyEnabled(" + isGracePeriodSemiMonthlyEnabled +
            ") isGracePeriodWeeklyEnabled(" + isGracePeriodWeeklyEnabled +
            ") isAutoRunEopOnSoftCloseEnabled(" + isAutoRunEopOnSoftCloseEnabled +
            ") isAutoSoftCloseBillGroupsEnabled(" + isAutoSoftCloseBillGroupsEnabled +
            ") isBlockNewAccountsWhenClosingEnabled(" + isBlockNewAccountsWhenClosingEnabled +
            ") isRunScheduledAdaptersEnabled(" + isRunScheduledAdaptersEnabled +
            ") multicastAddress(" + multicastAddress +
            ") multicastPort(" + multicastPort +
            ") multicastTimeToLive(" + multicastTimeToLive +
            ")";
      return result;
    }
  }
}
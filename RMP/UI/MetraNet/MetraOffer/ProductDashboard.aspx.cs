using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;

public partial class ProductDashboard : MTPage
{
  #region Localization Fields

  protected string MrrTotalGraphTitle;
  protected string MrrGainGraphTitle;
  protected string MrrLossGraphTitle;
  protected string TopSubsGraphTitle;
  protected string TopSubsGainGraphTitle;
  protected string TopSubsLossGraphTitle;
  protected string NoDataText;
  protected string MrrTooltipText;
  protected string SubscriptionsTooltipText;
  protected string GainTooltipText;
  protected string LossTooltipText;  
  protected string RevenueText;
  protected string Last30DaysText;
  protected string DateStampForGraph;

  #endregion

  protected bool ShowFinancialData { get; set; }

  protected void Page_Load(object sender, EventArgs e)
  {
    ShowFinancialData = UI.CoarseCheckCapability("View Summary Financial Information");
    
    if (!IsPostBack)
    {
      SetLocalization();
    }
  }

  protected override void OnLoadComplete(EventArgs e)
  {
    try
    {
      LoadGrids();
    }
    catch (Exception ex)
    {
      Response.Write(ex.StackTrace);
    }
    base.OnLoadComplete(e);
  }

  private void LoadGrids()
  {
    const string querydir = "..\\Extensions\\SystemConfig\\config\\SqlCore\\Queries\\UI\\Dashboard";

    var paramDictForRecentOfferingChanges = new Dictionary<string, object>
      {
        {"%%CURRENT_DATETIME%%", MetraTech.MetraTime.Now.ToString("MM/dd/yyyy", CultureInfo.InvariantCulture)}
      };
    ConfigureAndLoadGrid(grdRecentOfferingChanges, "__GET_RECENT_OFFERING_CHANGES__", querydir,
                         paramDictForRecentOfferingChanges);
    
    var paramDictForRecentRateChanges = new Dictionary<string, object>
      {
        {"%%CURRENT_DATETIME%%", MetraTech.MetraTime.Now.ToString("MM/dd/yyyy", CultureInfo.InvariantCulture)}
      };
    ConfigureAndLoadGrid(grdRecentRateChanges, "__GET_RECENT_RATE_CHANGES__", querydir, paramDictForRecentRateChanges);

    var paramDict = new Dictionary<string, object>
      {
        {"%%USERNAME%%", UI.User.UserName},
        {"%%CURRENT_DATETIME%%", MetraTech.MetraTime.Now.ToString("MM/dd/yyyy", CultureInfo.InvariantCulture)}
      };
    ConfigureAndLoadGrid(grdMyRecentChanges, "__GET_MY_RECENT_CHANGES__", querydir, paramDict);
  }

  private void ConfigureAndLoadGrid(MTFilterGrid grid, string queryName, string queryPath, Dictionary<string, object> paramDict)
  {
    var sqi = new SQLQueryInfo {QueryName = queryName, QueryDir = queryPath};

    foreach (var param in paramDict.Select(pair => new SQLQueryParam {FieldName = pair.Key, FieldValue = pair.Value}))
      sqi.Params.Add(param);

    var qsParam = MetraTech.UI.Common.SQLQueryInfo.Compact(sqi);
    grid.DataSourceURLParams.Add("q", qsParam);
    grid.DataSourceURLParams.Add("batchsize", "100");
  }

  private void SetLocalization()
  {
    MrrTotalGraphTitle = Convert.ToString(GetLocalResourceObject("TEXT_MRR_TOTAL"));
    MrrGainGraphTitle = Convert.ToString(GetLocalResourceObject("TEXT_MRR_GAIN"));
    MrrLossGraphTitle = Convert.ToString(GetLocalResourceObject("TEXT_MRR_LOSS"));
    TopSubsGraphTitle = Convert.ToString(GetLocalResourceObject("TEXT_SUBSCRIPTIONS_TOTAL"));
    TopSubsGainGraphTitle = Convert.ToString(GetLocalResourceObject("TEXT_SUBSCRIPTIONS_GAIN"));
    TopSubsLossGraphTitle = Convert.ToString(GetLocalResourceObject("TEXT_SUBSCRIPTIONS_LOSS"));
    NoDataText = Convert.ToString(GetLocalResourceObject("TEXT_NO_DATA_AVAILABLE"));
    MrrTooltipText = Convert.ToString(GetLocalResourceObject("TEXT_MRR_TOOLTIP"));
    SubscriptionsTooltipText = Convert.ToString(GetLocalResourceObject("TEXT_SUBSCRIPTIONS_TOOLTIP"));
    GainTooltipText = Convert.ToString(GetLocalResourceObject("TEXT_GAIN_TOOLTIP"));
    LossTooltipText = Convert.ToString(GetLocalResourceObject("TEXT_LOSS_TOOLTIP"));
    RevenueText = Convert.ToString(GetLocalResourceObject("TEXT_REVENUE_TOOLTIP"));
    DateStampForGraph = String.Format("{0} {1}", MetraTech.MetraTime.Now.AddMonths(-1).ToString("MMMM"), MetraTech.MetraTime.Now.AddMonths(-1).Year);
    Last30DaysText = Convert.ToString(GetLocalResourceObject("TEXT_LAST_30_DAYS"));
  }
}

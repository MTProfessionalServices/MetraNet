using System;
using System.Collections.Generic;
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
  protected string RevenueText;

  #endregion

  protected bool ShowFinancialData { get; set; }

  protected void Page_Load(object sender, EventArgs e)
  {
    ShowFinancialData = UI.CoarseCheckCapability("View Data from Analytics Datamart");
    
    if (!IsPostBack)
    {
      // TODO:  Get data to bind to and place in viewstate

      // TODO:  Set binding properties and template on MTGenericForm control
      SetLocalization();
    }
  }

  protected override void OnLoadComplete(EventArgs e)
  {

    try
    {
      loadGrids();
    }
    catch (Exception ex)
    {
      Response.Write(ex.StackTrace);
    }
    base.OnLoadComplete(e);
  }


  private void loadGrids()
  {
    string querydir = "..\\Extensions\\SystemConfig\\config\\SqlCore\\Queries\\UI\\Dashboard";

    ConfigureAndLoadGrid(grdRecentOfferingChanges, "__GET_RECENT_OFFERING_CHANGES__", querydir, null);
    ConfigureAndLoadGrid(grdRecentRateChanges, "__GET_RECENT_RATE_CHANGES__", querydir, null);

    Dictionary<string, object> paramDict = new Dictionary<string, object>();
    paramDict.Add("%%USERNAME%%", UI.User.UserName);
    ConfigureAndLoadGrid(grdMyRecentChanges, "__GET_MY_RECENT_CHANGES__", querydir, paramDict);
  }



  private void ConfigureAndLoadGrid(MTFilterGrid grid, string queryName, string queryPath, Dictionary<string, object> paramDict)
  {
    SQLQueryInfo sqi = new SQLQueryInfo();
    sqi.QueryName = queryName;
    sqi.QueryDir = queryPath;

    if (paramDict != null)
    {
      foreach (var pair in paramDict)
      {
        SQLQueryParam param = new SQLQueryParam();
        param = new SQLQueryParam();
        param.FieldName = pair.Key;
        param.FieldValue = pair.Value;
        sqi.Params.Add(param);
      }
    }

    string qsParam = MetraTech.UI.Common.SQLQueryInfo.Compact(sqi);
    grid.DataSourceURLParams.Add("q", qsParam);

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
    RevenueText = Convert.ToString(GetLocalResourceObject("TEXT_REVENUE_TOOLTIP")); 
  }
}



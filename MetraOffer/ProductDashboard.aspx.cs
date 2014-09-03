using System;
using System.Collections.Generic;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.UI.Controls;
using MetraTech.OnlineBill;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using System.Web.UI.WebControls;

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
  protected string MrrText;
  protected string ProductCodeText;
  protected string ChangeText;
  protected string SubscriptionsText;
  protected string SubscriptionsGainText;
  protected string SubscriptionsLossText;
  #endregion

  protected void Page_Load(object sender, EventArgs e)
  {
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
    Dictionary<string, object> paramDict = new Dictionary<string, object>();
    string querydir = "..\\Extensions\\SystemConfig\\config\\SqlCore\\Queries\\UI\\Dashboard";


    ConfigureAndLoadGrid(grdRecentOfferingChanges, "__GET_RECENT_OFFERING_CHANGES__", querydir, null);
    /*ConfigureAndLoadGrid(grdRecentRateChanges, "__GET_RECENT_RATE_CHANGES__", querydir, null);
    ConfigureAndLoadGrid(grdMyRecentChanges, "__GET_MY_RECENT_CHANGES__", querydir, null);*/
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
    MrrText = Convert.ToString(GetLocalResourceObject("TEXT_MRR"));
    ProductCodeText = Convert.ToString(GetLocalResourceObject("TEXT_PRODUCT_CODE_TOOLTIP"));
    ChangeText = Convert.ToString(GetLocalResourceObject("TEXT_CHANGE_TOOLTIP"));
    SubscriptionsText = Convert.ToString(GetLocalResourceObject("TEXT_SUBSCRIPTIONS_TOOLTIP"));
    SubscriptionsGainText = Convert.ToString(GetLocalResourceObject("TEXT_SUBSCRIPTIONS_GAIN_TOOLTIP"));
    SubscriptionsLossText = Convert.ToString(GetLocalResourceObject("TEXT_SUBSCRIPTIONS_LOSS_TOOLTIP"));
  }
}



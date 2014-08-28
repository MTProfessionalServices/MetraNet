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
    //MRRTotalText = GetLocalResourceObject("TEXT_MRR_TOTAL").ToString();
    MrrTotalGraphTitle = "MRR Total goes here";
    MrrGainGraphTitle = "MRR Gain goes here";
    MrrLossGraphTitle = "MRR Loss goes here";
    TopSubsGraphTitle = "Subscriptions Total goes here";
    TopSubsGainGraphTitle = "Subscriptions Gain goes here";
    TopSubsLossGraphTitle = "Subscriptions Loss goes here";
    NoDataText = "No data available";
  }
}



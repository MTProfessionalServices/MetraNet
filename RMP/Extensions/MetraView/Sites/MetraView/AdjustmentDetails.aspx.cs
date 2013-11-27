using System;
using MetraTech.UI.Common;

public partial class AdjustmentDetails : MTPage
{
  public string AccountSliceString { get; set; }
  public string IsPostBill { get; set; }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (Request.QueryString["accountSlice"] != null)
    {
      AccountSliceString = Request.QueryString["accountSlice"];
    }

    if (Request.QueryString["isPostBill"] != null)
    {
      IsPostBill = Request.QueryString["isPostBill"];
    }
  }

  /// <summary>
  /// On Load Complete gives you a chance to change the default properties on the grid.
  /// </summary>
  /// <param name="e"></param>
  protected override void OnLoadComplete(EventArgs e)
  {
    // Setup DataSource
    MTFilterGrid1.DataSourceURL =
        String.Format("{0}/AjaxServices/AdjustmentDetailSvc.aspx?isPostBill={1}&accountSlice={2}",
                      Request.ApplicationPath,
                      IsPostBill,
                      AccountSliceString);

    // Set Adjustment Defaults
    MTFilterGrid1.Title = GetLocalResourceObject("AdjustmentDetails.Text").ToString();
    MTFilterGrid1.Width = 710;
    MTFilterGrid1.Height = 360;
    MTFilterGrid1.PageSize = 10;
    MTFilterGrid1.FilterLabelWidth = 170;
    MTFilterGrid1.FilterInputWidth = 220;
    MTFilterGrid1.FilterColumnWidth = 340;
    MTFilterGrid1.EnableFilterConfig = true;
    MTFilterGrid1.EnableColumnConfig = true;
    MTFilterGrid1.EnableSaveSearch = true;
    MTFilterGrid1.EnableLoadSearch = true;
    MTFilterGrid1.FilterPanelCollapsed = true;
    MTFilterGrid1.Resizable = true;
    MTFilterGrid1.DisplayCount = true;
    MTFilterGrid1.ShowTopBar = false;
    MTFilterGrid1.CustomImplementationFilePath = String.Format("{0}/JavaScript/Details.aspx.js", Request.ApplicationPath);
  }
}

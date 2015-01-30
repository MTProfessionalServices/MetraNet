using System;
using MetraTech.UI.Common;
using MetraTech.DomainModel.Billing;

public partial class UserControls_ReportParams : System.Web.UI.UserControl
{
  public DateTime StartDate { get; set; }
  public DateTime EndDate { get; set; }
  protected void Page_Load(object sender, EventArgs e)
  {
    var billMgr = new BillManager(UI);
    if ((billMgr.ReportParamsLocalized.ReportView == ReportViewType.Interactive)
      && (billMgr.ReportParamsLocalized.DateRange is DateRangeSlice))
    {

      StartDate = ((DateRangeSlice)billMgr.ReportParamsLocalized.DateRange).Begin;
      EndDate = ((DateRangeSlice)billMgr.ReportParamsLocalized.DateRange).End;
    }
    else
    {
      Interval curInterval = billMgr.GetCurrentInterval();
      if (curInterval == null)
      {
        curInterval = billMgr.GetOpenIntervalWithoutSettingItAsCurrentOnTheUI();
      }

      StartDate = curInterval.StartDate;
      EndDate = curInterval.EndDate;
    }
  }
  
  public UIManager UI
  {
    get { return ((MTPage)Page).UI; }
  }
}

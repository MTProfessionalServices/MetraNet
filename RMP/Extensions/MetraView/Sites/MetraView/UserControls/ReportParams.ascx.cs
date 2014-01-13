using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Xml.Linq;
using MetraTech.UI.Common;
using MetraTech.DomainModel.Billing;

public partial class UserControls_ReportParams : System.Web.UI.UserControl
{
  public DateTime StartDate { get; set; }
  public DateTime EndDate { get; set; }
  protected void Page_Load(object sender, EventArgs e)
  {
    var billMgr = new BillManager(UI);
    if ((billMgr.ReportParams.ReportView == MetraTech.DomainModel.Billing.ReportViewType.Interactive)
      && (billMgr.ReportParams.DateRange is DateRangeSlice))
    {

      StartDate = ((DateRangeSlice)billMgr.ReportParams.DateRange).Begin;
      EndDate = ((DateRangeSlice)billMgr.ReportParams.DateRange).End;
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

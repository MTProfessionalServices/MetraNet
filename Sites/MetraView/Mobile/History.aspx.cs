using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;

public partial class MobileHistory : MTPage
{
  public string ChartData
  {
    get { return ViewState["ChartData"] as string; }
    set { ViewState["ChartData"] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if(!IsPostBack)
    {
      var billManger = new BillManager(UI);
      var intervals = billManger.GetBillingHistory();
      GetChartData(intervals);
    }
  }

  private void GetChartData(List<Interval> intervals)
  {
    var sb = new StringBuilder();

    IOrderedEnumerable<Interval> sortedIntervals;

    if (SiteConfig.Settings.BillSetting.ShowOnlyHardClosedIntervals.GetValueOrDefault(false))
    {
      sortedIntervals = from i in intervals
                        where i.Status == IntervalStatusCode.HardClosed
                        orderby i.EndDate ascending
                        select i;
    }
    else
    {
      sortedIntervals = from i in intervals
                        orderby i.EndDate ascending
                        select i;
    }

    foreach (var interval in sortedIntervals)
    {
      sb.Append("{\"group\": \"");
      sb.Append(Server.HtmlEncode(interval.StartDate.ToShortDateString()));
      sb.Append(" - ");
      sb.Append(Server.HtmlEncode(interval.EndDate.ToShortDateString()));
      sb.Append("\", \"total\":");
      sb.Append(interval.UsageAmount);
      sb.Append(", \"totalAsString\": \"");
      sb.Append(interval.UsageAmountAsString); 
      sb.Append("\", \"intervalId\":\"");
      sb.Append(interval.ID);
      sb.Append("\"},");
    }
    ChartData = sb.ToString().Trim(new[] {','});
  }
}

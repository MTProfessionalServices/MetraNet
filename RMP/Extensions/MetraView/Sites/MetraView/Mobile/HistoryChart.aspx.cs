using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;

public partial class Mobile_HistoryChart : MTPage
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

    //['2008-06-30', 4], ['2008-7-30', 6.5], ['2008-8-30', 5.7], ['2008-9-30', 9], ['2008-10-30', 8.2]
  private void GetChartData(List<Interval> intervals)
  {
      var sb = new StringBuilder();

      IOrderedEnumerable<Interval> sortedIntervals;

      if (SiteConfig.Settings.BillSetting.ShowOnlyHardClosedIntervals.GetValueOrDefault(false))
      {
        sortedIntervals = from i in intervals
                          where i.Status == IntervalStatusCode.HardClosed
                          orderby i.StartDate ascending
                          select i;
      }
      else
      {
        sortedIntervals = from i in intervals
                          orderby i.StartDate ascending
                          select i;
      }

      foreach (var interval in sortedIntervals)
      {
          sb.Append("['");
          sb.Append(Server.HtmlEncode(interval.EndDate.ToString("yyyy-MM-dd")));
          sb.Append("', ");
          sb.Append(interval.UsageAmount);
          sb.Append("],");
      }
      ChartData = sb.ToString().Trim(new[] { ',' });
  }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;

public partial class History : MTPage
{
  public string ChartData { get; set; }
  public string XTicks { get; set; }

  // Only show 20 intervals maximum, otherwise, the graph x axis labels start to become unreadable
  private const int MAX_INTERVALS_FOR_CHART = 20;
  private decimal _minY;

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      var billManger = new BillManager(UI);
      var intervals = billManger.GetBillingHistory();
      _minY = 0;
      GetChartData(intervals);
    }
  }

  protected decimal GetYMin()
  {
      return _minY;
  }

  private void GetChartData(List<Interval> intervals)
  {
    var sbChartData = new StringBuilder();
    var sbXTicks = new StringBuilder();

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

    int total = sortedIntervals.Count();
    int current = 0;
    foreach (var interval in sortedIntervals)
    {
      current = current + 1;
      if (total - current < MAX_INTERVALS_FOR_CHART)
      {
        sbChartData.Append("['");
        sbChartData.Append(Server.HtmlEncode(interval.EndDate.ToShortDateString()));
        sbChartData.Append("', ");
        sbChartData.Append(interval.UsageAmount);
        sbChartData.Append(", ");
        sbChartData.Append(interval.ID);
        sbChartData.Append(", '");
        sbChartData.Append(interval.InvoiceNumber);
        sbChartData.Append("'],");
        sbXTicks.Append("['");
        sbXTicks.Append(interval.EndDate.ToShortDateString());
        sbXTicks.Append("','");
        sbXTicks.Append(interval.StartDate.ToShortDateString());
        sbXTicks.Append(" - ");
        sbXTicks.Append(interval.EndDate.ToShortDateString());
        sbXTicks.Append("'],");

        if (interval.UsageAmount.HasValue == true && interval.UsageAmount.Value < _minY)
        {
            _minY = interval.UsageAmount.Value;
        }

      }
    }

    ChartData = sbChartData.ToString();
    if (!String.IsNullOrEmpty(ChartData))
      ChartData = ChartData.Trim(new[] { ',' });

    XTicks = sbXTicks.ToString();
    if (!String.IsNullOrEmpty(XTicks))
      XTicks = XTicks.Trim(new[] { ',' });
  }

}

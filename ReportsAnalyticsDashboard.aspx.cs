using System;
using MetraTech.UI.Common;

public partial class ReportsAnalyticsDashboard : MTPage
{
  protected long previousMonth, firstMonth;
  protected long startMonthMRR, endMonthMRR;

  public ReportsAnalyticsDashboard()
  {
    var previousMonthAndHalf = DateTime.Now.ToUniversalTime().AddMonths(-1).AddDays(1-DateTime.Today.Day + 15);
    var firstMonthAndHalf = DateTime.Now.ToUniversalTime().AddMonths(-13).AddDays(1 - DateTime.Today.Day - 15);

    var endMonthAndHalfForMRR = DateTime.Now.ToUniversalTime().AddMonths(12).AddDays(1 - DateTime.Today.Day + 15);
    var startMonthAndHalfForMRR = DateTime.Now.ToUniversalTime().AddMonths(-13).AddDays(1 - DateTime.Today.Day - 15);

    previousMonth = GetJSDate(previousMonthAndHalf);
    firstMonth = GetJSDate(firstMonthAndHalf);

    startMonthMRR = GetJSDate(startMonthAndHalfForMRR);
    endMonthMRR = GetJSDate(endMonthAndHalfForMRR);
  }

  private long GetJSDate(DateTime date)
  {
    return (date.Ticks - new DateTime(1970, 1, 1).Ticks) / 10000;
  }
}

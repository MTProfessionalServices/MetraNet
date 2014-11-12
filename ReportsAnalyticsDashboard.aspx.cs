using System;
using System.Globalization;
using MetraTech.UI.Common;

public partial class ReportsAnalyticsDashboard : MTPage
{
  protected long previousMonth, firstMonth;
  protected long startMonthMRR, endMonthMRR;

  public ReportsAnalyticsDashboard()
  {
    var previousMonthAndHalf = DateTime.Now.ToUniversalTime().AddMonths(-1).AddDays(1 - DateTime.Today.Day + 15);
    var firstMonthAndHalf = DateTime.Now.ToUniversalTime().AddMonths(-13).AddDays(1 - DateTime.Today.Day - 15);

    var endMonthAndHalfForMRR = DateTime.Now.ToUniversalTime().AddMonths(12).AddDays(1 - DateTime.Today.Day + 15);
    var startMonthAndHalfForMRR = DateTime.Now.ToUniversalTime().AddMonths(-13).AddDays(1 - DateTime.Today.Day - 15);

    previousMonth = GetJSDate(previousMonthAndHalf);
    firstMonth = GetJSDate(firstMonthAndHalf);

    startMonthMRR = GetJSDate(startMonthAndHalfForMRR);
    endMonthMRR = GetJSDate(endMonthAndHalfForMRR);
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!Page.IsPostBack)
    {
      spnSelectCurrency.InnerText = Convert.ToString(GetLocalResourceObject("SELECT_CURRENCY"));
    }
  }

  private long GetJSDate(DateTime date)
  {
    return (date.Ticks - new DateTime(1970, 1, 1).Ticks) / 10000;
  }
}

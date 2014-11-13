using System;
using System.Globalization;
using MetraTech.UI.Common;

public partial class ReportsAnalyticsDashboard : MTPage
{
  protected long previousMonth, firstMonth;
  protected long startMonthMRR, endMonthMRR;

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("View Summary Financial Information"))
    {
      SetError(Resources.ErrorMessages.ERROR_ACCESS_DENIED_INSUFFICIENT_CAPABILITY);
      Response.Write(Resources.ErrorMessages.ERROR_ACCESS_DENIED_INSUFFICIENT_CAPABILITY);
      Response.End();
    }

    if (!Page.IsPostBack)
    {
      spnSelectCurrency.InnerText = Convert.ToString(GetLocalResourceObject("SELECT_CURRENCY"));
    }
  }

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

  private long GetJSDate(DateTime date)
  {
    return (date.Ticks - new DateTime(1970, 1, 1).Ticks) / 10000;
  }
}

using System;
using System.Globalization;
using MetraTech.UI.Common;

public partial class ReportsAnalyticsDashboard : MTPage
{
  protected long previousMonth, firstMonth;
  protected string DateStampForGraph;

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
      spnSelectCurrency.InnerText = string.Format("{0}:", GetLocalResourceObject("SELECT_CURRENCY"));
    }
  }

  public ReportsAnalyticsDashboard()
  {
    //the same date range is set in VisualizeService.aspx.cs; any change made here should be done there too
    var previousMonthAndHalf = DateTime.Now.ToUniversalTime().AddMonths(-1).AddDays(1 - DateTime.Today.Day + 15);
    var firstMonthAndHalf = DateTime.Now.ToUniversalTime().AddMonths(-25).AddDays(1 - DateTime.Today.Day - 15);

    previousMonth = GetJSDate(previousMonthAndHalf);
    firstMonth = GetJSDate(firstMonthAndHalf);

    DateStampForGraph = string.Format("{0} {1} - {2} {3}", firstMonthAndHalf.AddMonths(1).ToString("MMMM"), firstMonthAndHalf.Year, previousMonthAndHalf.ToString("MMMM"), previousMonthAndHalf.Year);
  }

  private long GetJSDate(DateTime date)
  {
    return (date.Ticks - new DateTime(1970, 1, 1).Ticks) / 10000;
  }
}

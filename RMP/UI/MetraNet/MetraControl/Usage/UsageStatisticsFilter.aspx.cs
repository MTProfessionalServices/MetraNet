using System;
using System.Web;
using MetraTech.UI.Common;

namespace MetraNet.MetraControl.Usage
{
  public partial class UsageStatisticsFilter : MTPage
  {
    protected void Page_Load(object sender, EventArgs e)
    {
      if (IsPostBack) return;
      if (!UI.CoarseCheckCapability("Manage Usage Processing")) Response.End();

      SetLocalization();
    }

    protected void ButtonSearchClick(object sender, EventArgs e)
    {
      var startDate = DateTime.Parse(MTDatePickerFrom.Text, System.Threading.Thread.CurrentThread.CurrentCulture);
      var endDate = DateTime.Parse(MTDatePickerTo.Text, System.Threading.Thread.CurrentThread.CurrentCulture);

      var startDateProgramFormat = startDate.ToString("MM/dd/yyyy");
      var endDateProgramFormat = endDate.ToString("MM/dd/yyyy");

      var title = String.Format("Statistics from {0} to {1}", MTDatePickerFrom.Text, MTDatePickerTo.Text);
      var queryParams = String.Format("Title={0}&StartTime={1}&EndTime={2}", title, startDateProgramFormat, endDateProgramFormat);
      var momUrl = String.Format("/mom/default/dialog/Usage.Statistics.Frame.asp?{0}", queryParams);

      Response.Redirect(String.Format("/MetraNet/TicketToMOM.aspx?URL={0}", HttpContext.Current.Server.UrlEncode(momUrl)));
    }

    private void SetLocalization()
    {
      MTButtonSearch.Text = GetResourceString("TEXT_SEARCH", "JSConsts");
      MTDatePickerFrom.Label = GetResourceString("TEXT_START_DATE", "JSConsts");
      MTDatePickerTo.Label = GetResourceString("TEXT_END_DATE", "JSConsts");
    }

    private string GetResourceString(string resourceKey, string className = null)
    {
      var res = className == null
                  ? GetLocalResourceObject(resourceKey)
                  : GetGlobalResourceObject(className, resourceKey);
      if (res == null)
        throw new NullReferenceException(
          String.Format("Resource Key '{0}' not found in Resources Class '{1}'", resourceKey, className));

      return res.ToString();
    }
  }
}
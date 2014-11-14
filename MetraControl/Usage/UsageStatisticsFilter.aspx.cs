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
      var title = String.Format("Statistics from {0} to {1}", MTDatePickerFrom.Text, MTDatePickerTo.Text);
      //[TODO]: Convert localized dates to format, that Usage.Statistics.Frame.asp page expects
      var queryParams = String.Format("Title={0}&StartTime={1}&EndTime={2}",
                                      HttpContext.Current.Server.UrlEncode(title),
                                      HttpContext.Current.Server.UrlEncode(MTDatePickerFrom.Text),
                                      HttpContext.Current.Server.UrlEncode(MTDatePickerTo.Text));
      Response.Redirect(
        String.Format("/MetraNet/TicketToMOM.aspx?URL=/mom/default/dialog/Usage.Statistics.Frame.asp?{0}", queryParams));
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
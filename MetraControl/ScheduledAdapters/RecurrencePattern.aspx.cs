using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UsageServer;

public partial class RecurrencePattern : MTPage
{
  public string strMinutelyURL, strDailyURL, strWeeklyURL, strMonthlyURL, strManualURL;
  public BaseRecurrencePattern recurPattern;

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage Scheduled Adapters"))
    {
      Response.End();
      return;
    }

    string adapterName = "";
    string eventID = "";
    ScheduleAdapterServiceClient schedAdapterClient = new ScheduleAdapterServiceClient();
    if (!IsPostBack)
    {
      try
      {
        if (Request.QueryString["AdapterName"] != null)
        {
          adapterName = Request.QueryString["AdapterName"].ToString();
          ViewState["AdapterName"] = adapterName;
        }

        if(Request.QueryString["AdapterName"] != null)
        {
           ViewState["EventID"] = Request.QueryString["EventID"].ToString();
           eventID = ViewState["EventID"].ToString();
        }

        string queryString = Server.UrlEncode(adapterName) + "&EventID=" + Server.UrlEncode(eventID);
        strMinutelyURL = "ScheduleMinutely.aspx?AdapterName=" + queryString;
        strDailyURL = "ScheduleDaily.aspx?AdapterName=" + queryString;
        strMonthlyURL = "ScheduleMonthly.aspx?AdapterName=" + queryString;
        strWeeklyURL = "ScheduleWeekly.aspx?AdapterName=" + queryString;
        strManualURL = "ScheduleManual.aspx?AdapterName=" + queryString;

        schedAdapterClient.ClientCredentials.UserName.UserName = UI.User.UserName;
        schedAdapterClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;

        schedAdapterClient.GetRecurrencePattern(Convert.ToInt32(ViewState["EventID"]), out recurPattern);
        schedAdapterClient.Close();

        if (recurPattern is MinutelyRecurrencePattern)
        { 
           radMinutely.Checked = true;
          schedulePatternPage.Attributes["src"] = strMinutelyURL;
          schedulePatternPage.Attributes["src"] = strMinutelyURL;
        }
        else if (recurPattern is DailyRecurrencePattern)
        {
          radDaily.Checked = true;
        }
        else if (recurPattern is WeeklyRecurrencePattern)
        {
          radWeekly.Checked = true;
        }
        else if (recurPattern is MonthlyRecurrencePattern)
        {
          radMonthly.Checked = true;
        }
        else if (recurPattern is ManualRecurrencePattern)
        {
          radManual.Checked = true;
        }
      }
      catch (Exception ex)
      {
        SetError(ex.Message);
        this.Logger.LogError(ex.Message);
        schedAdapterClient.Abort();       
       }
    }
  }
}
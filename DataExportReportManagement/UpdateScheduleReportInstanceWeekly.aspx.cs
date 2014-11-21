using System;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;


public partial class DataExportReportManagement_UpdateScheduleReportInstanceWeekly : MTPage
{
  public ExportReportSchedule updateexportscheduleweekly
  {
    get { return ViewState["updateexportscheduleweekly"] as ExportReportSchedule; }
    //The ViewState labels are immaterial here..
    set { ViewState["updateexportscheduleweekly"] = value; }
  }

  public string strincomingIDSchedule { get; set; } //so we can read it any time in the session 
  public int intincomingIDSchedule { get; set; }

  public string strincomingIDReportInstance { get; set; } //so we can read it any time in the session 
  public int intincomingIDReportInstance { get; set; }
  public string strincomingAction { get; set; }

  public string strincomingReportId { get; set; }
  public int intincomingReportId { get; set; }


  protected void Page_Load(object sender, EventArgs e)
  {

    strincomingIDSchedule = Request.QueryString["idreportinstanceschedule"];
    intincomingIDSchedule = System.Convert.ToInt32(strincomingIDSchedule);

    strincomingIDReportInstance = Request.QueryString["idreportinstance"];
    intincomingIDReportInstance = System.Convert.ToInt32(strincomingIDReportInstance);
    strincomingAction = Request.QueryString["action"];

    strincomingReportId = Request.QueryString["reportid"];
    intincomingReportId = System.Convert.ToInt32(strincomingReportId);

    if (strincomingAction == "Update")
    {
      var title = GetLocalResourceObject("TEXT_Weekly_Daily_Report_Schedule");
      if (title != null)
        MTTitle1.Text = title.ToString();
    }
    else
    {
      var title = GetLocalResourceObject("TEXT_Weekly_Daily_Report_Schedule");
      if (title != null)
      {
        MTTitle1.Text = title.ToString();
        btnOK.Text = title.ToString();
      }
    }

    if (!IsPostBack)
    {
      updateexportscheduleweekly = new ExportReportSchedule();

      MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
      MTGenericForm1.RenderObjectType = updateexportscheduleweekly.GetType();
        //This should be same as the public property defined above 
      MTGenericForm1.RenderObjectInstanceName = "updateexportscheduleweekly";
        //This should be same as the public property defined above
      MTGenericForm1.TemplateName = "DataExportFramework.ScheduleReportInstanceWeekly";
        //This should be the <Name> tag from the page layout config file, not the file name itself
      MTGenericForm1.ReadOnly = false;

      //Gather the Existing Report Instance Schedule (Weekly) Details

      try
      {
        GetExistingReportInstanceScheduleWeekly();
      }

      catch (Exception ex)
      {
        SetError(ex.Message);
        this.Logger.LogError(ex.Message);
        //client.Abort();
      }


      if (!MTDataBinder1.DataBind())
      {
        Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
      }
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    if (!this.MTDataBinder1.Unbind())
    {
      this.Logger.LogError(this.MTDataBinder1.BindingErrors.ToHtml());
    }

    DataExportReportManagementServiceClient client = null;

    try
    {
      client = new DataExportReportManagementServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      string strskipweekdays = null;
      int intmonthtodate = 0;
      string strexecuteweekdays = "SUN,MON,TUE,WED,THU,FRI,SAT";

      if (updateexportscheduleweekly.bSkipSunday)
      {
        strskipweekdays = "SUN,";
        strexecuteweekdays = strexecuteweekdays.Replace("SUN,", "");
      }

      if (updateexportscheduleweekly.bSkipMonday)
      {
        strskipweekdays = strskipweekdays + "MON,";
        strexecuteweekdays = strexecuteweekdays.Replace("MON,", "");
      }

      if (updateexportscheduleweekly.bSkipTuesday)
      {
        strskipweekdays = strskipweekdays + "TUE,";
        strexecuteweekdays = strexecuteweekdays.Replace("TUE,", "");
      }

      if (updateexportscheduleweekly.bSkipWednesday)
      {
        strskipweekdays = strskipweekdays + "WED,";
        strexecuteweekdays = strexecuteweekdays.Replace("WED,", "");
      }

      if (updateexportscheduleweekly.bSkipThursday)
      {
        strskipweekdays = strskipweekdays + "THU,";
        strexecuteweekdays = strexecuteweekdays.Replace("THU,", "");
      }

      if (updateexportscheduleweekly.bSkipFriday)
      {
        strskipweekdays = strskipweekdays + "FRI,";
        strexecuteweekdays = strexecuteweekdays.Replace("FRI,", "");
      }

      if (updateexportscheduleweekly.bSkipSaturday)
      {
        strskipweekdays = strskipweekdays + "SAT";
        strexecuteweekdays = strexecuteweekdays.Replace("SAT", "");
      }

      intmonthtodate = updateexportscheduleweekly.bMonthToDate ? 0 : 1;

      if (strincomingAction == "Update")
      {
        client.UpdateReportInstanceScheduleWeekly(intincomingIDReportInstance, updateexportscheduleweekly.IDSchedule,
                                                  updateexportscheduleweekly.ExecuteTime, strexecuteweekdays,
                                                  strskipweekdays, intmonthtodate);

      }
      else
      {
        client.DeleteReportInstanceSchedule(intincomingIDSchedule);
      }

      client.Close();

      Response.Redirect(
        "ManageReportInstanceSchedules.aspx?idreportinstance=" + strincomingIDReportInstance + "&idreport=" +
        strincomingReportId, false);
    }

    catch (Exception ex)
    {
      SetError(ex.Message);
      this.Logger.LogError(ex.Message);
      client.Abort();
    }

  }

  protected void GetExistingReportInstanceScheduleWeekly()
  {
    DataExportReportManagementServiceClient client = null;

    try
    {
      client = new DataExportReportManagementServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      ExportReportSchedule exportReportSchedule;
      client.GetAScheduleInfoWeekly(intincomingIDSchedule, out exportReportSchedule);
      updateexportscheduleweekly = (ExportReportSchedule) exportReportSchedule;

      client.Close();

    }

    catch (Exception ex)
    {
      this.Logger.LogError(ex.Message);
      client.Abort();
      throw;
    }
  }


  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect(
      "ManageReportInstanceSchedules.aspx?idreportinstance=" + strincomingIDReportInstance + "&idreport=" +
      strincomingReportId, false);
  }
}
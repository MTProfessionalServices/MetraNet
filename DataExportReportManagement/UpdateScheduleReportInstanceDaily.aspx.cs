using System;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;


public partial class DataExportReportManagement_UpdateScheduleReportInstanceDaily : MTPage
{
  public ExportReportSchedule updateexportscheduledaily
  {
    get { return ViewState["updateexportscheduledaily"] as ExportReportSchedule; } //The ViewState labels are immaterial here..
    set { ViewState["updateexportscheduledaily"] = value; }
  }

  public string strincomingIDSchedule { get; set; }
  public int intincomingIDSchedule { get; set; }

  public string strincomingIDReportInstance { get; set; }
  public int intincomingIDReportInstance { get; set; }

  public string strincomingAction { get; set; }

  public string strincomingReportId { get; set; }
  public int intincomingReportId { get; set; }


  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage DataExportFramework"))
    {
      Response.End();
      return;
    }
    strincomingIDSchedule = Request.QueryString["idreportinstanceschedule"];
    intincomingIDSchedule = Convert.ToInt32(strincomingIDSchedule);

    strincomingIDReportInstance = Request.QueryString["idreportinstance"];
    intincomingIDReportInstance = Convert.ToInt32(strincomingIDReportInstance);
    strincomingAction = Request.QueryString["action"];

    strincomingReportId = Request.QueryString["reportid"];
    intincomingReportId = Convert.ToInt32(strincomingReportId);


    if (strincomingAction == "Update")
    {
      var title = GetLocalResourceObject("TEXT_Update_Daily_Report_Schedule");
      if (title != null)
        MTTitle1.Text = title.ToString();      
    }
    else
    {
      var title = GetLocalResourceObject("TEXT_Delete_Daily_Report_Schedule");
      if (title != null)
      {
        MTTitle1.Text = title.ToString();
        btnOK.Text = title.ToString();
      }
    }

    if (!IsPostBack)
    {
      updateexportscheduledaily = new ExportReportSchedule();

      MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
      MTGenericForm1.RenderObjectType = updateexportscheduledaily.GetType(); //This should be same as the public property defined above 
      MTGenericForm1.RenderObjectInstanceName = "updateexportscheduledaily";//This should be same as the public property defined above
      MTGenericForm1.TemplateName = "DataExportFramework.ScheduleReportInstanceDaily"; //This should be the <Name> tag from the page layout config file, not the file name itself
      MTGenericForm1.ReadOnly = false;

      //Gather the Existing Report Instance Schedule (Daily) Details

      try
      {
        GetExistingReportInstanceScheduleDaily();
      }

      catch (Exception ex)
      {
        SetError(ex.Message);
        Logger.LogError(ex.Message);
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
    if (!MTDataBinder1.Unbind())
    {
      Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
    }

    DataExportReportManagementServiceClient client = null;

    try
    {
      client = new DataExportReportManagementServiceClient();

      if (client.ClientCredentials != null)
      {
        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      //Following local variables are used for converting page data field data type to the database field data type 

      int intskipfirstdayofmonth = !updateexportscheduledaily.bSkipFirstDayMonth ? 0 : 1;
      
      int intskiplastdayofmonth = !updateexportscheduledaily.bSkipLastDayMonth ? 0 : 1;

      int intmonthtodate = !updateexportscheduledaily.bMonthToDate ? 0 : 1;


      if (strincomingAction == "Update")
      {
        client.UpdateReportInstanceScheduleDaily(intincomingIDReportInstance, updateexportscheduledaily.IDSchedule, updateexportscheduledaily.ExecuteTime, updateexportscheduledaily.RepeatHour,
          updateexportscheduledaily.ExecuteStartTime, updateexportscheduledaily.ExecuteEndTime, intskiplastdayofmonth, intskipfirstdayofmonth, updateexportscheduledaily.DaysInterval,
          intmonthtodate);

      }
      else
      {
        client.DeleteReportInstanceSchedule(intincomingIDSchedule);
      }

      client.Close();

      Response.Redirect("ManageReportInstanceSchedules.aspx?idreportinstance=" + strincomingIDReportInstance + "&idreport=" + strincomingReportId, false);

    }

    catch (Exception ex)
    {
      SetError(ex.Message);
      Logger.LogError(ex.Message);
      if (client != null) client.Abort();
    }

  }

  protected void GetExistingReportInstanceScheduleDaily()
  {
    DataExportReportManagementServiceClient client = null;

    try
    {
      client = new DataExportReportManagementServiceClient();

      if (client.ClientCredentials != null)
      {
        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      ExportReportSchedule exportReportSchedule;
      client.GetAScheduleInfoDaily(intincomingIDSchedule, out exportReportSchedule);
      updateexportscheduledaily = exportReportSchedule;

      client.Close();

    }

    catch (Exception ex)
    {
      Logger.LogError(ex.Message);
      if (client != null) client.Abort();
      throw;
    }
  }


  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect("ManageReportInstanceSchedules.aspx?idreportinstance=" + strincomingIDReportInstance + "&idreport=" + strincomingReportId, false);
  }
}
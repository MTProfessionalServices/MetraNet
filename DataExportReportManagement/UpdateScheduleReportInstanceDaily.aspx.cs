using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;
using MetraTech;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.Auth.Capabilities;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DataAccess;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Billing;
using MetraTech.Interop.MTAuth;
using MetraTech.UI.Common;
using System.ServiceModel;
using MetraTech.Debug.Diagnostics;



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
    intincomingIDSchedule = System.Convert.ToInt32(strincomingIDSchedule);

    strincomingIDReportInstance = Request.QueryString["idreportinstance"];
    intincomingIDReportInstance = System.Convert.ToInt32(strincomingIDReportInstance);
    strincomingAction = Request.QueryString["action"];

    strincomingReportId = Request.QueryString["reportid"];
    intincomingReportId = System.Convert.ToInt32(strincomingReportId);


    if (strincomingAction == "Update")
    {
      MTTitle1.Text = "Update Daily Report Schedule";
    }
    else
    {
      MTTitle1.Text = "Delete Daily Report Schedule";
      btnOK.Text = "Delete Instance Schedule";
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

        //Following local variables are used for converting page data field data type to the database field data type 
       int intskipfirstdayofmonth=0;
      int intskiplastdayofmonth = 0;
      int intmonthtodate = 0;
      int intdaysinterval = 0;
      int intrepeathour = 0;

      if (!updateexportscheduledaily.bSkipFirstDayMonth)
      //if (updateexportscheduledaily.SkipFirstDayMonth == SkipFirstDayOfMonthEnum.No)
      {
        intskipfirstdayofmonth = 0;
      }
      else
      {
        intskipfirstdayofmonth = 1;
      }


      if (!updateexportscheduledaily.bSkipLastDayMonth)
      //if (updateexportscheduledaily.SkipLastDayMonth == SkipLastDayOfMonthEnum.No)
      {
        intskiplastdayofmonth = 0;
      }
      else
      {
        intskiplastdayofmonth = 1;
      }


      if (!updateexportscheduledaily.bMonthToDate)
      //if (updateexportscheduledaily.MonthToDate == MonthToDateEnum.No)
      {
        intmonthtodate = 0;
      }
      else
      {
        intmonthtodate = 1;
      }

      intrepeathour = Convert.ToInt32(updateexportscheduledaily.RepeatHour);
      intdaysinterval = Convert.ToInt32(updateexportscheduledaily.DaysInterval);


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
        this.Logger.LogError(ex.Message);
        client.Abort();
      }

    }

    protected void GetExistingReportInstanceScheduleDaily()
    {
      DataExportReportManagementServiceClient client = null;

      try
      {
        client = new DataExportReportManagementServiceClient();

        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

        ExportReportSchedule exportReportSchedule;
        client.GetAScheduleInfoDaily(intincomingIDSchedule, out exportReportSchedule);
        updateexportscheduledaily = (ExportReportSchedule)exportReportSchedule;
                
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
      Response.Redirect("ManageReportInstanceSchedules.aspx?idreportinstance=" + strincomingIDReportInstance + "&idreport=" + strincomingReportId, false);
    }
    }
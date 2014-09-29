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



public partial class DataExportReportManagement_AddReportInstanceScheduleMaster : MTPage
{
  public ExportReportSchedule selectscheduletype
  {
    get { return ViewState["selectscheduletype"] as ExportReportSchedule; } //The ViewState labels are immaterial here..
    set { ViewState["selectscheduletype"] = value; }
  }

  public string strincomingIDReportInstance { get; set; } //so we can read it any time in the session 
  public int intincomingIDReportInstance { get; set; }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage DataExportFramework"))
    {
      Response.End();
      return;
    }
    strincomingIDReportInstance = Request.QueryString["idreportinstance"];
    intincomingIDReportInstance = System.Convert.ToInt32(strincomingIDReportInstance);
    Session["intSessionIDReportInstance"] = intincomingIDReportInstance;

    Logger.LogDebug("The report instance id is {0} ..", strincomingIDReportInstance);

    if (!IsPostBack)
    {
      selectscheduletype = new ExportReportSchedule();

      MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
      MTGenericForm1.RenderObjectType = selectscheduletype.GetType(); //This should be same as the public property defined above 
      MTGenericForm1.RenderObjectInstanceName = "selectscheduletype";//This should be same as the public property defined above
      MTGenericForm1.TemplateName = "DataExportFramework.AddReportInstanceScheduleMaster"; //This should be the <Name> tag from the page layout config file, not the file name itself
      MTGenericForm1.ReadOnly = false;

     //Load the blank page for creating a new report instance schedule 

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

      //Read the Schedule Type selection done by user

      try
      {
      //string strSelectedScheduleType = "";

      string strcreateschedulurldaily = "";
      string strcreateschedulurlweekly = "";
      string strcreateschedulurlmonthly = "";
      
        strcreateschedulurldaily = "CreateScheduleReportInstanceDaily.aspx?idreportinstance=" + strincomingIDReportInstance;   
        strcreateschedulurlweekly = "CreateScheduleReportInstanceWeekly.aspx?idreportinstance=" + strincomingIDReportInstance;   
        strcreateschedulurlmonthly = "CreateScheduleReportInstanceMonthly.aspx?idreportinstance=" + strincomingIDReportInstance;   

      if (selectscheduletype.ScheduleType == ScheduleTypeEnum.Daily)
      {
        Response.Redirect(strcreateschedulurldaily, false);     
        //  ("/MetraNet/DataExportReportManagement/CreateScheduleReportInstanceDaily.aspx?idreportinstance='+ strincomingIDReportInstance");
      }
      else
      {
        if (selectscheduletype.ScheduleType == ScheduleTypeEnum.Weekly)
        {
          Response.Redirect(strcreateschedulurlweekly, false);
          //Response.Redirect("/MetraNet/DataExportReportManagement/CreateScheduleReportInstanceWeekly.aspx?idreportinstance='+ strincomingIDReportInstance");
        }
        else
        {
          Response.Redirect(strcreateschedulurlmonthly, false);
          //Response.Redirect("/MetraNet/DataExportReportManagement/CreateScheduleReportInstanceMonthly.aspx?idreportinstance='+ strincomingIDReportInstance");
        }
      }

      
      }

      catch (Exception ex)
      {
        SetError(ex.Message);
        this.Logger.LogError(ex.Message);
      
      }

    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
      Response.Redirect("ManageReportInstanceSchedules.aspx?idreportinstance=" + strincomingIDReportInstance, false);

    }
    
}
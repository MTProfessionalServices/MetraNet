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



public partial class DataExportReportManagement_CreateScheduleReportInstanceWeekly : MTPage
{
  public ExportReportSchedule createexportscheduleweekly
  {
    get { return ViewState["createexportscheduleweekly"] as ExportReportSchedule; } //The ViewState labels are immaterial here..
    set { ViewState["createexportscheduleweekly"] = value; }
  }

  public string strincomingIDReportInstance { get; set; } 
  public int intincomingIDReportInstance { get; set; }

  public string strincomingReportId { get; set; }
  public int intincomingReportId { get; set; }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage DataExportFramework"))
    {
      Response.End();
      return;
    }
    strincomingIDReportInstance = Request.QueryString["idreportinstance"];
    intincomingIDReportInstance = System.Convert.ToInt32(strincomingIDReportInstance);
    //Session["intSessionIDReportInstance"] = intincomingIDReportInstance;

    strincomingReportId = Request.QueryString["reportid"];
    intincomingReportId = System.Convert.ToInt32(strincomingReportId);

    
    if (!IsPostBack)
    {
      createexportscheduleweekly = new ExportReportSchedule();

      MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
      MTGenericForm1.RenderObjectType = createexportscheduleweekly.GetType(); //This should be same as the public property defined above 
      MTGenericForm1.RenderObjectInstanceName = "createexportscheduleweekly";//This should be same as the public property defined above
      MTGenericForm1.TemplateName = "DataExportFramework.ScheduleReportInstanceWeekly"; //This should be the <Name> tag from the page layout config file, not the file name itself
      MTGenericForm1.ReadOnly = false;

     //Load the blank page for creating a new report instance

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
        string strscheduletype = "Weekly";

        //Following values are irrevalent for Monthyl schedule but required by the create schedule function 
        int intrepeathour = 0;
        int intdaysinterval = 0;
        int idreportschedule = 0;//This is O/P parameter
        string strexecutestarttime = "01:00";
        string strexecuteendtime = "10:00";
        int intskipfirstdayofmonth = 0;
        int intskiplastdayofmonth = 0;
        int intExecuteDay = 1;
        int intExecuteFirstDayOfMonth = 0;
        int intExecuteLastDayOfMonth = 0;
        string strskipthesemonths = "JAN";



        if (createexportscheduleweekly.bSkipSunday)
        //if (createexportscheduleweekly.SkipSunday == SkipThisDayEnum.Yes)
        {
          strskipweekdays = "SUN";
          strexecuteweekdays = strexecuteweekdays.Replace("SUN,", "");
        }

        if (createexportscheduleweekly.bSkipMonday)
        //if (createexportscheduleweekly.SkipMonday == SkipThisDayEnum.Yes)

        {
          strskipweekdays = strskipweekdays + "," + "MON";
          strexecuteweekdays = strexecuteweekdays.Replace("MON,", "");
        }

        if (createexportscheduleweekly.bSkipTuesday)
        //if (createexportscheduleweekly.SkipTuesday == SkipThisDayEnum.Yes)
        {
          strskipweekdays = strskipweekdays + "," + "TUE";
          strexecuteweekdays = strexecuteweekdays.Replace("TUE,", "");
        }

        if (createexportscheduleweekly.bSkipWednesday)
        //if (createexportscheduleweekly.SkipWednesday == SkipThisDayEnum.Yes)
        {
          strskipweekdays = strskipweekdays + "," + "WED";
          strexecuteweekdays = strexecuteweekdays.Replace("WED,", "");
        }

        if (createexportscheduleweekly.bSkipThursday)
        //if (createexportscheduleweekly.SkipThursday == SkipThisDayEnum.Yes)
        {
          strskipweekdays = strskipweekdays + "," + "THU";
          strexecuteweekdays = strexecuteweekdays.Replace("THU,", "");
        }

        if (createexportscheduleweekly.bSkipFriday)
        //if (createexportscheduleweekly.SkipFriday == SkipThisDayEnum.Yes)
        {
          strskipweekdays = strskipweekdays + "," + "FRI";
          strexecuteweekdays = strexecuteweekdays.Replace("FRI,", "");
        }

        if (createexportscheduleweekly.bSkipSaturday)
        //if (createexportscheduleweekly.SkipSaturday == SkipThisDayEnum.Yes)
        {
          strskipweekdays = strskipweekdays + "," + "SAT";
          strexecuteweekdays = strexecuteweekdays.Replace("SAT", "");
        }

        if (createexportscheduleweekly.bMonthToDate)
        //if (createexportscheduleweekly.MonthToDate == MonthToDateEnum.No)
        {
          intmonthtodate = 0;
        }
        else
        {
          intmonthtodate = 1;
        }      
      
      
        //Call Create New Daily Report Schedule

        client.ScheduleReportInstance(intincomingIDReportInstance, strscheduletype, createexportscheduleweekly.ExecuteTime, intrepeathour, strexecutestarttime,
          strexecuteendtime, intskipfirstdayofmonth, intskiplastdayofmonth, intdaysinterval, strexecuteweekdays, strskipweekdays, intExecuteDay,
          intExecuteFirstDayOfMonth, intExecuteLastDayOfMonth, strskipthesemonths, intmonthtodate, idreportschedule);

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

    protected void btnCancel_Click(object sender, EventArgs e)
    {
      Response.Redirect("ManageReportInstanceSchedules.aspx?idreportinstance=" + strincomingIDReportInstance + "&idreport=" + strincomingReportId, false);
    }
    
}
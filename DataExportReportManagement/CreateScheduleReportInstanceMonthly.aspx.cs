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



public partial class DataExportReportManagement_CreateScheduleReportInstanceMonthly : MTPage
{
  public ExportReportSchedule createexportschedulemonthly
  {
    get { return ViewState["createexportschedulemonthly"] as ExportReportSchedule; } 
    set { ViewState["createexportschedulemonthly"] = value; }
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
      createexportschedulemonthly = new ExportReportSchedule();

      MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
      MTGenericForm1.RenderObjectType = createexportschedulemonthly.GetType(); //This should be same as the public property defined above 
      MTGenericForm1.RenderObjectInstanceName = "createexportschedulemonthly";//This should be same as the public property defined above
      MTGenericForm1.TemplateName = "DataExportFramework.ScheduleReportInstanceMonthly"; //This should be the <Name> tag from the page layout config file, not the file name itself
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

      //Following local vriables are used for converting page field data types to database data types
      int intexecuteday;
      string strskipthesemonths = null;
      string strScheduleType = "Monthly";


      //Following values are irrevalent for Monthyl schedule but required by the create schedule function 
      int intdaysinterval = 0;
      string executeweekdays = "MON";//Hard coding because these values are not required for Daily Schedule
      string skipweekdays = "MON";//Hard coding because these values are not required for Daily Schedule
      int idreportschedule = 0;//This is O/P parameter
      string strexecutestarttime = "01:00";
      string strexecuteendtime = "10:00";
      int intskipfirstdayofmonth = 0;
      int intskiplastdayofmonth = 0;
      int intmonthtodate = 0;
      
      /* skip months mapping
       01-JAN
       02-FEB
       03-MAR
       04-APR
       05-MAY 
       06-JUN
       07-JUL
       08-AUG
       09-SEP
       10-OCT
       11-NOV
       12-DEC
       */ 
      
      int intexecutefirstdayofmonth = !createexportschedulemonthly.bExecuteFirstDayMonth ? 0 : 1;

      int intexecutelastdayofmonth = !createexportschedulemonthly.bExecuteLastDayMonth ? 0 : 1;

      if (createexportschedulemonthly.bExecuteLastDayMonth || createexportschedulemonthly.bExecuteFirstDayMonth)
      {
        intexecuteday = 0;
      }
      else
      {
        intexecuteday = Convert.ToInt32(createexportschedulemonthly.ExecuteDay);
      }

      if (createexportschedulemonthly.bSkipJanuary)
      {
        strskipthesemonths = "01,";
      }

      if (createexportschedulemonthly.bSkipFebruary)
      {
        strskipthesemonths += "02,";
      }

      if (createexportschedulemonthly.bSkipMarch)
      {
        strskipthesemonths += "03,";
      }

      if (createexportschedulemonthly.bSkipApril)
      {
        strskipthesemonths += "04,";
      }


      if (createexportschedulemonthly.bSkipMay)
      {
        strskipthesemonths += "05,";
      }

      if (createexportschedulemonthly.bSkipJune)
      {
        strskipthesemonths += "06,";
      }

      if (createexportschedulemonthly.bSkipJuly)
      {
        strskipthesemonths += "07,";
      }

      if (createexportschedulemonthly.bSkipAugust)
      {
        strskipthesemonths += "08,";
      }

      if (createexportschedulemonthly.bSkipSeptember)
      {
        strskipthesemonths += "09,";
      }

      if (createexportschedulemonthly.bSkipOctober)
      {
        strskipthesemonths += "10,";
      }


      if (createexportschedulemonthly.bSkipNovember)
      {
        strskipthesemonths += "11,";
      }

      if (createexportschedulemonthly.bSkipDecember)
      {
        strskipthesemonths += "12";
      }


      //Call Create New Monthly Report Schedule

      client.ScheduleReportInstance(intincomingIDReportInstance, strScheduleType, createexportschedulemonthly.ExecuteTime, createexportschedulemonthly.RepeatHour, strexecutestarttime,
          strexecuteendtime, intskipfirstdayofmonth, intskiplastdayofmonth, intdaysinterval, executeweekdays, skipweekdays, intexecuteday,
          intexecutefirstdayofmonth, intexecutelastdayofmonth, strskipthesemonths, intmonthtodate, idreportschedule);

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
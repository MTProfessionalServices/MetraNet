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

public partial class DataExportReportManagement_CreateScheduleReportInstanceDaily : MTPage
{
  public ExportReportSchedule createexportscheduledaily
  {
    get { return ViewState["createexportscheduledaily"] as ExportReportSchedule; } 
    set { ViewState["createexportscheduledaily"] = value; }
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
    
    strincomingReportId = Request.QueryString["reportid"];
    intincomingReportId = System.Convert.ToInt32(strincomingReportId);

    
    if (!IsPostBack)
    {
      // creates Daily schedule
      createexportscheduledaily = new ExportReportSchedule {DaysInterval = 1};

      MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
      MTGenericForm1.RenderObjectType = createexportscheduledaily.GetType(); //This should be same as the public property defined above 
      MTGenericForm1.RenderObjectInstanceName = "createexportscheduledaily";//This should be same as the public property defined above
      MTGenericForm1.TemplateName = "DataExportFramework.ScheduleReportInstanceDaily"; //This should be the <Name> tag from the page layout config file, not the file name itself
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

        //Following local variables are used for converting page data field data type to the database field data type 
        int intskipfirstdayofmonth = 0;
        int intskiplastdayofmonth = 0;
        int intmonthtodate = 0;
        int intdaysinterval = 0;
        int intrepeathour = 0;

        if (!createexportscheduledaily.bSkipFirstDayMonth)
        //if (createexportscheduledaily.SkipFirstDayMonth == SkipFirstDayOfMonthEnum.No)
        {
          intskipfirstdayofmonth = 0;
        }
        else
        {
          intskipfirstdayofmonth = 1;
        }


        if (!createexportscheduledaily.bSkipLastDayMonth)
        //if (createexportscheduledaily.SkipLastDayMonth == SkipLastDayOfMonthEnum.No)
        {
          intskiplastdayofmonth = 0;
        }
        else
        {
          intskiplastdayofmonth = 1;
        }


        if (!createexportscheduledaily.bMonthToDate)
        //if (createexportscheduledaily.MonthToDate == MonthToDateEnum.No)
        {
          intmonthtodate = 0;
        }
        else
        {
          intmonthtodate = 1;
        }

        intrepeathour = Convert.ToInt32(createexportscheduledaily.RepeatHour);
        intdaysinterval = Convert.ToInt32(createexportscheduledaily.DaysInterval);
      
      string executeweekdays="MON";//Hard coding because these values are not required for Daily Schedule
      string skipweekdays="MON";//Hard coding because these values are not required for Daily Schedule
      string scheduletype="Daily";//Hard coding because these values are not required for Daily Schedule
      int executefirstdayofmonth=0;//Hard coding because these values are not required for Daily Schedule
      int executelastdayofmonth=0;//Hard coding because these values are not required for Daily Schedule
      string skipthesemonths= "JAN"; //Hard coding because these values are not required for Daily Schedule
      int idreportschedule=0;//This is O/P parameter
      
      
        //Call Create New Daily Report Schedule

      client.ScheduleReportInstance(intincomingIDReportInstance, scheduletype, createexportscheduledaily.ExecuteTime, createexportscheduledaily.RepeatHour, createexportscheduledaily.ExecuteStartTime,
          createexportscheduledaily.ExecuteEndTime, intskipfirstdayofmonth, intskiplastdayofmonth, createexportscheduledaily.DaysInterval, executeweekdays, skipweekdays, createexportscheduledaily.ExecuteDay,
          executefirstdayofmonth, executelastdayofmonth, skipthesemonths, intmonthtodate, idreportschedule);

      client.Close();

      Response.Redirect("ManageReportInstanceSchedules.aspx?idreportinstance=" + strincomingIDReportInstance + "&idreport=" + strincomingReportId, false);
      }

      catch (Exception ex)
      {
        string errorMsgToFind = "Execute Time should be equal to or greater than Execute Start Time";
        bool isFound = false;
        if (ex is System.ServiceModel.FaultException<MetraTech.ActivityServices.Common.MASBasicFaultDetail>)
        {
          var masFault = ex as System.ServiceModel.FaultException<MetraTech.ActivityServices.Common.MASBasicFaultDetail>;

          foreach (var message in masFault.Detail.ErrorMessages)
          {
            if (message.Contains((errorMsgToFind)))
            {
              SetError(errorMsgToFind);
              isFound = true;
              break;
            }
          }
        }
        if (!isFound)
        {
          SetError(ex.Message);
        }
        this.Logger.LogError(ex.Message);
        client.Abort();
      }

    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
      Response.Redirect("ManageReportInstanceSchedules.aspx?idreportinstance=" + strincomingIDReportInstance + "&idreport=" + strincomingReportId, false);
    }
    }
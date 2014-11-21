using System;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;


public partial class DataExportReportManagement_UpdateScheduleReportInstanceMonthly : MTPage
{
  public ExportReportSchedule updateexportschedulemonthly
  {
    get { return ViewState["updateexportschedulemonthly"] as ExportReportSchedule; } //The ViewState labels are immaterial here..
    set { ViewState["updateexportschedulemonthly"] = value; }
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
    if (!UI.CoarseCheckCapability("Manage DataExportFramework"))
    {
      Response.End();
      return;
    }
    strincomingIDSchedule = Request.QueryString["idreportinstanceschedule"];
    intincomingIDSchedule = System.Convert.ToInt32(strincomingIDSchedule);

    strincomingIDReportInstance = Request.QueryString["idreportinstance"];
    intincomingIDReportInstance = Convert.ToInt32(strincomingIDReportInstance);
    strincomingAction = Request.QueryString["action"];

    strincomingReportId = Request.QueryString["reportid"];
    intincomingReportId = Convert.ToInt32(strincomingReportId);

    if (strincomingAction == "Update")
    {
      var title = GetLocalResourceObject("TEXT_Monthly_Daily_Report_Schedule");
      if (title != null)
        MTTitle1.Text = title.ToString();
    }
    else
    {
      var title = GetLocalResourceObject("TEXT_Monthly_Daily_Report_Schedule");
      if (title != null)
      {
        MTTitle1.Text = title.ToString();
        btnOK.Text = title.ToString();
      }
    }

    if (!IsPostBack)
    {
      updateexportschedulemonthly = new ExportReportSchedule();

      MTGenericForm1.DataBinderInstanceName = "MTDataBinder1";
      MTGenericForm1.RenderObjectType = updateexportschedulemonthly.GetType(); //This should be same as the public property defined above 
      MTGenericForm1.RenderObjectInstanceName = "updateexportschedulemonthly";//This should be same as the public property defined above
      MTGenericForm1.TemplateName = "DataExportFramework.ScheduleReportInstanceMonthly"; //This should be the <Name> tag from the page layout config file, not the file name itself
      MTGenericForm1.ReadOnly = false;

      //Gather the Existing Report Instance Schedule (Monthly) Details

      try
      {
        GetExistingReportInstanceScheduleMonthly();
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

      
        //Following local vriables are used for converting page field data types to database data types
        int intexecuteday;

        string strskipthesemonths = null;

        int intexecutefirstdayofmonth = !updateexportschedulemonthly.bExecuteFirstDayMonth ? 0 : 1;

        int intexecutelastdayofmonth = !updateexportschedulemonthly.bExecuteLastDayMonth ? 0 : 1;

        if (updateexportschedulemonthly.bExecuteLastDayMonth || updateexportschedulemonthly.bExecuteFirstDayMonth)
        {
          intexecuteday = 0;
        }
        else
        {
          intexecuteday = Convert.ToInt32(updateexportschedulemonthly.ExecuteDay);
        }

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

        if (updateexportschedulemonthly.bSkipJanuary)
        {
          strskipthesemonths = "01,";
        }

        if (updateexportschedulemonthly.bSkipFebruary)
        {
          strskipthesemonths += "02,";
        }

        if (updateexportschedulemonthly.bSkipMarch)
        {
          strskipthesemonths += "03,";
        }

        if (updateexportschedulemonthly.bSkipApril)
        {
          strskipthesemonths += "04,";
        }


        if (updateexportschedulemonthly.bSkipMay)
        {
          strskipthesemonths += "05,";
        }

        if (updateexportschedulemonthly.bSkipJune)
        {
          strskipthesemonths += "06,";
        }

        if (updateexportschedulemonthly.bSkipJuly)
        {
          strskipthesemonths += "07,";
        }

        if (updateexportschedulemonthly.bSkipAugust)
        {
          strskipthesemonths += "08,";
        }

        if (updateexportschedulemonthly.bSkipSeptember)
        {
          strskipthesemonths += "09,";
        }

        if (updateexportschedulemonthly.bSkipOctober)
        {
          strskipthesemonths += "10,";
        }

        if (updateexportschedulemonthly.bSkipNovember)
        {
          strskipthesemonths += "11,";
        }

        if (updateexportschedulemonthly.bSkipDecember)
        {
          strskipthesemonths += "12";
        }

        if (strincomingAction == "Update")
        {
          client.UpdateReportInstanceScheduleMonthly(intincomingIDReportInstance, updateexportschedulemonthly.IDSchedule, intexecuteday, updateexportschedulemonthly.ExecuteTime,
            intexecutefirstdayofmonth, intexecutelastdayofmonth, strskipthesemonths);
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

      protected void GetExistingReportInstanceScheduleMonthly()
    {
      DataExportReportManagementServiceClient client = null;

      try
      {
        client = new DataExportReportManagementServiceClient();

        client.ClientCredentials.UserName.UserName = UI.User.UserName;
        client.ClientCredentials.UserName.Password = UI.User.SessionPassword;


        ExportReportSchedule exportReportSchedule;
        client.GetAScheduleInfoMonthly(intincomingIDSchedule, out exportReportSchedule);
        updateexportschedulemonthly = (ExportReportSchedule)exportReportSchedule;

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
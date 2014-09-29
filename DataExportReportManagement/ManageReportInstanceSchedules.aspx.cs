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
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel;
using MetraTech.UI.Controls;
using System.Globalization;
using System.Reflection;
using System.Resources;
using MetraTech.Interop.IMTAccountType;
using MetraTech.Accounts.Type;
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.DomainModel.Billing;
using MetraTech.Core.Services.ClientProxies;



public partial class DataExportReportManagement_ManageReportInstanceSchedules : MTPage
{
  public string strincomingIDReportInstance { get; set; } //so we can read it any time in the session 
  public int intincomingIDReportInstance { get; set; }

  public string strincomingIDReport { get; set; } //so we can read it any time in the session 
  public int intincomingIDReport { get; set; }
  public int instancescheduleid { get; set; }

  protected override void OnLoadComplete(EventArgs e)
  {
    CheckIfScheduleExistsForThisInstance();
     //code to add grid button dynamically
    if (instancescheduleid == 0)
    {
      //Add Daily Schedule Button 
      MTGridButton btnD = new MTGridButton();
      btnD.ButtonID = "AddDailySchedule";
      btnD.ButtonText = "Daily Schedule";
      btnD.IconClass = "add";
      btnD.JSHandlerFunction = "adddailyschedule1";
      btnD.ToolTip = "Creates Daily Schedule";
      MyGrid1.ToolbarButtons.Add(btnD);

      //Add Weekly Schedule Button 
      MTGridButton btnW = new MTGridButton();
      btnW.ButtonID = "AddWeeklySchedule";
      btnW.ButtonText = "Weekly Schedule";
      btnW.IconClass = "add";
      btnW.JSHandlerFunction = "addweeklyschedule1";
      btnW.ToolTip = "Creates Weekly Schedule";
      MyGrid1.ToolbarButtons.Add(btnW);

      //Add Monthly Schedule Button 
      MTGridButton btnM = new MTGridButton();
      btnM.ButtonID = "AddMonthlySchedule";
      btnM.ButtonText = "Monthly Schedule";
      btnM.IconClass = "add";
      btnM.JSHandlerFunction = "addmonthlyschedule1";
      btnM.ToolTip = "Creates Monthly Schedule";
      MyGrid1.ToolbarButtons.Add(btnM);

    }
    base.OnLoadComplete(e);
  }

  protected override void OnLoad(EventArgs e)
  {
    base.OnLoad(e);
  }
  
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

    strincomingIDReport = Request.QueryString["idreport"];
    intincomingIDReport = System.Convert.ToInt32(strincomingIDReport);
  }

  protected void CheckIfScheduleExistsForThisInstance()
  {
    DataExportReportManagementServiceClient client = null;

    try
    {
      client = new DataExportReportManagementServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      
      
      ExportReportSchedule  exportreportschedule;

      client.CheckIfScheduleExists(intincomingIDReportInstance, out exportreportschedule);
      instancescheduleid = exportreportschedule.IDSchedule;
      client.Close();

    }

    catch (Exception ex)
    {
      this.Logger.LogError(ex.Message);
      client.Abort();
      throw;
    }
  }

}
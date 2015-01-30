using System;
using MetraTech.UI.Common;
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
    
    base.OnLoadComplete(e);
  }
  
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage DataExportFramework"))
    {
      Response.End();
      return;
    }
    strincomingIDReportInstance = Request.QueryString["idreportinstance"];
    intincomingIDReportInstance = Convert.ToInt32(strincomingIDReportInstance);
    Session["intSessionIDReportInstance"] = intincomingIDReportInstance;

    strincomingIDReport = Request.QueryString["idreport"];
    intincomingIDReport = Convert.ToInt32(strincomingIDReport);
  }

  protected void CheckIfScheduleExistsForThisInstance()
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


      ExportReportSchedule  exportreportschedule;

      client.CheckIfScheduleExists(intincomingIDReportInstance, out exportreportschedule);
      instancescheduleid = exportreportschedule.IDSchedule;
      client.Close();

    }

    catch (Exception ex)
    {
      Logger.LogError(ex.Message);
      if (client != null) client.Abort();
      throw;
    }
  }

}
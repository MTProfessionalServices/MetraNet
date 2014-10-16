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



public partial class DataExportReportManagement_DeleteInstanceSchedule : MTPage
{
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

    DataExportReportManagementServiceClient client = null;

    try
    {
      client = new DataExportReportManagementServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

        client.DeleteReportInstanceSchedule(intincomingIDSchedule);

      client.Close();

      //Response.Redirect("ManageReportInstanceSchedules.aspx?idreportinstance=" + strincomingIDReportInstance + "&idreport=" + strincomingReportId, false);

    }

    catch (Exception ex)
    {
      SetError(ex.Message);
      this.Logger.LogError(ex.Message);
      client.Abort();
    }
  }

    protected void btnBack_Click(object sender, EventArgs e)
    {
      Response.Redirect("ManageReportInstanceSchedules.aspx?idreportinstance=" + strincomingIDReportInstance + "&idreport=" + strincomingReportId, false);
    }
}
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
using MetraTech.Security.Crypto;



public partial class DataExportReportManagement_DeleteExistingReportInstance : MTPage
{
  public string strincomingReportInstanceId { get; set; } //so we can read it any time in the session 
  public int intincomingReportInstanceID { get; set; }

  public string strincomingReportId { get; set; } //so we can read it any time in the session 
  public int intincomingReportID { get; set; }
  public string strincomingAction { get; set; } //so we can read it any time in the session 

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage DataExportFramework"))
    {
      Response.End();
      return;
    }
    strincomingReportInstanceId = Request.QueryString["idreportinstance"];
    intincomingReportInstanceID = System.Convert.ToInt32(strincomingReportInstanceId);

    strincomingReportId = Request.QueryString["idreport"];
    intincomingReportID = System.Convert.ToInt32(strincomingReportId);
    strincomingAction = Request.QueryString["action"];

    DataExportReportManagementServiceClient client = null;

    try
    {
      client = new DataExportReportManagementServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      client.DeleteExistingReportInstance(intincomingReportInstanceID);

      client.Close();
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
      //Response.Redirect("ShowReportInstanceDetails.aspx?idreportinstance="+strincomingReportInstanceId, false);
      Response.Redirect("ManageReportInstances.aspx?reportid="+strincomingReportId, false);
    }

}
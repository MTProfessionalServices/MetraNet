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



public partial class DataExportReportManagement_DeleteAssignedReportParameter : MTPage
{
  public string strincomingReportId { get; set; } 
  public int intincomingReportID { get; set; }
  
  public string strincomingIDParameter { get; set; } 
  public int intincomingIDParameter { get; set; } 

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage DataExportFramework"))
    {
      Response.End();
      return;
    }
    strincomingReportId = Request.QueryString["reportid"];
    intincomingReportID = System.Convert.ToInt32(strincomingReportId);

    strincomingIDParameter = Request.QueryString["idparameter"];
    intincomingIDParameter = System.Convert.ToInt32(strincomingIDParameter);

    //Delete Report Parameter on Page Load only

    DataExportReportManagementServiceClient client = null;

    try
    {
      client = new DataExportReportManagementServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      client.DeleteOneReportParameter(intincomingReportID, intincomingIDParameter);

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
    Response.Redirect("ShowAssignedReportParameters.aspx?reportid=" + strincomingReportId, false);
  }




}
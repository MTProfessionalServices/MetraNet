using System;
using MetraTech.UI.Common;
using MetraTech.DomainModel.BaseTypes;

public partial class DataExportReportManagement_ReportInstanceCreated : MTPage
{
  public string strincomingReportId { get; set; } //so we can read it any time in the session 
  
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage DataExportFramework"))
    {
      Response.End();
      return;
    }
    strincomingReportId = Request.QueryString["reportid"];
  }

  protected void btnBack_Click(object sender, EventArgs e)
  {
    Response.Redirect("ManageReportInstances.aspx?reportid=" + strincomingReportId, false);
    
  }


}

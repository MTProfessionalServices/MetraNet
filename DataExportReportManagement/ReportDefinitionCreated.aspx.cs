using System;
using MetraTech.UI.Common;
using MetraTech.DomainModel.BaseTypes;

public partial class DataExportReportManagement_ReportDefinitionCreated : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage DataExportFramework"))
    {
      Response.End();
      return;
    }

  }

  protected void btnBack_Click(object sender, EventArgs e)
  {
    Response.Redirect("ShowAllReportDefinitions.aspx", false);
  }


}

using System;
using System.Web.UI.WebControls;

using MetraTech.UI.Common;

public partial class MetraControl_FailedTransactions_ChangeStatus : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    // Verify the user has permission to view this page
    if (!UI.CoarseCheckCapability("Update Failed Transactions"))
    {
      Response.End();
    }
    BindEnums();
  }
 
  private void BindEnums()
  {
    ddDismissedReasonCode.Items.Add(new ListItem("--", ""));
    var enumDismissed = typeof(MetraTech.DomainModel.Enums.SystemConfig.Metratech_com_failedtransaction.DismissedReasonCode);
    foreach (var dismissed in Enum.GetValues(enumDismissed))
    {
      var description = GetLocalizedEnumItemText(enumDismissed, dismissed.ToString());
      ddDismissedReasonCode.Items.Add(new ListItem(description, dismissed.ToString()));
    }

    ddInvestigationReasonCode.Items.Add(new ListItem("--", ""));
    var enumInvestigation = typeof(MetraTech.DomainModel.Enums.SystemConfig.Metratech_com_failedtransaction.InvestigationReasonCode);
    foreach (var investigation in Enum.GetValues(enumInvestigation))
    {
      var description = GetLocalizedEnumItemText(enumInvestigation, investigation.ToString());
      ddInvestigationReasonCode.Items.Add(new ListItem(description, investigation.ToString()));
    }
  }
}
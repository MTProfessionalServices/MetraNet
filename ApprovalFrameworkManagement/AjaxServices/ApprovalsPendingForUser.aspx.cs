using System;
using System.Web.Script.Serialization;
using System.Collections.Generic;
using MetraTech.Approvals;
using MetraTech.UI.Common;

public partial class AjaxServices_ApprovalsPendingForUser : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Allow ApprovalsView"))
    {
      Response.Write("[]");
      Response.End();
    }
    var approvalFramework = new ApprovalManagementImplementation {SessionContext = UI.SessionContext};

    List<ChangeNotificationSummary> pendingChangeNotifications;
    approvalFramework.GetPendingChangeNotificationsForUser(840, out pendingChangeNotifications);

    var jss = new JavaScriptSerializer();
    Response.Write(jss.Serialize(pendingChangeNotifications));
    Response.End();
  }
}

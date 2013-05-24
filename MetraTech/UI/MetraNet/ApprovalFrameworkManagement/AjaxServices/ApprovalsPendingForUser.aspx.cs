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

using MetraTech.UI.Common;
using System.Web.Script.Serialization;
using MetraTech.Approvals;
using System.Collections.Generic;
using System.Diagnostics;

public partial class AjaxServices_ApprovalsPendingForUser : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    //Debugger.Launch();
    if (!UI.CoarseCheckCapability("Allow ApprovalsView"))
    {
      Response.Write("[]"); //Write empty Ajax/Json list; makes javascript happier
      Response.End();
    }

    ApprovalManagementImplementation approvalFramework = new ApprovalManagementImplementation();
    approvalFramework.SessionContext = UI.SessionContext;

    List<ChangeNotificationSummary> pendingChangeNotifications = new List<ChangeNotificationSummary>();

    approvalFramework.GetPendingChangeNotificationsForUser(840, out pendingChangeNotifications);

    JavaScriptSerializer jss = new JavaScriptSerializer();
    Response.Write(jss.Serialize(pendingChangeNotifications));
    Response.End();
  }
}

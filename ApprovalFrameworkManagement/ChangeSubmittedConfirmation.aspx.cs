using System;
using MetraTech.UI.Common;

public partial class ApprovalFrameworkManagement_ChangeSubmittedConfirmation : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      Session.Remove("SubscriptionInstance");
      Session.Remove("UDRCs");
      Session.Remove("UDRCDictionary");
      Session.Remove("udrc_State");
      Session.Remove("udrc_InterfaceName");
      Session.Remove("udrc_ProcessorId");
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    String redirectLoc = (String)Session["RedirectLoc"];
    if (String.IsNullOrEmpty(redirectLoc))
    {
      Response.Redirect("/MetraNet/ApprovalFrameworkManagement/ShowChangesSummary.aspx?showchangestate=PENDING", false);
    }
    else
    {
      Session["RedirectLoc"] = "";
      Response.Redirect(redirectLoc, false);
    }
  }
}
